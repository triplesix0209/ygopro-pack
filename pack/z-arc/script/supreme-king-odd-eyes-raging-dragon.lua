-- Supreme King Odd-Eyes Raging Dragon
Duel.LoadScript("util.lua")
local s, id = GetID()

s.material_setcode = {SET_ODD_EYES}
s.listed_series = {SET_ODD_EYES}

function s.initial_effect(c)
    c:EnableReviveLimit()
    Pendulum.AddProcedure(c, false)

    -- overscale
    local pensum = Effect.CreateEffect(c)
    pensum:SetType(EFFECT_TYPE_SINGLE)
    pensum:SetCode(511004423)
    c:RegisterEffect(pensum)

    -- special summon limit
    local splimit = Effect.CreateEffect(c)
    splimit:SetType(EFFECT_TYPE_SINGLE)
    splimit:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    splimit:SetCode(EFFECT_SPSUMMON_CONDITION)
    splimit:SetValue(function(e, se, sp, st)
        return (st & SUMMON_TYPE_LINK) == SUMMON_TYPE_LINK or (st & SUMMON_TYPE_PENDULUM) == SUMMON_TYPE_PENDULUM
    end)
    c:RegisterEffect(splimit)

    -- place into pendulum zone
    local me4 = Effect.CreateEffect(c)
    me4:SetDescription(2203)
    me4:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    me4:SetCode(EVENT_DESTROYED)
    me4:SetProperty(EFFECT_FLAG_DELAY)
    me4:SetCondition(function(e, tp, eg, ep, ev, re, r, rp) return e:GetHandler():IsPreviousLocation(LOCATION_MZONE) and e:GetHandler():IsFaceup() end)
    me4:SetTarget(function(e, tp, eg, ep, ev, re, r, rp, chk) if chk == 0 then return Duel.CheckPendulumZones(tp) end end)
    me4:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
        if not Duel.CheckPendulumZones(tp) then return end
        local c = e:GetHandler()
        if c:IsRelateToEffect(e) then Duel.MoveToField(c, tp, tp, LOCATION_PZONE, POS_FACEUP, true) end
    end)
    c:RegisterEffect(me4)
end
