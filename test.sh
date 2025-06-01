#!/bin/bash

# Проверяем, установлен ли ImageMagick (необходим для работы convert)
if ! command -v convert &> /dev/null; then
    echo "Ошибка: ImageMagick не установлен. Установите его для работы скрипта."
    echo "На Ubuntu/Debian: sudo apt install imagemagick"
    echo "На CentOS/RHEL: sudo yum install imagemagick"
    exit 1
fi

# Проверяем, указана ли папка с изображениями
if [ -z "$1" ]; then
    echo "Использование: $0 /путь/к/папке/с/изображениями"
    exit 1
fi

# Переходим в указанную папку
cd "$1" || exit 1

# Счетчик конвертированных файлов
converted=0

# Обрабатываем все JPG и JPEG файлы
for file in *.jpg *.jpeg; do
    # Пропускаем несуществующие файлы (если нет jpg, например)
    [ -e "$file" ] || continue
    
    # Формируем имя PNG файла
    png_file="${file%.*}.png"
    
    echo "Конвертация: $file -> $png_file"
    
    # Выполняем конвертацию
    convert "$file" "$png_file"
    
    # Увеличиваем счетчик
    ((converted++))
done

echo "Готово! Конвертировано $converted файлов в PNG."
