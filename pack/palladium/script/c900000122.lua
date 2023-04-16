-- Palladium Master of Chaos
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {71703785}
s.listed_series = {0xcf}
s.material_setcode = {0x13a, 0xcf}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- fusion summon
    Fusion.AddProcMix(c, false, false, 71703785, function(c, fc, sumtype, tp)
        return c:IsType(TYPE_RITUAL, fc, sumtype, tp) and
                   (c:IsSetCard(0xcf, fc, sumtype, tp) or c:IsSetCard(0x1048, fc, sumtype, tp))
    end)

    -- special summon limit
    local splimit = Effect.CreateEffect(c)
    splimit:SetType(EFFECT_TYPE_SINGLE)
    splimit:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    splimit:SetCode(EFFECT_SPSUMMON_CONDITION)
    splimit:SetValue(function(e, se, sp, st)
        return not e:GetHandler():IsLocation(LOCATION_EXTRA) or aux.fuslimit(e, se, sp, st)
    end)
    c:RegisterEffect(splimit)

    -- to hand
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_TOHAND)
    e1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DELAY + EFFECT_FLAG_CARD_TARGET)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetCountLimit(1, {id, 1})
    e1:SetCondition(function(e) return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION) end)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- special summon
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 1))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1, {id, 2})
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)

    -- banish
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 2))
    e3:SetCategory(CATEGORY_REMOVE)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetCountLimit(1, {id, 3})
    e3:SetCost(s.e3cost)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingTarget(Card.IsAbleToHand, tp, LOCATION_GRAVE, 0, 1, nil) end

    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_GRAVE)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_RTOHAND)
    local g = Duel.SelectTarget(tp, aux.NecroValleyFilter(Card.IsAbleToHand), tp, LOCATION_GRAVE, 0, 1, 1, nil)

    if #g > 0 then
        Duel.SendtoHand(g, nil, REASON_EFFECT)
        Duel.ConfirmCards(1 - tp, g)
    end
end

function s.e2filter(c, e, tp)
    return c:IsAttribute(ATTRIBUTE_LIGHT + ATTRIBUTE_DARK) and not c:IsCode(id) and
               c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and
                   Duel.IsExistingMatchingCard(s.e2filter, tp, LOCATION_GRAVE + LOCATION_REMOVED, 0, 1, nil, e, tp)
    end

    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_GRAVE + LOCATION_REMOVED)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    if Duel.GetLocationCount(tp, LOCATION_MZONE) <= 0 then return end

    local g = Utility.SelectMatchingCard(HINTMSG_SPSUMMON, tp, aux.NecroValleyFilter(s.e2filter), tp,
        LOCATION_GRAVE + LOCATION_REMOVED, 0, 1, 1, nil, e, tp)
    if #g > 0 then Duel.SpecialSummon(g, 0, tp, tp, false, false, POS_FACEUP) end
end

function s.e3filter(c) return c:IsAttribute(ATTRIBUTE_LIGHT + ATTRIBUTE_DARK) end

function s.e3check(sg, tp)
    return sg:GetClassCount(Card.GetAttribute) == 2 and
               Duel.IsExistingMatchingCard(Card.IsAbleToRemove, tp, 0, LOCATION_MZONE, 1, sg)
end

function s.e3cost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.CheckReleaseGroupCost(tp, s.e3filter, 2, false, s.e3check, nil) end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_RELEASE)
    local g = Duel.SelectReleaseGroupCost(tp, s.e3filter, 2, 2, false, s.e3check, nil)
    Duel.Release(g, REASON_COST)
end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove, tp, 0, LOCATION_MZONE, 1, nil) end

    local g = Duel.GetMatchingGroup(Card.IsAbleToRemove, tp, 0, LOCATION_MZONE, nil)
    Duel.SetOperationInfo(0, CATEGORY_REMOVE, g, #g, LOCATION_MZONE, 1 - tp)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local g = Duel.GetMatchingGroup(Card.IsAbleToRemove, tp, 0, LOCATION_MZONE, nil)
    if #g > 0 then Duel.Remove(g, 0, REASON_EFFECT) end
end
