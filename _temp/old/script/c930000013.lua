-- Beyla of the Nordic Champions
local s, id = GetID()
Duel.LoadScript("util.lua")
Duel.LoadScript("util_nordic.lua")

s.listed_series = {0x4b, 0x42}

function s.initial_effect(c)
    -- extra summon
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1, id + 1000000, EFFECT_COUNT_CODE_OATH)
    e1:SetCondition(s.e1con)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- summon
    local e2 = Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_SUMMON)
    e2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_SUMMON_SUCCESS)
    e2:SetRange(LOCATION_HAND)
    e2:SetCountLimit(1, id + 2000000, EFFECT_COUNT_CODE_OATH)
    e2:SetCondition(s.e2con)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)
    local e2b = e2:Clone()
    e2b:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
    c:RegisterEffect(e2b)
    local e3b = e2:Clone()
    e3b:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e3b)
end

function s.e1con(e, tp, eg, ep, ev, re, r, rp)
    return Duel.GetTurnPlayer() == tp and not e:GetHandler():IsPublic()
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    c:RegisterFlagEffect(id, RESET_EVENT + RESETS_STANDARD + RESET_PHASE +
                             PHASE_END, 0, 1)

    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetCode(EFFECT_PUBLIC)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
    c:RegisterEffect(ec1)

    local ec2 = Effect.CreateEffect(c)
    ec2:SetDescription(aux.Stringid(id, 0))
    ec2:SetType(EFFECT_TYPE_FIELD)
    ec2:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
    ec2:SetRange(LOCATION_HAND)
    ec2:SetTargetRange(LOCATION_HAND + LOCATION_MZONE, 0)
    ec2:SetCondition(function(e)
        return e:GetHandler():GetFlagEffect(id) ~= 0 and
                   e:GetHandler():IsPublic()
    end)
    ec2:SetTarget(function(e, c)
        return c:IsSetCard(0x42) and c ~= e:GetHandler()
    end)
    ec2:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
    c:RegisterEffect(ec2)
end

function s.e2con(e, tp, eg, ep, ev, re, r, rp)
    local ec = eg:GetFirst()
    return ep == tp and ec:IsSetCard(0x42)
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return c:IsSummonable(true, nil) end
    Duel.SetOperationInfo(0, CATEGORY_SUMMON, c, 1, 0, 0)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) then return end
    Duel.Summon(tp, c, true, nil)
end
