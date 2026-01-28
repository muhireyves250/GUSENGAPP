require('dotenv').config();
const mongoose = require('mongoose');

// Define minimal schema matching the one in Broadcast.js to avoid issues
const broadcastSchema = new mongoose.Schema({
    id: Number,
    title: String,
    type: String,
    category: String,
    coverPhoto: String,
    youtubeUrl: String
}, { strict: false });

const Broadcast = mongoose.model('Broadcast', broadcastSchema);

async function checkData() {
    console.log('Connecting to DB...');
    try {
        await mongoose.connect(process.env.MONGO_URI);
        console.log('Connected.');

        console.log('Querying for type="video"...');
        const videos = await Broadcast.find({ type: 'video' });

        console.log(`Found ${videos.length} videos.`);
        videos.forEach(v => {
            console.log(JSON.stringify(v, null, 2));
        });

        await mongoose.disconnect();
    } catch (err) {
        console.error('Error:', err);
    }
}

checkData();
