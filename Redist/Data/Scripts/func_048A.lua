require "U7LuaFuncs"
-- Manages Gorn's dialogue in a cave, covering his quest to find Brom, his homeland Balema, and suspicions about the Avatar influenced by Brom's voice.
function func_048A(eventid, itemref)
    local local0, local1, local2, local3, local4, local5

    if eventid == 1 then
        switch_talk_to(-138, 0)
        local0 = get_player_name()
        local1 = get_party_size()
        local2 = switch_talk_to(-1)
        local3 = switch_talk_to(-3)
        local4 = switch_talk_to(-4)
        local5 = check_item(-359, -359, 644, -357) -- Unmapped intrinsic

        add_answer({"bye", "job", "name"})
        if not get_flag(716) then
            add_answer("Iriale")
        end

        if not get_flag(699) then
            say("You see a familiar face, a stern-looking bearded warrior whom you have met on one of your previous journeys to Britannia.")
            set_flag(699, true)
        else
            say("\"Ho, Avatar!\" says Gorn. \"Thou dost vish to speak mit me?\"")
        end

        if get_flag(722) then
            say("\"De voice ov Brom has told me not to trust thee, Avatar,\" says Gorn. \"I tought dat ve vere friends and I do not vish to cause thee harm. But I varn thee, do not speak mit me anymore!\"*")
            return
        end

        while true do
            local answer = get_answer()
            if answer == "name" then
                say("The warrior's eyes narrow. \"I am Gorn, as if thou didst not remember! It is good to see thee again.\" He laughs and slaps you on the shoulder.")
                remove_answer("name")
            elseif answer == "job" then
                say("\"My job is a never-ending qvest of high adventure. Ever since I vas a child und vas taken from mine homeland of Balema, I haf spent my life in search of heroic deeds to perform.\"")
                add_answer({"heroic deeds", "Balema"})
            elseif answer == "Balema" then
                say("\"Yah, Balema is vere I vas born. I vas a child dere. It is a vonderland ov snow-covered mountains und dark forests. It vas not an easy life, but it vas a place dat made young boys into strong heroic men. Dat vas long before I came to Britannia.\"")
                remove_answer("Balema")
                add_answer("Britannia")
            elseif answer == "Britannia" then
                say("\"Yah! I came to Britannia t'rough vone ov de Moongates, de same as thee. Dat vas many, many years ago.\"")
                remove_answer("Britannia")
            elseif answer == "heroic deeds" then
                say("\"I perform heroic deeds in honor ov Brom. Everyting I do is in service to him.\"")
                remove_answer("heroic deeds")
                add_answer("Brom")
            elseif answer == "Brom" then
                say("\"He is my master, und de master ov all ov de people ov Balema. Brom is all powerful und if I am strong he vill aid me. Sometimes I hear de voice ov Brom inside ov mine head.\"")
                remove_answer("Brom")
                add_answer({"voice", "master"})
            elseif answer == "master" then
                say("\"Ya! Brom he is my master. If he vishes me to do someting, I must do it! If he does not vant me to do someting, I must not do it!\"")
                remove_answer("master")
            elseif answer == "voice" then
                say("\"Ya! Only recently I haf begun to hear his voice in mine head. His voice tells me vat to do! As I came tovard dis cave de voice ov Brom became clearer.\"")
                remove_answer("voice")
                add_answer({"clearer", "cave", "what to do"})
            elseif answer == "what to do" then
                say("\"Vhen I first heard de voice ov Brom, he told me dat I should follow him. But how does one follow de voice ov someone dat thou cannot see vhen de voice is coming from inside ov thine head?\"")
                remove_answer("what to do")
                add_answer("follow")
            elseif answer == "follow" then
                say("\"Dis vas very, very difficult for me but after a vhile I vas able to figure out how to do it. Vhen I came nearer to da camp surrounding dis cave da voice vould get louder. Vhen I vould move avay de voice vould be qvieter.\"")
                remove_answer("follow")
                add_answer("camp")
            elseif answer == "camp" then
                say("\"It vas very simple for a trained varrior like myself to slip into de camp ov dose who are holding Brom prisoner. Dey posed no threat vatsoever. So dat means dat de danger must be vaiting down here. But I cannot find it!\"")
                if local5 then
                    say("\"I can see by dat medallion thou dost vear dat thou hast snuck into dis place by disguising thyself as vone of dem. Very clever, Avatar!\"")
                end
                if local2 then
                    switch_talk_to(-1, 0)
                    say("Iolo whispers to you, \"This fellow is quite sharp, is he not?\"*")
                    hide_npc(-1)
                    switch_talk_to(-138, 0)
                end
                remove_answer("camp")
                add_answer("danger")
            elseif answer == "danger" then
                say("\"Zo far de only danger I haf found down here has been a female fighter. She vas beautiful. Vhen I vent to talk to her she hit me over de head mit her svord. Vhen I voke up she vas gone. I bet she tought she had killed me but mine head is harder dan dat. I vas not even vounded.\"")
                if local3 then
                    switch_talk_to(-3, 0)
                    say("Shamino whispers to you. \"Luckily, Gorn was hit in the one spot where he has no feeling whatsoever -- his head!\"*")
                    switch_talk_to(-138, 0)
                    say("\"Hey, vhat are you vhispering about over dere?\"*")
                    switch_talk_to(-3, 0)
                    say("\"Oh, nothing. Nothing at all.\"*")
                    hide_npc(-3)
                    switch_talk_to(-138, 0)
                end
                remove_answer("danger")
            elseif answer == "cave" then
                say("\"I know dat Brom is somevhere down in dis cave, und I vill not leave dis place until I find him!\"")
                remove_answer("cave")
                add_answer("find Brom")
            elseif answer == "clearer" then
                say("\"The nearer I haf come to dis cave, the more times I haf been hearing de voice ov Brom. But lately he has been saying tings to me dat are very, very strange!\"")
                remove_answer("clearer")
                add_answer("strange")
            elseif answer == "strange" then
                say("\"De first strange ting dat he says to me is 'Strive For Unity'. I say, yah, dat is vhy I am performing mine heroic deeds. Den Brom says someting else dat is strange.\"")
                remove_answer("strange")
                add_answer("something else strange")
            elseif answer == "something else strange" then
                say("\"Next de voice ov Brom says to me 'Trust My Brothers'. Dis is strange because all ov my brothers are back in Balema, und I vould never trust dem anyvays. Dey vere all bigger den me and vere alvays beating me. But even dat vas not as strange as da next strange ting.\"")
                remove_answer("something else strange")
                add_answer("next strange thing")
            elseif answer == "next strange thing" then
                say("\"De voice ov Brom tells me dat 'Worldliness Receives Avard'. I haf been tinking about dat von for a long time und I still haf not figured it out. But I vill not give up until I find Brom.\"")
                if local4 then
                    switch_talk_to(-4, 0)
                    say("\"A mysterious voice speaking inside someone's head, suggesting the philosophy of The Fellowship. Does this sound familiar, " .. local0 .. "?\"*")
                    hide_npc(-4)
                    switch_talk_to(-138, 0)
                end
                remove_answer("next strange thing")
                add_answer("find Brom")
            elseif answer == "find Brom" then
                say("\"Wouldst thou help me find Brom?\"")
                local1 = get_answer()
                if local1 then
                    say("Gorn seems distracted for a moment. He places his hand to his ear as if he is listening to something. He looks back at you and there is a shocked look on his face. \"I haf just heard de voice ov Brom and he has told me not to trust thee! Go avay from me, Avatar! I tought dat thou vert my friend! I do not vish to speak vith thee anymore!\"*")
                    set_flag(722, true)
                    break
                else
                    say("Gorn has a confused look on his face. \"Vhy vill thou not help me find Brom? Dost thou tink dat dis is all some kind ov trick, or should I go on looking for Brom by myself?\"")
                    add_answer({"it's a trick", "look for Brom"})
                end
                remove_answer("find Brom")
            elseif answer == "look for Brom" then
                say("\"If dat is how thou vants it. Den I shall go on searching for Brom mit no vone else but myself. Good luck in vhatever qvest thou art on, Avatar. Farewell to thee!\"*")
                set_schedule(-138, 12)
                break
            elseif answer == "it's a trick" then
                say("Gorn seems distracted for a moment. He puts his hand to his ear as if he is listening to something. He looks back at you with a shocked expression on his face. \"I haf just heard de voice ov Brom and he says dat I should not trust thee! I tought dat thou vert my friend, Avatar! Go avay! I do not vish to speak vith thee again!\"*")
                set_flag(722, true)
                break
            elseif answer == "Iriale" then
                say("\"Dat is de name ov de female fighter who has been guarding dis place. I haf fought her vonce already. She is a strong fighter! I haf to find her so I can make her to tell me vhere is Brom!\"")
                remove_answer("Iriale")
            elseif answer == "bye" then
                say("\"Until ve meet again, Avatar.\"*")
                break
            end
        end
    end
    return
end