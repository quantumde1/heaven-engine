def translit(text):
    """Транслитерирует русский текст в латинский алфавит."""

    mapping = {
        'а': 'a', 'б': 'b', 'в': 'c', 'г': 'd', 'д': 'e', 'е': 'f', 'ё': 'g',
        'ж': 'h', 'з': 'i', 'и': 'j', 'й': 'k', 'к': 'l', 'л': 'm', 'м': 'n',
        'н': 'o', 'о': 'p', 'п': 'q', 'р': 'r', 'с': 's', 'т': 't', 'у': 'u',
        'ф': 'v', 'х': 'w', 'ц': 'x', 'ч': 'y', 'ш': 'z',
        'А': 'A', 'Б': 'B', 'В': 'C', 'Г': 'D', 'Д': 'E', 'Е': 'F', 'Ё': 'G',
        'Ж': 'H', 'З': 'I', 'И': 'J', 'Й': 'K', 'К': 'L', 'Л': 'M', 'М': 'N',
        'Н': 'O', 'О': 'P', 'П': 'Q', 'Р': 'R', 'С': 'S', 'Т': 'T', 'У': 'U',
        'Ф': 'V', 'Х': 'W', 'Ц': 'X', 'Ч': 'Y', 'Ш': 'Z',
    }

    result = ''.join(mapping.get(char, char) for char in text)
    return result

# Пример использования
russian_text = input()
latin_text = translit(russian_text)
print(f"Русский текст: {russian_text}")
print(f"Латинская транслитерация: {latin_text}")