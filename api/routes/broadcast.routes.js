const express = require('express');
const router = express.Router();
const { authenticateToken } = require('../middleware/auth');
const Broadcast = require('../models/Broadcast');

const multer = require('multer');
const path = require('path');

// Configure upload storage
const { storage } = require('../config/cloudinary');
const upload = multer({ storage: storage });

// GET /api/broadcasts - Get all broadcasts (Protected)
router.get('/', authenticateToken, async (req, res) => {
    try {
        const { type } = req.query;
        let query = {};
        if (type) {
            query.type = type;
        }
        const broadcasts = await Broadcast.find(query);
        res.json(broadcasts);
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
});

// GET /api/broadcasts/top - Get top broadcasts
router.get('/top', async (req, res) => {
    try {
        const topItems = await Broadcast.find({
            $or: [{ category: 'top' }, { category: 'featured' }]
        });
        res.json(topItems);
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
});

// POST /api/broadcasts/audio - Upload audio broadcast
router.post('/audio', authenticateToken, upload.fields([
    { name: 'audio', maxCount: 1 },
    { name: 'cover', maxCount: 1 }
]), async (req, res) => {
    const { title, description, category } = req.body;

    if (!req.files || !req.files['audio']) {
        return res.status(400).json({ message: 'Audio file is required' });
    }

    const audioFile = req.files['audio'][0];
    const coverFile = req.files['cover'] ? req.files['cover'][0] : null;

    const serverUrl = `${req.protocol}://${req.get('host')}`;

    try {
        // Generate new ID (find max ID + 1) -> In a real app, ObjectId is better, but keeping ID for compatibility with frontend if needed
        // Assuming frontend expects 'id' as number. If frontend can handle _id, we should switch.
        // For now, let's keep the numeric ID logic or just rely on _id and map it. 
        // Let's stick to the previous logic of incrementing ID for safety.
        const lastBroadcast = await Broadcast.findOne().sort({ id: -1 });
        const nextId = lastBroadcast ? lastBroadcast.id + 1 : 1;

        const now = new Date();

        const newBroadcast = new Broadcast({
            id: nextId,
            title,
            description: description || '',
            type: 'audio',
            category: category || 'new',
            // Cloudinary returns the URL in file.path or file.secure_url
            audioUrl: audioFile.path,
            coverPhoto: coverFile ? coverFile.path : '', // Also set coverPhoto
            date: new Date().toLocaleDateString('en-GB', { day: 'numeric', month: 'long', year: 'numeric' }),
            time: `${now.getHours()}:${now.getMinutes().toString().padStart(2, '0')}`
        });

        const savedBroadcast = await newBroadcast.save();
        res.status(201).json({ message: 'Audio broadcast uploaded', broadcast: savedBroadcast });
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
});

// POST /api/broadcasts/video - Add video broadcast
router.post('/video', authenticateToken, upload.fields([
    { name: 'cover', maxCount: 1 }
]), async (req, res) => {
    const { title, description, youtubeUrl, category } = req.body;

    if (!title || !youtubeUrl) {
        return res.status(400).json({ message: 'Title and YouTube URL are required' });
    }

    const coverFile = req.files && req.files['cover'] ? req.files['cover'][0] : null;
    // const serverUrl = `${req.protocol}://${req.get('host')}`;

    try {
        const lastBroadcast = await Broadcast.findOne().sort({ id: -1 });
        const nextId = lastBroadcast ? lastBroadcast.id + 1 : 1;

        const newBroadcast = new Broadcast({
            id: nextId,
            title,
            description: description || '',
            youtubeUrl,
            type: 'video',
            category: category || 'new',
            coverPhoto: coverFile ? coverFile.path : '', // Cloudinary URL
            date: new Date().toLocaleDateString('en-GB', { day: 'numeric', month: 'long', year: 'numeric' }),
            time: `${new Date().getHours()}:${new Date().getMinutes().toString().padStart(2, '0')}`
        });

        const savedBroadcast = await newBroadcast.save();
        res.status(201).json({ message: 'Video broadcast added', broadcast: savedBroadcast });
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
});

// PUT /api/broadcasts/:id - Update broadcast (Protected)
router.put('/:id', authenticateToken, async (req, res) => {
    try {
        const id = parseInt(req.params.id);
        const { title, description, category, youtubeUrl, coverPhoto } = req.body;

        const broadcast = await Broadcast.findOne({ id: id });
        if (!broadcast) {
            return res.status(404).json({ message: 'Broadcast not found' });
        }

        if (title) broadcast.title = title;
        if (description) broadcast.description = description;
        if (category) broadcast.category = category;
        if (youtubeUrl && broadcast.type === 'video') broadcast.youtubeUrl = youtubeUrl;
        if (coverPhoto) broadcast.coverPhoto = coverPhoto;

        const updatedBroadcast = await broadcast.save();
        res.json({ message: 'Broadcast updated', broadcast: updatedBroadcast });
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
});

// DELETE /api/broadcasts/:id - Delete broadcast (Protected)
router.delete('/:id', authenticateToken, async (req, res) => {
    try {
        const id = parseInt(req.params.id);
        const deletedBroadcast = await Broadcast.findOneAndDelete({ id: id });

        if (!deletedBroadcast) {
            return res.status(404).json({ message: 'Broadcast not found' });
        }

        res.json({ message: 'Broadcast deleted', broadcast: deletedBroadcast });
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
});

module.exports = router;

