from PIL import Image

# convert magenta to transparent
def make_magenta_transparent(input_image_path, output_image_path):
    """
    Конвертирует магенту в прозрачный цвет в изображении.

    Args:
        input_image_path: Путь к входному изображению.
        output_image_path: Путь к выходному изображению.
    """
    try:
        img = Image.open(input_image_path)
        img = img.convert("RGBA")  # Преобразуем изображение в RGBA для прозрачности

        data = img.getdata()
        newData = []
        for item in data:
            if item[0] == 255 and item[1] == 0 and item[2] == 255:  # Проверяем, является ли пиксель магентой
                newData.append((255, 255, 255, 0))  # Делаем пиксель прозрачным
            else:
                newData.append(item)

        img.putdata(newData)
        img.save(output_image_path)

    except FileNotFoundError:
        print(f"Ошибка: Файл {input_image_path} не найден.")
    except Exception as e:
        print(f"Произошла ошибка: {e}")


# Пример использования:
input_image = "output_font.png"  # Замените на путь к вашему изображению
output_image = "font_ru.png"  # Замените на желаемое имя выходного файла

make_magenta_transparent(input_image, output_image)

print(f"Изображение сохранено как {output_image}")

