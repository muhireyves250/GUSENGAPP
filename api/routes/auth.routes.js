const express = require('express');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const router = express.Router();

// POST /api/auth/login - Admin login
router.post('/login', async (req, res) => {
    const { username, password } = req.body;

    if (username !== process.env.ADMIN_USER) {
        return res.status(401).json({ message: 'Invalid credentials' });
    }

    const validPassword = await bcrypt.compare(password, process.env.ADMIN_PASSWORD_HASH || '');
    if (!validPassword) {
        return res.status(401).json({ message: 'Invalid credentials' });
    }

    const token = jwt.sign({ username }, process.env.JWT_SECRET, { expiresIn: '24h' });
    res.json({ token });
});

module.exports = router;
