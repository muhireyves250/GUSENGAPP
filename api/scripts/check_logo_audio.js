const mongoose = require('mongoose');
const Broadcast = require('../models/Broadcast');
const AppConfig = require('../models/AppConfig');
require('dotenv').config();

const check = async () => {
    try {
        await mongoose.connect(process.env.MONGO_URI);

        console.log('\n--- Audio Check ---');
        const audioItem = await Broadcast.findOne({ type: 'audio' });
        if (audioItem) {
            console.log('Title:', audioItem.title);
            console.log('Audio URL:', audioItem.audioUrl);
        } else {
            console.log('No audio broadcast found.');
        }

        console.log('\n--- Logo Check ---');
        const logoConfig = await AppConfig.findOne({ key: 'logo' });
        if (logoConfig) {
            console.log('Logo URL:', logoConfig.value);
        } else {
            console.log('No logo config found.');
        }

    } catch (e) {
        console.error(e);
    } finally {
        mongoose.disconnect();
    }
};
check();
