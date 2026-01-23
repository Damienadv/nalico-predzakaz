const XLSX = require('xlsx');
const fs = require('fs');
const path = require('path');

console.log('🔄 Конвертация Excel → JSON...\n');

// Находим все Excel файлы в price_files/
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
    console.error('❌ Не найдены Excel файлы в директории price_files/');
    process.exit(1);
}

const latestFile = files[0];
console.log(`📄 Обработка файла: ${latestFile.name}`);
console.log(`📅 Дата изменения: ${latestFile.mtime.toLocaleString('ru-RU')}\n`);

// Читаем Excel файл
const workbook = XLSX.readFile(latestFile.path);
const firstSheet = workbook.Sheets[workbook.SheetNames[0]];
const jsonData = XLSX.utils.sheet_to_json(firstSheet, { header: 1, defval: '', raw: false });

// Ищем заголовки
let headerRowIndex = -1;
let headers = [];

for (let i = 0; i < Math.min(5, jsonData.length); i++) {
    const row = jsonData[i];
    const hasHeaders = row.some(cell => {
        const cellStr = String(cell || '').toLowerCase().trim();
        return cellStr.includes('бренд') || 
               cellStr.includes('наименование') || 
               cellStr.includes('остаток');
    });
    
    if (hasHeaders) {
        headerRowIndex = i;
        headers = row;
        console.log(`✓ Заголовки найдены в строке ${i}`);
        break;
    }
}

if (headerRowIndex === -1) {
    console.error('❌ Не удалось найти заголовки в файле');
    process.exit(1);
}

// Маппинг колонок
const columnMap = {
    brand: -1,
    name: -1,
    description: -1,
    article: -1,
    volume: -1,
    rrp: -1,
    price: -1,
    order: -1,
    total: -1,
    stock: -1
};

headers.forEach((header, index) => {
    const h = String(header || '').toLowerCase().trim();
    if (h.includes('бренд')) columnMap.brand = index;
    else if (h.includes('наименование')) columnMap.name = index;
    else if (h.includes('артикул')) columnMap.article = index;
    else if (h.includes('объем')) columnMap.volume = index;
    else if (h.includes('ррц')) columnMap.rrp = index;
    else if (h.includes('стоимость')) columnMap.price = index;
    else if (h.includes('заказ')) columnMap.order = index;
    else if (h.includes('итого')) columnMap.total = index;
    else if (h.includes('остаток')) columnMap.stock = index;
});

// Определяем столбец описания
if (columnMap.name >= 0 && columnMap.name + 1 < headers.length) {
    const nextCol = String(headers[columnMap.name + 1] || '').trim();
    if (!nextCol || nextCol === '') {
        columnMap.description = columnMap.name + 1;
    }
}

console.log('✓ Структура колонок распознана\n');

// Парсим данные
const products = [];
let skipped = 0;

for (let i = headerRowIndex + 1; i < jsonData.length; i++) {
    const row = jsonData[i];
    if (!row || row.length === 0) continue;

    const brand = columnMap.brand >= 0 ? String(row[columnMap.brand] || '').trim() : '';
    const name = columnMap.name >= 0 ? String(row[columnMap.name] || '').trim() : '';
    const description = columnMap.description >= 0 ? String(row[columnMap.description] || '').trim() : '';
    const article = columnMap.article >= 0 ? String(row[columnMap.article] || '').trim() : '';
    
    const volume = columnMap.volume >= 0 ? parseFloat(String(row[columnMap.volume] || '0').replace(/[^\d.-]/g, '')) || 0 : 0;
    const rrp = columnMap.rrp >= 0 ? parseFloat(String(row[columnMap.rrp] || '0').replace(/[^\d.-]/g, '')) || 0 : 0;
    const price = columnMap.price >= 0 ? parseFloat(String(row[columnMap.price] || '0').replace(/[^\d.-]/g, '')) || 0 : 0;
    const order = columnMap.order >= 0 ? parseInt(String(row[columnMap.order] || '0').replace(/[^\d-]/g, '')) || 0 : 0;
    const total = columnMap.total >= 0 ? parseFloat(String(row[columnMap.total] || '0').replace(/[^\d.-]/g, '')) || 0 : 0;
    const stock = columnMap.stock >= 0 ? parseInt(String(row[columnMap.stock] || '0').replace(/[^\d-]/g, '')) || 0 : 0;

    if (!brand && !name) {
        skipped++;
        continue;
    }

    products.push({
        brand,
        name,
        description,
        article: article || description,
        volume,
        rrp,
        price,
        order,
        total,
        stock
    });
}

console.log(`✓ Обработано товаров: ${products.length}`);
console.log(`✓ Пропущено пустых строк: ${skipped}\n`);

// Создаем JSON объект с метаданными
const jsonOutput = {
    metadata: {
        filename: latestFile.name,
        updated: latestFile.mtime.toISOString(),
        totalProducts: products.length,
        inStock: products.filter(p => p.stock > 0).length
    },
    products: products
};

// Сохраняем JSON файл
const outputPath = path.join(__dirname, 'data.json');
fs.writeFileSync(outputPath, JSON.stringify(jsonOutput, null, 2), 'utf-8');

console.log(`✅ JSON файл создан: ${outputPath}`);
console.log(`📊 Размер файла: ${(fs.statSync(outputPath).size / 1024).toFixed(2)} KB\n`);
console.log('🎉 Конвертация завершена успешно!\n');
console.log('Теперь можете открыть index.html в браузере');
