#pragma once

#include <raylib.h>

void displayDialog(char** pages, int pagesLength, int choicePage, Font dialogFont, bool* showDialog, float textSpeed);
void drawSnakeAnimation(int rectX, int rectY, int rectWidth, int rectHeight);