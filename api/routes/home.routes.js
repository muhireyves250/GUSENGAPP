const express = require('express');
const router = express.Router();
const { authenticateToken } = require('../middleware/auth');
const { heroBackground, logo, broadcasts } = require('../models/data');

const multer = require('multer');
const path = require('path');

// Configure upload storage
const storage = multer.diskStorage({
    destination: (req, file, cb) => {
        cb(null, 'uploads/');
    },
    filename: (req, file, cb) => {
        cb(null, Date.now() + path.extname(file.originalname));
    }
});

const upload = multer({ storage: storage });

// GET /api/home/hero-background - Get hero background
router.get('/hero-background', (req, res) => {
    res.json(heroBackground);
});

// PUT /api/home/hero-background - Update hero background (Protected)
router.put('/hero-background', authenticateToken, upload.single('hero'), (req, res) => {
    if (!req.file) {
        return res.status(400).json({ message: 'Image file is required' });
    }

    const serverUrl = `${req.protocol}://${req.get('host')}`;
    heroBackground.url = `${serverUrl}/uploads/${req.file.filename}`;

    res.json({ message: 'Hero background updated', heroBackground });
});

// GET /api/home/logo - Get logo
router.get('/logo', (req, res) => {
    res.json(logo);
});

// PUT /api/home/logo - Update logo (Protected)
router.put('/logo', authenticateToken, upload.single('logo'), (req, res) => {
    if (!req.file) {
        return res.status(400).json({ message: 'Image file is required' });
    }

    const serverUrl = `${req.protocol}://${req.get('host')}`;
    logo.url = `${serverUrl}/uploads/${req.file.filename}`;

    res.json({ message: 'Logo updated', logo });
});

// GET /api/home/featured - Get featured content
router.get('/featured', (req, res) => {
    const featured = broadcasts.find(b => b.category === 'featured');
    res.json(featured || broadcasts[0]);
});

// GET /api/home/new - Get new broadcasts
router.get('/new', (req, res) => {
    const newItems = broadcasts.filter(b => b.category === 'new' || b.category === 'featured');
    res.json(newItems);
});

// GET /api/home/audio-releases - Get audio releases
router.get('/audio-releases', (req, res) => {
    const audioReleases = broadcasts.filter(b => b.type === 'audio');
    res.json(audioReleases);
});

// GET /api/search - Search broadcasts
router.get('/search', (req, res) => {
    const { q } = req.query;
    if (!q) {
        return res.status(400).json({ message: 'Search query is required' });
    }

    const results = broadcasts.filter(b =>
        b.title.toLowerCase().includes(q.toLowerCase()) ||
        (b.description && b.description.toLowerCase().includes(q.toLowerCase()))
    );
    res.json(results);
});

module.exports = router;
