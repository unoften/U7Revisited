require "U7LuaFuncs"
-- Function 04EF: Owings's comedic miner dialogue
function func_04EF(eventid, itemref)
    -- Local variables (5 as per .localc)
    local local0, local1, local2, local3, local4

    if eventid == 0 then
        return
    end

    _SwitchTalkTo(0, -239)
    local0 = call_0909H()
    local1 = call_08F7H(-243)
    local2 = call_08F7H(-1)
    local3 = call_08F7H(-3)
    local4 = call_08F7H(-4)
    _AddAnswer({"bye", "job", "name"})

    if not get_flag(0x02BC) then
        say("Before you is a skinny man with a silly smile on his face. He is holding a lantern in one hand and a dirty spoon in the other.")
        set_flag(0x02BC, true)
    else
        say("\"Hello, again,\" says Owings. He smiles and tips his mining hat to you.")
    end

    while true do
        local answer = wait_for_answer()

        if answer == "name" then
            say("\"My name is Owings,\" he says giving you a rapid up and down handshake. \"Pleased to meet thee.\"")
            if local1 then
                if not get_flag(0x02BD) then
                    say("\"My partner's name is Malloy.\"")
                else
                    say("\"Thou dost already know my partner, Malloy.\"")
                end
            end
            _RemoveAnswer("name")
        elseif answer == "job" then
            if local1 then
                say("\"I do what he does.\" Owings jerks his thumb towards Malloy digging away next to him. The fat man is trying to chisel through the rock wall using only a spoon. Owings's thumb hits him in the back.")
                _SwitchTalkTo(0, -243)
                say("Malloy looks over at you and gives you a friendly wave as he goes to stand up. As he does this, he bumps his head. There is a loud knocking noise. He says, \"Oooooooohh!\" very loudly. His cry echoes through the length of the mineshaft. You can feel dust from the cracks in the ceiling settling on your shoulder.*")
                _SwitchTalkTo(0, -239)
                say("Owings suddenly looks very nervous and throws both of his arms over his head. There is a terrible rumble and you feel the ground beneath you start to shake. After a moment the tremor subsides. Both of them look very relieved.*")
                _SwitchTalkTo(0, -243)
                say("Malloy puts one hand up to his bruised head and feels around on the ground with the other. He eventually finds and picks up a metal mining helmet. He gingerly places it over his head which appears to still be causing him pain. You can see that the top of Malloy's head barely fits into it.*")
                _SwitchTalkTo(0, -239)
                say("\"Allow me to rephrase that. I do what he does, except I always wears me helmet.\" With that Owings gives a big nod, throwing his head up and down. This causes his helmet to fall down over his eyes.*")
                _SwitchTalkTo(0, -243)
                say("Malloy looks over at you and at Owings, giving both of you an incredulous pouting grimace.*")
                _HideNPC(-243)
                _SwitchTalkTo(0, -239)
                _AddAnswer({"eyes", "helmet", "tremor"})
            else
                say("\"Normally I am digging, but as of late I cannot seem to find my partner Malloy. So I suppose my job is to look for him. I wonder where he has gone to?\"")
            end
        elseif answer == "tremor" then
            say("Owings puts his hand on your shoulder and puts a finger up to his lips. \"Shhhhh! Be very quiet! This is an old tunnel. Mikos, the foreman, says that any sudden loud noise could trigger a cave-in!\"*")
            _SwitchTalkTo(0, -243)
            say("Malloy goes back to digging. The exertion from his work causes his helmet to fall off. He sighs, picks it up, puts it back on and goes back to work. Almost immediately it falls off again. He puts it back on. It falls off. He puts it back on. Malloy grunts and sighs. It falls off. Dejected, he puts it back on. This happens again and again so many times that it is almost painful to watch. Finally, Malloy just lets the helmet lie there and throws a tantrum. He trembles and bites into his hand to keep from crying out in frustration.*")
            _SwitchTalkTo(0, -239)
            say("Owings steps up to Malloy and puts his finger to his lips. \"Shhhhhh!\" Looking down, Owings sees Malloy's helmet on the ground. \"Dost thou not remember Mikos telling thee to always wear thine helmet?\" he says. Owings picks it up and dusts it off. He pushes it down on top of Malloy's sore head, causing Malloy to wrinkle his face in pain. \"No need to thank me!\" Owings says. With that, he nods his head up and down, causing the front of his helmet to fall down over his eyes. He reaches out with his arms blindly.*")
            _SwitchTalkTo(0, -243)
            say("Malloy looks over at Owings and at you, giving you both a pouting grimace.*")
            _HideNPC(-243)
            _SwitchTalkTo(0, -239)
            set_flag(0x02D8, true)
            _RemoveAnswer("tremor")
            _AddAnswer("eyes")
        elseif answer == "eyes" then
            say("You reach up and tip Owings's helmet back so that it is no longer covering his eyes. He smiles at you thankfully. He takes off his helmet to scratch at the top of his head. He puts it back on and it immediately tilts back down over his eyes.*")
            _SwitchTalkTo(0, -243)
            say("Malloy watches this, smirks and slowly shakes his head.*")
            _HideNPC(-243)
            _SwitchTalkTo(0, -239)
            _RemoveAnswer("eyes")
            if not get_flag(0x02D8) then
                _AddAnswer("Owings's helmet")
            end
        elseif answer == "helmet" then
            say("\"Mikos, the foreman of this mine told us to always wear a helmet. It is very important. The two of us even sent a mining helmet to Lord British. A funny man dressed just like the Avatar told us of how Lord British had been hit in the head with falling objects - twice! So we sent a helmet to him.\"*")
            _SwitchTalkTo(0, -243)
            say("It appears Malloy can no longer stand being left out of the conversation. \"It was -mine- idea to send Lord British the helmet,\" he says proudly. \"While we have not yet heard back from him about it I am sure he will find some way to thank us.\" Malloy's helmet falls off and he stands there a long time before regaining the composure to pick it up again.*")
            _HideNPC(-243)
            _SwitchTalkTo(0, -239)
            _RemoveAnswer("helmet")
        elseif answer == "Owings's helmet" then
            say("\"Thou art a kind person to fix mine helmet for me,\" Owings says, giving you a big grin.")
            _SwitchTalkTo(0, -243)
            say("You see Malloy look very suspiciously at Owings's helmet. \"Thou art wearing mine hat!\" He lets out a growling \"Hmmmf!\" and snatches Owings's helmet off of his head. Malloy removes his helmet, casually tossing it to the ground. He then puts Owings's helmet on. It fits him perfectly. Malloy flashes you both a big condescending smile. With a curt nod he turns to go back to work.*")
            _SwitchTalkTo(0, -239)
            say("Owings looks at Malloy and then back to you. He is very confused. \"That was not very nice, Malloy! Thou didst take mine hat!\" Owings's face is covered with a large frown. His lower lip starts to tremble.")
            _HideNPC(-243)
            _SwitchTalkTo(0, -239)
            _RemoveAnswer({"eyes", "Owings's helmet"})
            _AddAnswer("mine hat")
        elseif answer == "mine hat" then
            say("Owings reaches over and takes the mining helmet off Malloy's head so carefully that he does not notice. Owings puts the helmet back on with a little sneaky laugh of triumph. Pointing to the hat he taps Malloy on the back to let him know what he's done.*")
            _SwitchTalkTo(0, -243)
            say("Malloy stops digging and goes to stand up. As he does this he hits his head on the ceiling. Once again it makes a loud knocking noise. Malloy says \"Oooooh!\" After shaking his head clear, he slowly steps toward Owings. He is quite angry - so angry that he does not notice that he has stepped into the other helmet and it is stuck onto his foot. Taking his spoon he whaps Owings in the nose with it.*")
            call_000FH(83)
            set_flag(0x02D9, true)
            _SwitchTalkTo(0, -239)
            say("Upon getting hit in the nose, Owings jerks his head back, causing his helmet to fall off. \"Ooh! Mine helmet!\" he cries.*")
            _SwitchTalkTo(0, -243)
            say("Malloy is so angry that he can no longer contain himself. \"That is not thine helmet! It is mine helmet!\" he shouts. This sends a thunderous echo down the mineshaft. You can feel a shower of falling dust and rocks. There is a low rumble and an ominous vibration of the earth. Owings and Malloy are so scared that in their panic they run right into each other. Malloy's foot - the one with the helmet stuck on it - slides out from under him and he lands on his posterior. Both cover their heads in anticipation of a massive cave-in.*")
            _HideNPC(-243)
            _SwitchTalkTo(0, -239)
            _RemoveAnswer("mine hat")
            _AddAnswer("cave-in")
        elseif answer == "cave-in" then
            say("After a few moments of fearful anticipation, the tremor subsides. The tunnel is still standing, none the worse for wear. \"I thought I was done for!\" says Owings. With that, a large piece of rock falls from the ceiling and lands squarely on Owings's head. It makes a loud knocking noise. Owings starts to pout and cry very childishly.")
            call_000FH(83)
            _SwitchTalkTo(0, -243)
            say("Malloy points at Owings and laughs until tears run down his face. Glancing up at the ceiling, Malloy starts feeling around for his helmet. Finally, feeling underneath himself, he pulls out his helmet, on top of which he had fallen! Looking at the hat, Malloy discovers that his bulk has crumpled it. It is ruined. He puts it on anyway, looking most ridiculous, and his tears of laughter turn to tears of sorrow. Now, both of them break down into fits of childish bawling. Malloy looks at Owings and says \"This is another fine mess thou hast gotten us into!\"*")
            set_flag(0x02DA, true)
            _HideNPC(-243)
            _SwitchTalkTo(0, -239)
            _RemoveAnswer("cave-in")
        elseif answer == "bye" then
            if local1 then
                say("Owings and Malloy, both unable to stop their crying, wave goodbye.*")
            else
                say("\"Good day to thee, ", local0, ".\"*")
            end
            return
        end
    end

    return
end

-- Helper functions
function say(...)
    print(table.concat({...}))
end

function wait_for_answer()
    return "bye" -- Placeholder
end

function get_flag(flag)
    return false -- Placeholder
end

function set_flag(flag, value)
    -- Placeholder
end