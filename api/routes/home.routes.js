const express = require('express');
const router = express.Router();
const { authenticateToken } = require('../middleware/auth');
const AppConfig = require('../models/AppConfig');
const Broadcast = require('../models/Broadcast');

const multer = require('multer');
const path = require('path');

// Configure upload storage
const { storage } = require('../config/cloudinary');
const upload = multer({ storage: storage });

// Helper to get config
const getConfig = async (key) => {
    const config = await AppConfig.findOne({ key });
    return config ? config.value : null;
};

// GET /api/home/hero-background - Get hero background
router.get('/hero-background', async (req, res) => {
    try {
        const heroBackground = await getConfig('hero_background');
        res.json(heroBackground || { url: '' });
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
});

// PUT /api/home/hero-background - Update hero background (Protected)
router.put('/hero-background', authenticateToken, upload.single('hero'), async (req, res) => {
    if (!req.file) {
        return res.status(400).json({ message: 'Image file is required' });
    }

    const newUrl = req.file.path;

    try {
        const config = await AppConfig.findOneAndUpdate(
            { key: 'hero_background' },
            { value: { url: newUrl } },
            { new: true, upsert: true }
        );
        res.json({ message: 'Hero background updated', heroBackground: config.value });
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
});

// GET /api/home/logo - Get logo
router.get('/logo', async (req, res) => {
    try {
        const logo = await getConfig('logo');
        res.json(logo || { url: '' });
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
});

// PUT /api/home/logo - Update logo (Protected)
router.put('/logo', authenticateToken, upload.single('logo'), async (req, res) => {
    if (!req.file) {
        return res.status(400).json({ message: 'Image file is required' });
    }

    const newUrl = req.file.path;

    try {
        const config = await AppConfig.findOneAndUpdate(
            { key: 'logo' },
            { value: { url: newUrl } },
            { new: true, upsert: true }
        );
        res.json({ message: 'Logo updated', logo: config.value });
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
});

// GET /api/home/featured - Get featured content
router.get('/featured', async (req, res) => {
    try {
        const featured = await Broadcast.findOne({ category: 'featured' });
        if (featured) {
            res.json(featured);
        } else {
            const first = await Broadcast.findOne();
            res.json(first);
        }
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
});

// GET /api/home/new - Get new broadcasts
router.get('/new', async (req, res) => {
    try {
        const newItems = await Broadcast.find({
            $or: [{ category: 'new' }, { category: 'featured' }]
        });
        res.json(newItems);
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
});

// GET /api/home/audio-releases - Get audio releases
router.get('/audio-releases', async (req, res) => {
    try {
        const audioReleases = await Broadcast.find({ type: 'audio' });
        res.json(audioReleases);
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
});

// Search route moved to search.routes.js

module.exports = router;

