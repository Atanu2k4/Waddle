const jwt = require('jsonwebtoken');
const User = require('../models/User');

const auth = async (req, res, next) => {
  try {
    console.log(`🔐 AUTH: ${req.method} ${req.originalUrl}`);
    const token = req.header('Authorization')?.replace('Bearer ', '');
    
    if (!token) {
      console.log('❌ AUTH: No token provided');
      return res.status(401).json({ error: 'Authentication required' });
    }
    console.log('🔑 AUTH: Token present');

    const jwtSecret = process.env.JWT_SECRET;
    if (!jwtSecret) {
      console.error('❌ JWT_SECRET not configured');
      return res.status(500).json({ error: 'Server configuration error' });
    }

    const decoded = jwt.verify(token, jwtSecret);
    console.log('✅ AUTH: Token verified, userId:', decoded.userId);
    
    const user = await User.findById(decoded.userId);

    if (!user) {
      console.log('❌ AUTH: User not found in database');
      return res.status(401).json({ error: 'User not found' });
    }
    console.log('✅ AUTH: User found:', user.username);

    req.user = user;
    req.token = token;
    next();
  } catch (error) {
    console.log('❌ AUTH ERROR:', error.message);
    res.status(401).json({ error: 'Invalid authentication token' });
  }
};

module.exports = auth;
