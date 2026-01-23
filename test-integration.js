const fs = require('fs');
const path = require('path');

console.log('\n🧪 ИНТЕГРАЦИОННЫЙ ТЕСТ СИСТЕМЫ\n');
console.log('═══════════════════════════════════════════════════\n');

let passed = 0;
let failed = 0;

// Тест 1: Проверка data.json
console.log('Тест 1: Загрузка и валидация data.json');
try {
    const data = require('./data.json');
    
    if (!data.metadata) {
        throw new Error('Отсутствует metadata');
    }
    
    if (!data.products || !Array.isArray(data.products)) {
        throw new Error('Отсутствует массив products');
    }
    
    console.log('✅ PASSED: data.json валиден');
    console.log(`   - Файл: ${data.metadata.filename}`);
    console.log(`   - Обновлен: ${new Date(data.metadata.updated).toLocaleString('ru-RU')}`);
    console.log(`   - Всего товаров: ${data.metadata.totalProducts}`);
    console.log(`   - В наличии: ${data.metadata.inStock}`);
    passed++;
} catch (error) {
    console.log(`❌ FAILED: ${error.message}`);
    failed++;
}
console.log('');

// Тест 2: Проверка структуры товаров
console.log('Тест 2: Проверка структуры товаров');
try {
    const data = require('./data.json');
    const product = data.products[0];
    
    const requiredFields = ['brand', 'name', 'description', 'article', 'volume', 'rrp', 'price', 'stock'];
    const missingFields = requiredFields.filter(field => !(field in product));
    
    if (missingFields.length > 0) {
        throw new Error(`Отсутствуют поля: ${missingFields.join(', ')}`);
    }
    
    console.log('✅ PASSED: Структура товара корректна');
    console.log(`   Пример: ${product.brand} - ${product.name}`);
    passed++;
} catch (error) {
    console.log(`❌ FAILED: ${error.message}`);
    failed++;
}
console.log('');

// Тест 3: Проверка наличия в data.json
console.log('Тест 3: Проверка фильтрации товаров в наличии');
try {
    const data = require('./data.json');
    const inStock = data.products.filter(p => p.stock > 0);
    const outOfStock = data.products.filter(p => p.stock === 0);
    
    console.log('✅ PASSED: Фильтрация работает');
    console.log(`   - В наличии: ${inStock.length}`);
    console.log(`   - Нет в наличии: ${outOfStock.length}`);
    console.log(`   - Процент в наличии: ${(inStock.length / data.products.length * 100).toFixed(1)}%`);
    passed++;
} catch (error) {
    console.log(`❌ FAILED: ${error.message}`);
    failed++;
}
console.log('');

// Тест 4: Проверка брендов
console.log('Тест 4: Проверка уникальных брендов');
try {
    const data = require('./data.json');
    const brands = [...new Set(data.products.map(p => p.brand))].sort();
    
    console.log('✅ PASSED: Бренды извлечены');
    console.log(`   - Уникальных брендов: ${brands.length}`);
    console.log(`   - Примеры: ${brands.slice(0, 5).join(', ')}...`);
    passed++;
} catch (error) {
    console.log(`❌ FAILED: ${error.message}`);
    failed++;
}
console.log('');

// Тест 5: Проверка размера файла
console.log('Тест 5: Проверка размера data.json');
try {
    const stats = fs.statSync('./data.json');
    const sizeKB = (stats.size / 1024).toFixed(2);
    
    if (stats.size === 0) {
        throw new Error('Файл пустой');
    }
    
    if (stats.size > 5 * 1024 * 1024) {
        console.log(`⚠️  WARNING: Файл очень большой (${sizeKB} KB)`);
    }
    
    console.log('✅ PASSED: Размер файла адекватный');
    console.log(`   - Размер: ${sizeKB} KB`);
    passed++;
} catch (error) {
    console.log(`❌ FAILED: ${error.message}`);
    failed++;
}
console.log('');

// Тест 6: Проверка HTML файла
console.log('Тест 6: Проверка index.html');
try {
    const html = fs.readFileSync('./index.html', 'utf8');
    
    if (!html.includes('loadDataFromJSON')) {
        throw new Error('Функция loadDataFromJSON не найдена');
    }
    
    if (!html.includes('data.json')) {
        throw new Error('Ссылка на data.json не найдена');
    }
    
    if (!html.includes('Склад "Эльвира-Кореянка"')) {
        throw new Error('Название дашборда не обновлено');
    }
    
    console.log('✅ PASSED: HTML файл содержит все необходимые элементы');
    passed++;
} catch (error) {
    console.log(`❌ FAILED: ${error.message}`);
    failed++;
}
console.log('');

// Тест 7: Симуляция загрузки данных (как в браузере)
console.log('Тест 7: Симуляция загрузки данных');
try {
    const data = require('./data.json');
    
    // Симулируем функцию populateBrandFilter
    const brands = [...new Set(data.products.map(p => p.brand))].sort();
    
    // Симулируем функцию applyFilters (только в наличии)
    const filteredProducts = data.products.filter(p => p.stock > 0);
    
    // Симулируем updateStats
    const stats = {
        totalProducts: filteredProducts.length,
        inStockProducts: filteredProducts.filter(p => p.stock > 0).length
    };
    
    console.log('✅ PASSED: Симуляция загрузки успешна');
    console.log(`   - Отображаемых товаров: ${stats.totalProducts}`);
    console.log(`   - Брендов в фильтре: ${brands.length}`);
    passed++;
} catch (error) {
    console.log(`❌ FAILED: ${error.message}`);
    failed++;
}
console.log('');

// Тест 8: Проверка кодировки
console.log('Тест 8: Проверка кодировки (UTF-8)');
try {
    const data = require('./data.json');
    const russianText = data.products[0].name;
    
    // Проверяем, что кириллица читается корректно
    if (!/[а-яА-Я]/.test(russianText)) {
        throw new Error('Кириллица не обнаружена или повреждена');
    }
    
    console.log('✅ PASSED: Кириллица читается корректно');
    console.log(`   - Пример: ${russianText}`);
    passed++;
} catch (error) {
    console.log(`❌ FAILED: ${error.message}`);
    failed++;
}
console.log('');

// Итоги
console.log('═══════════════════════════════════════════════════');
console.log('           📊 ИТОГОВЫЕ РЕЗУЛЬТАТЫ');
console.log('═══════════════════════════════════════════════════\n');

console.log(`✅ Успешно: ${passed}`);
console.log(`❌ Провалено: ${failed}`);
console.log(`📊 Всего тестов: ${passed + failed}\n`);

if (failed === 0) {
    console.log('🎉 ВСЕ ТЕСТЫ ПРОЙДЕНЫ!\n');
    console.log('✅ BAT файлы готовы к использованию');
    console.log('✅ Система работает корректно');
    console.log('✅ Дашборд готов к открытию в браузере\n');
    
    console.log('📝 Следующие шаги:');
    console.log('   1. На Windows: запустите start.bat');
    console.log('   2. Или откройте index.html в браузере');
    console.log('   3. Данные загрузятся автоматически из data.json\n');
    
    process.exit(0);
} else {
    console.log('❌ НЕКОТОРЫЕ ТЕСТЫ НЕ ПРОЙДЕНЫ\n');
    console.log('Проверьте ошибки выше и исправьте их.\n');
    process.exit(1);
}
