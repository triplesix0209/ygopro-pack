-- The Origin Messiah
Duel.LoadScript("util.lua")
Duel.LoadScript("util_messiah.lua")
local s, id = GetID()

function s.initial_effect(c)
    Messiah.RegisterMessiahBabyEffect(s, c, id, LOCATION_HAND + LOCATION_DECK, function(c) return c:IsLevelBelow(4) end)

    -- link summon
    Link.AddProcedure(c,
        function(c, sc, sumtype, tp) return not c:IsType(TYPE_LINK, sc, sumtype, tp) and not c:IsType(TYPE_TOKEN, sc, sumtype, tp) end, 2, 2)

    -- avoid battle damage
    local me1 = Effect.CreateEffect(c)
    me1:SetType(EFFECT_TYPE_SINGLE)
    me1:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
    me1:SetValue(1)
    c:RegisterEffect(me1)
end
