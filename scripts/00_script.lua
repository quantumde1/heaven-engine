
--[[ НАЧАЛО ОБЪЯВЛЕНИЯ ФУНКЦИЙ LUA ]]--


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

function sleep(seconds)
    local end_time = os.clock() + seconds
    while os.clock() < end_time do
        -- Busy-wait
    end
end

--[[ КОНЕЦ ОБЪЯВЛЕНИЯ ФУНКЦИЙ LUA ]]--


--[[ НАЧАЛО ОБЪЯВЛЕНИЙ ГЛОБАЛЬНЫХ ПЕРЕМЕННЫХ ]]--

local globalDialogForNPC1 = {""}
local globalDialogForNPC2 = {""}
local answerValue
local dialogCoroutine
previousDialogName = ""
local neededPosition = { 4.0, 0.0, 10.0 }
local currentStage = 0 -- Переменная для отслеживания текущего этапа

--[[ КОНЕЦ ОБЪЯВЛЕНИЯ ГЛОБАЛЬНЫХ ПЕРЕМЕННЫХ]]--


--[[ НАЧАЛО СИСТЕМНЫХ ФУНКЦИЙ ДВИЖКА ]]--


-- Загрузка музыки и локации
loadMusic("PublicFacility.mp3")
playMusic()
loadLocation("res/area1.glb", 19.0)

function startDialogCoroutine()
    dialogCoroutine = coroutine.create(function()
        rotateCamera(360, 130)
        startCubeRotation(1, 90, 80, 10)
        -- напишите сюда код, который будет инициализироваться сразу после входа в локацию. Пример:
        dialogBox("Yuki", {" Good job on the coverage. There's a letter for you, Maya. But there's no return address on it..."}, 0, -1, {""})
        --dialogBox("Alexey", {"Okay, i got it...", "You want problems - you will have it.", "I'm leaving your bullshit team. arividerchi!"}, 1, 2, {"Go fuck yourself", "Good luck."})
        while isDialogExecuted() do
            coroutine.yield() -- Ожидание завершения диалога
        end
        dialogBox("Maya", {"But there's no return address on it..."}, 0, 0, {"Thanks, Yukki!--", "Thanks. But who could it be from?"})
        while isDialogExecuted() do
            coroutine.yield() -- Ожидание завершения диалога
            answerValue = getAnswerValue()
        end
        ::answer_1::
        if answerValue == 0 then
            dialogBox("#Maya Amano", {"Editor of Kismet Publishing's teen Magazine, Coolest. The game's main character."}, 0, -1, {""})
            while isDialogExecuted() do
                coroutine.yield() -- Ожидание завершения диалога
            end
            rotateCamera(-90, 130)
            showHint("Go forward!")

        elseif answerValue == 1 then
            print("answer 1")
            dialogBox("Yuki", {" Yeah. No return address.", " Maybe, some your fan? xD"}, 0, -1, {""})
            while isDialogExecuted() do
                coroutine.yield()
            end
            answerValue = 0
            goto answer_1
        end
    end)
end

