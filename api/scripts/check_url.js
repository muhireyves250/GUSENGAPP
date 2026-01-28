const mongoose = require('mongoose');
const Broadcast = require('../models/Broadcast');
require('dotenv').config();

const check = async () => {
    try {
        await mongoose.connect(process.env.MONGO_URI);
        const item = await Broadcast.findOne({ type: 'audio' });
        if (item) {
            console.log('Audio URL:', item.audioUrl);
            console.log('Cover Photo:', item.coverPhoto);
        } else {
            console.log('No audio broadcast found.');
        }
    } catch (e) {
        console.error(e);
    } finally {
        mongoose.disconnect();
    }
};
check();
