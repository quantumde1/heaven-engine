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
loadLocation("res/area1.glb", 19.0)

-- Создание корутины для управления диалогами
local dialogCoroutine
local answerValue
function startDialogCoroutine()
    dialogCoroutine = coroutine.create(function()
        -- Начало диалога с Сергеем
        loadMusic("prologue_1.mp3")
        hideUI()
        playMusic()
        stopDraw2Dtexture()
        startTime = os.clock() -- Get the current time
        draw2Dtexture("epilogue_4.png")
        while os.clock() - startTime < 0.25 do
            coroutine.yield() -- Wait for 2 seconds
        end
        stopDraw2Dtexture()
        startTime = os.clock() -- Get the current time
        draw2Dtexture("epilogue_5.png")
        while os.clock() - startTime < 0.25 do
            coroutine.yield() -- Wait for 2 seconds
        end
        stopDraw2Dtexture()
        startTime = os.clock() -- Get the current time
        draw2Dtexture("epilogue_7.png")
        while os.clock() - startTime < 0.25 do
            coroutine.yield() -- Wait for 2 seconds
        end
        stopDraw2Dtexture()
        startTime = os.clock() -- Get the current time
        draw2Dtexture("epilogue_8.png")
        while os.clock() - startTime < 0.25 do
            coroutine.yield() -- Wait for 2 seconds
        end
        stopDraw2Dtexture()
        startTime = os.clock() -- Get the current time
        draw2Dtexture("epilogue_6.png")
        while os.clock() - startTime < 0.25 do
            coroutine.yield() -- Wait for 2 seconds
        end
        stopDraw2Dtexture()
        draw2Dtexture("epilogue_1.png")
        local startTime = os.clock() -- Get the current time
        while os.clock() - startTime < 0.25 do
            coroutine.yield() -- Wait for 2 seconds
        end
        stopDraw2Dtexture()
        startTime = os.clock() -- Get the current time
        draw2Dtexture("epilogue_2.png")
        while os.clock() - startTime < 0.25 do
            coroutine.yield() -- Wait for 2 seconds
        end
        -- Draw the texture and wait for 2 seconds
        startTime = os.clock() -- Get the current time
        draw2Dtexture("epilogue_3.png")
        while os.clock() - startTime < 0.25 do
            coroutine.yield() -- Wait for 2 seconds
        end
        draw2Dtexture("background_news_paradigm_x.png")
        dialogBox("Announcer", {
            "Our next story tonight concerns the upcoming virtual city, \"Paradigm X\"",
            "While its public opening is coming soon, creator Algon Software is reportedly being flooded with beta applications.",
            "The number of users is so great that the company is unable to shut down the site for new user registrations."
        }, "news_reporter.png", -1, {""}, 0)

        while isDialogExecuted() do
            coroutine.yield() -- Ожидание завершения диалога
        end
        stopDraw2Dtexture()
        draw2Dtexture("background_city_1.png")
        dialogBox("Announcer", {"We will continue our coverage of the public release of Paradigm X as the story unfolds..."}, "", -1, {""}, 0)
        while isDialogExecuted() do
            coroutine.yield()
        end
        draw2Dcharacter("hitomi_staying_texture.png", getScreenWidth() /2 - 100, getScreenHeight()/2 - 100, 5.0)
        dialogBox("Hitomi", {"Hey, how about here...?", "You're a member of a great hacker group, The Spookies. You should to be able to pull this off, at least.", "See? It's deserted around this terminal. Its the perfect place to do a little remote hacking, don't you think?", "What do you say?"}, "hitomi_normal.png", 3, {"We'll do it here.", "We're really doing this?"}, 1)
        while isDialogExecuted() do       
            coroutine.yield()
            answerValue = getAnswerValue()
        end
        if answerValue == 1 then
            dialogBox("Hitomi", {"We can't rely on luck to get us into the Paradigm X beta. I doubt we'd win that lottery...", "Come on, please?"}, "hitomi_normal.png", 1, {"I'll give it a shot.", "I guess so..."}, 1)
            while isDialogExecuted() do
                coroutine.yield()
                answerValue = getAnswerValue()
            end
            dialogBox("Hitomi", {"Haha, thanks."}, "hitomi_normal.png", -1, {""}, 1)
            while isDialogExecuted() do
                coroutine.yield()
            end
        end
        dialogBox("Hitomi", {"Leader already found where the list of winners is kept on their server, so just overwrite one of the names there."}, "hitomi_normal.png", -1, {""}, 1)
        while isDialogExecuted() do
            coroutine.yield()
        end
        playVideo("res/movie003.mp4")
    end)
end

-- Функция для проверки статуса диалога
function checkDialogStatus()
    -- Implement any necessary checks for dialog status here
end

-- Функция для обновления диалога
function updateDialog()
    if dialogCoroutine and coroutine.status(dialogCoroutine) ~= "dead" then
        coroutine.resume(dialogCoroutine) -- Возобновление выполнения корутины
    end
end

-- Настройка позиции камеры
changeCameraPosition(0.0, 5.0, 0.1)
changeCameraTarget(0.0, 5.0, 0.0)
changeCameraUp(0.0, 1.0, 0.0)
drawPlayerModel(0)
dungeonCrawlerMode(1)

-- Запуск корутины диалога
startDialogCoroutine()

-- В основном цикле игры, не забудьте вызывать updateDialog()
