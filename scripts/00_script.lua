-- Инициализация переменных
local sergey = 1
local alexey = 2
local mc_name = "Arseniy"
previousDialogName = ""
local istalked
local bad

-- Диалоги для Сергея и Алексея
local sergey_dialog = {
    "What the hell is going on here?...",
    "What these demons doing here?! Where are they from?",
    "I'm pretty scared guys...",
    "1234567890-+=_!@#$%^&()[], testing font and UI"
}
local alexey_dialog = {
    "I don't know what's going on, but we must get rid of these shit in our city...",
    "I guess we will be going to this factory again tomorrow.",
    "Are you guys with me?"
}

-- Диалоги для Сергея в зависимости от выбора игрока
local sergey_dialog_ok = {
    "What the fuck are you two fucking doing about...",
    "But this sounds funny. I going with you two!"
}

local sergey_dialog_bad = {
    "You're two fucking idiots.",
    "What we must do now?!"
}

-- Позиция, необходимая для триггера диалога
local neededPosition = { 10.0, 0.0, 10.0 }

-- Функция для сравнения двух таблиц
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

-- Загрузка музыки и локации
loadMusic("default.mp3")
playMusic()
loadLocation("res/area1.glb", 19.0)

-- Создание корутины для управления диалогами
local dialogCoroutine
local answerValue
local battleRunning
local cubeMoving

function startDialogCoroutine()
    dialogCoroutine = coroutine.create(function()
        -- Начало диалога с Сергеем
        dialogBox("Sergey", sergey_dialog, 1, 3, {"Testing", "debug answer"})
        while isDialogExecuted() do
            coroutine.yield() -- Ожидание завершения диалога
        end

        -- Поворот камеры
        rotateCamera(180.0, 130.0)
        -- Диалог с Алексеем
        dialogBox("Alexey", alexey_dialog, 1, 2, {"Yes, i think so too...", "No, you're fucking freak!"})
        while isDialogExecuted() do
            coroutine.yield() -- Ожидание завершения диалога
            answerValue = getAnswerValue() -- Получение значения ответа игрока    
        end
        -- Обработка ответа игрока
        if answerValue == 0 then
            dialogBox("Alexey", {"Okay, so, let's go and see what the hell is going on there..."}, 1, 1, {""})
            while isDialogExecuted() do
                coroutine.yield() -- Ожидание завершения диалога
            end
        elseif answerValue == 1 then
            dialogBox("Alexey", {"So, u think will be better to sit and do nothing?!", "You are an idiot! Come here, i will show you some lessons of good manners!"}, 1, 1, {""})
            while isDialogExecuted() do
                coroutine.yield()
            end
            -- Инициация боя
            initBattle(1, 1, "Alexey", "Our talk already ended!")
            while getBattleStatus() do
                coroutine.yield()
                battleRunning = getBattleStatus()
            end
            if not battleRunning then
                dialogBox("Alexey", {"Okay, i got it...", "You want problems - you will have it.", "I'm leaving your bullshit team. arividerchi!"}, 1, 2, {"Go fuck yourself", "Good luck."})
                while isDialogExecuted() do
                    coroutine.yield()
                    answerValue = getAnswerValue() -- Получение значения ответа игрока 
                end
                -- Движение и вращение куба Алексея
                startCubeRotation(alexey, 270, 80, 10)
                startCubeMove(alexey, 10.0, 0.0, 10.0, 0.9)
                startCubeRotation(alexey, 45, 80, 10)
                while isCubeMoving() do
                    coroutine.yield()
                    cubeMoving = isCubeMoving() -- Проверка, движется ли куб
                end
                if not cubeMoving then
                    if answerValue == 0 then
                        playVideo("res/ending.mp4") -- Воспроизведение видео, если игрок выбрал первый ответ
                    end
                    removeCubeModel(alexey) -- Удаление модели куба Алексея
                    removeCube("Alexey") -- Удаление куба Алексея из игры
                    updateCubeDialog("Sergey", sergey_dialog_bad) -- Обновление диалога Сергея на негативный
                    bad = true -- Установка флага, что ситуация плохая
                    setFriendlyZone(1) -- Установка зоны дружбы
                    showHint("Go to Sergey")
                end
            end
        end
    end)
end

