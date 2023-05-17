-- Supreme Wrath
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {CARD_ZARC}
s.listed_series = {SET_SUPREME_KING_DRAGON}

function s.initial_effect(c)
    -- activate
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_DESTROY + CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCondition(s.e1con)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- attach materials
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCost(s.e2cost)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)
end

function s.e1filter(c, e, tp)
    if not c:IsSetCard(SET_SUPREME_KING_DRAGON) or not c:IsCanBeSpecialSummoned(e, 0, tp, true, false) then return false end
    if c:IsLocation(LOCATION_EXTRA) then
        local g = Duel.GetMatchingGroup(aux.NOT(aux.FaceupFilter(Card.IsCode, CARD_ZARC)), tp, LOCATION_MZONE, 0, nil)
        return Duel.GetLocationCountFromEx(tp, tp, g, c) > 0
    else
        return Duel.GetMZoneCount(tp) > 0
    end
end

function s.e1con(e, tp, eg, ep, ev, re, r, rp)
    return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode, CARD_ZARC), tp, LOCATION_ONFIELD, 0, 1, nil)
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local loc = LOCATION_HAND + LOCATION_DECK + LOCATION_GRAVE + LOCATION_EXTRA
    if chk == 0 then return Duel.IsExistingMatchingCard(s.e1filter, tp, loc, 0, 1, nil, e, tp) end

    local g = Duel.GetMatchingGroup(aux.NOT(aux.FaceupFilter(Card.IsCode, CARD_ZARC)), tp, LOCATION_MZONE, 0, nil)
    if #g > 0 then Duel.SetOperationInfo(0, CATEGORY_DESTROY, g, #g, 0, 0) end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, loc)
    Duel.SetChainLimit(aux.FALSE)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local dg = Duel.GetMatchingGroup(aux.NOT(aux.FaceupFilter(Card.IsCode, CARD_ZARC)), tp, LOCATION_MZONE, 0, nil)
    if #dg > 0 then Duel.Destroy(dg, REASON_EFFECT) end

    local ft1 = Duel.GetLocationCount(tp, LOCATION_MZONE)
    local ft2 = Duel.GetLocationCountFromEx(tp)
    local ft3 = Duel.GetLocationCountFromEx(tp, tp, nil, TYPE_FUSION + TYPE_SYNCHRO + TYPE_XYZ)
    local ft4 = Duel.GetLocationCountFromEx(tp, tp, nil, TYPE_PENDULUM + TYPE_LINK)
    local ft = math.min(Duel.GetUsableMZoneCount(tp), 4)
    if Duel.IsPlayerAffectedByEffect(tp, CARD_BLUEEYES_SPIRIT) then
        if ft1 > 0 then ft1 = 1 end
        if ft2 > 0 then ft2 = 1 end
        if ft3 > 0 then ft3 = 1 end
        if ft4 > 0 then ft4 = 1 end
        ft = 1
    end

    local ect = aux.CheckSummonGate(tp)
    if ect then
        ft1 = math.min(ect, ft1)
        ft2 = math.min(ect, ft2)
        ft3 = math.min(ect, ft3)
        ft4 = math.min(ect, ft4)
    end

    local loc = 0
    if ft1 > 0 then loc = loc + LOCATION_HAND + LOCATION_DECK + LOCATION_GRAVE end
    if ft2 > 0 or ft3 > 0 or ft4 > 0 then loc = loc + LOCATION_EXTRA end
    if loc == 0 then return end

    local sg = Duel.GetMatchingGroup(aux.NecroValleyFilter(s.e1filter), tp, loc, 0, nil, e, tp)
    if #sg == 0 then return end
    local sg = aux.SelectUnselectGroup(sg, e, tp, 1, ft, s.e1rescon(ft1, ft2, ft3, ft4, ft), 1, tp, HINTMSG_SPSUMMON)
    Duel.SpecialSummon(sg, 0, tp, tp, true, false, POS_FACEUP)

    local og = Duel.GetOperatedGroup()
    for sc in og:Iter() do sc:CompleteProcedure() end
end

function s.e1exfilter1(c) return c:IsLocation(LOCATION_EXTRA) and c:IsFacedown() and c:IsType(TYPE_FUSION + TYPE_SYNCHRO + TYPE_XYZ) end
function s.e1exfilter2(c) return c:IsLocation(LOCATION_EXTRA) and (c:IsType(TYPE_LINK) or (c:IsFaceup() and c:IsType(TYPE_PENDULUM))) end
function s.e1rescon(ft1, ft2, ft3, ft4, ft)
    return function(sg, e, tp, mg)
        local exnpct = sg:FilterCount(s.e1exfilter1, nil, LOCATION_EXTRA)
        local expct = sg:FilterCount(s.e1exfilter2, nil, LOCATION_EXTRA)
        local mct = sg:FilterCount(aux.NOT(Card.IsLocation), nil, LOCATION_EXTRA)
        local exct = sg:FilterCount(Card.IsLocation, nil, LOCATION_EXTRA)
        local groupcount = #sg
        local classcount = sg:GetClassCount(Card.GetCode)
        local res = ft3 >= exnpct and ft4 >= expct and ft1 >= mct and ft >= groupcount and classcount == groupcount
        return res, not res
    end
end

function s.e2filter1(c) return c:IsFaceup() and c:IsRace(RACE_DRAGON) and c:IsType(TYPE_XYZ) end

function s.e2filter2(c) return c:IsSetCard(SET_SUPREME_KING_DRAGON) and c:IsMonster() and (c:IsFaceup() or not c:IsLocation(LOCATION_EXTRA)) end

function s.e2cost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return c:IsAbleToDeckAsCost() end

    Duel.SendtoDeck(c, nil, SEQ_DECKSHUFFLE, REASON_COST)
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chk == 0 then
        return Duel.IsExistingTarget(s.e2filter1, tp, LOCATION_MZONE, 0, 1, nil) and
                   Duel.IsExistingMatchingCard(s.e2filter2, tp, LOCATION_GRAVE + LOCATION_EXTRA, 0, 1, nil)
    end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_FACEUP)
    Duel.SelectTarget(tp, s.e2filter1, tp, LOCATION_MZONE, 0, 1, 1, nil)
    Duel.SetChainLimit(aux.FALSE)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local tc = Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) then
        local g = Utility.SelectMatchingCard(HINTMSG_FACEUP, tp, s.e2filter2, tp, LOCATION_GRAVE + LOCATION_EXTRA, 0, 1, 2, nil)
        if #g > 0 then Duel.Overlay(tc, g) end
    end
end
