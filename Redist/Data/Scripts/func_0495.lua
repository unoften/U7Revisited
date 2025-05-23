require "U7LuaFuncs"
-- Manages the three-headed hydra's dialogue in Skara Brae, guarding the Caddellite, with a humorous and threatening tone, escalating to combat if provoked.
function func_0495(eventid, itemref)
    local local0, local1, local2, local3, local4, local5

    if eventid == 0 then
        return
    end

    switch_talk_to(-280, 0)
    local0 = 0
    local1 = get_party_members()
    local2 = 0

    for local3 = 0, 13 do
        local2 = local2 + 1
    end

    add_answer({"bye", "job", "name"})

    if not get_flag(711) then
        say("You see a three-headed hydra. The head on the left speaks.~~ \"Wake up, there is something here.\"")
        switch_talk_to(-282, 0)
        say("The head on the right looks up and at you.~~\"I wonder if it is good to eat.\"*")
        hide_npc(-282)
        switch_talk_to(-281, 0)
        say("The middle head wakes with a start, sees you, becomes alarmed, and begins to snort excitedly.*")
        switch_talk_to(-280, 0)
        say("\"Fear not, brother; we know it's there.\"*")
        hide_npc(-281)
        switch_talk_to(-282, 0)
        say("\"I wonder if it talks?\"*")
        hide_npc(-282)
        switch_talk_to(-280, 0)
        set_flag(711, true)
    else
        say("\"We are not talking to thee! We are trying to eat thee!\"*")
        set_schedule(-149, 2)
        apply_effect(-149, 0) -- Unmapped intrinsic
        return
    end

    while true do
        local answer = get_answer()
        if answer == "name" then
            say("\"My name is Shandu. My brother next to me is Shanda. My brother next to him is Shando.\"*")
            switch_talk_to(-282, 0)
            say("\"It does not matter what our names are!\"*")
            hide_npc(-282)
            switch_talk_to(-281, 0)
            say("Shanda shakes his head and glares at you.*")
            hide_npc(-281)
            switch_talk_to(-280, 0)
            remove_answer("name")
            add_answer({"Shando", "Shanda", "Shandu"})
        elseif answer == "Shandu" then
            say("\"That is me.\"~~Shandu smiles and licks his lips.~~ \"I like it when my food says my name!\"")
            remove_answer("Shandu")
        elseif answer == "Shanda" then
            switch_talk_to(-281, 0)
            say("Shanda rolls his eyes and exhales a puff of smoke from his nostrils.*")
            hide_npc(-281)
            switch_talk_to(-282, 0)
            say("\"Shanda says that thou shouldst refrain from saying his name. He does not like it when his food says his name.\"*")
            hide_npc(-282)
            switch_talk_to(-280, 0)
            remove_answer("Shanda")
        elseif answer == "Shando" then
            switch_talk_to(-282, 0)
            say("\"That is me. I am the oldest brother.\"*")
            switch_talk_to(-280, 0)
            say("\"We are all connected, Shando! Thou cannot be older!\"*")
            switch_talk_to(-282, 0)
            say("\"Mine head was the first to breathe the air.\"*")
            switch_talk_to(-280, 0)
            say("Shandu spits.~~\"What does it matter? Our food does not care which of us is the eldest!\"*")
            hide_npc(-282)
            switch_talk_to(-280, 0)
            remove_answer("Shando")
        elseif answer == "job" then
            say("\"Job?\"")
            switch_talk_to(-281, 0)
            say("Shanda opens his mouth wide and emits a burst of flame.*")
            hide_npc(-281)
            switch_talk_to(-282, 0)
            say("\"He thinks that is a joke. Job! Ha! I think it is amusing, too. I have never heard my food tell jokes.\"*")
            switch_talk_to(-280, 0)
            say("\"Ah, but brothers, we -do- have a job.\"*")
            switch_talk_to(-282, 0)
            say("\"We do?\"*")
            switch_talk_to(-280, 0)
            say("\"We guard the Caddellite, do we not? Our purpose in life is to guard the Caddellite!\"")
            hide_npc(-282)
            switch_talk_to(-280, 0)
            add_answer("Caddellite")
        elseif answer == "Caddellite" then
            if local0 == 0 then
                switch_talk_to(-281, 0)
                say("Shanda becomes excited and snorts as if he were saying several sentences.")
                hide_npc(-281)
                switch_talk_to(-280, 0)
                remove_answer("Caddellite")
                add_answer("What did he say?")
                local0 = 1
            else
                say("\"Thou dost want to know about Caddellite? Very well, I shall tell thee about Caddellite.\"~~The hydra shifts its weight a moment, then grins wickedly.~~\"We are guarding it.\"")
                remove_answer("Caddellite")
                add_answer("guarding")
            end
        elseif answer == "What did he say?" then
            say("\"He wasn't talking to thee!\"")
            remove_answer("What did he say?")
            add_answer("Caddellite")
        elseif answer == "guarding" then
            switch_talk_to(-282, 0)
            say("\"The creature seems to echo everything we say, Shandu.\"*")
            hide_npc(-282)
            switch_talk_to(-281, 0)
            say("Shanda makes a horrid growling noise.*")
            hide_npc(-281)
            switch_talk_to(-280, 0)
            say("\"Shanda says he is hungry!\"*")
            switch_talk_to(-282, 0)
            say("\"So am I!\"*")
            hide_npc(-282)
            switch_talk_to(-280, 0)
            say("\"Now that thou dost mention it, I am feeling a few hunger pangs myself. If we did not have to protect the Caddellite, I would eat this creature in a single gulp!\"")
            remove_answer("guarding")
            add_answer({"protect", "echo"})
        elseif answer == "echo" then
            say("\"Hearing this creature repeat whatever we say is making me hungry!\"*")
            switch_talk_to(-282, 0)
            say("\"It amuses me! Obviously it is a creature of severely limited intelligence!\"*")
            hide_npc(-282)
            switch_talk_to(-281, 0)
            say("Shanda lets out a low growl.*")
            hide_npc(-281)
            switch_talk_to(-280, 0)
            say("\"Shanda says he wants something to eat!\"")
            remove_answer("echo")
        elseif answer == "protect" then
            say("\"I suppose we must protect the Caddellite from creatures like thee who come around once every 1000 years or so wanting to take it.\"*")
            switch_talk_to(-281, 0)
            say("Shanda growls louder than before, then breathes a bit of fire.*")
            hide_npc(-281)
            switch_talk_to(-282, 0)
            say("\"Creature! Thou art making Shanda angry! He thinks that thou art attempting to steal the Caddellite! Beware!\"*")
            hide_npc(-282)
            switch_talk_to(-280, 0)
            remove_answer("protect")
            add_answer("steal")
        elseif answer == "steal" then
            say("Shandu becomes enraged.~~\"I knew it! It is trying to steal our Caddellite!\"~~Shandu addresses his brothers.~~\"We must not delay any longer.\"*")
            switch_talk_to(-281, 0)
            say("Shanda roars angrily!*")
            hide_npc(-281)
            switch_talk_to(-280, 0)
            say("\"That is a good idea, my brother!\"~~Shandu turns to you.~~ \"This creature vaguely resembles a troll, only it smells a little more pleasant. Dost thou think it might taste better than a troll, Shando?\"*")
            switch_talk_to(-282, 0)
            say("\"We shall not know until we try!\"*")
            hide_npc(-282)
            switch_talk_to(-281, 0)
            say("Shanda nods his head furiously, licking his lips.*")
            hide_npc(-281)
            switch_talk_to(-280, 0)
            say("\"Very well! Let's eat it!\"*")
            set_schedule(-149, 2)
            apply_effect(-149, 0) -- Unmapped intrinsic
            return
        elseif answer == "bye" then
            say("\"Thou cannot say 'bye' to us! How rude!\"")
            remove_answer("bye")
        end
    end

    say("\"Leaving so soon?\"*")
    return
end