-- Функция для проверки статуса диалога
function checkDialogStatus()
    local cubePosition = { getPlayerX(), getPlayerY(), getPlayerZ() } -- Получение текущей позиции куба
    
    -- Проверка, достиг ли куб нужной позиции
    if tablesEqual(cubePosition, neededPosition) then
        rotateCamera(90.0, 130.0) -- Поворот камеры
        dialogBox("Text", {"Oh shit. How you find me?", "Go ahead, please. I dont wanna see you."}, 1, -1, {""})
        neededPosition = { } -- Сброс нужной позиции
    end

    -- Проверка, выполняется ли диалог
    if isDialogExecuted() then
        local dialogName = getDialogName() -- Получение имени текущего диалога
        if dialogName == previousDialogName then
            return false, "" -- Если диалог не изменился, возвращаем false
        end
        if dialogName == "Sergey" then
            startCubeRotation(sergey, 90, 80, 10) -- Вращение куба Сергея
            istalked = true -- Установка флага, что с Сергеем поговорили
        end
        if dialogName == "Alexey" and istalked == true then
            updateCubeDialog("Alexey", alexey_dialog) -- Обновление диалога Алексея
            rotateCamera(180.0, 130.0) -- Поворот камеры
            startCubeMove(alexey, 6.0, 0.0, 0.0, 0.8) -- Движение куба Алексея
            startCubeRotation(alexey, 270, 80, 10) -- Вращение куба Алексея
        end
        if bad == true then
            -- Создание новой корутины для негативного диалога Сергея
            dialogCoroutine = coroutine.create(function()
                hideHint()
                rotateCamera(360, 130)
                dialogBox("Sergey", {"what must we do now?! Do you know? Ah shit. Things goes as much bad as only this can be!", "If not you two, maybe..."}, 1, 1, {"I know, im sorry.", "..nothing changed, you're an idiot!"})
                while isDialogExecuted() do
                    coroutine.yield() -- Ожидание завершения диалога
                    answerValue = getAnswerValue() -- Получение значения ответа игрока
                end
                if answerValue == 0 then
                    dialogBox("Sergey", {"Argh... Okay, lets go, maybe further will be better?"}, 1, -1, {""})
                    while isDialogExecuted() do
                        coroutine.yield() -- Ожидание завершения диалога
                    end
                elseif answerValue == 1 then
                    dialogBox("Sergey", {"Are you SO stupid?!", "I cannot go with you anymore.", "Fuck you and your girlfriend, two fucking freaks! I'm leaving. Fuck yourself you two!"}, 1, -1, {""})
                    while isDialogExecuted() do
                        coroutine.yield() -- Ожидание завершения диалога
                    end
                    removeCubeModel(sergey) -- Удаление модели куба Сергея
                    removeCube("Sergey") -- Удаление куба Сергея из игры
                    
                end
            end)
        end
        
        previousDialogName = dialogName -- Обновление имени предыдущего диалога
        return true, dialogName -- Возвращение статуса диалога
    end
    return false, "" -- Если диалог не выполняется, возвращаем false
end

-- Функция для обновления диалога
function updateDialog()
    if dialogCoroutine and coroutine.status(dialogCoroutine) ~= "dead" then
        coroutine.resume(dialogCoroutine) -- Возобновление выполнения корутины
    end
end

-- Установка модели игрока
setPlayerModel("res/mc.glb", 3.0)
-- Настройка позиции камеры
changeCameraPosition(0.0, 5.0, 0.1)
changeCameraTarget(0.0, 5.0, 0.0)
changeCameraUp(0.0, 1.0, 0.0)
drawPlayerModel(0);
-- Добавление кубов для Сергея и Алексея
addCube(-6.0, 0.0, 0.0, "Sergey", {""}, 1, -1) -- Добавление куба Сергея
updateCubeDialog("Sergey", sergey_dialog) -- Обновление диалога для Сергея
addCube(2.0, 0.0, 4.0, "Alexey", {""}, 1, -1) -- Добавление куба Алексея
howMuchModels(2) -- Установка количества моделей в сцене

-- Установка модели кубов для Сергея и Алексея
setCubeModel(sergey, "res/mc.glb", 3.0) -- Установка модели для куба Сергея
setCubeModel(alexey, "res/mc.glb", 3.0) -- Установка модели для куба Алексея

-- Запуск корутины диалога
startDialogCoroutine()