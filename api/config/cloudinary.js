const cloudinary = require('cloudinary').v2;
const { CloudinaryStorage } = require('multer-storage-cloudinary');

// Configure Cloudinary using the CLOUDINARY_URL from .env
// No explicit config needed if CLOUDINARY_URL is set, 
// but we can ensure it's loaded.

// If you want to explicitly check connection or config:
// console.log("Cloudinary Config:", cloudinary.config());

const storage = new CloudinaryStorage({
    cloudinary: cloudinary,
    params: {
        folder: 'gusenga_app', // Folder name in Cloudinary
        resource_type: 'auto', // Allow both audio and video/image
        allowed_formats: ['jpg', 'png', 'jpeg', 'mp3', 'wav', 'm4a'],
    },
});

module.exports = {
    cloudinary,
    storage,
};
