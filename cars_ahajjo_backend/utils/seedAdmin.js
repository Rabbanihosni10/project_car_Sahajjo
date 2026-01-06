const bcrypt = require('bcryptjs');
const User = require('../models/user');

async function seedAdmin() {
  try {
    const email = 'rabbanihosni10@gmail.com';
    const passwordPlain = '123';

    let admin = await User.findOne({ email });

    const hashed = await bcrypt.hash(passwordPlain, 10);

    if (!admin) {
      admin = await User.create({
        name: 'Admin',
        email,
        phone: '0000000000',
        password: hashed,
        role: 'admin',
        isActive: true,
        isVerified: true,
      });
      console.log('Admin user created:', email);
    } else {
      let changed = false;
      if (admin.role !== 'admin') {
        admin.role = 'admin';
        changed = true;
      }
      // Ensure the admin uses the requested password
      admin.password = hashed;
      changed = true;
      if (changed) {
        await admin.save();
        console.log('Admin user ensured/updated:', email);
      }
    }
  } catch (err) {
    console.error('Admin seeding failed:', err.message);
  }
}

module.exports = { seedAdmin };
