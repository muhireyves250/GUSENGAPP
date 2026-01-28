const dotenv = require('dotenv');
dotenv.config(); // Load env vars immediately
const mongoose = require('mongoose');
const { v2: cloudinary } = require('cloudinary');
const fs = require('fs');
const Broadcast = require('../models/Broadcast');
const AppConfig = require('../models/AppConfig'); // If we want to seed these too
let { broadcasts, heroBackground, logo } = require('../models/data');

// Configure Cloudinary explicitly if needed, or rely on CLOUDINARY_URL var
cloudinary.config({
    secure: true
});
console.log('CLOUDINARY_URL loaded:', process.env.CLOUDINARY_URL ? 'YES (Starts with ' + process.env.CLOUDINARY_URL.substring(0, 15) + ')' : 'NO');

const connectDB = async () => {
    try {
        await mongoose.connect(process.env.MONGO_URI);
        console.log('MongoDB Connected');
    } catch (err) {
        console.error('MongoDB Connection Error:', err);
        process.exit(1);
    }
};

const uploadToCloudinary = async (url, folder, resourceType = 'auto') => {
    if (!url || url.includes('cloudinary.com')) return url; // Skip if empty or already cloudinary

    try {
        console.log(`Uploading ${url} to Cloudinary folder ${folder}...`);
        const result = await cloudinary.uploader.upload(url, {
            folder: folder,
            resource_type: resourceType
        });
        console.log(`✅ Uploaded: ${result.secure_url}`);
        return result.secure_url;
    } catch (error) {
        console.error(`❌ Upload Failed for ${url}`);
        const fs = require('fs');
        fs.appendFileSync('debug_errors.log', `Upload Failed for ${url}: ${JSON.stringify(error, null, 2)}\n`);
        return url; // Fallback to original if upload fails
    }
};

const seedCloudinary = async () => {
    await connectDB();

    // 1. Upload Broadcast Assets
    console.log('\nProcessing Broadcasts...');
    const updatedBroadcasts = [];

    for (const item of broadcasts) {
        let coverUrl = item.coverPhoto;
        let audioUrl = item.audioUrl;

        // Upload Cover Photo
        if (item.coverPhoto) {
            coverUrl = await uploadToCloudinary(item.coverPhoto, 'gusenga_app/covers', 'image');
        }

        // Upload Audio
        if (item.type === 'audio' && item.audioUrl) {
            // Cloudinary treats audio as 'video' resource type often, or 'auto' works
            audioUrl = await uploadToCloudinary(item.audioUrl, 'gusenga_app/audio', 'video');
        }

        // Create the broadcast entry
        const broadcastData = {
            id: item.id,
            title: item.title,
            description: item.description,
            type: item.type,
            category: item.category,
            date: item.date,
            time: item.time,
            coverPhoto: coverUrl
        };

        if (item.type === 'video') {
            broadcastData.youtubeUrl = item.youtubeUrl;
        } else {
            broadcastData.audioUrl = audioUrl;
        }

        updatedBroadcasts.push(broadcastData);
    }

    // 2. Upload App Config Assets (Optional, but good for completeness)
    console.log('\nProcessing App Config...');
    if (heroBackground.url) {
        heroBackground.url = await uploadToCloudinary(heroBackground.url, 'gusenga_app/config', 'image');
    }
    if (logo.url) {
        logo.url = await uploadToCloudinary(logo.url, 'gusenga_app/config', 'image');
    }

    // 3. Save to Database
    console.log('\nSeeding Database with Cloudinary URLs...');

    try {
        // Clear existing
        await Broadcast.deleteMany({});
        await AppConfig.deleteMany({});

        // Insert Broadcasts
        await Broadcast.insertMany(updatedBroadcasts);

        // Insert Configs
        await AppConfig.create({ key: 'hero_background', value: heroBackground.url });
        if (logo.url) await AppConfig.create({ key: 'logo', value: logo.url });

        console.log('✅ Database Seeded Successfully with Cloudinary Assets!');
    } catch (err) {
        console.error('Database Seed Error:', err);
    } finally {
        mongoose.connection.close();
        process.exit();
    }
};

seedCloudinary();
