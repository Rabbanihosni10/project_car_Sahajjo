// In-memory chat storage (can be replaced with MongoDB)
const chatHistory = new Map();

/**
 * Ask AI Assistant a question
 * POST /api/chat/ask
 */
exports.askAI = async (req, res) => {
  try {
    const { question } = req.body;
    const image = req.file; // From multer middleware
    const userId = req.user.id;

    // If image is present, question can be optional (or default to "What is this?")
    const finalQuestion = question || (image ? "What is this?" : "");

    if (!finalQuestion || finalQuestion.trim() === "") {
      return res.status(400).json({
        success: false,
        message: "Question is required",
      });
    }

    // Store user message
    if (!chatHistory.has(userId)) {
      chatHistory.set(userId, []);
    }
    const userHistory = chatHistory.get(userId);
    userHistory.push({
      role: "user",
      content: finalQuestion + (image ? " [Image Attached]" : ""),
      timestamp: new Date()
    });

    // Get AI response using Google Gemini
    const aiResponse = await getGeminiResponse(finalQuestion, userHistory, image);

    // Store AI response
    userHistory.push({ role: "assistant", content: aiResponse, timestamp: new Date() });

    // Keep only last 20 messages
    if (userHistory.length > 20) {
      chatHistory.set(userId, userHistory.slice(-20));
    }

    res.json({
      success: true,
      data: {
        answer: aiResponse,
        timestamp: new Date(),
      },
    });
  } catch (error) {
    console.error("Error in askAI:", error);
    res.status(500).json({
      success: false,
      message: "Failed to get AI response",
      error: error.message,
    });
  }
};

/**
 * Get chat history for current user
 * GET /api/chat/history
 */
exports.getChatHistory = async (req, res) => {
  try {
    const userId = req.user.id;
    const history = chatHistory.get(userId) || [];

    res.json({
      success: true,
      data: history,
    });
  } catch (error) {
    console.error("Error in getChatHistory:", error);
    res.status(500).json({
      success: false,
      message: "Failed to get chat history",
      error: error.message,
    });
  }
};

/**
 * Clear chat history for current user
 * DELETE /api/chat/history
 */
exports.clearChatHistory = async (req, res) => {
  try {
    const userId = req.user.id;
    chatHistory.delete(userId);

    res.json({
      success: true,
      message: "Chat history cleared",
    });
  } catch (error) {
    console.error("Error in clearChatHistory:", error);
    res.status(500).json({
      success: false,
      message: "Failed to clear chat history",
      error: error.message,
    });
  }
};

/**
 * Get AI response from Google Gemini (Free API)
 */
/**
 * Get AI response from Google Gemini (Free API)
 */
async function getGeminiResponse(question, history = [], image = null) {
  try {
    // Use Google Gemini Free API
    const { GoogleGenerativeAI } = require("@google/generative-ai");

    // Get API key from environment variable
    const apiKey = process.env.GEMINI_API_KEY || "AIzaSyBT8hYQVxDxVvxR2F3kQJ5nZ8nH4VYo3wA"; // Fallback key

    const genAI = new GoogleGenerativeAI(apiKey);

    // Choose model based on input type (Vision model for images)
    const modelName = image ? "gemini-1.5-flash" : "gemini-pro";
    const model = genAI.getGenerativeModel({ model: modelName });

    // Create context-aware prompt
    const systemPrompt = `You are a helpful AI assistant for a ride-sharing and car rental platform called "Car Sahajjo". 
You help users with:
- Car maintenance tips (oil changes, tire care, battery, brakes)
- Driving advice and safety tips
- Rental car guidance and booking tips
- Traffic rules and road safety in Bangladesh
- Fuel efficiency and cost-saving tips
- General car-related questions
${image ? '- VISUAL DIAGNOSIS: Analyze the attached image (car part, dashboard light, smoke, etc.) and identify potential issues.' : ''}

Always be friendly, concise, and helpful. Give practical advice.`;

    let userContent = [];

    // Add image to content if present
    if (image) {
      userContent.push({
        inlineData: {
          data: image.buffer.toString("base64"),
          mimeType: image.mimetype,
        },
      });
      userContent.push({ text: `Analyze this image and answer: ${question}` });
    } else {
      // Build conversation history for context (text-only)
      const conversationContext = history
        .slice(-6) // Last 3 exchanges
        .map((msg) => `${msg.role === "user" ? "User" : "Assistant"}: ${msg.content}`)
        .join("\n");

      userContent.push({ text: `${systemPrompt}\n\n${conversationContext}\nUser: ${question}\nAssistant:` });
    }

    // Generate response
    const result = await model.generateContent(userContent);
    const response = await result.response;
    const text = response.text();

    return text.trim();
  } catch (error) {
    console.error("Gemini API Error:", error);
    // Fallback to local responses if API fails
    return getLocalAIResponse(question);
  }
}

/**
 * Local fallback AI responses (when API fails)
 */
