local stepan = 1
local alexey = 2
local mc_name = "Arseniy"
previousDialogName = ""
local istalked
local stepa_dialog = {"testeef", "test2", "test3"}
local alesha_dialog = {"Hey, "..mc_name.."!\n", "What's going on? How are you?", "What're u doing at this strange place? and why we're all cubes?\n"}
function checkDialogStatus()
    if isDialogExecuted() then
        local dialogName = getDialogName()
        if dialogName == previousDialogName then
            return false, ""
        end
        if dialogName == "Alexey" then
            rotateCamera(180.0, 70.0)
            startCubeMove(stepan, 10.0, 0.0, 6.0, 0.8)
            alesha_dialog = {"debug test", "debug"}
            updateAlexeyDialog(alesha_dialog)
            if dialogAnswerValue() == 0 then
                stepa_dialog = {"miauef", "woofefef", "chik-chirik"}
                updateStepanDialog(stepa_dialog)
            else
                stepa_dialog = {"hui", "pizda"}
                updateStepanDialog(stepa_dialog)
            end
            istalked = true
        end
        if dialogName == "Stepan" then
            if istalked == true then
                rotateCamera(-360, 80.0)
            end
        end
        previousDialogName = dialogName
        return true, dialogName
    end
    return false, ""
end

function updateStepanDialog(dialog)
    updateCubeDialog("Stepan", dialog)
end

function updateAlexeyDialog(dialog)
    updateCubeDialog("Alexey", dialog)
end
-- addCube(coorX, coorY, coorZ, "Name", dialog_massive, emotion, choice page)
loadMusic("res/default.mp3")
playMusic()
loadLocation("res/area1.glb", "res/test.png")
dialogBox(mc_name, {"testing", "debug"}, 0, 1)
dialogBox("debug", {"meow"}, 0, 1)
print(dialogAnswerValue())
addCube(0.0, 0.0, 0.0, "Stepan", stepa_dialog, 1, 1)
addCube(2.0, 0.0, 4.0, "Alexey", alesha_dialog, 1, 1)
startCubeMove(alexey, 5.0, 0.0, 4.0, 0.8)
startCubeMove(alexey, 2.0, 0.0, 6.0, 0.8)
rotateCamera(180, 80.0)