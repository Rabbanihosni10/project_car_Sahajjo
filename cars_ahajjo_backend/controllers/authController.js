const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");
const User = require("../models/user.js");
const Transaction = require("../models/transaction");

// Utility to sign JWTs consistently
const signToken = (payload) =>
    jwt.sign(payload, process.env.JWT_SECRET || 'your-secret-key', { expiresIn: "7d" });

exports.register = async (req, res) => {
    try {
        const {
            name,
            email,
            phone,
            password,
            role,
            licenseNumber,
            licenseExpiry,
            vehicleType,
            yearsOfExperience,
            companyName,
            businessRegistration,
            numberOfCars,
            businessType,
        } = req.body;

        // Validation
        if (!name || !email || !phone || !password) {
            return res
                .status(400)
                .json({ message: "Name, email, phone, and password are required" });
        }

        // Check if user already exists
        const existing = await User.findOne({ email: email.toLowerCase() });
        if (existing) {
            return res.status(409).json({ message: "Email already registered" });
        }

        // Hash password
        const hashedPassword = await bcrypt.hash(password, 10);

        // Create user object
        const userData = {
            name,
            email: email.toLowerCase(),
            phone,
            password: hashedPassword,
            role: role || "visitor",
        };

        // Add role-specific fields
        if (role === "driver") {
            userData.licenseNumber = licenseNumber;
            userData.licenseExpiry = licenseExpiry;
            userData.vehicleType = vehicleType;
            userData.yearsOfExperience = yearsOfExperience;
        } else if (role === "owner") {
            userData.companyName = companyName;
            userData.businessRegistration = businessRegistration;
            userData.numberOfCars = numberOfCars;
            userData.businessType = businessType;
        }

        // Create user
        const user = await User.create(userData);

        // Sign token
        const token = signToken({ id: user._id, role: user.role });

        return res.status(201).json({
            token,
            user: {
                id: user._id,
                name: user.name,
                email: user.email,
                phone: user.phone,
                role: user.role,
            },
        });
    } catch (error) {
        return res.status(500).json({ message: error.message });
    }
};

exports.login = async (req, res) => {
    try {
        const { email, password } = req.body;

        if (!email || !password) {
            return res
                .status(400)
                .json({ message: "Email and password are required" });
        }

        const user = await User.findOne({ email });
        if (!user) {
            return res.status(401).json({ message: "Invalid credentials" });
        }

        const isValid = await bcrypt.compare(password, user.password);
        if (!isValid) {
            return res.status(401).json({ message: "Invalid credentials" });
        }

        // Add random earnings for drivers on login (simulating ride earnings)
        if (user.role === 'driver') {
            const randomEarning = Math.floor(Math.random() * 401) + 100; // 100-500 TK
            const earning = new Transaction({
                userId: user._id,
                transactionType: 'driver_earning',
                amount: randomEarning,
                currency: 'BDT',
                description: `Ride earnings (simulated)`,
                paymentMethod: 'cash',
                status: 'completed',
            });
            await earning.save();
            console.log(`Added ${randomEarning} TK earnings for driver ${user.name}`);
        }

        const token = signToken({ id: user._id, role: user.role });

        return res.json({
            token,
            user: {
                id: user._id,
                name: user.name,
                email: user.email,
                role: user.role,
            },
        });
    } catch (error) {
        return res.status(500).json({ message: error.message });
    }
};