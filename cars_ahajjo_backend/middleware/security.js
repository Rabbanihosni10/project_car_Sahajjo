// Security middleware implementations
const rateLimit = require('express-rate-limit');
const helmet = require('helmet');
const mongoSanitize = require('express-mongo-sanitize');
const validator = require('validator');

// Rate limiting middleware
const apiLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // 100 requests per windowMs
  message: 'Too many requests from this IP, please try again later.',
  standardHeaders: true, // Return rate limit info in the `RateLimit-*` headers
  legacyHeaders: false, // Disable the `X-RateLimit-*` headers
});

const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 5, // 5 requests per windowMs
  message: 'Too many login attempts, please try again later.',
  skipSuccessfulRequests: true,
});

const paymentLimiter = rateLimit({
  windowMs: 60 * 60 * 1000, // 1 hour
  max: 10, // 10 payment attempts per hour
  message: 'Too many payment attempts, please try again later.',
});

// Input validation middleware
const validateInput = {
  email: (email) => {
    if (!email || !validator.isEmail(email)) {
      throw new Error('Invalid email format');
    }
    return email.toLowerCase();
  },

  phone: (phone) => {
    const sanitized = validator.trim(phone.toString());
    if (!validator.isMobilePhone(sanitized, ['bn-BD', 'en-BD'])) {
      throw new Error('Invalid phone number');
    }
    return sanitized;
  },

  password: (password) => {
    if (password.length < 8) {
      throw new Error('Password must be at least 8 characters');
    }
    if (!/[A-Z]/.test(password)) {
      throw new Error('Password must contain uppercase letter');
    }
    if (!/[0-9]/.test(password)) {
      throw new Error('Password must contain number');
    }
    if (!/[!@#$%^&*]/.test(password)) {
      throw new Error('Password must contain special character');
    }
    return password;
  },

  name: (name) => {
    const sanitized = validator.trim(name.toString());
    if (sanitized.length < 2 || sanitized.length > 50) {
      throw new Error('Name must be between 2 and 50 characters');
    }
    return sanitized;
  },

  amount: (amount) => {
    const num = parseFloat(amount);
    if (isNaN(num) || num <= 0 || num > 1000000) {
      throw new Error('Invalid amount');
    }
    return num;
  },

  text: (text, minLength = 1, maxLength = 5000) => {
    const sanitized = validator.trim(text.toString());
    if (sanitized.length < minLength || sanitized.length > maxLength) {
      throw new Error(`Text must be between ${minLength} and ${maxLength} characters`);
    }
    return validator.escape(sanitized);
  },

  mongoId: (id) => {
    if (!validator.isMongoId(id)) {
      throw new Error('Invalid ID format');
    }
    return id;
  },

  url: (url) => {
    if (!validator.isURL(url)) {
      throw new Error('Invalid URL format');
    }
    return url;
  },

  date: (date) => {
    const d = new Date(date);
    if (isNaN(d.getTime())) {
      throw new Error('Invalid date format');
    }
    return d;
  },
};

// Sanitization middleware
const sanitizeMiddleware = (req, res, next) => {
  // Remove HTML tags from req.body
  if (req.body) {
    Object.keys(req.body).forEach((key) => {
      if (typeof req.body[key] === 'string') {
        req.body[key] = validator.escape(req.body[key]);
      }
    });
  }
  next();
};

// CORS security
const corsOptions = {
  origin: process.env.ALLOWED_ORIGINS?.split(',') || ['http://localhost:3000', 'http://localhost:3001'],
  credentials: true,
  optionsSuccessStatus: 200,
};

// Security headers with Helmet
const helmetConfig = helmet({
  contentSecurityPolicy: {
    directives: {
      defaultSrc: ["'self'"],
      styleSrc: ["'self'", "'unsafe-inline'"],
      scriptSrc: ["'self'"],
      imgSrc: ["'self'", 'data:', 'https:'],
    },
  },
  hsts: {
    maxAge: 31536000, // 1 year
    includeSubDomains: true,
    preload: true,
  },
});

// SQL Injection prevention (Mongoose prevents by default, but double check)
const preventSqlInjection = (req, res, next) => {
  const suspiciousPatterns = ['DROP', 'DELETE', 'INSERT', 'UPDATE', 'SELECT', '--', ';', '/*', '*/'];

  const checkString = (str) => {
    if (typeof str !== 'string') return false;
    return suspiciousPatterns.some((pattern) => str.toUpperCase().includes(pattern));
  };

  // Check query parameters
  Object.values(req.query).forEach((value) => {
    if (checkString(value)) {
      return res.status(400).json({ success: false, message: 'Invalid input detected' });
    }
  });

  // Check body parameters
  if (req.body) {
    Object.values(req.body).forEach((value) => {
      if (checkString(value)) {
        return res.status(400).json({ success: false, message: 'Invalid input detected' });
      }
    });
  }

  next();
};

module.exports = {
  apiLimiter,
  authLimiter,
  paymentLimiter,
  validateInput,
  sanitizeMiddleware,
  corsOptions,
  helmetConfig,
  preventSqlInjection,
  mongoSanitize: mongoSanitize(),
};
