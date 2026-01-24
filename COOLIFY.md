# Coolify Deployment Guide

## Информация о деплое

Этот проект настроен для деплоя в Coolify с использованием Docker.

### Порты

- Приложение слушает порт определенный в переменной окружения `PORT` (по умолчанию 3000)
- В Coolify настройте Port Mapping: `3000:3000` или используйте переменную окружения `PORT`

### Переменные окружения

Рекомендуемые переменные окружения в Coolify:

```
PORT=3000
NODE_ENV=production
```

### Обновление данных после деплоя

После успешного деплоя, для обновления файла `data.json`:

1. **Через SSH подключение к контейнеру:**
   ```bash
   # Найдите ID контейнера
   docker ps | grep nalico-predzakaz
   
   # Подключитесь к контейнеру
   docker exec -it <container_id> sh
   
   # Загрузите новый Excel файл в price_files/
   # Затем конвертируйте
   node convert-to-json.js
   ```

2. **Автоматизация через Git:**
   - Загрузите новый файл Excel в `price_files/`
   - Запустите `node convert-to-json.js` локально
   - Закоммитьте `data.json`
   - Пушьте в Git - Coolify автоматически задеплоит

3. **Volume для price_files (рекомендуется):**
   В Coolify добавьте Volume:
   - Source: `./price_files` (на хосте)
   - Destination: `/app/price_files` (в контейнере)
   
   Это позволит обновлять файлы без редеплоя.

### Health Check

Приложение отвечает на:
- `GET /` - главная страница
- `GET /data.json` - данные о товарах

Для Coolify Health Check используйте:
- Path: `/`
- Port: `3000`
- Interval: `30s`

### Особенности

- Автозагрузка данных из `data.json` при открытии страницы
- Файл `data.json` обновляется скриптом `convert-to-json.js`
- Все Excel файлы хранятся в папке `price_files/`
