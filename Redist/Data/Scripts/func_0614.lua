require "U7LuaFuncs"
-- Delivers context-specific dialogue from an NPC (likely the Guardian or an ally), guiding or taunting the Avatar during the Black Gate quest.
function func_0614(eventid, itemref)
    local local0

    switch_talk_to(-277, 0)
    local0 = get_context_value() -- Unmapped intrinsic

    if local0 == 1 then
        say("\"Yes, rest, my friend. Rest and heal, so that you are strong and able to face the perils before you. Pleasant dreams!\"")
        hide_npc(-277)
    elseif local0 == 2 then
        say("\"Go inside. Tell them you are the Avatar!\"")
        hide_npc(-277)
    elseif local0 == 3 then
        say("\"Thank you for the information in the notebook, Avatar! It was most useful! Ha ha ha ha ha!\"")
        hide_npc(-277)
    elseif local0 == 4 then
        say("\"Do not go in! It is a trap! Do you not see? It is a trap!\"")
        hide_npc(-277)
    elseif local0 == 5 then
        say("\"You are not going to trust the Time Lord are you? Careful, my friend -- do not believe him!\"")
        hide_npc(-277)
    elseif local0 == 6 then
        say("\"Do not go in! You will surely die!\"")
        hide_npc(-277)
    elseif local0 == 7 then
        say("\"Avatar, you are not welcome here!\"")
        hide_npc(-277)
    elseif local0 == 8 then
        say("\"Are you sure? Think again!\"")
        hide_npc(-277)
    elseif local0 == 9 then
        say("\"At least one sign is true, and at least one sign is false.\"")
        hide_npc(-277)
    elseif local0 == 10 then
        say("\"Two of these signs are either true or false!\"")
        hide_npc(-277)
    elseif local0 == 11 then
        say("\"No no no! Think again!\"")
        hide_npc(-277)
    elseif local0 == 12 then
        say("\"Each sign could be either true or false!\"")
        hide_npc(-277)
    elseif local0 == 13 then
        say("\"Stop the Avatar! I will come through the Black Gate now! Do not let him near!\"")
        hide_npc(-277)
    elseif local0 == 14 then
        say("\"So, Avatar! The moment of truth has come! You can destroy the Black Gate, but you will never return to your beloved Earth. Or you can come through now and go home! It is your choice!\"")
        hide_npc(-277)
    elseif local0 > 17 and local0 < 22 then
        say("\"Ha ha ha ha ha ha!\"*")
        hide_npc(-277)
    elseif local0 == 22 then
        say("\"Poor Avatar... poor, poor Avatar...\"")
        hide_npc(-277)
    elseif local0 == 23 then
        say("\"Well done, my friend! You are truly an Avatar!\"")
        hide_npc(-277)
    elseif local0 == 24 then
        say("\"You are travelling in the wrong direction, my friend!\"")
        hide_npc(-277)
    elseif local0 == 25 then
        say("\"Go away!!\"")
        hide_npc(-277)
    elseif local0 == 26 then
        say("\"That is precisely the thing to do, Avatar!\"")
        hide_npc(-277)
    elseif local0 == 27 then
        say("\"You had best not do that, Avatar!\"")
        hide_npc(-277)
    elseif local0 == 28 then
        say("\"Do you really know where you are going, Avatar?\"")
        hide_npc(-277)
    elseif local0 == 29 then
        say("\"Yes, that is the proper direction to travel, Avatar.\"")
        hide_npc(-277)
    else
        say("\"Ho ho ha ha heh heh heh!\"")
    end

    return
end