-- Junk Bot
Duel.LoadScript("util.lua")
local s, id = GetID()

function s.initial_effect(c)
    -- synchro level
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_CANNOT_NEGATE)
    e1:SetCode(EFFECT_SYNCHRO_LEVEL)
    e1:SetRange(LOCATION_MZONE)
    e1:SetValue(function(e, c) return 2 * 65536 + e:GetHandler():GetLevel() end)
    c:RegisterEffect(e1)

    -- special summon
    local e2 = Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1, id)
    e2:SetCondition(s.e2con)
    e2:SetCost(s.e2cost)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)
end

function s.e2filter(c, ft, tp)
    return
        (ft > 0 or (c:IsControler(tp) and c:GetSequence() < 5)) and (c:IsControler(tp) or c:IsFaceup()) and c:IsLevelBelow(4) and
            not c:IsType(TYPE_TUNER)
end

function s.e2con(e, tp, eg, ep, ev, re, r, rp)
    return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsType, TYPE_TUNER), tp, LOCATION_MZONE, 0, 1, nil)
end

function s.e2cost(e, tp, eg, ep, ev, re, r, rp, chk)
    local ft = Duel.GetLocationCount(tp, LOCATION_MZONE)
    if chk == 0 then return ft > -1 and Duel.CheckReleaseGroupCost(tp, s.e2filter, 1, false, nil, nil, ft, tp) end

    local g = Duel.SelectReleaseGroupCost(tp, s.e2filter, 1, 1, false, nil, nil, ft, tp)
    Duel.Release(g, REASON_COST)
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return c:IsCanBeSpecialSummoned(e, 0, tp, false, false) end

    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, c, 1, 0, 0)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) or
        not Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsType, TYPE_TUNER), tp, LOCATION_MZONE, 0, 1, nil) then return end

    Duel.SpecialSummon(c, 0, tp, tp, false, false, POS_FACEUP)
end
