#!/usr/bin/env python3
"""Production-grade static server for the IED Reader PWA preview.

Adds:
  - Correct caching headers (long cache for hashed/static assets, no-cache
    for index.html and the service worker so updates propagate immediately)
  - CORS headers (safe default for a public read-only PWA)
  - gzip compression for text-based assets
  - Security headers appropriate for a public-facing PWA
"""
import http.server
import socketserver
import sys
import os
import gzip
from io import BytesIO

PORT = int(sys.argv[1]) if len(sys.argv) > 1 else 5060

COMPRESSIBLE_EXT = {
    ".js", ".css", ".html", ".json", ".svg", ".txt", ".xml", ".wasm",
}

NO_CACHE_FILES = {"index.html", "flutter_service_worker.js", "manifest.json", "version.json"}


class PWARequestHandler(http.server.SimpleHTTPRequestHandler):
    def end_headers(self):
        path = self.path.split("?")[0]
        filename = os.path.basename(path) or "index.html"

        # CORS (public, read-only content)
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Access-Control-Allow-Methods", "GET, HEAD, OPTIONS")

        # Security headers
        self.send_header("X-Content-Type-Options", "nosniff")
        self.send_header("X-Frame-Options", "SAMEORIGIN")
        self.send_header("Referrer-Policy", "strict-origin-when-cross-origin")

        # Caching strategy
        if filename in NO_CACHE_FILES:
            self.send_header("Cache-Control", "no-cache, must-revalidate")
        elif filename == "main.dart.js" or "/canvaskit/" in path or "/assets/" in path:
            self.send_header("Cache-Control", "public, max-age=31536000, immutable")
        else:
            self.send_header("Cache-Control", "public, max-age=3600")

        super().end_headers()

    def do_GET(self):
        path = self.translate_path(self.path.split("?")[0])
        ext = os.path.splitext(path)[1].lower()
        accept_encoding = self.headers.get("Accept-Encoding", "")

        if (
            ext in COMPRESSIBLE_EXT
            and "gzip" in accept_encoding
            and os.path.isfile(path)
        ):
            try:
                with open(path, "rb") as f:
                    content = f.read()
                buf = BytesIO()
                with gzip.GzipFile(fileobj=buf, mode="wb", compresslevel=6) as gz:
                    gz.write(content)
                compressed = buf.getvalue()

                self.send_response(200)
                self.send_header("Content-Type", self.guess_type(path))
                self.send_header("Content-Encoding", "gzip")
                self.send_header("Content-Length", str(len(compressed)))
                self.end_headers()
                self.wfile.write(compressed)
                return
            except Exception:
                pass  # fall back to default handling below

        super().do_GET()


class ThreadingHTTPServer(socketserver.ThreadingMixIn, http.server.HTTPServer):
    daemon_threads = True
    allow_reuse_address = True


if __name__ == "__main__":
    os.chdir(os.path.dirname(os.path.abspath(__file__)) or ".")
    with ThreadingHTTPServer(("0.0.0.0", PORT), PWARequestHandler) as httpd:
        print(f"Serving IED Reader PWA on port {PORT} ...")
        httpd.serve_forever()
