#ifdef _arch_dreamcast
#include "GL/glkos.h"
#include "GL/glu.h"
#include "GL/glext.h"
#include "kos.h"
#else
#include "GL/freeglut.h"
#endif

#include "../../include/abstraction.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

char* concat_strings(const char* str1, const char* str2) {
    char* result = malloc(strlen(str1) + strlen(str2) + 1);
    
    if (result == NULL) {
        fprintf(stderr, "Error memory allocation\n");
        exit(1);
    }
    
    strcpy(result, str1);
    strcat(result, str2);
    
    return result;
}

void glSwapBuffers() {
    #ifdef _arch_dreamcast
    glKosSwapBuffers();
    #else
    glutSwapBuffers();
    #endif
}

void glInit(int* pargc, char** argv) {
    #ifdef _arch_dreamcast
    glKosInit(pargc, argv);
    #else
    glutInit(pargc, argv);
    glutInitDisplayMode(GLUT_DOUBLE | GLUT_RGB | GLUT_DEPTH);
    glutInitWindowSize(640, 480);
    glutCreateWindow("JSRF-dc");
    #endif
}

void playMusic() {

}

void playEffect() {
    
}