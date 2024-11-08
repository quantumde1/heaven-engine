local sergey = 1
local alexey = 2
local mc_name = "Arseniy"
previousDialogName = ""
local istalked

local sergey_dialog = {
    "What the hell is going on here?...",
    "What these demons doing here?! Where are they from?",
    "I'm pretty scared guys...",
    "1234567890-+=_!@#$%^&()[], testing \n\n\nfont and UI"
}
local alexey_dialog = {
    "I don't know what's going on, but we must get rid of these shit in our city...",
    "I guess we will be going to this factory again tomorrow.",
    "Are you guys with me?"
}

local sergey_dialog_ok = {
    "What the fuck are you two fucking doing about...",
    "But this sounds funny. I going with you two!"
}

local sergey_dialog_bad = {
    "You're two fucking idiots.",
    "What we must do now?!"
}

local neededPosition = { 10.0, 0.0, 10.0 }

function tablesEqual(table1, table2)
    if #table1 ~= #table2 then
        return false
    end
    for i = 1, #table1 do
        if table1[i] ~= table2[i] then
            return false
        end
    end
    return true
end

function checkDialogStatus()
    local cubePosition = { getCubeX(), getCubeY(), getCubeZ()}
    
    if tablesEqual(cubePosition, neededPosition) and tablesEqual(neededPosition, { 10.0, 0.0, 10.0}) then
        rotateCamera(90.0, 130.0)
        addCube(10.0, 0.0, 7.0, "Text", {""}, 1, -1)
        howMuchModels(3);
        setCubeModel(3, "res/mc.glb")
        dialogBox("Text", {"Oh shit. How you find me?", "Go ahead, please. I dont wanna see you."}, 1, -1, {""})
        neededPosition = { }
    end

    if isDialogExecuted() then
        local dialogName = getDialogName()
        if dialogName == previousDialogName then
            return false, ""
        end
        if dialogName == "Sergey" then
            updateCubeDialog("Sergey", sergey_dialog)
            startCubeRotation(sergey, 90, 80, 10)
            istalked = true
        end
        if dialogName == "Alexey" and istalked == true then
            updateCubeDialog("Alexey", alexey_dialog)
            rotateCamera(180.0, 130.0)
            startCubeMove(alexey, 3.0, 0.0, 0.0, 0.8)
            startCubeRotation(alexey, 270, 80, 10)
        end
        previousDialogName = dialogName
        return true, dialogName
    end
    return false, ""
end

-- Load music and location
loadMusic("default.mp3")
playMusic()
loadLocation("res/area1.glb")

-- Create coroutine for managing dialogs
local dialogCoroutine
local answerValue
local battleRunning
local cubeMoving

function startDialogCoroutine()
    dialogCoroutine = coroutine.create(function()
        
        dialogBox("Sergey", sergey_dialog, 1, 3, {"Testing", "debug answer"})
        while isDialogExecuted() do
            coroutine.yield() -- Wait for dialog to finish
        end

        rotateCamera(180.0, 130.0)
        dialogBox("Alexey", alexey_dialog, 1, 2, {"Yes, i think so too...", "No, you're fucking freak!"})
        while isDialogExecuted() do
            coroutine.yield() -- Wait for dialog to finish
            answerValue = getAnswerValue() -- Call the function to get the answer value    
        end
        if answerValue == 0 then
            dialogBox("Alexey", {"Okay, so, let's go and see what the hell is going on there..."}, 1, 1, {""})
            while isDialogExecuted() do
                coroutine.yield() -- Wait for dialog to finish
            end
        end
        if answerValue == 1 then
            dialogBox("Alexey", {"So, u think will be better to sit and do nothing?!", "You are an idiot! Come here, i will show you some lessons of good manners!"}, 1,1, {""})
            while isDialogExecuted() do
                coroutine.yield()
            end
            initBattle(1,1)
            while getBattleStatus() do
                coroutine.yield()
                battleRunning = getBattleStatus()
            end
            if battleRunning == false then
                dialogBox("Alexey", {"Okay, i got it...", "You want problems - you will have it.", "I'm leaving your bullshit team. arividerchi!"}, 1,2,{"Go fuck yourself", "Good luck."})
                while isDialogExecuted() do
                    coroutine.yield()
                end
                startCubeRotation(alexey, 270, 80, 10)
                startCubeMove(alexey, 10.0, 0.0, 10.0, 0.9)
                startCubeRotation(alexey, 45, 80, 10)
                while isCubeMoving() do
                    coroutine.yield()
                    cubeMoving = isCubeMoving()
                end
                if cubeMoving == false then
                    removeCubeModel(alexey)
                    removeCube("Alexey")
                    updateCubeDialog("Sergey", sergey_dialog_bad)
                end
            end
        end
    end)
end

function updateDialog()
    if dialogCoroutine and coroutine.status(dialogCoroutine) ~= "dead" then
        coroutine.resume(dialogCoroutine) -- Resume coroutine execution
    end
end

setPlayerModel("res/mc.glb")
changeCameraPosition(0.0, 10.0, 10.0)
changeCameraTarget(0.0, 4.0, 0.0)
changeCameraUp(0.0, 1.0, 0.0)
-- Add cubes for Sergey and Alexey
addCube(-3.0, 0.0, 0.0, "Sergey", {""}, 1, -1)
addCube(2.0, 0.0, 4.0, "Alexey", {""}, 1, -1)
howMuchModels(2);
setCubeModel(sergey, "res/mc.glb")
setCubeModel(alexey, "res/mc.glb")
-- Start the dialog coroutine
startDialogCoroutine()