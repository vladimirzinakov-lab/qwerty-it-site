/* Мини-сервер для локального просмотра сайта без зависимостей.
   Запуск: node tools/serve.js 8123   →   http://localhost:8123
   Неизвестные пути отдают 404.html — как на GitHub Pages. */
const http = require('http');
const fs = require('fs');
const path = require('path');

const root = path.resolve(__dirname, '..');
const port = Number(process.argv[2]) || 8080;

const types = {
  '.html': 'text/html; charset=utf-8',
  '.css': 'text/css; charset=utf-8',
  '.js': 'text/javascript; charset=utf-8',
  '.jpg': 'image/jpeg',
  '.jpeg': 'image/jpeg',
  '.png': 'image/png',
  '.svg': 'image/svg+xml',
  '.xml': 'application/xml; charset=utf-8',
  '.txt': 'text/plain; charset=utf-8',
  '.md': 'text/plain; charset=utf-8'
};

http.createServer((req, res) => {
  const requested = decodeURIComponent(req.url.split('?')[0]);
  let filePath = path.join(root, requested === '/' ? 'index.html' : requested);

  if (!path.resolve(filePath).startsWith(root)) {
    res.writeHead(403, { 'Content-Type': 'text/plain; charset=utf-8' });
    res.end('403 — выход за пределы каталога сайта');
    return;
  }

  fs.stat(filePath, (statErr, stat) => {
    if (!statErr && stat.isDirectory()) {
      filePath = path.join(filePath, 'index.html');
    }

    fs.readFile(filePath, (readErr, data) => {
      if (readErr) {
        fs.readFile(path.join(root, '404.html'), (nfErr, nfData) => {
          res.writeHead(404, { 'Content-Type': types['.html'] });
          res.end(nfErr ? '404 — страница не найдена' : nfData);
        });
        return;
      }

      res.writeHead(200, { 'Content-Type': types[path.extname(filePath).toLowerCase()] || 'application/octet-stream' });
      res.end(data);
    });
  });
}).listen(port, () => {
  console.log('Сайт доступен: http://localhost:' + port);
});
