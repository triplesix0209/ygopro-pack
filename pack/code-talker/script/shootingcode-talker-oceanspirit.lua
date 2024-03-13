-- Shootingcode Talker Oceanspirit
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_series = {SET_CYNET}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- link summon
    Link.AddProcedure(c, aux.FilterBoolFunctionEx(Card.IsRace, RACE_CYBERSE), 2, 99,
        function(g, sc, sumtype, tp) return g:CheckSameProperty(Card.GetAttribute, sc, sumtype, tp) end)

    -- atk up
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetValue(s.e1val)
    c:RegisterEffect(e1)

    -- set
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 0))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_MZONE)
    e2:SetHintTiming(0, TIMING_END_PHASE)
    e2:SetCountLimit(1, id)
    e2:SetCost(s.e2cost)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)
end

function s.e1val(e, c)
    local g = Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsRace, RACE_CYBERSE), e:GetHandlerPlayer(), LOCATION_MZONE, 0, e:GetHandler())
    return g:GetClassCount(Card.GetAttribute) * 500
end

function s.e2filter1(c) return c:IsSetCard(SET_CYNET) and c:IsSpellTrap() and c:IsSSetable() end

function s.e2filter2(c, e, tp)
    return not c:IsCode(id) and c:IsRace(RACE_CYBERSE) and c:IsLinkBelow(3) and c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end

function s.e2cost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.CheckLPCost(tp, 1000) end
    Duel.PayLPCost(tp, 1000)
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.e2filter1, tp, LOCATION_DECK + LOCATION_GRAVE, 0, 1, nil) end
    Duel.SetOperationInfo(0, CATEGORY_LEAVE_GRAVE, nil, 1, 0, 0)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local g = Utility.SelectMatchingCard(HINTMSG_SET, tp, s.e2filter1, tp, LOCATION_DECK + LOCATION_GRAVE, 0, 1, 1, nil)
    if #g > 0 and Duel.SSet(tp, g) > 0 and Duel.GetLP(tp) <= 2000 and
        Duel.IsExistingMatchingCard(s.e2filter2, tp, LOCATION_GRAVE + LOCATION_REMOVED, 0, 1, nil, e, tp) and
        Duel.SelectEffectYesNo(tp, c, aux.Stringid(id, 1)) then
        Duel.BreakEffect()
        local sg = Duel.SelectMatchingCard(tp, s.e2filter2, tp, LOCATION_GRAVE + LOCATION_REMOVED, 0, 1, 1, nil, e, tp)
        if #sg > 0 then Duel.SpecialSummon(sg, 0, tp, tp, false, false, POS_FACEUP) end
    end
end
