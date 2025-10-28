#!/usr/bin/env python3
import http.server
import socketserver
import json
import sys

PORT = 8765

class ScriptletHandler(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        # Enable CORS
        self.send_response(200)
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type')
        self.send_header('Content-Type', 'text/plain')
        self.end_headers()
        
        if self.path == '/':
            self.wfile.write(b'Scriptlet Bridge Server v2.0 - Use /status, /scriptlets, /exit endpoints')
        elif self.path == '/status':
            self.send_header('Content-Type', 'application/json')
            self.end_headers()
            response = json.dumps({"status": "running", "port": PORT})
            self.wfile.write(response.encode())
        elif self.path == '/scriptlets':
            self.send_header('Content-Type', 'application/json')
            self.end_headers()
            response = json.dumps([])
            self.wfile.write(response.encode())
        elif self.path == '/exit':
            self.wfile.write(b'Server shutting down...')
            sys.exit(0)
        else:
            self.send_response(404)
            self.end_headers()
            self.wfile.write(b'Not found')
    
    def do_OPTIONS(self):
        self.send_response(200)
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type')
        self.end_headers()

try:
    with socketserver.TCPServer(("", PORT), ScriptletHandler) as httpd:
        print(f"Server running on port {PORT}")
        httpd.serve_forever()
except Exception as e:
    print(f"Error: {e}")
    sys.exit(1)







