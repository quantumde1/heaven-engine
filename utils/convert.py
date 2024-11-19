from PIL import Image

def make_transparent_black(input_filename, output_filename):
    """
    Заменяет прозрачный цвет на чёрный в изображении.

    Args:
        input_filename: Путь к входному файлу изображения.
        output_filename: Путь к выходному файлу изображения.
    """
    try:
        img = Image.open(input_filename)
        if img.mode != 'RGBA':
            print("Изображение не имеет альфа-канала (RGBA).")
            return

        # Создаём копию изображения, чтобы не изменять оригинал
        img_new = img.copy()

        #  Проходим по пикселям и заменяем прозрачные на чёрные
        for x in range(img.width):
            for y in range(img.height):
                r, g, b, a = img.getpixel((x, y))
                if a == 0:  # Прозрачный пиксель
                    img_new.putpixel((x, y), (0, 0, 0, 255))  # Заменяем на чёрный (непрозрачный)

        img_new.save(output_filename)
        print(f"Обработка завершена. Результат сохранён в {output_filename}")

    except FileNotFoundError:
        print(f"Файл {input_filename} не найден.")
    except Exception as e:
        print(f"Произошла ошибка: {e}")


if __name__ == "__main__":
    import sys
    if len(sys.argv) != 3:
        print("Использование: python script.py <входной_файл> <выходной_файл>")
    else:
        input_file = sys.argv[1]
        output_file = sys.argv[2]
        make_transparent_black(input_file, output_file)
