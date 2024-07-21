-- The Newborn Messiah
Duel.LoadScript("util.lua")
Duel.LoadScript("util_messiah.lua")
local s, id = GetID()

function s.initial_effect(c)
    Messiah.RegisterMessiahBabyEffect(s, c, id, 3)

    -- link summon
    Link.AddProcedure(c, function(c, sc, sumtype, tp) return not c:IsType(TYPE_LINK, sc, sumtype, tp) end, 3, 3)

    -- indes & avoid battle damage
    local me1 = Effect.CreateEffect(c)
    me1:SetType(EFFECT_TYPE_SINGLE)
    me1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
    me1:SetValue(1)
    c:RegisterEffect(me1)
    local me1b = me1:Clone()
    me1b:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
    c:RegisterEffect(me1b)
end
