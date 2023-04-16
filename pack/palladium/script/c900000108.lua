-- Palladium Knight of King
Duel.LoadScript("util.lua")
local s, id = GetID()

function s.initial_effect(c)
    c:AddSetcodesRule(id, true, 0x13a)

    -- special summon itself
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCode(EVENT_TO_HAND)
    e1:SetCountLimit(1, {id, 1})
    e1:SetCondition(s.e1con)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- special summon other
    local e2 = Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_SUMMON_SUCCESS)
    e2:SetCountLimit(1, {id, 2})
    e2:SetCondition(s.e2con)
    e2:SetCost(s.e2cost)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)
    local e2b = e2:Clone()
    e2b:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e2b)

    -- gain effect
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
    e3:SetCode(EVENT_BE_MATERIAL)
    e3:SetCondition(s.e3con)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)
end

function s.e1con(e, tp, eg, ep, ev, re, r, rp) return not e:GetHandler():IsReason(REASON_DRAW) end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and c:IsCanBeSpecialSummoned(e, 0, tp, false, false) end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, c, 1, 0, 0)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) then return end

    Duel.SpecialSummon(c, 0, tp, tp, false, false, POS_FACEUP)
end

function s.e2filter1(c) return c:IsFaceup() and c:IsLevel(4) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_WARRIOR) end

function s.e2filter2(c, e, tp)
    return c:IsLevel(5) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_WARRIOR) and
               c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end

function s.e2con(e, tp, eg, ep, ev, re, r, rp)
    return Duel.IsExistingMatchingCard(s.e2filter1, tp, LOCATION_MZONE, 0, 1, e:GetHandler())
end

function s.e2cost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return c:GetAttackAnnouncedCount() == 0 end

    local ec1 = Effect.CreateEffect(c)
    ec1:SetDescription(3206)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_OATH + EFFECT_FLAG_CLIENT_HINT)
    ec1:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
    c:RegisterEffect(ec1)
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and
                   Duel.IsExistingMatchingCard(s.e2filter2, tp, LOCATION_HAND + LOCATION_DECK + LOCATION_GRAVE, 0, 1, nil, e, tp)
    end

    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_HAND + LOCATION_DECK + LOCATION_GRAVE)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if Duel.GetLocationCount(tp, LOCATION_MZONE) <= 0 then return end

    local tc = Utility.SelectMatchingCard(HINTMSG_SPSUMMON, tp, aux.NecroValleyFilter(s.e2filter2), tp,
        LOCATION_HAND + LOCATION_DECK + LOCATION_GRAVE, 0, 1, 1, nil, e, tp):GetFirst()
    if not tc then return end

    Duel.SpecialSummon(tc, 0, tp, tp, false, false, POS_FACEUP)
end

function s.e3con(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local rc = c:GetReasonCard()
    return (r & REASON_FUSION + REASON_LINK) ~= 0 and rc:IsAttribute(ATTRIBUTE_LIGHT) and rc:IsRace(RACE_WARRIOR)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local rc = c:GetReasonCard()

    local ec1 = Effect.CreateEffect(rc)
    ec1:SetDescription(aux.Stringid(id, 0))
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetProperty(EFFECT_FLAG_SINGLE_RANGE + EFFECT_FLAG_CLIENT_HINT)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
    rc:RegisterEffect(ec1, true)

    if not rc:IsType(TYPE_EFFECT) then
        local ec2 = Effect.CreateEffect(c)
        ec2:SetType(EFFECT_TYPE_SINGLE)
        ec2:SetCode(EFFECT_ADD_TYPE)
        ec2:SetValue(TYPE_EFFECT)
        ec2:SetReset(RESET_EVENT + RESETS_STANDARD)
        rc:RegisterEffect(ec2, true)
    end

    local ec3 = Effect.CreateEffect(c)
    ec3:SetDescription(aux.Stringid(id, 2))
    ec3:SetType(EFFECT_TYPE_FIELD)
    ec3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    ec3:SetRange(LOCATION_MZONE)
    ec3:SetCode(EFFECT_CANNOT_ACTIVATE)
    ec3:SetTargetRange(0, 1)
    ec3:SetCondition(function(e) return Duel.GetAttacker() == e:GetHandler() end)
    ec3:SetValue(function(e, re) return re:IsHasType(EFFECT_TYPE_ACTIVATE) end)
    ec3:SetReset(RESET_EVENT + RESETS_STANDARD)
    rc:RegisterEffect(ec3, true)
end
