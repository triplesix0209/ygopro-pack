-- Junk Bot
Duel.LoadScript("util.lua")
local s, id = GetID()

function s.initial_effect(c)
    -- special summon
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_GRAVE)
    e1:SetCountLimit(1, id)
    e1:SetCondition(s.e1con)
    e1:SetCost(s.e1cost)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)
end

function s.e1filter(c, ft, tp)
    return
        (ft > 0 or (c:IsControler(tp) and c:GetSequence() < 5)) and (c:IsControler(tp) or c:IsFaceup()) and c:IsLevelBelow(4) and
            not c:IsType(TYPE_TUNER)
end

function s.e1con(e, tp, eg, ep, ev, re, r, rp)
    return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsType, TYPE_TUNER), tp, LOCATION_MZONE, 0, 1, nil)
end

function s.e1cost(e, tp, eg, ep, ev, re, r, rp, chk)
    local ft = Duel.GetLocationCount(tp, LOCATION_MZONE)
    if chk == 0 then return ft > -1 and Duel.CheckReleaseGroupCost(tp, s.e1filter, 1, false, nil, nil, ft, tp) end

    local g = Duel.SelectReleaseGroupCost(tp, s.e1filter, 1, 1, false, nil, nil, ft, tp)
    Duel.Release(g, REASON_COST)
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return c:IsCanBeSpecialSummoned(e, 0, tp, false, false) end

    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, c, 1, 0, 0)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) or
        not Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsType, TYPE_TUNER), tp, LOCATION_MZONE, 0, 1, nil) then return end

    Duel.SpecialSummon(c, 0, tp, tp, false, false, POS_FACEUP)
end
