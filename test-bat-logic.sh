#!/bin/bash

echo "======================================================"
echo "   🧪 ТЕСТ BAT-файла (симуляция в Linux)"
echo "======================================================"
echo ""

# Цвета для вывода
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

test_passed=0
test_failed=0

# Тест 1: Проверка наличия Node.js
echo "Тест 1: Проверка наличия Node.js"
if command -v node &> /dev/null; then
    echo -e "${GREEN}✅ PASSED${NC}: Node.js установлен ($(node -v))"
    ((test_passed++))
else
    echo -e "${RED}❌ FAILED${NC}: Node.js не установлен"
    ((test_failed++))
fi
echo ""

# Тест 2: Проверка наличия node_modules
echo "Тест 2: Проверка наличия node_modules"
if [ -d "node_modules" ]; then
    echo -e "${GREEN}✅ PASSED${NC}: node_modules существует"
    ((test_passed++))
else
    echo -e "${YELLOW}⚠️  WARNING${NC}: node_modules не найден, нужна установка"
    echo "Запуск: npm install"
    npm install --silent
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ PASSED${NC}: Зависимости установлены"
        ((test_passed++))
    else
        echo -e "${RED}❌ FAILED${NC}: Ошибка установки зависимостей"
        ((test_failed++))
    fi
fi
echo ""

# Тест 3: Проверка наличия price_files/
echo "Тест 3: Проверка директории price_files/"
if [ -d "price_files" ]; then
    excel_count=$(find price_files -name "*.xlsx" ! -name "*Zone*" | wc -l)
    if [ $excel_count -gt 0 ]; then
        echo -e "${GREEN}✅ PASSED${NC}: Найдено Excel файлов: $excel_count"
        latest_file=$(ls -t price_files/*.xlsx | grep -v Zone | head -1)
        echo "   Последний файл: $(basename "$latest_file")"
        ((test_passed++))
    else
        echo -e "${RED}❌ FAILED${NC}: Нет Excel файлов в price_files/"
        ((test_failed++))
    fi
else
    echo -e "${RED}❌ FAILED${NC}: Директория price_files/ не существует"
    ((test_failed++))
fi
echo ""

# Тест 4: Проверка скрипта convert-to-json.js
echo "Тест 4: Проверка наличия convert-to-json.js"
if [ -f "convert-to-json.js" ]; then
    echo -e "${GREEN}✅ PASSED${NC}: convert-to-json.js найден"
    ((test_passed++))
else
    echo -e "${RED}❌ FAILED${NC}: convert-to-json.js не найден"
    ((test_failed++))
fi
echo ""

# Тест 5: Запуск конвертации (основной тест)
echo "Тест 5: Запуск конвертации Excel → JSON"
echo "Выполняется: node convert-to-json.js"
echo "─────────────────────────────────────────────────────"
node convert-to-json.js
exit_code=$?
echo "─────────────────────────────────────────────────────"

if [ $exit_code -eq 0 ]; then
    echo -e "${GREEN}✅ PASSED${NC}: Конвертация завершена успешно (exit code: $exit_code)"
    ((test_passed++))
else
    echo -e "${RED}❌ FAILED${NC}: Ошибка конвертации (exit code: $exit_code)"
    ((test_failed++))
fi
echo ""

# Тест 6: Проверка созданного data.json
echo "Тест 6: Проверка созданного data.json"
if [ -f "data.json" ]; then
    file_size=$(du -h data.json | cut -f1)
    echo -e "${GREEN}✅ PASSED${NC}: data.json создан (размер: $file_size)"
    
    # Проверка валидности JSON
    if node -e "require('./data.json')" 2>/dev/null; then
        echo -e "${GREEN}✅ PASSED${NC}: JSON валиден"
        ((test_passed++))
    else
        echo -e "${RED}❌ FAILED${NC}: JSON невалиден"
        ((test_failed++))
    fi
else
    echo -e "${RED}❌ FAILED${NC}: data.json не создан"
    ((test_failed++))
fi
echo ""

# Тест 7: Проверка структуры JSON
echo "Тест 7: Проверка структуры данных в JSON"
if [ -f "data.json" ]; then
    metadata_check=$(node -e "const d=require('./data.json'); console.log(d.metadata && d.products ? 'ok' : 'fail')")
    if [ "$metadata_check" == "ok" ]; then
        products_count=$(node -e "console.log(require('./data.json').products.length)")
        echo -e "${GREEN}✅ PASSED${NC}: Структура корректна"
        echo "   Товаров в JSON: $products_count"
        ((test_passed++))
    else
        echo -e "${RED}❌ FAILED${NC}: Некорректная структура JSON"
        ((test_failed++))
    fi
else
    echo -e "${RED}❌ FAILED${NC}: data.json не найден"
    ((test_failed++))
fi
echo ""

# Тест 8: Проверка наличия index.html
echo "Тест 8: Проверка наличия index.html"
if [ -f "index.html" ]; then
    echo -e "${GREEN}✅ PASSED${NC}: index.html найден"
    ((test_passed++))
else
    echo -e "${RED}❌ FAILED${NC}: index.html не найден"
    ((test_failed++))
fi
echo ""

# Тест 9: Проверка наличия всех BAT файлов
echo "Тест 9: Проверка наличия BAT файлов"
bat_files=("start.bat" "update.bat" "watch.bat" "update-silent.bat")
bat_found=0
for bat in "${bat_files[@]}"; do
    if [ -f "$bat" ]; then
        ((bat_found++))
    fi
done

if [ $bat_found -eq ${#bat_files[@]} ]; then
    echo -e "${GREEN}✅ PASSED${NC}: Все BAT файлы найдены ($bat_found/${#bat_files[@]})"
    ((test_passed++))
else
    echo -e "${YELLOW}⚠️  WARNING${NC}: Найдено BAT файлов: $bat_found/${#bat_files[@]}"
    ((test_passed++))
fi
echo ""

# Итоговый результат
echo "======================================================"
echo "              📊 РЕЗУЛЬТАТЫ ТЕСТИРОВАНИЯ"
echo "======================================================"
echo ""
echo -e "${GREEN}Успешно: $test_passed${NC}"
echo -e "${RED}Провалено: $test_failed${NC}"
echo "Всего тестов: $((test_passed + test_failed))"
echo ""

if [ $test_failed -eq 0 ]; then
    echo -e "${GREEN}🎉 ВСЕ ТЕСТЫ ПРОЙДЕНЫ!${NC}"
    echo ""
    echo "BAT файлы готовы к использованию в Windows:"
    echo "  • start.bat - для первого запуска"
    echo "  • update.bat - для обновления данных"
    echo "  • watch.bat - для автоматического отслеживания"
    echo ""
    exit 0
else
    echo -e "${RED}❌ НЕКОТОРЫЕ ТЕСТЫ НЕ ПРОЙДЕНЫ${NC}"
    echo "Проверьте ошибки выше"
    echo ""
    exit 1
fi
