-- Brunhild of the Nordic Ascendant
local s, id = GetID()
Duel.LoadScript("util.lua")
Duel.LoadScript("util_nordic.lua")

s.listed_series = {0x42}

function s.initial_effect(c)
    -- cannot disable summon
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_IGNORE_RANGE + EFFECT_FLAG_SET_AVAILABLE)
    e1:SetCode(EFFECT_CANNOT_DISABLE_SPSUMMON)
    e1:SetRange(LOCATION_MZONE)
    e1:SetTargetRange(1, 0)
    e1:SetTarget(function(e, c) return c:IsSetCard(0x42) end)
    c:RegisterEffect(e1)

    -- act limit
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EVENT_CHAINING)
    e2:SetRange(LOCATION_MZONE)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)

    -- special summon
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 0))
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1, id)
    e3:SetCost(s.e3cost)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    if ep == tp and re:GetHandler():IsSetCard(0x42) and
        re:IsHasCategory(CATEGORY_SPECIAL_SUMMON) then
        Duel.SetChainLimit(function(e, rp, tp) return tp == rp end)
    end
end

function s.e3filter1(c, e, tp)
    return c:IsDiscardable() and
               Duel.IsExistingMatchingCard(s.e3filter2, tp,
                                           LOCATION_HAND + LOCATION_DECK, 0, 1,
                                           c, e, tp)
end

function s.e3filter2(c, e, tp)
    return c:IsCanBeSpecialSummoned(e, 0, tp, false, false) and
               c:IsLevelBelow(5) and not c:IsType(TYPE_TUNER) and
               c:IsSetCard(0x42)
end

function s.e3cost(e, tp, eg, ep, ev, re, r, rp, chk)
    e:SetLabel(1)
    return true
end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        if Duel.GetLocationCount(tp, LOCATION_MZONE) <= 0 then
            return false
        end

        if e:GetLabel() ~= 0 then
            e:SetLabel(0)
            return Duel.IsExistingMatchingCard(s.e3filter1, tp, LOCATION_HAND,
                                               0, 1, nil, e, tp)
        else
            return Duel.IsExistingMatchingCard(s.e3filter2, tp,
                                               LOCATION_HAND + LOCATION_DECK, 0,
                                               1, nil, e, tp)
        end
    end

    if e:GetLabel() ~= 0 then
        e:SetLabel(0)
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_DISCARD)
        local g = Duel.SelectMatchingCard(tp, s.e3filter1, tp, LOCATION_HAND, 0,
                                          1, 1, nil, e, tp)
        Duel.SendtoGrave(g, REASON_COST + REASON_DISCARD)
    end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp,
                          LOCATION_HAND + LOCATION_DECK)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    if Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 then
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
        local g = Duel.SelectMatchingCard(tp, s.e3filter2, tp,
                                          LOCATION_HAND + LOCATION_DECK, 0, 1,
                                          1, nil, e, tp)
        if #g > 0 then
            Duel.SpecialSummon(g, 0, tp, tp, false, false, POS_FACEUP)
        end
    end
end
