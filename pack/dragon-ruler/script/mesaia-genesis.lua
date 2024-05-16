-- Mesaia, Genesis of Dragons
Duel.LoadScript("util.lua")
local s, id = GetID()

function s.initial_effect(c)
    Pendulum.AddProcedure(c)

    -- pendulum summon limit
    local pe1 = Effect.CreateEffect(c)
    pe1:SetType(EFFECT_TYPE_FIELD)
    pe1:SetProperty(EFFECT_FLAG_PLAYER_TARGET + EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_CANNOT_NEGATE)
    pe1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    pe1:SetRange(LOCATION_PZONE)
    pe1:SetTargetRange(1, 0)
    pe1:SetTarget(function(e, c, tp, sumtp, sumpos) return not c:IsRace(RACE_DRAGON) and (sumtp & SUMMON_TYPE_PENDULUM) == SUMMON_TYPE_PENDULUM end)
    c:RegisterEffect(pe1)

    -- return from the pendulum zone
    local pe2 = Effect.CreateEffect(c)
    pe2:SetDescription(aux.Stringid(id, 0))
    pe2:SetCategory(CATEGORY_TOHAND)
    pe2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_F)
    pe2:SetCode(EVENT_SPSUMMON_SUCCESS)
    pe2:SetRange(LOCATION_PZONE)
    pe2:SetCondition(function(e, tp, eg, ep, ev, re, r, rp)
        return eg:IsExists(function(c, tp) return c:IsSummonType(SUMMON_TYPE_PENDULUM) and c:IsSummonPlayer(tp) end, 1, nil, tp)
    end)
    pe2:SetTarget(function(e, tp, eg, ep, ev, re, r, rp, chk)
        if chk == 0 then return true end
        Duel.SetOperationInfo(0, CATEGORY_TOHAND, e:GetHandler(), 1, 0, 0)
    end)
    pe2:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
        local c = e:GetHandler()
        if not c:IsRelateToEffect(e) then return end
        Duel.SendtoHand(c, nil, REASON_EFFECT)
    end)
    c:RegisterEffect(pe2)
end
