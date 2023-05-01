-- The Wicked Deity Dreadroot
Duel.LoadScript("util.lua")
Duel.LoadScript("util_divine.lua")
local s, id = GetID()

function s.initial_effect(c)
    Divine.WickedGod(s, c, 1)

    -- summon success
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
    e1:SetCode(EVENT_SUMMON_SUCCESS)
    e1:SetOperation(function(e, tp, eg, ep, ev, re, r, rp) Duel.SetChainLimitTillChainEnd(aux.FALSE) end)
    c:RegisterEffect(e1)

    -- half atk/def
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCode(EFFECT_SET_ATTACK_FINAL)
    e2:SetRange(LOCATION_MZONE)
    e2:SetTargetRange(LOCATION_MZONE, LOCATION_MZONE)
    e2:SetTarget(function(e, tc)
        local c = e:GetHandler()
        return tc ~= e:GetHandler() and Divine.GetDivineHierarchy(tc) <= Divine.GetDivineHierarchy(c)
    end)
    e2:SetValue(function(e, c) return math.ceil(c:GetAttack() / 2) end)
    c:RegisterEffect(e2)
    local e2b = e2:Clone()
    e2b:SetCode(EFFECT_SET_DEFENSE_FINAL)
    e2b:SetValue(function(e, c) return math.ceil(c:GetDefense() / 2) end)
    c:RegisterEffect(e2b)
end
