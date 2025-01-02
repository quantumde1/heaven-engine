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

function file_exists(filename)
    local file = io.open(filename, "r")  -- Try to open the file in read mode
    if file then
        file:close()  -- Close the file if it was opened successfully
        return true    -- File exists
    else
        return false   -- File does not exist
    end
end

local dialogCoroutine
local answerValue

loadScene("res/scene1.json")

function startDialogCoroutine()
    dialogCoroutine = coroutine.create(function()
        -- Начало диалога с Сергеем
        setFriendlyZone(1)
        loadMusic("prologue_1.mp3")
        playMusic()
        hideUI()
        --[[
        load2Dtexture("epilogue_1.png",0)
        load2Dtexture("epilogue_2.png",1)
        load2Dtexture("epilogue_3.png",2)
        load2Dtexture("epilogue_4.png",3)
        load2Dtexture("epilogue_5.png",4)
        draw2Dtexture(0)
        local startTime = os.clock() -- Get the current time
        while os.clock() - startTime < 0.29 do
            coroutine.yield() -- Wait for 2 seconds
        end
        stopDraw2Dtexture()
        startTime = os.clock() -- Get the current time
        draw2Dtexture(3)
        while os.clock() - startTime < 0.29 do
            coroutine.yield() -- Wait for 2 seconds
        end
        stopDraw2Dtexture()
        startTime = os.clock() -- Get the current time
        draw2Dtexture(4)
        while os.clock() - startTime < 0.29 do
            coroutine.yield() -- Wait for 2 seconds
        end
        unload2Dtexture(3)
        unload2Dtexture(4)
        stopDraw2Dtexture()
        load2Dtexture("epilogue_7.png", 3)
        load2Dtexture("epilogue_8.png", 4)
        startTime = os.clock() -- Get the current time
        draw2Dtexture(3)
        while os.clock() - startTime < 0.29 do
            coroutine.yield() -- Wait for 2 seconds
        end
        stopDraw2Dtexture()
        startTime = os.clock() -- Get the current time
        unload2Dtexture(3)
        load2Dtexture("epilogue_6.png", 3)
        draw2Dtexture(4)
        while os.clock() - startTime < 0.29 do
            coroutine.yield() -- Wait for 2 seconds
        end
        stopDraw2Dtexture()
        unload2Dtexture(4)
        unload2Dtexture(0)
        load2Dtexture("epilogue_1.png",0)
        startTime = os.clock() -- Get the current time
        draw2Dtexture(3)
        while os.clock() - startTime < 0.29 do
            coroutine.yield() -- Wait for 2 seconds
        end
        stopDraw2Dtexture()
        draw2Dtexture(0)
        local startTime = os.clock() -- Get the current time
        while os.clock() - startTime < 0.29 do
            coroutine.yield() -- Wait for 2 seconds
        end
        stopDraw2Dtexture()
        startTime = os.clock() -- Get the current time
        draw2Dtexture(1)
        while os.clock() - startTime < 0.29 do
            coroutine.yield() -- Wait for 2 seconds
        end
        -- Draw the texture and wait for 2 seconds
        startTime = os.clock() -- Get the current time
        draw2Dtexture(2)
        while os.clock() - startTime < 0.29 do
            coroutine.yield() -- Wait for 2 seconds
        end
        unload2Dtexture(0)
        unload2Dtexture(1)
        unload2Dtexture(2)
        unload2Dtexture(3)
        unload2Dtexture(4)
        ]]--
        load2Dtexture("background_news_paradigm_x.png", 0)
        load2Dtexture("background_city_2.png", 1)
        load2Dtexture("background_city_1.png", 2)
        load2Dtexture("background_city_3.png", 3)
        draw2Dtexture(0)
        dialogBox("Announcer", {
            "Our next story tonight concerns the upcoming virtual city, \"Paradigm X\"",
            "While its public opening is coming soon, creator Algon Software is reportedly being flooded with beta applications.",
            "The number of users is so great that the company is unable to shut down the site for new user registrations."
        }, "news_reporter.png", -1, {""}, 0)

        while isDialogExecuted() do
            coroutine.yield() -- Ожидание завершения диалога
        end
        draw2Dtexture(1)
        dialogBox("Announcer", {"We will continue our coverage of the public release of Paradigm X as the story unfolds..."}, "empty", -1, {""}, 0)
        while isDialogExecuted() do
            coroutine.yield()
        end
        dialogBox("Hitomi", {"Hey, how about here...?"}, "hitomi_normal.png", -1, {""}, 1)
        while isDialogExecuted() do       
            coroutine.yield()
        end
        draw2Dcharacter("hitomi_staying_texture.png", getScreenWidth() /2 - 100, getScreenHeight()/2 - 100, 5.0, 0)
        draw2Dtexture(2)
        dialogBox("Hitomi", {"You're a member of a great hacker group, The Spookies. You should to be able to pull this off, at least.", "See? It's deserted around this terminal. Its the perfect place to do a little remote hacking, don't you think?", "What do you say?"}, "hitomi_normal.png", 2, {"We'll do it here.", "We're really doing this?"}, 1)
        while isDialogExecuted() do       
            coroutine.yield()
        end
        answerValue = getAnswerValue()
        if answerValue == 1 then
            dialogBox("Hitomi", {"We can't rely on luck to get us into the Paradigm X beta. I doubt we'd win that lottery...", "Come on, please?"}, "hitomi_normal.png", 1, {"I'll give it a shot.", "I guess so..."}, 1)
            while isDialogExecuted() do
                coroutine.yield()
            end
            answerValue = getAnswerValue()
            dialogBox("Hitomi", {"Haha, thanks."}, "hitomi_normal.png", -1, {""}, 1)
            while isDialogExecuted() do
                coroutine.yield()
            end
        end
        dialogBox("Hitomi", {"Leader already found where the list of winners is kept on their server, so just overwrite one of the names there."}, "hitomi_normal.png", -1, {""}, 1)
        while isDialogExecuted() do
            coroutine.yield()
        end
        stopMusic()
        playVideo("res/videos/movie003.mp4")
        playMusic()
        stopDraw2Dcharacter(0)
        draw2Dtexture(3)
        dialogBox("Hitomi", {"So, this is the list of lucky winners who are getting into the beta..."}, "hitomi_normal.png", -1, {""}, 1)
        while isDialogExecuted() do
            coroutine.yield()
        end
        dialogBox("System", {"Password accepted. Re-registering Paradigm X beta entry."}, "", -1, {""}, 1)
        while isDialogExecuted() do
            coroutine.yield()
        end
        draw2Dtexture(2)
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
        stopMusic()
        loadMusic("redman.mp3")
        playMusic()
        draw2Dtexture(3)
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
        draw2Dtexture(2)
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
        end
        answerValue = getAnswerValue()
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
        stopDraw2Dcharacter(0)
        stopMusic()
        loadMusic("default.mp3")
        playMusic()
        unload2Dtexture(0)
        unload2Dtexture(1)
        unload2Dtexture(2)
        unload2Dtexture(3)
        load2Dtexture("house_mc_hall.png", 0)
        load2Dtexture("house_mc_room.png", 1)
        load2Dtexture("network_background.png", 2)
        load2Dtexture("network_background_2.png", 3)
        draw2Dtexture(0)
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
        while os.clock() - startTime < 0.03 do
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
        stopDraw2Dcharacter(0)
        stopDraw2Dcharacter(1)
        stopDraw2Dcharacter(2)
        draw2Dtexture(1)
        dialogBox("Hitomi", {"Your father and sister were really happy to hear that you got into the beta...", "I know we shouldn't have done that, but.. I'm glad it worked.", "Huh? Oh, hey, you've got some mail."}, "hitomi_normal.png", -1, {""}, 1)
        while isDialogExecuted() do
            coroutine.yield()
        end
        draw2Dtexture(2)
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
        draw2Dtexture(3)
        dialogBox("System",{"Decryption complete.", "Our HQ has moved to the South Parking Garage in Shibahama. Spookies, assemble.\n\n-Spooky"}, "empty", -1, {""}, 1)
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
        unload2Dtexture(0)
        unload2Dtexture(1)
        unload2Dtexture(2)
        unload2Dtexture(3)
        stopDraw2Dtexture()
        openMap("home");
        local location_name
        location_name = getLocationName()
        if location_name == "garage" then
            loadMusic("hq.mp3")
            playMusic()
            load2Dtexture("garage_2.png", 0)
            load2Dtexture("spooky_room.png", 1)
            load2Dtexture("gump_first_1.png", 2)
            load2Dtexture("gump_first_2.png", 3)
            draw2Dtexture(0)
            dialogBox("Hitomi", {"It's supposed to be here... But i don't see anyone.", "Where is everybody? Are we too early?"}, "hitomi_sad.png", -1, {""}, 1)
            while isDialogExecuted() do
                coroutine.yield()
            end
            playVideo("res/videos/movie025.moflex.mp4")
            draw2Dcharacter("spooky_staying_texture.png", getScreenWidth() /2, getScreenHeight()/2 - 100, 5.0, 0)
            while os.clock() - startTime < 0.07 do
                coroutine.yield() -- Wait for 2 seconds
            end
            dialogBox("Spooky", {"Oh, you guys beat me here. Sorry for calling you so suddenly."}, "spooky_normal.png", -1, {""}, 0)
            while isDialogExecuted() do
                coroutine.yield()
            end
            dialogBox("#Spooky", {"Name: Masahiro Sakurai\nAlias: Leader\nHandle: Spooky"}, "spooky_normal.png", -1, {""}, 0)
            while isDialogExecuted() do
                coroutine.yield()
            end
            dialogBox("#Spooky", {"The founder and chief of the hacking group, The Spookies. He is a capable man who is respected by others."}, "spooky_normal.png", -1, {""}, 0)
            while isDialogExecuted() do
                coroutine.yield()
            end
            dialogBox("Hitomi", {"So, what happened? You moved the HQ without any warning."}, "hitomi_sad.png", -1, {""}, 1)
            while isDialogExecuted() do
                coroutine.yield()
            end
            dialogBox("Spooky", {"It's nothing, really. I've just got something on my mind. Come on, let's talk inside."}, "spooky_normal.png", -1, {""}, 0)
            while isDialogExecuted() do
                coroutine.yield()
            end
            stopDraw2Dtexture()
            draw2Dtexture(1)
            dialogBox("Spooky", {"\"Kinap\", huh... I haven't heard of any hackers going by that name, either."}, "spooky_normal.png", -1, {""}, 0)
            while isDialogExecuted() do
                coroutine.yield()
            end
            dialogBox("Hitomi", {"This guy even knew his name. That's what bother me..."}, "hitomi_sad.png", -1, {""}, 1)
            while isDialogExecuted() do
                coroutine.yield()
            end
            dialogBox("Spooky", {"Maybe you're just being paranoid. You got your name on the beta list without any problems, after all.", "Amami City's a fully network-integrated city. It wouldn't surprise me if there was a hacker that skilled out there.", "Still, i wouldn't think that you'd be all that worried about something like that.", "Hey, is she always like this?"}, "spooky_normal.png", 3, {"She's more upbeat.", "She's a calm one.", "Sexy defines her."}, 0)
            while isDialogExecuted() do
                coroutine.yield()
            end
            answerValue = getAnswerValue()
            if answerValue == 2 then
                dialogBox("Hitomi", {"H-Hey! What are you saying!?"}, "hitomi_surpised.png", -1, {""}, 1)
                while isDialogExecuted() do
                    coroutine.yield()
                end
                dialogBox("Spooky", {"Ha ha! Well, either way, I don't think there's any cause for concern."}, "spooky_normal.png", -1, {""}, 0)
                while isDialogExecuted() do
                    coroutine.yield()
                end
            else
                dialogBox("Spooky", {"Well, either way, I don't think there's any cause for concern."}, "spooky_normal.png", -1, {""}, 0)
                while isDialogExecuted() do
                    coroutine.yield()
                end
            end
            dialogBox("Hitomi", {"I suppose not...", "But you said you had something on your mind before? What is it?"}, "hitomi_sad.png", -1, {""}, 1)
            while isDialogExecuted() do
                coroutine.yield()
            end
            dialogBox("Spooky", {"Hmm... Well, I guess I'll show you two first. You see, I picked up something interesting recently."}, "spooky_normal.png", -1, {""}, 0)
            while isDialogExecuted() do
                coroutine.yield()
            end
            while os.clock() - startTime < 0.03 do
                coroutine.yield() -- Wait for 2 seconds
            end
            draw2Dtexture(2)
            stopDraw2Dcharacter(0)
            dialogBox("Hitomi", {"What is this...? Is that... A gun?"}, "hitomi_sad.png", -1, {""}, 1)
            while isDialogExecuted() do
                coroutine.yield()
            end
            dialogBox("Spooky", {"Looks like one, doesn't it? But when you unlatch this part..."}, "spooky_normal.png", -1, {""}, 0)
            while isDialogExecuted() do
                coroutine.yield()
            end
            stopDraw2Dtexture(2)
            draw2Dtexture(3)
            dialogBox("Hitomi", {"Wait, so this is a PC?"}, "hitomi_surpised.png", -1, {""}, 1)
            while isDialogExecuted() do
                coroutine.yield()
            end
            dialogBox("Spooky", {"I'm calling it a \"Gun-Type PC\" for now, but that's really all I know about it."}, "spooky_normal.png", -1, {""}, 0)
            while isDialogExecuted() do
                coroutine.yield()
            end
            draw2Dcharacter("spooky_staying_texture.png", getScreenWidth() /2, getScreenHeight()/2 - 100, 5.0, 0)
            draw2Dtexture(1)
            dialogBox("Hitomi", {"But what does this have to do with moving our HQ?"}, "hitomi_sad.png", -1, {""}, 1)
            while isDialogExecuted() do
                coroutine.yield()
            end
            dialogBox("Spooky", {"Ever since I obtained this, I've noticed some suspicious people following me around.", "This PC is the only reason I can think of that would explain that. It's more just to soothe my nerves, though."}, "spooky_normal.png", -1, {""}, 0)
            while isDialogExecuted() do
                coroutine.yield()
            end
            dialogBox("Hitomi", {"But is this thing really all that special?..."}, "hitomi_sad.png", -1, {""}, 1)
            while isDialogExecuted() do
                coroutine.yield()
            end
            dialogBox("Spooky", {"I don't know. I plan on doing some research. I'm glad you two showed up so early.", "I'm going back to the junk store I bought this thing from. Watch over the trailer while I'm gone, okay?", "If we can learn what this gun-type PC really is, we might be able to figure out who those suspicious guys are, too.", "I'll leave the gun PC with you. I don't want to risk getting back on those guys' radar. I'll see you later."}, "spooky_normal.png", -1, {""}, 0)
            while isDialogExecuted() do
                coroutine.yield()
            end
            stopDraw2Dcharacter(0)
            while os.clock() - startTime < 0.03 do
                coroutine.yield() -- Wait for 2 seconds
            end
            dialogBox("Hitomi", {"Huh? Hold on, Leader...", "Geez, he called us just so we could babysit the trailer for him? Still, I doubt anyone else will show up soon...", "Hey, what should we do?"}, "hitomi_sad.png", 2, {"Save", "Leave", "Gun-type PC"}, 1)
            while isDialogExecuted() do
                coroutine.yield()
            end
            answerValue = getAnswerValue()
            if answerValue == 0 then
                dialogBox("System", {"Saving, please wait..."}, "empty", -1, {""}, 1, 0.03)
                while isDialogExecuted() do
                    coroutine.yield()
                end
                file = io.open("save_garage01.txt", "w")
                file:write("garage:01")
                file:close()
                dialogBox("System", {"Saved."}, "empty", -1, {""}, 1, 0.03)
                while isDialogExecuted() do
                    coroutine.yield()
                end
            end
            if answerValue == 1 then
                openMap("garage", "shibahama")
            end
            if answerValue == 2 then
                dialogBox("Hitomi", {".............\nIt's not working. Is it broken?\nWell, we don't have anything else to do."}, "hitomi_sad.png", -1, {""}, 1)
                while isDialogExecuted() do
                    coroutine.yield()
                end
                dialogBox("Hitomi", {"Oh, i know! Let's check out Paradigm X. You just got the license, so let's see what the big deal is.", "That will pass the time until Lunch and the others get here. Come on, let's do it!"}, "hitomi_normal.png", -1, {""}, 1)
                while isDialogExecuted() do
                    coroutine.yield()
                end
            end
            dialogBox("System", {"What will you do?"}, "empty", 0, {"Save", "Leave", "Paradigm X"}, 1)
            while isDialogExecuted() do
                coroutine.yield()
            end
            answerValue = getAnswerValue()
            if answerValue == 0 then
                dialogBox("System", {"Saving, please wait..."}, "empty", -1, {""}, 1, 0.03)
                while isDialogExecuted() do
                    coroutine.yield()
                end
                file = io.open("save_garage01.txt", "w")
                file:write("garage:01")
                file:close()
                dialogBox("System", {"Saved."}, "empty", -1, {""}, 1, 0.03)
                while isDialogExecuted() do
                    coroutine.yield()
                end
            end
            if answerValue == 1 then
                openMap("garage", "shibahama")
            end
            if answerValue == 2 then
                dialogBox("Hitomi", {"Ha ha, i'm kind of excited!"}, "hitomi_normal.png", -1, {""}, 1)
                while isDialogExecuted() do
                    coroutine.yield()
                end
                playVideo("res/videos/movie01e.moflex.mp4")
                unload2Dtexture(1)
                unload2Dtexture(0)
                unload2Dtexture(2)
                unload2Dtexture(3)
                loadMusic("counter.mp3")
                playMusic()
                load2Dtexture("user_counter.png", 0)
                load2Dtexture("first_paradigm_X_1.png", 1)
                load2Dtexture("first_paradigm_X_2.png", 2)
                load2Dtexture("first_paradigm_X_3.png", 3)
                load2Dtexture("first_paradigm_X_4.png", 4)
                draw2Dtexture(0)
                dialogBox("Receptionist", {"Welcome to Paradigm X! This is the User Counter, your portal to accessing this virtual world.", "First-time users will receive an explanation of Amami City's network.", "Please, listen carefully."}, "counter.png", -1, {""}, 0)
                while isDialogExecuted() do
                    coroutine.yield()
                end
                draw2Dtexture(1)
                dialogBox("???", {"Ah hah haaaaaaaaah! If you need to know anything about the 'Net, just come to me!"}, "empty", -1, {""}, 0)
                while isDialogExecuted() do
                    coroutine.yield()
                end
                draw2Dcharacter("cpt_paradigm_staying.png", getScreenWidth() /2 - 100, getScreenHeight()/2 - 150, 5.0, 0)
                dialogBox("Cpt. Paradigm", {"I am this world's defender of justice! CAPTAIN PARADIGM!", "Let me tell you about the network that connects the beloved citizens of Amami City to Paradigm X."}, "cpt_paradigm.png", -1, {""}, 0)
                while isDialogExecuted() do
                    coroutine.yield()
                end
                stopDraw2Dcharacter(0)
                
                draw2Dtexture(2)
                dialogBox("Cpt. Paradigm", {"Paradigm X is a virtual city located on the massive servers of Algon Soft Corporation"}, "cpt_paradigm.png", -1, {""}, 0)
                while isDialogExecuted() do
                    coroutine.yield()
                end
                draw2Dtexture(3)
                dialogBox("Cpt. Paradigm", {"The network that connects that server to your PCs is a city-wide broadband intranet that run throughout Amami City.", "Thanks to this network, you can enter Paradigm X freely from your home PC and meet with your friends online."}, "cpt_paradigm.png", -1, {""}, 0)
                while isDialogExecuted() do
                    coroutine.yield()
                end
                draw2Dtexture(4)
                dialogBox("Cpt. Paradigm", {"With no lag and a nigh-zero percent rate of packet loss, the intranet of Amami City makes Paradigm X truly another world!"}, "cpt_paradigm.png", -1, {""}, 0)
                while isDialogExecuted() do
                    coroutine.yield()
                end
                draw2Dcharacter("cpt_paradigm_staying.png", getScreenWidth() /2 - 100, getScreenHeight()/2 - 150, 5.0, 0)
                draw2Dtexture(1)
                dialogBox("Cpt. Paradigm", {"Now, allow me to briefly describe my home of Paradigm X, the dream city that resides within this network.", "Anything you want can be found on Paradigm X's virtual streets: a movie threater, pet shops... Anything!", "Through your PCs, you can access these \"cyber-shops\" and use them at any time. The city of the future never closes!", "This is truly the life of the future, brought to Amami City by Algon Soft!", "But, enough from me. It's time for you to experience it for yourself! Now, have a gooooooood time! Hahaha!"}, "cpt_paradigm.png", -1, {""}, 0)
                while isDialogExecuted() do
                    coroutine.yield()
                end
                while os.clock() - startTime < 0.02 do
                    coroutine.yield() -- Wait for 2 seconds
                end
                stopDraw2Dcharacter(0)
                draw2Dtexture(0)
                dialogBox("Receptionist", {"Did you enjoy the explanation? It's now time for you to actually experience Paradigm X.", "You may be surprised by the intense quality of the virtual city.", "When you want to end your time in Paradigm X, please return here. And... Have fun!"}, "counter.png", -1, {""}, 0)
                while isDialogExecuted() do
                    coroutine.yield()
                end
                stopDraw2Dtexture()
                unload2Dtexture(0)
                unload2Dtexture(1)
                unload2Dtexture(2)
                unload2Dtexture(3)
                unload2Dtexture(4)
                stopMusic()
                loadMusic("paradigm_x.mp3")
                playMusic()
                allowControl()
            end
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

shadersState(0)
-- Настройка позиции камеры
local dungeonCrawler = true
if dungeonCrawler == true then
    changeCameraPosition(0.0, 7.0, 0.1)
    changeCameraTarget(0.0, 7.0, 0.0)
    changeCameraUp(0.0, 1.0, 0.0)
    drawPlayerModel(0)
    dungeonCrawlerMode(1)
else
    setPlayerModel("res/mc.glb", 0.020)
    changeCameraPosition(0.0, 8.0, 10.0)
    changeCameraTarget(0.0, 6.0, 0.0)
    changeCameraUp(0.0, 1.0, 0.0)
    drawPlayerModel(1)
    dungeonCrawlerMode(0)
end

-- Запуск корутины диалога
startDialogCoroutine()
