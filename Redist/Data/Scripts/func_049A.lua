require "U7LuaFuncs"
-- Manages Grod's dialogue in Moonglow, as a troll torturing prisoners for the Fellowship, discussing his job and philosophy.
function func_049A(eventid, itemref)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9, local10, local11, local12, local13, local14

    if eventid ~= 1 then
        return
    end

    switch_talk_to(-154, 0)
    add_answer({"bye", "Fellowship", "job", "name"})
    local0 = switch_talk_to(-1)
    local1 = switch_talk_to(-2)
    local2 = switch_talk_to(-240)
    local3 = switch_talk_to(-220)
    local4 = get_player_name()
    local5 = get_party_size()
    set_schedule(-154, 2)
    local14 = get_answer({"the Avatar", local4, local5})

    if not get_flag(702) then
        say("The troll snarls at you, obviously displeased at your presence.")
        set_flag(702, true)
    else
        say("\"What you want?\" asks Grod.")
    end

    while true do
        local answer = get_answer()
        if answer == "name" then
            local6 = get_answer()
            if local6 then
                say("\"I Grod. Why you want know? Is voice unhappy?\"")
                local7 = get_answer()
                if local7 then
                    say("He seems truly worried.~~\"I will do job better. I promise! I beat harder and more often!\"")
                    if local2 then
                        say("*")
                        switch_talk_to(-240, 0)
                        if get_flag(707) then
                            local8 = "Anton,"
                        else
                            local8 = "a prisoner,"
                        end
                        say("\"Thank thee ever so much, " .. local4 .. ",\" says " .. local8 .. " sarcastically.*")
                        hide_npc(-240)
                        switch_talk_to(-154, 0)
                    end
                    if local2 and local3 then
                        switch_talk_to(-220, 0)
                        say("\"Now, now, Anton, the nice person was simply answering a question.\"*")
                        hide_npc(-220)
                        switch_talk_to(-154, 0)
                    end
                else
                    say("\"Good. I do my job good!\"")
                end
            else
                say("\"I Grod. Who you?\"")
                if local14 == local5 then
                    say("\"I not know you.\" He shrugs.")
                elseif local14 == local4 then
                    say("\"Funny name. But, all humans have funny names.\" He shrugs.")
                elseif local14 == "the Avatar" then
                    say("\"The Avatar?\" He begins laughing. \"The Avatar not been here for...,\" he begins counting on his fingers. After several attempts, he gives up, saying, \"for many years!~~\"You no Avatar.\"")
                end
            end
            remove_answer("name")
        elseif answer == "job" then
            say("\"I torture prisoners,\" he says, thumping his chest proudly.*")
            if local1 then
                switch_talk_to(-2, 0)
                say("Spark's eyes light up.~\"Torture? Wow! He quickly looks at you and changes expressions.~~ \"I, er, mean, that is very awful.\"*")
                hide_npc(-2)
                switch_talk_to(-154, 0)
            end
            local11 = get_answer()
            if local11 then
                if local2 and local3 then
                    say("He points to one of the prisoners.~~\"He not fun like the other. Torture other first.\"*")
                    switch_talk_to(-220, 0)
                    say("\"What? No, that's all right, " .. local4 .. ". Torture me, first.\"*")
                    hide_npc(-220)
                    switch_talk_to(-240, 0)
                    say("\"Yes, " .. local4 .. ". Torture him first.\"*")
                    hide_npc(-240)
                    switch_talk_to(-220, 0)
                    say("\"I thank thee,\" he says to the other.*")
                    hide_npc(-220)
                    switch_talk_to(-154, 0)
                    say("\"Go ahead,\" says Grod.*")
                    local13 = add_item(true, -359, -359, 622, 1)
                    if local13 then
                        say("He hands you a whip.")
                    else
                        say("\"You too wimpy to use whip!\"")
                    end
                    return
                else
                    say("\"No one here to abuse.\" He appears disappointed.")
                end
            else
                say("\"You make funny joke. Go ahead, torture.\"*")
                return
            end
            add_answer({"prisoners", "torture"})
        elseif answer == "Fellowship" then
            local14 = get_answer()
            if local14 then
                say("\"Yes,\" he nods. \"I belong, too. I strive for unity. I be worthy for my reward. And I trust my brother.\"~~ He smiles, obviously pleased with himself.\"")
                add_answer({"trust", "worthy", "strive"})
            else
                say("\"Big group, many people. You should join!\"")
                add_answer("join")
            end
            remove_answer("Fellowship")
        elseif answer == "trust" or answer == "worthy" or answer == "strive" then
            say("\"You don't know?\" He frowns.~~ \"You should learn before the voice become angry!\"")
            remove_answer({"trust", "worthy", "strive"})
        elseif answer == "join" then
            say("\"Good, join. See Abraham or Danag about join.\"")
            remove_answer("join")
        elseif answer == "prisoners" then
            if get_flag(737) and get_flag(738) then
                say("\"None here at the moment...\" he appears truly disconcerted.")
            else
                say("\"There one!\" he says, pointing to a man.*")
                if not get_flag(737) and get_flag(738) then
                    say("\"There another one!\" he says, indicating the other man.")
                    switch_talk_to(-220, 0)
                    say("\"How art thou today, " .. local4 .. "?\" he says, smiling.")
                    hide_npc(-220)
                    switch_talk_to(-154, 0)
                end
            end
            remove_answer("prisoners")
        elseif answer == "torture" then
            say("\"Much fun! Prisoners scream loudly.\"*")
            if local3 then
                say("\"Except that one. He not scream. He just talk. And talk. I get so bored I get mad. So I torture more. And,\" he throws up his hands, \"he just talk more! I no know what to do.\"*")
            end
            if local0 then
                switch_talk_to(-1, 0)
                say("\"That is terrible, " .. local5 .. ". We must command him to stop!\"*")
                hide_npc(-1)
                switch_talk_to(-154, 0)
            end
            if local3 then
                say("\"I try make him stop. But he talk and talk. You try? Maybe he stop.\"")
            end
            add_answer("stop torturing")
            remove_answer("torture")
        elseif answer == "stop torturing" then
            say("\"Oh, no! Grod love job! Grod never stop. You go away now.\"*")
            return
        elseif answer == "bye" then
            say("\"Come back and visit Grod. Hear victims squeal!\"*")
            break
        end
    end
    return
end