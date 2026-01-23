#!/bin/bash

MODE="${1:-update}"

if [ "$MODE" = "watch" ]; then
    echo "👁️  Авто-отслеживание: Elvira-Koreanka Warehouse"
    echo ""
    echo "Этот скрипт автоматически обновит data.json"
    echo "при изменении Excel файлов в папке price_files"
    echo ""
    echo "Нажмите Ctrl+C для остановки"
    echo ""
    echo "------------------------------------------------------"
    echo ""
    
    LAST_CHECK=""
    
    while true; do
        # Найти последний изменённый Excel файл
        LATEST_FILE=$(ls -t price_files/*.xlsx 2>/dev/null | head -1)
        
        if [ -z "$LATEST_FILE" ]; then
            echo "[ERROR] Нет Excel файлов в price_files"
            sleep 10
            continue
        fi
        
        # Получить дату изменения файла
        FILE_DATE=$(stat -c %Y "$LATEST_FILE" 2>/dev/null || stat -f %m "$LATEST_FILE" 2>/dev/null)
        
        # Проверить, изменилась ли дата
        if [ "$FILE_DATE" != "$LAST_CHECK" ]; then
            if [ -n "$LAST_CHECK" ]; then
                echo ""
                echo "[ALERT] Обнаружены изменения в $(basename "$LATEST_FILE")"
                echo "[TIME] $(date)"
                echo ""
                echo "[INFO] Обновление данных..."
                node convert-to-json.js
                
                if [ $? -eq 0 ]; then
                    echo "[SUCCESS] Данные обновлены! Обновите страницу браузера (F5)"
                else
                    echo "[ERROR] Ошибка обновления"
                fi
                echo ""
                echo "------------------------------------------------------"
            else
                echo "[INFO] Отслеживание: $(basename "$LATEST_FILE")"
                echo "[TIME] Последнее изменение: $(date -r "$LATEST_FILE" 2>/dev/null || date)"
                echo ""
                echo "[SUCCESS] Готово. Ожидание изменений..."
                echo ""
            fi
            
            LAST_CHECK="$FILE_DATE"
        fi
        
        # Подождать 5 секунд перед следующей проверкой
        sleep 5
    done
else
    echo "🔄 Обновление прайс-листа..."
    echo ""
    
    # Проверка наличия Node.js
    if ! command -v node &> /dev/null; then
        echo "❌ Node.js не установлен!"
        echo "Установите Node.js с https://nodejs.org/"
        exit 1
    fi
    
    # Конвертация Excel в JSON
    echo "📊 Конвертация Excel → JSON..."
    node convert-to-json.js
    
    if [ $? -eq 0 ]; then
        echo ""
        echo "✅ Обновление завершено успешно!"
        echo "🌐 Откройте или обновите index.html в браузере"
    else
        echo ""
        echo "❌ Ошибка при конвертации"
        exit 1
    fi
fi

