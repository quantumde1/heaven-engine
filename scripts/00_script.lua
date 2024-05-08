local function addAndDrawCube(x, y, z, name, message, size)
    addCube(x+0.5, y+0.5, z+0.5, name, message, size)
end

loadMusic("res/2test.mp3")
playMusic()
addAndDrawCube(0.0, 0.0, 0.0, "michel", "testing debugs", 5)
addAndDrawCube(4.0, 0.0, 4.0, "furher", "second debug test", 5)