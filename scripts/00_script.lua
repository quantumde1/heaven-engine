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
        dialogBox("Announcer", {"We will continue our coverage of the public release of Paradigm X as the story unfolds..."}, "empty", -1, {""}, 0)
        while isDialogExecuted() do
            coroutine.yield()
        end
        dialogBox("Hitomi", {"Hey, how about here...?"}, "hitomi_normal.png", -1, {""}, 1)
        while isDialogExecuted() do       
            coroutine.yield()
        end
        stopDraw2Dtexture()
        draw2Dcharacter("hitomi_staying_texture.png", getScreenWidth() /2 - 100, getScreenHeight()/2 - 100, 5.0, 0)
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
        stopDraw2Dcharacter(0)
        draw2Dtexture("background_city_3.png")
        dialogBox("Hitomi", {"So, this is the list of lucky winners who are getting into the beta..."}, "hitomi_normal.png", -1, {""}, 1)
        while isDialogExecuted() do
            coroutine.yield()
        end
        dialogBox("System", {"Password accepted. Re-registering Paradigm X beta entry."}, "", -1, {""}, 1)
        while isDialogExecuted() do
            coroutine.yield()
        end
        draw2Dtexture("background_city_1.png")
        draw2Dcharacter("hitomi_staying_texture.png", getScreenWidth() /2 - 100, getScreenHeight()/2 - 100, 5.0, 0)
        dialogBox("Hitomi", {"Huh? Did it work? One you're on the list, the license should be sent to your home email..."}, "hitomi_sad.png", -1, {""}, 1)
        while isDialogExecuted() do
            coroutine.yield()
        end
        dialogBox("Hitomi", {"Wait, hold on. There's still something on screen..."}, "hitomi_sad.png", -1, {""}, 1)
        while isDialogExecuted() do
            coroutine.yield()
        end
        stopDraw2Dcharacter(0)
        stopDraw2Dtexture()
        stopMusic()
        loadMusic("redman.mp3")
        playMusic()
        draw2Dtexture("background_city_3.png")
        dialogBox("???", {"...Bearer of strong soul... We meet at last..."}, "empty", -1, {""}, 1)
        while isDialogExecuted() do
            coroutine.yield()
        end
        dialogBox("Hitomi", {"Huh? Who's this? This guys know you? What's going on?"}, "hitomi_sad.png", -1, {""}, 1)
        while isDialogExecuted() do
            coroutine.yield()
        end
        dialogBox("???", {"My name is Kinap. You are in danger. Leave now. The authorities are on their way."}, "empty", -1, {""}, 1)
        while isDialogExecuted() do
            coroutine.yield()
        end
        dialogBox("Hitomi", {"\"Kinap...\"?", "Hey, do you know him?"}, "hitomi_sad.png", 1, {"It must be a prank.", "No."}, 1)
        while isDialogExecuted() do
            coroutine.yield()
        end
        dialogBox("Kinap", {"I cannot speak much now, but remember this: i will appear before you again..."}, "empty", -1, {""}, 1)
        while isDialogExecuted() do
            coroutine.yield()
        end
        stopDraw2Dtexture(0)
        draw2Dtexture("background_city_1.png")
        draw2Dcharacter("hitomi_staying_texture.png", getScreenWidth() /2 - 100, getScreenHeight()/2 - 100, 5.0, 0)
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
        stopDraw2Dcharacter(0)
        stopMusic()
        loadMusic("default.mp3")
        playMusic()
        draw2Dtexture("house_mc_hall.png")
        draw2Dcharacter("dad_normal.png", getScreenWidth() /2 - 150, getScreenHeight()/2 - 50, 5.0, 0)
        dialogBox("Father", {"Hm? Ah, it's you. You're home."}, "dad_normal.png", -1, {""},0)
        while isDialogExecuted() do
            coroutine.yield()
        end
        dialogBox("#Father", {"Your father. A hardworking salaryman and a loving dad. He likes new things."}, "dad_normal.png", -1, {""}, 0)
        while isDialogExecuted() do
            coroutine.yield()
        end
        dialogBox("Father", {"Tomoko was looking for you earlier... Oh, speak of the devil."}, "dad_normal.png", -1, {""}, 0)
        while isDialogExecuted() do
            coroutine.yield()
        end
        local startTime = os.clock() -- Get the current time
        while os.clock() - startTime < 0.07 do
            coroutine.yield() -- Wait for 2 seconds
        end
        draw2Dcharacter("tomoko_staying_texture.png", getScreenWidth()/2 - 250, getScreenHeight()/2 - 80, 5.0, 1)
        local startTime = os.clock() -- Get the current time
        while os.clock() - startTime < 0.3 do
            coroutine.yield() -- Wait for 2 seconds
        end
        dialogBox("Tomoko", {"Hey, brother!"}, "tomoko_normal.png", -1, {""}, 0)
        while isDialogExecuted() do
            coroutine.yield()
        end
        dialogBox("#Tomoko", {"Your little sister. A lively third-year in middle school."}, "tomoko_normal.png", -1, {""}, 0)
        while isDialogExecuted() do
            coroutine.yield()
        end
        dialogBox("Tomoko", {"Oh, Hitomi is here, too! Hello!"}, "tomoko_normal.png", -1, {""}, 0)
        while isDialogExecuted() do
            coroutine.yield()
        end
        dialogBox("Hitomi", {"It's been a while, Tomoko. You look happy. Did you get good news?"}, "hitomi_normal.png", -1, {""}, 1)
        while isDialogExecuted() do
            coroutine.yield()
        end
        dialogBox("Tomoko", {"Yeah! Was it obvious? Big, big news! Tah-dah!", "One of us is lucky enough to get into the Paradigm X beta test! Congrats!"}, "tomoko_normal.png", -1, {""}, 0)
        while isDialogExecuted() do
            coroutine.yield()
        end
        dialogBox("Father", {"Is that so? Nice! I didn't think you'd win that drawing, hahaha."}, "dad_normal.png", -1, {""}, 0)
        while isDialogExecuted() do
            coroutine.yield()
        end
        local startTime = os.clock() -- Get the current time
        while os.clock() - startTime < 0.07 do
            coroutine.yield() -- Wait for 2 seconds
        end
        draw2Dcharacter("mother_staying_texture.png", getScreenWidth()/2 + 310, getScreenHeight()/2 - 80, 5.0, 2)
        local startTime = os.clock() -- Get the current time
        while os.clock() - startTime < 0.03 do
            coroutine.yield() -- Wait for 2 seconds
        end
        dialogBox("Mother", {"Oh, dear, you are such a child. You have to raise the kids better."}, "mother_normal.png", -1, {""}, 0)
        while isDialogExecuted() do
            coroutine.yield()
        end
        dialogBox("#Mother", {"Your mother. Kind, but stern. She has no interest in computers."}, "mother_normal.png", -1, {""}, 0)
        while isDialogExecuted() do
            coroutine.yield()
        end
        dialogBox("Mother", {"Tomoko, you need to study to get into a good school. You don't have time to be playing on the computer.", "I'm sorry, Hitomi. You shouldn't have to see this.", "Is your father still away on that research trip of his?"}, "mother_normal.png", -1, {""}, 0)
        while isDialogExecuted() do
            coroutine.yield()
        end
        dialogBox("Hitomi", {"Yes. This time, he's investigating the pyramids."}, "hitomi_normal.png", -1, {""}, 1)
        while isDialogExecuted() do
            coroutine.yield()
        end
        dialogBox("Mother", {"It must be hard for you to be all by yourself at your age. You're always welcome to have dinner with us."}, "mother_normal.png", -1, {""}, 0)
        while isDialogExecuted() do
            coroutine.yield()
        end
        dialogBox("Tomoko", {"Hey, brother!! want to see Paradigm X!"}, "tomoko_normal.png", -1, {""}, 0)
        while isDialogExecuted() do
            coroutine.yield()
        end
        dialogBox("Mother", {"Have you finished your homework, Tomoko?"}, "mother_normal.png", -1, {""}, 0)
        while isDialogExecuted() do
            coroutine.yield()
        end
        dialogBox("Tomoko", {"Awwww.. I'm almost done..."}, "tomoko_normal.png", -1, {""}, 0)
        while isDialogExecuted() do
            coroutine.yield()
        end
        dialogBox("Hitomi", {"Haha... Don't worry. Tomoko.", "Come to your brother's room  when you're finished. We'll play on Paradigm X together."}, "hitomi_normal.png", -1, {""}, 1)
        while isDialogExecuted() do
            coroutine.yield()
        end
        stopDraw2Dtexture()
        stopDraw2Dcharacter(0)
        stopDraw2Dcharacter(1)
        stopDraw2Dcharacter(2)
        draw2Dtexture("house_mc_room.png")
        dialogBox("Hitomi", {"Your father and sister were really happy to hear that you got into the beta...", "I know we shouldn't have done that, but.. I'm glad it worked.", "Huh? Oh, hey, you've got some mail."}, "hitomi_normal.png", -1, {""}, 1)
        while isDialogExecuted() do
            coroutine.yield()
        end
        stopDraw2Dtexture()
        draw2Dtexture("network_background.png")
        dialogBox("System",{"You have 1 new message."}, "empty", -1, {""}, 1)
        while isDialogExecuted() do
            coroutine.yield()
        end
        dialogBox("System",{"56?81%22:0^5431&446&787/97298/775.6^8\"12/205%4#34;465<6%139/8758120\"5446[78\"5"}, "empty", -1, {""}, 1)
        while isDialogExecuted() do
            coroutine.yield()
        end
        dialogBox("Hitomi", {"This came from Leader, right?", "He must have used the Spookies cypher, then. Go ahead and run it through the decoding tool."}, "hitomi_normal.png", -1, {""}, 1)
        while isDialogExecuted() do
            coroutine.yield()
        end
        dialogBox("System",{"You have 1 new message."}, "empty", -1, {""}, 1)
        while isDialogExecuted() do
            coroutine.yield()
        end
        dialogBox("System",{".................."}, "empty", -1, {""}, 1, 0.1)
        while isDialogExecuted() do
            coroutine.yield()
        end
        stopDraw2Dtexture()
        draw2Dtexture("network_background_2.png")
        dialogBox("System",{"Decryption complete.", "Our HQ has moved to the South Parking Garage in Shibahama. Spookies, assemble.\n\n-Spooky"}, "empty", -1, {""}, 1, 0.1)
        while isDialogExecuted() do
            coroutine.yield()
        end
        dialogBox("Hitomi", {"We moved our HQ? I didn't hear anything about that... Did something happen?"}, "hitomi_sad.png", -1, {""}, 1)
        while isDialogExecuted() do
            coroutine.yield()
        end
        dialogBox("Hitomi", {"Anyway, we should get to the South Parking Garage in Shibahama. Paradigm X is just going to have to wait. Too bad."}, "hitomi_sad.png", -1, {""}, 1)
        while isDialogExecuted() do
            coroutine.yield()
        end
        openMap("home", "akenadai");
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