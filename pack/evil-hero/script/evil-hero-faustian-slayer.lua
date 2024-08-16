-- Evil HERO Faustian Slayer
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {CARD_DARK_FUSION}
s.listed_series = {SET_HERO}
s.material_setcode = {SET_HERO, SET_EVIL_HERO}
s.dark_calling = true

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- fusion summon
    Fusion.AddProcMixRep(c, true, true, aux.FilterBoolFunctionEx(Card.IsSummonLocation, LOCATION_EXTRA), 1, 1,
        function(c, sc, st, tp) return c:IsSetCard(SET_EVIL_HERO, sc, st, tp) and c:IsType(TYPE_FUSION, sc, st, tp) end)

    -- lizard check
    local lizcheck = Effect.CreateEffect(c)
    lizcheck:SetType(EFFECT_TYPE_SINGLE)
    lizcheck:SetCode(CARD_CLOCK_LIZARD)
    lizcheck:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    lizcheck:SetCondition(function(e, tp, eg, ep, ev, re, r, rp)
        return not Duel.IsPlayerAffectedByEffect(e:GetHandlerPlayer(), EFFECT_SUPREME_CASTLE)
    end)
    lizcheck:SetValue(1)
    c:RegisterEffect(lizcheck)

    -- special summon limit
    local splimit = Effect.CreateEffect(c)
    splimit:SetType(EFFECT_TYPE_SINGLE)
    splimit:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    splimit:SetCode(EFFECT_SPSUMMON_CONDITION)
    splimit:SetValue(aux.EvilHeroLimit)
    c:RegisterEffect(splimit)

    -- atk up
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_ATKCHANGE)
    e1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
    e1:SetCountLimit(1)
    e1:SetCondition(s.e1con)
    e1:SetCost(s.e1cost)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- activate effect
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 1))
    e2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_PHASE + PHASE_END)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1, id)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)
end

function s.e1con(e) return e:GetHandler() == Duel.GetAttacker() end

function s.e1cost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.CheckReleaseGroupCost(tp, Card.IsSetCard, 1, false, nil, e:GetHandler(), SET_HERO) end
    local g = Duel.SelectReleaseGroupCost(tp, Card.IsSetCard, 1, 1, false, nil, e:GetHandler(), SET_HERO)
    e:SetLabel(g:GetFirst():GetAttack())
    Duel.Release(g, REASON_COST)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if c:IsFacedown() or not c:IsRelateToEffect(e) then return end

    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetCode(EFFECT_UPDATE_ATTACK)
    ec1:SetValue(e:GetLabel())
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
    c:RegisterEffect(ec1)
end

function s.e2countfilter(c) return c:IsSetCard(SET_HERO) and c:IsMonster() and c:IsFaceup() end

function s.e2filter1(c) return c:IsControlerCanBeChanged() and c:IsSummonType(SUMMON_TYPE_SPECIAL) end

function s.e2filter2(c) return c:IsAbleToDeck() end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local opt = {}
    local sel = {}
    local ct = Duel.GetMatchingGroup(s.e2countfilter, tp, LOCATION_GRAVE + LOCATION_REMOVED, 0, nil):GetClassCount(Card.GetCode)
    if ct >= 2 and Duel.IsExistingMatchingCard(nil, tp, 0, LOCATION_ONFIELD, 1, nil) then
        table.insert(opt, aux.Stringid(id, 2))
        table.insert(sel, 1)
    end
    if ct >= 4 and Duel.IsExistingMatchingCard(s.e2filter1, tp, 0, LOCATION_MZONE, 1, nil) then
        table.insert(opt, aux.Stringid(id, 3))
        table.insert(sel, 2)
    end
    if ct >= 6 and Duel.IsExistingMatchingCard(s.e2filter2, tp, LOCATION_GRAVE + LOCATION_REMOVED, 0, 1, nil) then
        table.insert(opt, aux.Stringid(id, 4))
        table.insert(sel, 3)
    end

    if chk == 0 then return #opt > 0 end
    local op = sel[Duel.SelectOption(tp, table.unpack(opt)) + 1]
    e:SetLabel(op)

    e:SetCategory(0)
    if op == 1 then
        e:SetCategory(CATEGORY_DESTROY)
        local g = Duel.GetMatchingGroup(nil, tp, 0, LOCATION_ONFIELD, nil)
        Duel.SetOperationInfo(0, CATEGORY_DESTROY, g, #g, 0, 0)
    elseif op == 2 then
        e:SetCategory(CATEGORY_CONTROL)
        local g = Duel.GetMatchingGroup(s.e2filter1, tp, 0, LOCATION_MZONE, nil)
        Duel.SetOperationInfo(0, CATEGORY_CONTROL, g, #g, 0, 0)
    elseif op == 3 then
        e:SetCategory(CATEGORY_TODECK)
        local g = Duel.GetMatchingGroup(s.e2filter2, tp, LOCATION_GRAVE + LOCATION_REMOVED, 0, nil)
        Duel.SetOperationInfo(0, CATEGORY_TODECK, g, #g, 0, 0)
    end
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local op = e:GetLabel()

    if op == 1 then
        local g = Utility.SelectMatchingCard(HINTMSG_DESTROY, tp, nil, tp, 0, LOCATION_ONFIELD, 1, 1, nil)
        Duel.HintSelection(g)
        Duel.Destroy(g, REASON_EFFECT)
    elseif op == 2 then
        local g = Utility.SelectMatchingCard(HINTMSG_CONTROL, tp, s.e2filter1, tp, 0, LOCATION_MZONE, 1, 1, nil)
        Duel.HintSelection(g)
        Duel.GetControl(g, tp)
    elseif op == 3 then
        local g = Utility.SelectMatchingCard(HINTMSG_TODECK, tp, s.e2filter2, tp, LOCATION_GRAVE + LOCATION_REMOVED, 0, 1, 1, nil)
        Duel.HintSelection(g)
        Duel.SendtoDeck(g, nil, SEQ_DECKSHUFFLE, REASON_EFFECT)
    end
end
