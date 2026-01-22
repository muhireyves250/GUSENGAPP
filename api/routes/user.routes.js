const express = require('express');
const router = express.Router();
const { authenticateToken } = require('../middleware/auth');
const { adminProfile } = require('../models/data');
const multer = require('multer');
const path = require('path');

// Configure upload storage (reusing logic from home.routes.js logic effectively, 
// though typically this should be shared. For now, duplicating is safe for this scale.)
const storage = multer.diskStorage({
    destination: (req, file, cb) => {
        cb(null, 'uploads/');
    },
    filename: (req, file, cb) => {
        cb(null, 'avatar-' + Date.now() + path.extname(file.originalname));
    }
});

const upload = multer({ storage: storage });

// GET /api/user - Get admin profile
router.get('/', authenticateToken, (req, res) => {
    res.json(adminProfile);
});

// PUT /api/user/avatar - Update avatar
router.put('/avatar', authenticateToken, upload.single('avatar'), (req, res) => {
    if (!req.file) {
        return res.status(400).json({ message: 'Image file is required' });
    }

    const serverUrl = `${req.protocol}://${req.get('host')}`;
    adminProfile.avatarUrl = `${serverUrl}/uploads/${req.file.filename}`;

    res.json({ message: 'Profile picture updated', adminProfile });
});

module.exports = router;
