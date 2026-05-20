import http.server
import socketserver
import os

os.chdir(r"C:\Users\MSI-\Desktop\Сеул 2026")
Handler = http.server.SimpleHTTPRequestHandler

with socketserver.TCPServer(("", 8081), Handler) as httpd:
    print(f"Server running at http://localhost:8081")
    httpd.serve_forever()
