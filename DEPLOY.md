# Инструкция по деплою на сервер

## Требования

- Node.js 14+ и npm
- PM2 (опционально, для production)
- Nginx или Apache (опционально, для reverse proxy)

## Способ 1: Простой деплой (без PM2)

### Шаг 1: Клонируйте репозиторий
```bash
git clone https://github.com/Damienadv/nalico-predzakaz.git
cd nalico-predzakaz
```

### Шаг 2: Установите зависимости
```bash
npm install
```

### Шаг 3: Запустите сервер
```bash
npm start
# или
node server.js
```

Сайт будет доступен на порту 3000.

## Способ 2: Production деплой с PM2 (рекомендуется)

### Шаг 1: Установите PM2
```bash
npm install -g pm2
```

### Шаг 2: Клонируйте и настройте проект
```bash
git clone https://github.com/Damienadv/nalico-predzakaz.git
cd nalico-predzakaz
npm install
```

### Шаг 3: Запустите с PM2
```bash
pm2 start ecosystem.config.js
pm2 save
pm2 startup
```

### Управление PM2
```bash
pm2 status              # Статус приложения
pm2 logs                # Логи приложения
pm2 restart all         # Перезапуск
pm2 stop all            # Остановка
```

## Способ 3: С Nginx Reverse Proxy

### Настройка Nginx

Создайте файл `/etc/nginx/sites-available/nalico-predzakaz`:

```nginx
server {
    listen 80;
    server_name your-domain.com www.your-domain.com;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

Активируйте конфигурацию:
```bash
sudo ln -s /etc/nginx/sites-available/nalico-predzakaz /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

### SSL с Let's Encrypt (опционально)
```bash
sudo apt install certbot python3-certbot-nginx
sudo certbot --nginx -d your-domain.com -d www.your-domain.com
```

## Обновление данных на сервере

### Способ 1: Загрузка нового Excel файла
1. Загрузите новый файл `.xlsx` в папку `price_files/`
2. Конвертируйте в JSON:
```bash
npm run convert
```
3. Перезагрузите страницу в браузере - данные обновятся автоматически

### Способ 2: Автоматическое обновление
Настройте cron job для автоматической конвертации:
```bash
crontab -e
```

Добавьте строку (проверка каждые 10 минут):
```
*/10 * * * * cd /path/to/nalico-predzakaz && /usr/bin/node convert-to-json.js
```

## Переменные окружения

Создайте файл `.env` (опционально):
```
PORT=3000
NODE_ENV=production
```

## Проверка работы

После деплоя откройте в браузере:
- `http://your-domain.com` (с Nginx)
- `http://your-domain.com:3000` (без Nginx)

Должна загрузиться главная страница с автоматически загруженными данными из `data.json`.

## Troubleshooting

### Порт уже занят
```bash
# Найдите процесс на порту 3000
lsof -i :3000
# Или
netstat -tlnp | grep 3000

# Убейте процесс
kill -9 <PID>
```

### Файл data.json не найден
```bash
# Конвертируйте Excel в JSON
npm run convert
```

### Проблемы с правами доступа
```bash
chmod +x start.sh
chmod 644 data.json
```

## Мониторинг

### С PM2
```bash
pm2 monit
```

### Логи
```bash
pm2 logs nalico-predzakaz --lines 100
```

## Бэкап

Рекомендуется делать бэкап:
- Папка `price_files/` (исходные Excel файлы)
- Файл `data.json` (конвертированные данные)

```bash
tar -czf backup-$(date +%Y%m%d).tar.gz price_files/ data.json
```
