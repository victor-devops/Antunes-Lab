// server.js
const http = require("http");
const fs = require("fs");
const path = require("path");

const port = process.env.PORT || 3000;

const mime = {
    ".html": "text/html",
    ".js": "text/javascript",
    ".css": "text/css",
    ".png": "image/png",
    ".jpg": "image/jpeg",
    ".svg": "image/svg+xml",
};

http
    .createServer((req, res) => {
        const safePath = req.url === "/" ? "/index.html" : req.url;
        const filePath = path.join(__dirname, decodeURIComponent(safePath));

        fs.readFile(filePath, (err, data) => {
            if (err) {
                res.writeHead(404);
                return res.end("Not found");
            }
            res.writeHead(200, { "Content-Type": mime[path.extname(filePath)] || "text/plain" });
            res.end(data);
        });
    })
    .listen(port, "127.0.0.1", () => console.log(`Listening on http://127.0.0.1:${port}`));
