const http = require('http');
const fs = require('fs');
const path = require('path');

const PORT = 3000;

// MIME типы
const mimeTypes = {
    '.html': 'text/html',
    '.js': 'text/javascript',
    '.css': 'text/css',
    '.json': 'application/json',
    '.xlsx': 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    '.xls': 'application/vnd.ms-excel'
};

const server = http.createServer((req, res) => {
    console.log(`${req.method} ${req.url}`);

    // API для получения последнего файла
    if (req.url === '/api/latest-file') {
        try {
            const priceFilesDir = path.join(__dirname, 'price_files');
            const files = fs.readdirSync(priceFilesDir)
                .filter(f => f.endsWith('.xlsx') && !f.includes('Zone'))
                .map(f => ({
                    name: f,
                    path: path.join(priceFilesDir, f),
                    mtime: fs.statSync(path.join(priceFilesDir, f)).mtime
                }))
                .sort((a, b) => b.mtime - a.mtime);

            if (files.length === 0) {
                res.writeHead(404, { 'Content-Type': 'application/json' });
                res.end(JSON.stringify({ error: 'No Excel files found' }));
                return;
            }

            const latestFile = files[0];
            res.writeHead(200, { 'Content-Type': 'application/json' });
            res.end(JSON.stringify({ 
                filename: latestFile.name,
                url: `/price_files/${latestFile.name}`,
                modified: latestFile.mtime
            }));
        } catch (error) {
            res.writeHead(500, { 'Content-Type': 'application/json' });
            res.end(JSON.stringify({ error: error.message }));
        }
        return;
    }

    // Обработка статических файлов
    let filePath = '.' + req.url;
    if (filePath === './') {
        filePath = './index.html';
    }

    const extname = String(path.extname(filePath)).toLowerCase();
    const contentType = mimeTypes[extname] || 'application/octet-stream';

    fs.readFile(filePath, (error, content) => {
        if (error) {
            if (error.code === 'ENOENT') {
                res.writeHead(404, { 'Content-Type': 'text/html' });
                res.end('<h1>404 - File Not Found</h1>', 'utf-8');
            } else {
                res.writeHead(500);
                res.end(`Server Error: ${error.code}`);
            }
        } else {
            res.writeHead(200, { 
                'Content-Type': contentType,
                'Access-Control-Allow-Origin': '*'
            });
            res.end(content, 'utf-8');
        }
    });
});

server.listen(PORT, () => {
    console.log(`\n📦 Склад "Эльвира-Кореянка" запущен!`);
    console.log(`🌐 Откройте в браузере: http://localhost:${PORT}`);
    console.log(`\nДля остановки сервера нажмите Ctrl+C\n`);
});
