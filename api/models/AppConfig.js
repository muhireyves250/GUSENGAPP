const mongoose = require('mongoose');

const appConfigSchema = new mongoose.Schema({
    key: {
        type: String,
        required: true,
        unique: true // 'hero_background', 'logo', 'admin_profile'
    },
    value: {
        type: mongoose.Schema.Types.Mixed,
        required: true
    }
}, {
    timestamps: true
});

module.exports = mongoose.model('AppConfig', appConfigSchema);
