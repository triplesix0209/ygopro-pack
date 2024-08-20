-- Evil HERO Neos
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {CARD_DARK_FUSION}
s.listed_series = {SET_HERO}

function s.initial_effect(c)
    -- special summon itself
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e1:SetCode(EFFECT_SPSUMMON_PROC)
    e1:SetRange(LOCATION_HAND + LOCATION_GRAVE)
    e1:SetCountLimit(1, {id, 1})
    e1:SetCondition(s.e1con)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- fusion substitute
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_FUSION_SUBSTITUTE)
    e2:SetCondition(function(e) return e:GetHandler():IsLocation(LOCATION_HAND + LOCATION_ONFIELD + LOCATION_GRAVE + LOCATION_REMOVED) end)
    e2:SetValue(function(e, c) return c.dark_calling end)
    c:RegisterEffect(e2)

    -- special summon "evil HERO" fusion monster
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 1))
    e3:SetCategory(CATEGORY_TODECK + CATEGORY_SPECIAL_SUMMON + CATEGORY_FUSION_SUMMON)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetRange(LOCATION_MZONE)
    e3:SetHintTiming(0, TIMING_MAIN_END + TIMINGS_CHECK_MONSTER)
    e3:SetCountLimit(1, {id, 3})
    e3:SetCondition(s.e3con)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)
end

function s.e1filter(c, ft)
    return c:IsSetCard(SET_HERO) and c:IsType(TYPE_FUSION + TYPE_LINK) and c:IsAbleToExtraAsCost() and (ft > 0 or c:GetSequence() < 5)
end

function s.e1con(e, c)
    if c == nil then return true end
    local tp = c:GetControler()
    local eff = {c:GetCardEffect(EFFECT_NECRO_VALLEY)}
    for _, te in ipairs(eff) do
        local op = te:GetOperation()
        if not op or op(e, c) then return false end
    end

    local ft = Duel.GetLocationCount(tp, LOCATION_MZONE)
    local rg = Duel.GetMatchingGroup(s.e1filter, tp, LOCATION_MZONE, 0, nil, ft)
    return ft > -1 and #rg > 0 and aux.SelectUnselectGroup(rg, e, tp, 1, 1, nil, 0)
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, c)
    local c = e:GetHandler()
    local ft = Duel.GetLocationCount(tp, LOCATION_MZONE)
    local rg = Duel.GetMatchingGroup(s.e1filter, tp, LOCATION_MZONE, 0, nil, ft)
    local g = aux.SelectUnselectGroup(rg, e, tp, 1, 1, nil, 1, tp, HINTMSG_REMOVE, nil, nil, true)
    if #g > 0 then
        g:KeepAlive()
        e:SetLabelObject(g)
        return true
    end
    return false
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp, c)
    local g = e:GetLabelObject()
    if not g then return end
    Duel.SendtoDeck(g, nil, SEQ_DECKSHUFFLE, REASON_COST)
    g:DeleteGroup()
end

function s.e3filter1(c, e, tp)
    return c:IsSetCard(SET_HERO) and c:IsMonster() and c:IsAbleToDeck() and
               Duel.IsExistingMatchingCard(s.e3filter2, tp, LOCATION_EXTRA, 0, 1, nil, c, e, tp)
end

function s.e3filter2(c, mc, e, tp)
    return c:IsType(TYPE_FUSION) and c.dark_calling and c.material and mc:IsCode(table.unpack(c.material)) and
               c:IsCanBeSpecialSummoned(e, SUMMON_TYPE_FUSION, tp, true, false) and Duel.GetLocationCountFromEx(tp, tp, nil, c) > 0
end

function s.e3excheck(sg, tp, exg, ssg, c)
    return ssg:IsExists(function(c, sg, tp, oc)
        local sg = sg + oc
        return Duel.GetLocationCountFromEx(tp, tp, sg, c) > 0
    end, 1, nil, sg, tp, c)
end

function s.e3con(e, tp, eg, ep, ev, re, r, rp) return (Duel.IsTurnPlayer(tp) and Duel.IsMainPhase()) or not Duel.IsTurnPlayer(tp) end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return c:IsAbleToDeck() and Duel.IsExistingMatchingCard(s.e3filter1, tp, LOCATION_HAND + LOCATION_MZONE, 0, 1, c, e, tp) end

    Duel.SetOperationInfo(0, CATEGORY_TODECK, nil, 1, 0, LOCATION_HAND + LOCATION_MZONE)
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_EXTRA)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local g = Utility.SelectMatchingCard(HINTMSG_TODECK, tp, s.e3filter1, tp, LOCATION_HAND + LOCATION_MZONE, 0, 1, 1, c, e, tp)
    local mc = g:GetFirst()
    g:AddCard(c)

    if Duel.SendtoDeck(g, nil, SEQ_DECKSHUFFLE, REASON_EFFECT) > 0 then
        local tc = Utility.SelectMatchingCard(HINTMSG_SPSUMMON, tp, s.e3filter2, tp, LOCATION_EXTRA, 0, 1, 1, nil, mc, e, tp):GetFirst()
        if tc and Duel.SpecialSummon(tc, SUMMON_TYPE_FUSION, tp, tp, true, false, POS_FACEUP) > 0 then tc:CompleteProcedure() end
    end
end
