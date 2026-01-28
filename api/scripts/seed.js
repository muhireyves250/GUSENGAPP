require('dotenv').config();
const mongoose = require('mongoose');
const connectDB = require('../config/db');
const Broadcast = require('../models/Broadcast');
const AppConfig = require('../models/AppConfig');
const { broadcasts, heroBackground, logo, adminProfile } = require('../models/data');

const seedData = async () => {
    try {
        await connectDB();

        console.log('Clearing existing data...');
        await Broadcast.deleteMany({});
        await AppConfig.deleteMany({});

        console.log('Seeding Broadcasts...');
        await Broadcast.insertMany(broadcasts);

        console.log('Seeding App Configurations...');
        const configs = [
            { key: 'hero_background', value: heroBackground },
            { key: 'logo', value: logo },
            { key: 'admin_profile', value: adminProfile }
        ];

        await AppConfig.insertMany(configs);

        console.log('Data Imported Successfully!');
        process.exit();
    } catch (error) {
        console.error(`Error with data import: ${error.message}`);
        process.exit(1);
    }
};

seedData();
