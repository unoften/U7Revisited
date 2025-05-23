require "U7LuaFuncs"
-- Function 08AA: Manages armor purchase dialogue
function func_08AA()
    -- Local variables (13 as per .localc)
    local local0, local1, local2, local3, local4, local5, local6, local7, local8, local9, local10, local11, local12

    callis_0007()
    local0 = true
    local1 = {"gorget", "scale armour", "crested helm", "nothing"}
    local2 = {586, 570, 542, 0}
    local3 = {30, 120, 150, 0}
    local4 = {"a ", "", "a ", ""}
    local5 = 0
    local6 = ""
    local7 = 1
    local8 = -359

    while true do
        say("What wouldst thou like to buy?")
        if not local0 then
            callis_0008()
            callis_0008()
            return
        end

        local9 = call_090CH(local1)
        if local9 == 1 then
            say("Fine.")
            local0 = false
        else
            local10 = call_091BH(local6, local3[local9], local5, local1[local9], local4[local9])
            local11 = 0
            say("^", local10, " Is that acceptable?")
            local12 = call_090AH()
            if local12 then
                local11 = call_08F8H(true, 1, 0, local3[local9], local7, local8, local2[local9])
            end
            if local11 == 1 then
                say("Done!")
            elseif local11 == 2 then
                say("Thou cannot possibly carry that much!")
            elseif local11 == 3 then
                say("Thou dost not have enough gold for that!")
            end
        end
        say("Wouldst thou like something else?")
        local0 = call_090AH()
    end

    return
end

-- Helper functions
function say(...)
    print(table.concat({...}))
end