function getLocalAIResponse(question) {
  const lowerQuestion = question.toLowerCase();

  // Car maintenance
  if (lowerQuestion.includes("oil change") || lowerQuestion.includes("engine oil")) {
    return "🔧 Regular oil changes every 5,000-7,500 km keep your engine healthy. Use the recommended oil grade (usually 5W-30 or 10W-40) from your car's manual. Check oil level monthly and change oil filter every oil change.";
  }

  if (lowerQuestion.includes("tire") || lowerQuestion.includes("tyre") || lowerQuestion.includes("wheel")) {
    return "🚗 Check tire pressure monthly (usually 32-35 PSI) and rotate tires every 10,000 km. Replace when tread depth is below 1.6mm. Proper inflation improves fuel efficiency by 3-5%.";
  }

  if (lowerQuestion.includes("brake")) {
    return "🛑 Brake pads should be replaced when thickness is below 3mm. Warning signs: squeaking sounds, longer stopping distance, vibrating brake pedal. Check brake fluid every 6 months.";
  }

  if (lowerQuestion.includes("battery")) {
    return "🔋 Car batteries typically last 3-5 years. Keep terminals clean, check water level in non-sealed batteries every 3 months. If car doesn't start, check battery connections first.";
  }

  if (lowerQuestion.includes("ac") || lowerQuestion.includes("air conditioning")) {
    return "❄️ Service AC yearly. Clean cabin air filter every 15,000 km. If AC isn't cold enough, check refrigerant level. Running AC uses 10-15% more fuel.";
  }

  if (lowerQuestion.includes("transmission") || lowerQuestion.includes("gear")) {
    return "⚙️ Change automatic transmission fluid every 50,000 km. For manual transmission, replace clutch when slipping occurs (usually 80,000-120,000 km). Never shift without clutch fully pressed.";
  }

  // Driving tips
  if (lowerQuestion.includes("speed") || lowerQuestion.includes("highway") || lowerQuestion.includes("fast")) {
    return "🏁 Follow speed limits: 60 km/h in city, 80-100 km/h on highways. Maintain steady speed for best fuel efficiency. Avoid sudden acceleration and harsh braking.";
  }

  if (lowerQuestion.includes("fuel") || lowerQuestion.includes("gas") || lowerQuestion.includes("petrol") || lowerQuestion.includes("mileage")) {
    return "⛽ Improve fuel efficiency: 1) Maintain proper tire pressure 2) Avoid idling 3) Accelerate gradually 4) Use AC sparingly 5) Regular servicing 6) Remove excess weight. This can save 15-25% fuel!";
  }

  if (lowerQuestion.includes("safe") || lowerQuestion.includes("accident") || lowerQuestion.includes("crash")) {
    return "🛡️ Stay safe: 1) Always wear seatbelt 2) Avoid phone while driving 3) Keep 3-second distance 4) Check mirrors every 5-8 seconds 5) Drive defensively 6) Never drink and drive. Safety first!";
  }

  if (lowerQuestion.includes("rain") || lowerQuestion.includes("wet") || lowerQuestion.includes("monsoon")) {
    return "🌧️ Rainy driving tips: Reduce speed by 30%, increase following distance, turn on headlights, avoid standing water, test brakes after deep puddles, and never use cruise control.";
  }

  if (lowerQuestion.includes("traffic") || lowerQuestion.includes("jam") || lowerQuestion.includes("dhaka")) {
    return "🚦 In Dhaka traffic: Stay patient, keep safe distance, use Google Maps for traffic updates, avoid peak hours (8-10 AM, 5-8 PM), consider alternative routes. Car Sahajjo can help you navigate!";
  }

  // Rental tips
  if (lowerQuestion.includes("rent") || lowerQuestion.includes("rental") || lowerQuestion.includes("book")) {
    return "🚙 Car rental tips: 1) Photograph all damage before taking car 2) Check fuel level 3) Test brakes and lights 4) Read rental agreement carefully 5) Return on time to avoid extra charges. Book with Car Sahajjo for best rates!";
  }

  if (lowerQuestion.includes("price") || lowerQuestion.includes("cost") || lowerQuestion.includes("how much")) {
    return "💰 Car Sahajjo offers competitive rates! Check our Car Info section for daily/monthly rates. Prices vary by car model, location, and rental duration. Book longer for better discounts!";
  }

  // Platform features
  if (lowerQuestion.includes("ride") || lowerQuestion.includes("driver")) {
    return "🚖 Car Sahajjo connects you with verified drivers. Book rides easily, track in real-time, rate your experience, and pay securely. Download the app and get your first ride discount!";
  }

  if (lowerQuestion.includes("garage") || lowerQuestion.includes("service") || lowerQuestion.includes("repair")) {
    return "🔧 Find nearby garages in Car Sahajjo app! We list verified service centers with ratings, services offered, and contact info. Book appointments and get special discounts!";
  }

  // General help
  if (lowerQuestion.includes("help") || lowerQuestion.includes("how") || lowerQuestion.includes("what")) {
    return "👋 I'm here to help! Ask me about:\n• Car maintenance (oil, tires, brakes, battery)\n• Driving tips and safety\n• Fuel efficiency\n• Rental advice\n• Car Sahajjo features\n• Traffic and roads in Bangladesh\n\nWhat would you like to know?";
  }

  // Default response
  return "🤖 I'm your AI assistant for Car Sahajjo! I can help with car maintenance, driving tips, rental advice, and platform features. Could you please be more specific about what you'd like to know?";
}
