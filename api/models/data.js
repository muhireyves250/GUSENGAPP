// In-memory data storage (will be replaced with database later)

const heroBackground = {
    url: 'https://images.unsplash.com/photo-1519681393784-d120267933ba' // Default
};

const logo = {
    url: '' // Default empty or a placeholder
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
        thumbnail: 'https://www.figma.com/api/mcp/asset/3e8a38c1-eaf4-4219-b2de-628cfc7d9d41',
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
        thumbnail: 'https://www.figma.com/api/mcp/asset/de3fd8bb-4f80-4d80-98f2-d32ea8f55c0d',
        youtubeUrl: 'https://www.youtube.com/watch?v=example2'
    },
    {
        id: 3,
        title: 'Ubuzima bushingiye kumana',
        description: 'Building a life on divine foundations.',
        date: '2 November 2025',
        time: '11:00',
        type: 'audio',
        category: 'new',
        thumbnail: 'https://www.figma.com/api/mcp/asset/73ac629c-21e2-4d3f-a0d8-563499aad246',
        youtubeUrl: 'https://www.youtube.com/watch?v=example3'
    }
];

module.exports = {
    heroBackground,
    logo,
    broadcasts
};
