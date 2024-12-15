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
        --[[
        draw2Dtexture("epilogue_1.png")
        local startTime = os.clock() -- Get the current time
        while os.clock() - startTime < 0.29 do
            coroutine.yield() -- Wait for 2 seconds
        end
        stopDraw2Dtexture()
        startTime = os.clock() -- Get the current time
        draw2Dtexture("epilogue_4.png")
        while os.clock() - startTime < 0.29 do
            coroutine.yield() -- Wait for 2 seconds
        end
        stopDraw2Dtexture()
        startTime = os.clock() -- Get the current time
        draw2Dtexture("epilogue_5.png")
        while os.clock() - startTime < 0.29 do
            coroutine.yield() -- Wait for 2 seconds
        end
        stopDraw2Dtexture()
        startTime = os.clock() -- Get the current time
        draw2Dtexture("epilogue_7.png")
        while os.clock() - startTime < 0.29 do
            coroutine.yield() -- Wait for 2 seconds
        end
        stopDraw2Dtexture()
        startTime = os.clock() -- Get the current time
        draw2Dtexture("epilogue_8.png")
        while os.clock() - startTime < 0.29 do
            coroutine.yield() -- Wait for 2 seconds
        end
        stopDraw2Dtexture()
        startTime = os.clock() -- Get the current time
        draw2Dtexture("epilogue_6.png")
        while os.clock() - startTime < 0.29 do
            coroutine.yield() -- Wait for 2 seconds
        end
        stopDraw2Dtexture()
        draw2Dtexture("epilogue_1.png")
        local startTime = os.clock() -- Get the current time
        while os.clock() - startTime < 0.29 do
            coroutine.yield() -- Wait for 2 seconds
        end
        stopDraw2Dtexture()
        startTime = os.clock() -- Get the current time
        draw2Dtexture("epilogue_2.png")
        while os.clock() - startTime < 0.29 do
            coroutine.yield() -- Wait for 2 seconds
        end
        -- Draw the texture and wait for 2 seconds
        startTime = os.clock() -- Get the current time
        draw2Dtexture("epilogue_3.png")
        while os.clock() - startTime < 0.29 do
            coroutine.yield() -- Wait for 2 seconds
        end]]--
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
        draw2Dtexture("background_city_2.png")
        dialogBox("Announcer", {"We will continue our coverage of the public release of Paradigm X as the story unfolds..."}, "", -1, {""}, 0)
        while isDialogExecuted() do
            coroutine.yield()
        end
        dialogBox("Hitomi", {"Hey, how about here...?"}, "hitomi_normal.png", -1, {""}, 1)
        while isDialogExecuted() do       
            coroutine.yield()
        end
        stopDraw2Dtexture()
        draw2Dcharacter("hitomi_staying_texture.png", getScreenWidth() /2 - 100, getScreenHeight()/2 - 100, 5.0)
        draw2Dtexture("background_city_1.png")
        dialogBox("Hitomi", {"You're a member of a great hacker group, The Spookies. You should to be able to pull this off, at least.", "See? It's deserted around this terminal. Its the perfect place to do a little remote hacking, don't you think?", "What do you say?"}, "hitomi_normal.png", 2, {"We'll do it here.", "We're really doing this?"}, 1)
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
        playVideo("res/videos/movie003.mp4")
        stopDraw2Dtexture()
        stopDraw2Dcharacter()
        draw2Dtexture("background_city_3.png")
        dialogBox("Hitomi", {"So, this is the list of lucky winners who are getting into the beta..."}, "hitomi_normal.png", -1, {""}, 1)
        while isDialogExecuted() do
            coroutine.yield()
        end
        dialogBox("System", {"Password accepted. Re-registering Paradigm X beta entry."}, "", -1, {""}, 1)
        while isDialogExecuted() do
            coroutine.yield()
        end
        stopDraw2Dcharacter()
        draw2Dtexture("background_city_1.png")
        draw2Dcharacter("hitomi_staying_texture.png", getScreenWidth() /2 - 100, getScreenHeight()/2 - 100, 5.0)
        dialogBox("Hitomi", {"Huh? Did it work? One you're on the list, the license should be sent to your home email..."}, "hitomi_sad.png", -1, {""}, 1)
        while isDialogExecuted() do
            coroutine.yield()
        end
        dialogBox("Hitomi", {"Wait, hold on. There's still something on screen..."}, "hitomi_sad.png", -1, {""}, 1)
        while isDialogExecuted() do
            coroutine.yield()
        end
        stopDraw2Dcharacter()
        stopDraw2Dtexture()
        stopMusic()
        loadMusic("redman.mp3")
        playMusic()
        draw2Dtexture("background_city_3.png")
        dialogBox("???", {"...Bearer of strong soul... We meet at last..."}, "", -1, {""}, 1)
        while isDialogExecuted() do
            coroutine.yield()
        end
        dialogBox("Hitomi", {"Huh? Who's this? This guys know you? What's going on?"}, "hitomi_sad.png", -1, {""}, 1)
        while isDialogExecuted() do
            coroutine.yield()
        end
        dialogBox("???", {"My name is Kinap. You are in danger. Leave now. The authorities are on their way."}, "", -1, {""}, 1)
        while isDialogExecuted() do
            coroutine.yield()
        end
        dialogBox("Hitomi", {"\"Kinap...\"?", "Hey, do you know him?"}, "hitomi_sad.png", 1, {"It must be a prank.", "No."}, 1)
        while isDialogExecuted() do
            coroutine.yield()
        end
        dialogBox("Kinap", {"I cannot speak much now, but remember this: i will appear before you again..."}, "", -1, {""}, 1)
        while isDialogExecuted() do
            coroutine.yield()
        end
        stopDraw2Dtexture()
        draw2Dtexture("background_city_1.png")
        draw2Dcharacter("hitomi_staying_texture.png", getScreenWidth() /2 - 100, getScreenHeight()/2 - 100, 5.0)
        dialogBox("Hitomi", {"Who was that? He knew your name. That's weird, huh?"}, "hitomi_sad.png", -1, {""}, 1)
        while isDialogExecuted() do
            coroutine.yield()
        end
        dialogBox("Hitomi", {"Ah! Oh... Geez... That's just your phone."}, "hitomi_surpised.png", -1, {""}, 1)
        while isDialogExecuted() do
            coroutine.yield()
        end
        dialogBox("Phone", {"Hi, brother! It's me, Tomoko! I have big news!", "It's...... Heehee. It's big! Hurry up and come home! Hurry!"}, "", -1, {""}, 1)
        while isDialogExecuted() do
            coroutine.yield()
        end
        dialogBox("Hitomi", {"Oh, was that Tomoko?", "It was, wasn't it?"}, "hitomi_normal.png", 1, {"That's right.", "No, it wasn't."}, 1)
        while isDialogExecuted() do
            coroutine.yield()
            answerValue = getAnswerValue()
        end
        if answerValue == 1 then
            dialogBox("Hitomi", {"Nice try. I heard her voice from here. She sure sounded happy, though."}, "hitomi_normal.png", -1, {""}, 1)
            while isDialogExecuted() do
                coroutine.yield()
            end 
        end
        dialogBox("Hitomi", {"Well... I wonder if your hack's taken effect yet. Let's get back to your house."}, "hitomi_normal.png", -1, {""}, 1)
        while isDialogExecuted() do
            coroutine.yield()
        end
        stopDraw2Dtexture()
        stopDraw2Dcharacter()
        stopMusic()
        loadMusic("default.mp3")
        playMusic()
        draw2Dtexture("house_mc_hall.png")
        draw2Dcharacter("dad_normal.png", getScreenWidth() /2 - 150, getScreenHeight()/2 - 50, 5.0)
        dialogBox("Dad", {"Hm? Ah, it's you. You're home."}, "dad_normal.png", -1, {""},0)
        while isDialogExecuted() do
            coroutine.yield()
        end
        dialogBox("#Dad", {"Your father. A hardworking salaryman and a loving dad. He likes new things."}, "dad_normal.png", -1, {""}, 0)
        while isDialogExecuted() do
            coroutine.yield()
        end
        dialogBox("Dad", {"Tomoko was looking for you earlier... Oh, speak of the devil."}, "dad_normal.png", -1, {""}, 0)
        while isDialogExecuted() do
            coroutine.yield()
        end
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
