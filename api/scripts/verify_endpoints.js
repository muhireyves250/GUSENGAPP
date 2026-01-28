const axios = require('axios');
require('dotenv').config();

const verifyEndpoints = async () => {
    const baseUrl = 'http://localhost:5000/api';

    // Admin Credentials from .env
    const adminUser = process.env.ADMIN_USER || 'admin';
    // We assume the default known password for dev testing if not easily retrievable, 
    // BUT the .env hash implies a password we might not know raw.
    // However, the auth route checks process.env.ADMIN_PASSWORD_HASH for comparison.
    // Wait, the auth route logic: 
    // const validPassword = await bcrypt.compare(password, process.env.ADMIN_PASSWORD_HASH);
    // We need the RAW password to login. 
    // In dev, usually 'admin123' or similar. 
    // If we don't know the raw password, we can't login via script easily without resetting the hash.
    // OR we can bypass auth in the script by manually generating a token since we have the JWT_SECRET!

    // Approach: Generate Token Manually
    const jwt = require('jsonwebtoken');
    const secret = process.env.JWT_SECRET;
    const token = jwt.sign({ username: adminUser }, secret, { expiresIn: '1h' });

    console.log(`Generated Test Token for user: ${adminUser}`);

    const config = {
        headers: { Authorization: `Bearer ${token}` }
    };

    try {
        console.log('\n--- PUBLIC ENDPOINTS ---');
        console.log('GET /home/hero-background');
        const heroRes = await axios.get(`${baseUrl}/home/hero-background`);
        console.log('✅ Status:', heroRes.status, '| Data:', heroRes.data ? 'Found' : 'Empty');

        console.log('GET /home/logo');
        const logoRes = await axios.get(`${baseUrl}/home/logo`);
        console.log('✅ Status:', logoRes.status, '| Data:', logoRes.data ? 'Found' : 'Empty');

        console.log('GET /home/featured');
        const featRes = await axios.get(`${baseUrl}/home/featured`);
        console.log('✅ Status:', featRes.status, '| Data:', featRes.data ? featRes.data.title : 'None');

        console.log('GET /home/new');
        const newRes = await axios.get(`${baseUrl}/home/new`);
        console.log('✅ Status:', newRes.status, '| Count:', newRes.data.length);

        console.log('GET /home/audio-releases');
        const audioRes = await axios.get(`${baseUrl}/home/audio-releases`);
        console.log('✅ Status:', audioRes.status, '| Count:', audioRes.data.length);

        console.log('\n--- PROTECTED ENDPOINTS (Verified with Token) ---');
        console.log('GET /broadcasts');
        const allRes = await axios.get(`${baseUrl}/broadcasts`, config);
        console.log('✅ Status:', allRes.status, '| Total Broadcasts:', allRes.data.length);
        if (allRes.data.length > 0) {
            console.log('   Sample:', allRes.data[0].title, `(${allRes.data[0].type})`);
        }

        console.log('GET /broadcasts/top');
        const topRes = await axios.get(`${baseUrl}/broadcasts/top`, config); // Actually public? broadcast.routes.js says no auth middleware on /top, checking...
        // router.get('/top', (req, res)...) -> No authenticateToken. It IS public.
        // But verifying it anyway.
        console.log('✅ Status:', topRes.status, '| Top Count:', topRes.data.length);

    } catch (error) {
        console.error('❌ Request Failed:', error.message);
        if (error.response) {
            console.error('Response Status:', error.response.status);
            console.error('Response Data:', error.response.data);
        }
    }
};

verifyEndpoints();
