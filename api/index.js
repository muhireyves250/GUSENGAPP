require('dotenv').config();
const express = require('express');
const cors = require('cors');

// Import routes
const authRoutes = require('./routes/auth.routes');
const broadcastRoutes = require('./routes/broadcast.routes');
const homeRoutes = require('./routes/home.routes');

const app = express();
const PORT = process.env.PORT || 5000;

// Middleware
app.use(cors());
app.use(express.json());
app.use('/uploads', express.static('uploads'));

// Basic routes
app.get('/', (req, res) => {
  res.json({ message: 'Gusenga App API is running' });
});

app.get('/health', (req, res) => {
  res.status(200).json({ status: 'OK', timestamp: new Date().toISOString() });
});

// API routes
app.use('/api/auth', authRoutes);
app.use('/api/broadcasts', broadcastRoutes);
app.use('/api/home', homeRoutes);
app.use('/api', homeRoutes); // For /api/search

// Start server
app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});
