const express = require('express');
const router = express.Router();
const { broadcasts } = require('../models/data');

// GET /api/search - Search broadcasts
router.get('/', (req, res) => {
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
