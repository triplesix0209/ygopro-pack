-- Astrochrono Sorcerer
Duel.LoadScript("util.lua")
local s, id = GetID()

function s.initial_effect(c)
    c:EnableReviveLimit()
    Pendulum.AddProcedure(c, false)

    -- place into pendulum zone
    local me9 = Effect.CreateEffect(c)
    me9:SetDescription(2203)
    me9:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    me9:SetCode(EVENT_DESTROYED)
    me9:SetProperty(EFFECT_FLAG_DELAY)
    me9:SetCondition(function(e, tp, eg, ep, ev, re, r, rp)
        local c = e:GetHandler()
        return c:IsPreviousLocation(LOCATION_MZONE) and c:IsFaceup()
    end)
    me9:SetTarget(function(e, tp, eg, ep, ev, re, r, rp, chk) if chk == 0 then return Duel.CheckPendulumZones(tp) end end)
    me9:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
        if not Duel.CheckPendulumZones(tp) then return end
        local c = e:GetHandler()
        if c:IsRelateToEffect(e) then Duel.MoveToField(c, tp, tp, LOCATION_PZONE, POS_FACEUP, true) end
    end)
    c:RegisterEffect(me9)
end
