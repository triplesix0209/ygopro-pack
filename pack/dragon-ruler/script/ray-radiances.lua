-- Ray, Dragon Ruler of Radiances
Duel.LoadScript("util.lua")
local s, id = GetID()

function s.initial_effect(c)
    -- special summon
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1, id)
    e1:SetCost(s.e1cost)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)
end

s.listed_names = {900007016}

function s.e1filter1(c) return (c:IsRace(RACE_DRAGON) or c:IsAttribute(ATTRIBUTE_LIGHT)) and c:IsDiscardable() end

function s.e1filter2(c, e, tp) return c:IsCode(900007016) and c:IsCanBeSpecialSummoned(e, 0, tp, false, false) end

function s.e1cost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return c:IsDiscardable() and Duel.IsExistingMatchingCard(s.e1filter1, tp, LOCATION_HAND, 0, 1, c) end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_DISCARD)
    local g = Duel.SelectMatchingCard(tp, s.e1filter1, tp, LOCATION_HAND, 0, 1, 1, c)

    g:AddCard(c)
    Duel.SendtoGrave(g, REASON_COST + REASON_DISCARD)
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and Duel.IsExistingMatchingCard(s.e1filter2, tp, LOCATION_DECK, 0, 1, nil, e, tp)
    end

    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_DECK)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if Duel.GetLocationCount(tp, LOCATION_MZONE) <= 0 then return end

    local tc = Duel.GetFirstMatchingCard(s.e1filter2, tp, LOCATION_DECK, 0, nil, e, tp)
    if tc and Duel.SpecialSummonStep(tc, 0, tp, tp, false, false, POS_FACEUP) then
        local ec1 = Effect.CreateEffect(c)
        ec1:SetDescription(3206)
        ec1:SetType(EFFECT_TYPE_SINGLE)
        ec1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
        ec1:SetCode(EFFECT_CANNOT_ATTACK)
        ec1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
        tc:RegisterEffect(ec1)
    end

    Duel.SpecialSummonComplete()
end
