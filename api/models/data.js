// In-memory data storage (will be replaced with database later)

const heroBackground = {
    url: 'https://images.unsplash.com/photo-1519681393784-d120267933ba' // Default
};

const logo = {
    url: 'https://images.unsplash.com/photo-1599305445671-ac291c95aaa9' // Placeholder Logo (Mountain/cross)
};

const adminProfile = {
    avatarUrl: ''
};

const broadcasts = [
    {
        id: 1,
        title: 'Ruhuka umutima',
        description: 'A soothing message for the soul.',
        date: '28 October 2025',
        time: '1:55',
        type: 'video',
        category: 'featured',
        coverPhoto: 'https://images.unsplash.com/photo-1507692049790-de58293a4697', // Real photo (Peaceful nature)
        youtubeUrl: 'https://www.youtube.com/watch?v=example1'
    },
    {
        id: 2,
        title: 'Imana ni nyembabazi',
        description: 'Discover the mercy of God.',
        date: '28 October 2025',
        time: '10:00',
        type: 'audio',
        category: 'new',
        coverPhoto: 'https://images.unsplash.com/photo-1490730141103-6cac27aaab94', // Real photo (Praying/Bible)
        audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3' // Placeholder audio
    },
    {
        id: 3,
        title: 'Ubuzima bushingiye kumana',
        description: 'Building a life on divine foundations.',
        date: '2 November 2025',
        time: '11:00',
        type: 'audio',
        category: 'new',
        coverPhoto: 'https://images.unsplash.com/photo-1504052434569-70ad5836ab65', // Real photo (Cross/Sunset)
        audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3' // Placeholder audio
    }
];

module.exports = {
    heroBackground,
    logo,
    adminProfile,
    broadcasts
};
