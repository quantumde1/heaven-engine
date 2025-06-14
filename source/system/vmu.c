#ifdef _arch_dreamcast

#include <kos.h>
#include <string.h>
#include <dc/vmu_pkg.h>

void write_entry(char* text_data) {
    vmu_pkg_t   pkg;
    uint8       *data, *pkg_out;
    int     pkg_size;
    int     i;
    file_t      f;
    int     data_len;

    // Calculate required data length (text length + null terminator)
    data_len = strlen(text_data) + 1;

    // Allocate buffer for data
    data = malloc(data_len);
    if (!data) {
        printf("Memory allocation failed\n");
        return;
    }

    // Copy text data into buffer
    strcpy((char*)data, text_data);

    strcpy(pkg.desc_short, "VMU Test");
    strcpy(pkg.desc_long, "This is a test VMU file");
    strcpy(pkg.app_id, "KOS");
    pkg.icon_cnt = 0;
    pkg.icon_anim_speed = 0;
    pkg.eyecatch_type = VMUPKG_EC_NONE;
    pkg.data_len = data_len;  // Use actual data length
    pkg.data = data;

    vmu_pkg_build(&pkg, &pkg_out, &pkg_size);

    fs_unlink("/vmu/a1/TESTFILE");
    f = fs_open("/vmu/a1/TESTFILE", O_WRONLY);

    if(!f) {
        printf("error writing\n");
        free(data);
        return;
    }

    fs_write(f, pkg_out, pkg_size);
    fs_close(f);
    free(data);
}

char* read_entry() {
    file_t f;
    int size;
    uint8 *buffer;
    vmu_pkg_t pkg;
    char *data = NULL;

    // Открываем файл
    f = fs_open("/vmu/a1/TESTFILE", O_RDONLY);
    if (!f) {
        printf("Ошибка: не удалось открыть файл\n");
        return NULL;
    }

    // Получаем размер файла
    size = fs_total(f);
    buffer = malloc(size);
    if (!buffer) {
        printf("Ошибка: не удалось выделить память\n");
        fs_close(f);
        return NULL;
    }

    // Читаем весь файл в буфер
    if (fs_read(f, buffer, size) != size) {
        printf("Ошибка чтения файла\n");
        free(buffer);
        fs_close(f);
        return NULL;
    }
    fs_close(f);

    // Распарсить VMU-пакет
    if (vmu_pkg_parse(buffer, &pkg) != 0) {
        printf("Ошибка: неверный формат VMU-пакета\n");
        free(buffer);
        return NULL;
    }

    // Копируем данные (предполагаем, что это текст)
    data = malloc(pkg.data_len + 1); // +1 для нуль-терминатора
    if (!data) {
        printf("Ошибка: не удалось выделить память\n");
        free(buffer);
        return NULL;
    }

    memcpy(data, pkg.data, pkg.data_len);
    data[pkg.data_len] = '\0'; // Гарантируем, что строка завершена

    free(buffer); // Освобождаем временный буфер
    return data;
}
#endif