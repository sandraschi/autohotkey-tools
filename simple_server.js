const http = require('http');
const fs = require('fs');
const path = require('path');

const port = 8765;

const server = http.createServer((req, res) => {
    // Enable CORS
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
    res.setHeader('Access-Control-Allow-Headers', 'Content-Type');
    
    if (req.method === 'OPTIONS') {
        res.writeHead(200);
        res.end();
        return;
    }
    
    const url = req.url;
    
    if (url === '/') {
        // Serve the HTML dashboard
        const htmlPath = path.join(__dirname, 'launcher_enhanced.html');
        fs.readFile(htmlPath, 'utf8', (err, data) => {
            if (err) {
                res.writeHead(500, {'Content-Type': 'text/plain'});
                res.end('Error loading dashboard');
            } else {
                res.writeHead(200, {'Content-Type': 'text/html'});
                res.end(data);
            }
        });
    } else if (url === '/status') {
        res.writeHead(200, {'Content-Type': 'application/json'});
        res.end(JSON.stringify({status: 'running', port: port}));
    } else if (url === '/scriptlets') {
        res.writeHead(200, {'Content-Type': 'application/json'});
        res.end(JSON.stringify([]));
    } else if (url === '/exit') {
        res.writeHead(200, {'Content-Type': 'text/plain'});
        res.end('Server shutting down...');
        server.close();
        process.exit(0);
    } else {
        res.writeHead(404, {'Content-Type': 'text/plain'});
        res.end('Not found');
    }
});

server.listen(port, '0.0.0.0', () => {
    console.log(`Server running on port ${port}`);
});

server.on('error', (err) => {
    console.error('Server error:', err);
});


