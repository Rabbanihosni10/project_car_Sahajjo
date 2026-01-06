const mongoose = require('mongoose');

const connectMongo = async () => {
    try {
        const uri = process.env.MONGO_URI || 'mongodb://127.0.0.1:27017/cars_ahajjo';

        await mongoose.connect(uri, {
            serverSelectionTimeoutMS: 5000,
        });
        console.log('Database Connected Successfully');
    } catch (error) {
        console.error('MongoDB connection error:', error.message);
        process.exit(1);
    }
};

module.exports = connectMongo;