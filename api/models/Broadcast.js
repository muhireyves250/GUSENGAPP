const mongoose = require('mongoose');

const broadcastSchema = new mongoose.Schema({
    id: {
        type: Number,
        required: true,
        unique: true
    },
    title: {
        type: String,
        required: true
    },
    description: {
        type: String,
        default: ''
    },
    type: {
        type: String, // 'audio' or 'video'
        required: true,
        enum: ['audio', 'video']
    },
    category: {
        type: String, // 'featured', 'new', 'top'
        default: 'new'
    },
    date: {
        type: String,
        required: true
    },
    time: {
        type: String,
        required: true
    },
    coverPhoto: {
        type: String,
        default: ''
    },
    youtubeUrl: {
        type: String
    },
    audioUrl: {
        type: String
    }
}, {
    timestamps: true
});

module.exports = mongoose.model('Broadcast', broadcastSchema);
