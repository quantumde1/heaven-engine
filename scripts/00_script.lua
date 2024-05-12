loadMusic("res/2test.mp3")
playMusic()
local stepan = 1
local alexey = 2
addCube(0.0, 0.0, 0.0, "stepan", {"меня зовут степа", "мне три годика", "живу в городе москва"}, 1)
addCube(2.0, 0.0, 4.0, "alexey", {"а меня леша", "мне 33 годика", "живу в мухосранске в однокомнатной квартире с бабушкой"}, 1)
startCubeMove(alexey, 5.0, 0.0, 4.0, 0.8)
startCubeMove(alexey, 2.0, 0.0, 6.0, 0.8)