const express = require('express');
const router = express.Router();
const { authenticateToken } = require('../middleware/auth');
const { broadcasts } = require('../models/data');

// GET /api/broadcasts - Get all broadcasts (Protected)
router.get('/', authenticateToken, (req, res) => {
    const { type } = req.query;
    if (type) {
        return res.json(broadcasts.filter(b => b.type === type));
    }
    res.json(broadcasts);
});

// GET /api/broadcasts/top - Get top broadcasts
router.get('/top', (req, res) => {
    const topItems = broadcasts.filter(b => b.category === 'top' || b.category === 'featured');
    res.json(topItems);
});

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

// POST /api/broadcasts/audio - Upload audio broadcast
router.post('/audio', authenticateToken, upload.fields([
    { name: 'audio', maxCount: 1 },
    { name: 'cover', maxCount: 1 }
]), (req, res) => {
    const { title, description, category } = req.body;

    if (!req.files || !req.files['audio']) {
        return res.status(400).json({ message: 'Audio file is required' });
    }

    const audioFile = req.files['audio'][0];
    const coverFile = req.files['cover'] ? req.files['cover'][0] : null;

    const serverUrl = `${req.protocol}://${req.get('host')}`;

    const newBroadcast = {
        id: broadcasts.length > 0 ? Math.max(...broadcasts.map(b => b.id)) + 1 : 1,
        title,
        description: description || '',
        type: 'audio',
        category: category || 'new',
        audioUrl: `${serverUrl}/uploads/${audioFile.filename}`,
        thumbnail: coverFile ? `${serverUrl}/uploads/${coverFile.filename}` : '',
        date: new Date().toLocaleDateString('en-GB', { day: 'numeric', month: 'long', year: 'numeric' }),
        time: new Date().toLocaleTimeString('en-US', { hour: 'numeric', minute: '2-digit', hour12: false }) // Helper needed or simplified
    };

    // Simple time formatting fix
    const now = new Date();
    newBroadcast.time = `${now.getHours()}:${now.getMinutes().toString().padStart(2, '0')}`;

    broadcasts.push(newBroadcast);
    res.status(201).json({ message: 'Audio broadcast uploaded', broadcast: newBroadcast });
});

// POST /api/broadcasts/video - Add video broadcast
router.post('/video', authenticateToken, upload.fields([
    { name: 'cover', maxCount: 1 }
]), (req, res) => {
    const { title, description, youtubeUrl, category } = req.body;

    if (!title || !youtubeUrl) {
        return res.status(400).json({ message: 'Title and YouTube URL are required' });
    }

    const coverFile = req.files && req.files['cover'] ? req.files['cover'][0] : null;
    const serverUrl = `${req.protocol}://${req.get('host')}`;

    const newBroadcast = {
        id: broadcasts.length > 0 ? Math.max(...broadcasts.map(b => b.id)) + 1 : 1,
        title,
        description: description || '',
        youtubeUrl,
        type: 'video',
        category: category || 'new',
        thumbnail: coverFile ? `${serverUrl}/uploads/${coverFile.filename}` : '', // Use uploaded file if exists
        date: new Date().toLocaleDateString('en-GB', { day: 'numeric', month: 'long', year: 'numeric' }),
        time: `${new Date().getHours()}:${new Date().getMinutes().toString().padStart(2, '0')}`
    };

    broadcasts.push(newBroadcast);
    res.status(201).json({ message: 'Video broadcast added', broadcast: newBroadcast });
});

// PUT /api/broadcasts/:id - Update broadcast (Protected)
router.put('/:id', authenticateToken, (req, res) => {
    const id = parseInt(req.params.id);
    const { title, description, category, youtubeUrl, thumbnail } = req.body;

    const broadcastIndex = broadcasts.findIndex(b => b.id === id);
    if (broadcastIndex === -1) {
        return res.status(404).json({ message: 'Broadcast not found' });
    }

    const broadcast = broadcasts[broadcastIndex];

    // Update fields if provided
    if (title) broadcast.title = title;
    if (description) broadcast.description = description;
    if (category) broadcast.category = category;
    if (youtubeUrl && broadcast.type === 'video') broadcast.youtubeUrl = youtubeUrl;
    if (thumbnail && broadcast.type === 'video') broadcast.thumbnail = thumbnail;

    // Note: File updates (audio/cover) are not handled in this simple PUT for now to avoid complexity with multer

    res.json({ message: 'Broadcast updated', broadcast });
});

// DELETE /api/broadcasts/:id - Delete broadcast (Protected)
router.delete('/:id', authenticateToken, (req, res) => {
    const id = parseInt(req.params.id);
    const index = broadcasts.findIndex(b => b.id === id);

    if (index === -1) {
        return res.status(404).json({ message: 'Broadcast not found' });
    }

    const deleted = broadcasts.splice(index, 1);
    res.json({ message: 'Broadcast deleted', broadcast: deleted[0] });
});

module.exports = router;
