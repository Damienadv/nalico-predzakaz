const XLSX = require('xlsx');
const fs = require('fs');
const path = require('path');

// Читаем Excel файл
const priceFilesDir = path.join(__dirname, 'price_files');
const files = fs.readdirSync(priceFilesDir).filter(f => f.endsWith('.xlsx') && !f.includes('Zone'));
console.log('Найденные файлы:', files);

if (files.length === 0) {
    console.error('Нет .xlsx файлов в директории price_files/');
    process.exit(1);
}

const filePath = path.join(priceFilesDir, files[0]);
console.log('Читаем файл:', filePath, '\n');

const workbook = XLSX.readFile(filePath);

console.log('=== АНАЛИЗ EXCEL ФАЙЛА ===\n');
console.log(`Имя файла: ${path.basename(filePath)}`);
console.log(`Листы: ${workbook.SheetNames.join(', ')}\n`);

workbook.SheetNames.forEach(sheetName => {
    console.log(`\n=== Лист: "${sheetName}" ===`);
    const sheet = workbook.Sheets[sheetName];
    const jsonData = XLSX.utils.sheet_to_json(sheet, { header: 1, defval: '', raw: false });
    
    console.log(`Всего строк: ${jsonData.length}`);
    console.log(`\nПервые 10 строк:\n`);
    
    jsonData.slice(0, 10).forEach((row, i) => {
        console.log(`Строка ${i}:`, row);
    });
    
    // Пробуем найти заголовки
    console.log('\n--- Поиск заголовков ---');
    for (let i = 0; i < Math.min(5, jsonData.length); i++) {
        const row = jsonData[i];
        const hasHeaders = row.some(cell => 
            String(cell).toLowerCase().includes('бренд') ||
            String(cell).toLowerCase().includes('наименование') ||
            String(cell).toLowerCase().includes('артикул') ||
            String(cell).toLowerCase().includes('остаток')
        );
        if (hasHeaders) {
            console.log(`\nЗаголовки найдены в строке ${i}:`, row);
            console.log('\nПримеры данных (следующие 3 строки):');
            jsonData.slice(i + 1, i + 4).forEach((dataRow, idx) => {
                console.log(`Данные ${idx + 1}:`, dataRow);
            });
            break;
        }
    }
});
