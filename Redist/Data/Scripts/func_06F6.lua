require "U7LuaFuncs"
-- Function 06F6: Manages Arcadion's dialogue and interactions
function func_06F6(eventid, itemref)
    -- Local variables (30 as per .localc)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9
    local local10, local11, local12, local13, local14, local15, local16, local17, local18, local19
    local local20, local21, local22, local23, local24, local25, local26, local27, local28, local29

    if not get_flag(0x032F) then
        local0 = false
        local1 = callis_0035(8, 10, 154, itemref)
        while sloop() do
            local4 = local1
            if not call_GetContainerItems(4, 240, 797, local4) then
                local0 = local4
            end
        end
        if not local0 then
            _SwitchTalkTo(0, -290)
            say("\"Yes, Master. How may I serve thee...\" The wavering visage in the mirror hesitates for a moment, \"Thou art not my master.\"")
            _SwitchTalkTo(1, -286)
            local5 = get_flag(0x0310) and "the mage" or "Erethian"
            say("Suprised, ", local5, " looks around and says, \"I don't recall summoning thee. Nevermind, I have no need of thee at the current time. Begone!\" The old man waves his hand, negligently.")
            _SwitchTalkTo(0, -290)
            say("Through a tightly clenched smile, the figure replies, \"Very well...\" And after a significant pause, \"Master.\"*")
            call_0843H()
        else
            if not get_flag(0x0332) then
                if not get_flag(0x0333) then
                    say("Arcadion appears truly astonished, \"For what dost thou wait?! I beg of thee! Release me!\"")
                    call_0843H()
                else
                    local6 = callis_0035(0, 15, 760, itemref)
                    if not local6 then
                        say("\"There is a gem nearby that can free me! It is a small blue stone. Take it, quickly, and use it to free me of this accursed mirror!\" The large daemon seethes with pent up frustration.*")
                        call_0843H()
                    else
                        say("\"Can I be of some small assistance in thy quest to release me. If so, thou hast but to ask.\" Arcadion's smile stretches from ear to ear.")
                        _AddAnswer({"bye", "release", "job", "name"})
                        call_0844H()
                    end
                end
            else
                say("\"Thou hast within thy possessions a small blue gem. It can be used to free me! Crack this accursed mirror with it! I'll enter it as I am freed!\" Arcadion looks prepared to burst from the mirror.*")
                _AddAnswer({"bye", "release", "job", "name"})
                call_0844H()
            end
        end
    else
        _SwitchTalkTo(0, -292)
        if not get_flag(0x0343) then
            local10 = callis_0001({1, 17447, 8040, 1, 17447, 8041, 1, 17447, 8042, 4, 7769}, callis_001B(-356))
            local15 = callis_0001({1782, 8021, 7, 7719}, itemref)
            set_flag(0x0343, true)
        elseif not get_flag(0x0344) then
            local13 = callis_0018(callis_001B(-356))
            callis_0053(3, 0, 0, 0, local13[2], local13[1], 17)
            callis_0053(-1, 0, 0, 0, local13[2], local13[1], 17)
            call_000FH(62)
            local15 = callis_0001({1782, 8021, 3, 7719}, itemref)
            set_flag(0x0344, true)
        end
        say("The sword glimmers darkly as you speak to it. \"Greetings, my master. And how can thy humble servant aid thee?\" The daemon's voice has regained much of its oddly disturbing humor.")
        set_flag(0x0313, true)
    end

    if eventid == 1 then
        callis_007E()
        calle_0690H(itemref)
    elseif eventid == 2 then
        if not get_flag(0x0313) then
            if not get_flag(0x0343) then
                local10 = callis_0001({1, 17447, 8040, 1, 17447, 8041, 1, 17447, 8042, 4, 7769}, callis_001B(-356))
                local15 = callis_0001({1782, 8021, 7, 7719}, itemref)
                set_flag(0x0343, true)
            elseif not get_flag(0x0344) then
                local13 = callis_0018(callis_001B(-356))
                callis_0053(3, 0, 0, 0, local13[2], local13[1], 17)
                callis_0053(-1, 0, 0, 0, local13[2], local13[1], 17)
                call_000FH(62)
                local15 = callis_0001({1782, 8021, 3, 7719}, itemref)
                set_flag(0x0344, true)
            end
            say("\"Yes, master. What dost thou seek of thy servant?\" Arcadion asks you in a deep, harmonic voice.")
            set_flag(0x0313, true)
        else
            say("\"Yes, master. What dost thou seek of thy servant?\" Arcadion asks you in a deep, harmonic voice.")
        end
        _AddAnswer({"powers", "bye", "job", "name"})
        if get_flag(0x030E) and not get_flag(0x030C) then
            _AddAnswer("help")
        end
        local11 = false
        local12 = false
        local13 = false
        local14 = false
        local15 = false
        while true do
            local answer = wait_for_answer()
            if answer == "name" then
                say("The daemon sword's tone is rather ominous as he says, \"I am, and ever shall be, thy servant Arcadion.\"")
                _RemoveAnswer("name")
            elseif answer == "job" then
                say("\"I am the Shade Blade. My destiny is to serve thee until we are...\" The sword pauses, \"parted.\"")
                _RemoveAnswer("job")
            elseif answer == "powers" then
                if not callis_0072(-359, 707, 1, callis_001B(-356)) then
                    say("\"I needs must be in thy hand, master, if thou wishest to use my powers.\"")
                else
                    say("\"Which of my powers dost thou seek to use?\"")
                    _SaveAnswers()
                    _AddAnswer({"none", "Return", "Death", "Fire", "Magic"})
                end
            elseif answer == "help" then
                say("Arcadion's voice is smug as he replies to your request for assistance. \"Yes, I can help thee if thou wishest to exile what remains of Exodus to the Void. Firstly, thou shalt have need of the lenses of which the doddering, old fool spoke. Next thou needs must have the three Talismans of Principle. And finally, make sure that there are lit torches upon the walls to either side of the pedestal upon which the Dark Core rests.\"")
                _AddAnswer({"talismans", "lenses"})
                _RemoveAnswer("help")
            elseif answer == "lenses" then
                say("\"The concave and convex lenses which thou used to place the Codex of Infinite Wisdom within the Void, I believe now sit forgotten in the Museum of Britannia. They must be placed between the Dark Core and the torches on either side of the pedestal\"")
                _RemoveAnswer("lenses")
            elseif answer == "talismans" then
                say("\"The Talismans of Principle must be placed upon the Dark Core like wedges in a pie.\"")
                _RemoveAnswer("talismans")
            elseif answer == "none" then
                say("\"As thou wish, master. I but seek to serve thee.\"")
                _RestoreAnswers()
            elseif answer == "Magic" then
                local16 = callis_003B()
                if local16 == 7 or local16 == 0 or local16 == 1 then
                    call_0845H(true)
                else
                    say("The blade croons quietly, \"Alas, master. My energies seem a trifle low. Perhaps if thou were to find some creature to slay, my power would be sufficient. After all, I have needs just as thou dost.\"")
                end
            elseif answer == "Death" then
                say("\"Where is the corpse of which thou dost speak?\" The dark sword begins to vibrate in your hand.*")
                _HideNPC(-292)
                local11 = _ItemSelectModal()
                local17 = call_GetItemType(local11)
                local18 = callis_0018(local11)
                _SwitchTalkTo(0, -292)
                if not callis_0031(local11) then
                    if local17 == 721 or local17 == 989 then
                        say("The daemon speaks with a sanctimonious tone. \"I could not in honor take the life of my most wondrous master.\"")
                    elseif local17 == 466 then
                        if callis_0019(local11, callis_001B(-356), itemref) <= 5 then
                            say("\"Yes! I have long sought the end of Lord British, my traitorous master.\"")
                            local19 = call_0908H()
                            _SwitchTalkTo(0, -23)
                            say("\"", local19, ", for what reason art thou brandishing that black sword in my presence?\"")
                            _SwitchTalkTo(0, -292)
                            say("The daemon responds, using your mouth. \"This blade is thy doom,...\" You spit the words, \"Lord British!\"")
                            _HideNPC(-292)
                            _SwitchTalkTo(0, -356)
                            say("Lord British looks truly taken aback, his eyes narrow calculatingly. \"What foul treachery is this?\"")
                            _SwitchTalkTo(0, -23)
                            say("You find yourself unable to respond, and your muscles are clenching as if to lash out with the wicked blade in your hand.")
                            _SwitchTalkTo(0, -23)
                            say("\"Perhaps when thou art sitting in a dungeon, thy tongue will loosen.\"")
                            say("\"Guards!\"*")
                            local14 = true
                        else
                            say("The Shade Blade lets out a harsh whisper. \"Move a little closer to him, and I'll perform this task for thee, master.\"")
                        end
                    elseif local17 == 482 or local17 == 403 then
                        say("\"Alas master, this one is protected by a power greater than mine. His destiny lies elsewhere.\"")
                    elseif call_0849H(local17) then
                        say("The sword recoils in something akin to horror. \"That creature is beyond even my power. I suggest that thou hackest it to bits, if possible, then burn the pieces.\"")
                    elseif local17 == 504 then
                        if callis_0019(local11, callis_001B(-356), itemref) <= 5 then
                            if not call_GetContainerItems(4, 241, 797, local11) then
                                say("\"Ah, Dracothraxus. We meet once again. 'Tis a pity thou shan't survive our meeting this time. Perhaps if thou hadst given the gem to me when first I asked, none of this unpleasantness would be necessary.\"")
                                _SwitchTalkTo(0, -293)
                                say("The dragon responds with great resignation. \"My will is not mine own in this matter, Arcadion. Mayhap thou art finding too, that thy will is not thine own.\"")
                                _HideNPC(-293)
                                _SwitchTalkTo(0, -292)
                                say("The daemon, possibly stung by the dragon's repartee, falls silent and goes to its bloody work.*")
                                local15 = true
                            else
                                say("The Shade Blade croons softly. \"Move a little closer to the dragon, and I'll end its life for thee, master.\"")
                            end
                        else
                            say("\"I owe thee quite a favor for this, master. I thank thee for allowing me this, my revenge!\"*")
                            local15 = true
                        end
                    elseif local17 == 154 then
                        if callis_0019(local11, callis_001B(-356), itemref) <= 5 then
                            if not call_GetContainerItems(4, 240, 797, local11) then
                                say("\"I owe thee quite a favor for this, master. I thank thee for allowing me this, my revenge!\"*")
                                local15 = true
                            else
                                say("\"Move closer to him, and I'll see that his life plagues thee no more.\" The dark sword sounds almost gleeful at this prospect.")
                            end
                        else
                            say("\"This creature is not strictly speaking,... living. Thy best course of action would be to smash it to pieces\" You hear a smile in Arcadion's voice.")
                        end
                    elseif call_0848H(local17) then
                        if callis_0019(local11, callis_001B(-356), itemref) <= 5 then
                            say("\"Very well, master. If thou cannot dispatch this foe thyself, I shall do it for thee.\"")
                            local15 = true
                        else
                            say("\"I must get closer to this one in order to enjoy its essence.\" The blade hums eagerly as it tugs in the direction of your selected target.")
                        end
                    else
                        say("The daemon sword abruptly ceases its vibration. \"This being is hardly worth a death the likes of which I would visit upon it. Call upon me again when thou art faced with a more worthy opponent.\"")
                    end
                else
                    say("\"Perhaps thou misunderstands my meaning. I do not raise the dead... I slay the living.\" The last is spoken in a sibilant whisper.")
                end
            elseif answer == "Fire" then
                say("\"And what, pray tell, is the intended target of thy immense and most puissant wrath, O' Master of Infinite Destruction?\"")
                _HideNPC(-292)
                local12 = true
            elseif answer == "bye" then
                say("\"Forgive me master, but I shan't be leaving. However, thou mayest cease thy speaking... if thou dost wish it.\"*")
                break
            elseif answer == "Return" then
                if not call_08E7H() then
                    say("\"Ah... home again. I never tire of rocky little islands. Dost thou truly wish to go to the forsaken Isle of Fire?\"")
                    if call_090AH() then
                        say("\"I see. Very well, master. But let us not forget this little favor...\" The gem in the hilt of the sword glows brightly then everything dims.*")
                        local13 = true
                    else
                        say("\"It is good. Sense returns to the Virtuous Wonder. Thou art truly without peer in the arena of thought, master.\"")
                    end
                else
                    say("\"Forgive me, master, but are we not already on or near the Isle of Fire? Though, why one would wish to remain here on this forsaken piece of rock, I have no idea.\"")
                end
            end
        end
    end

    if local12 then
        local11 = _ItemSelectModal()
        local17 = call_GetItemType(local11)
        local18 = callis_0018(local11)
        _SwitchTalkTo(0, -292)
        if not callis_0031(local11) then
            if local17 == 721 or local17 == 989 then
                say("The daemon speaks with a sanctimonious tone. \"I could not in honor take the life of my most wondrous master.\"")
            elseif local17 == 466 then
                if callis_0019(local11, callis_001B(-356), itemref) <= 5 then
                    say("\"Yes! I have long sought the end of Lord British, my traitorous master.\"")
                    local19 = call_0908H()
                    _SwitchTalkTo(0, -23)
                    say("\"", local19, ", for what reason art thou brandishing that black sword in my presence?\"")
                    _SwitchTalkTo(0, -292)
                    say("The daemon responds, using your mouth. \"This blade is thy doom,...\" You spit the words, \"Lord British!\"")
                    _HideNPC(-292)
                    _SwitchTalkTo(0, -356)
                    say("Lord British looks truly taken aback, his eyes narrow calculatingly. \"What foul treachery is this?\"")
                    _SwitchTalkTo(0, -23)
                    say("You find yourself unable to respond, and your muscles are clenching as if to lash out with the wicked blade in your hand.")
                    _SwitchTalkTo(0, -23)
                    say("\"Perhaps when thou art sitting in a dungeon, thy tongue will loosen.\"")
                    say("\"Guards!\"*")
                    local14 = true
                else
                    say("The Shade Blade lets out a harsh whisper. \"Move a little closer to him, and I'll perform this task for thee, master.\"")
                end
            elseif local17 == 482 or local17 == 403 then
                say("\"Alas master, this one is protected by a power greater than mine. His destiny lies elsewhere.\"")
            elseif call_0849H(local17) then
                say("The sword recoils in something akin to horror. \"That creature is beyond even my power. I suggest that thou hackest it to bits, if possible, then burn the pieces.\"")
            elseif local17 == 504 then
                if callis_0019(local11, callis_001B(-356), itemref) <= 5 then
                    if not call_GetContainerItems(4, 241, 797, local11) then
                        say("\"Ah, Dracothraxus. We meet once again. 'Tis a pity thou shan't survive our meeting this time. Perhaps if thou hadst given the gem to me when first I asked, none of this unpleasantness would be necessary.\"")
                        _SwitchTalkTo(0, -293)
                        say("The dragon responds with great resignation. \"My will is not mine own in this matter, Arcadion. Mayhap thou art finding too, that thy will is not thine own.\"")
                        _HideNPC(-293)
                        _SwitchTalkTo(0, -292)
                        say("The daemon, possibly stung by the dragon's repartee, falls silent and goes to its bloody work.*")
                        local15 = true
                    else
                        say("The Shade Blade croons softly. \"Move a little closer to the dragon, and I'll end its life for thee, master.\"")
                    end
                else
                    say("\"I owe thee quite a favor for this, master. I thank thee for allowing me this, my revenge!\"*")
                    local15 = true
                end
            elseif local17 == 154 then
                if callis_0019(local11, callis_001B(-356), itemref) <= 5 then
                    if not call_GetContainerItems(4, 240, 797, local11) then
                        say("\"I owe thee quite a favor for this, master. I thank thee for allowing me this, my revenge!\"*")
                        local15 = true
                    else
                        say("\"Move closer to him, and I'll see that his life plagues thee no more.\" The dark sword sounds almost gleeful at this prospect.")
                    end
                else
                    say("\"This creature is not strictly speaking,... living. Thy best course of action would be to smash it to pieces\" You hear a smile in Arcadion's voice.")
                end
            elseif call_0848H(local17) then
                if callis_0019(local11, callis_001B(-356), itemref) <= 5 then
                    say("\"Very well, master. If thou cannot dispatch this foe thyself, I shall do it for thee.\"")
                    local15 = true
                else
                    say("\"I must get closer to this one in order to enjoy its essence.\" The blade hums eagerly as it tugs in the direction of your selected target.")
                end
            else
                say("The daemon sword abruptly ceases its vibration. \"This being is hardly worth a death the likes of which I would visit upon it. Call upon me again when thou art faced with a more worthy opponent.\"")
            end
        else
            say("\"Perhaps thou misunderstands my meaning. I do not raise the dead... I slay the living.\" The last is spoken in a sibilant whisper.")
        end
    end

    if local14 then
        local10 = callis_0001({8033, 2, 17447, 8042, 1, 17447, 8041, 2, 17447, 8040, 2, 17447, 8548, local19, 7769}, callis_001B(-356))
        callis_0088(1, local11)
        if not callis_0088(1, local11) then
            local20 = (local19 + 4) % 8
            local21 = callis_0001({1807, 8021, 7, 17447, 8036, 3, 8487, local20, 7769}, local11)
        else
            local21 = callis_0001({1807, 8021, 12, 7719}, local11)
        end
    elseif local15 then
        local10 = callis_0001({8033, 2, 17447, 8042, 1, 17447, 8041, 1, 17447, 8040, 1, 17447, 8548, local19, 7769}, callis_001B(-356))
        callis_0088(1, local11)
        if not callis_0088(1, local11) then
            local20 = (local19 + 4) % 8
            local21 = callis_0001({1807, 8021, 1, 17447, 8045, 1, 17447, 8044, 4, 17447, 8036, 2, 8487, local20, 7769}, local11)
        else
            local21 = callis_0001({1807, 8021, 12, 7719}, local11)
        end
    end

    if local13 then
        call_06FCH(itemref)
    end

    return
end

-- Helper functions
function sloop()
    return false -- Placeholder
end

function get_flag(flag)
    return false -- Placeholder
end

function set_flag(flag, value)
    -- Placeholder
end

function say(...)
    print(table.concat({...}))
end

function wait_for_answer()
    return "" -- Placeholder
end