function checkDialogStatus()
    local cubePosition = { getPlayerX(), getPlayerY(), getPlayerZ() } -- Получение текущей позиции куба
    print(neededPosition[1], neededPosition[2], neededPosition[3])
    -- Проверка, достиг ли куб нужной позиции
    if currentStage == 0 and cubePosition[1] >= neededPosition[1] - 2 and cubePosition[1] <= neededPosition[1] + 2 and
       cubePosition[2] >= neededPosition[2] - 2 and cubePosition[2] <= neededPosition[2] + 2 and
       cubePosition[3] >= neededPosition[3] - 2 and cubePosition[3] <= neededPosition[3] + 2 then
            hideHint()
            dialogCoroutine = coroutine.create(function()
            dialogBox("#Letter", {"yOu'rE nEXt...\n\n\n\n\n\n\n\n\n                JOKER"}, 0, -1, {""})
            while isDialogExecuted() do
                coroutine.yield()
            end
            dialogBox("You", {" .........?"}, 0, -1, {""})
            while isDialogExecuted() do
                coroutine.yield()
            end
            startCubeMove(2, getPlayerX()+4, getPlayerY(), getPlayerZ(), 0.9)
            startCubeRotation(2, 270, 80, 10)
            rotateCamera(-180.0, 130)
            dialogBox("Rookie Reporter", {"Miss Amano, the chief wants to see you.", "It must be rough, always getting the difficult jobs...", "Even if I work hard, it does no good. Dreams and reality are such...(sigh) Maybe I should just quit."}, 0, -1, {""})
            while isDialogExecuted() do
                coroutine.yield()
            end
            dialogBox("You", {" Everything will be OK. Don't worry about it!"}, 0, -1, {""})
            while isDialogExecuted() do
                coroutine.yield()
            end
            showHint("Go forward!")
        end)
        neededPosition = { 8.0, 0.0, -10.0 } -- Сброс нужной позиции
        currentStage = 1 -- Переход к следующему этапу
    elseif currentStage == 1 and cubePosition[1] >= neededPosition[1] - 2 and cubePosition[1] <= neededPosition[1] + 2 and
           cubePosition[2] >= neededPosition[2] - 2 and cubePosition[2] <= neededPosition[2] + 2 and
           cubePosition[3] >= neededPosition[3] - 2 and cubePosition[3] <= neededPosition[3] + 2 then
        hideHint()
        dialogCoroutine = coroutine.create(function()
            startCubeRotation(3, 270, 80, 10)
            rotateCamera(-180.0, 130)
            dialogBox("Editor-in-Chief Mizuno", {"There you are...Amano."}, 0, -1, {""})
            while isDialogExecuted() do
                coroutine.yield()
            end
            dialogBox("#Editor-in-Chief Mizuno", {"Coolest's Editor-in-Chief who hates Maya. An experienced woman who goes by the book. 30-something and still not married."}, 0, -1, {""})
            while isDialogExecuted() do
                coroutine.yield()
            end
            startCubeRotation(3, 90, 80, 10)
            dialogBox("Editor-in-Chief Mizuno", {"You know why you were called in, right? That interview project you turned in...\"Dream of the Rumored Student\".. was crap.", "It's boring.\n\n\nIt has no impact.\n\n\nWho would want to read about a green brat?"}, 0, -1, {""})
            while isDialogExecuted() do
                coroutine.yield()
            end
            dialogBox("You", {" Who would want to read about a green brat?"}, 0, 0, {"Huh...?", "I thought it was important."})
            startCubeRotation(3, 270, 80, 10)
            while isDialogExecuted() do
                coroutine.yield()
                answerValue = getAnswerValue()
            end
            if answerValue == 0 then
                dialogBox("Editor-in-Chief Mizuno", {"That's a half hearted answer...It doesn't matter anyway.", "The kids are saying that the recent series of murders are the work of the Joker."}, 0, -1, {""})
                while isDialogExecuted() do
                    coroutine.yield()
                end
            elseif answerValue == 1 then
                dialogBox("Editor-in-Chief Mizuno", {"Are you arguing with me?! If you like your job, you better get started on Joker story!", "You know the rumors the kids are telling about how the recent series of bizzare murders are the work of the Joker, right?"}, 0, -1, {""})
                while isDialogExecuted() do
                    coroutine.yield()
                end
            end
            dialogBox("Editor-in-Chief Mizuno", {"Get your ass over to Seven Sisters High and get the scoop. I'm taking Mayuzumi off this case, so you'll be on your own."}, 0, -1, {""})
            while isDialogExecuted() do
                coroutine.yield()
            end
            startCubeRotation(3, 90, 80, 10)
            dialogBox("Editor-in-Chief Mizuno", {"Oh, by the way, you can just forget about this afternoon...the time off you asked for... ", "If you don't like it, I've got plenty of other reporters that would love to take your spot. So what are you waiting for?"}, 0, -1, {""})
            while isDialogExecuted() do
                coroutine.yield()
            end
        end)
        -- Здесь можно добавить дополнительную логику для нового этапа
        currentStage = 2 -- Переход к следующему этапу, если необходимо
    end

    if isDialogExecuted() then -- проверка инициализации диалога
        local dialogName = getDialogName() -- Получение имени NPC
        if dialogName == previousDialogName then
            return false, "" -- Если диалог не изменился, возвращаем false и показываем что-то другое, либо не показываем ничего
        end
    end
    return false, "" -- Если диалог не выполняется, возвращаем false
end

-- Функция для обновления диалога
function updateDialog()
    if dialogCoroutine and coroutine.status(dialogCoroutine) ~= "dead" then
        coroutine.resume(dialogCoroutine) -- Возобновление выполнения корутины
    end
end

--[[ КОНЕЦ СИСТЕМНЫХ ФУНКЦИЙ ДВИЖКА ]]--


--[[ НАЧАЛО ФУНКЦИЙ ОБЪЯВЛЕНИЯ ОСНОВНЫХ КОМПОНЕНТОВ ]]--

-- Установка безопасной зоны
setFriendlyZone(1)
-- Установка модели игрока
setPlayerModel("res/mc.glb", 3.0)
-- Настройка позиции камеры
changeCameraPosition(0.0, 10.0, 10.0)
changeCameraTarget(0.0, 4.0, 0.0)
changeCameraUp(0.0, 1.0, 0.0)

-- Добавление кубов
addCube(-6.0, 0.0, 0.0, "Yuki", globalDialogForNPC1, 1, -1)
addCube(15.0, 0.0, 10.0, "Rookie Reporter", globalDialogForNPC2, 1, -1)
addCube(14.0, 0.0, -10.0, "Editor-in-Chief Mizuno", globalDialogForNPC2, 1, -1)
howMuchModels(3) -- Установка количества моделей в сцене

-- Установка модели кубов для Сергея и Алексея
setCubeModel(1, "res/mc.glb", 3.0) -- Установка модели для куба NPC no.1
setCubeModel(2, "res/mc.glb", 3.0) -- Установка модели для куба NPC no.2
setCubeModel(3, "res/mc.glb", 3.0) -- Установка модели для куба NPC no.3
startDialogCoroutine()

--[[ КОНЕЦ ФУНКЦИЙ ОБЪЯВЛЕНИЯ ОСНОВНЫХ КОМПОНЕНТОВ ]]--