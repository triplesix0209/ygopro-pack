-- Stardust Armory Dragon
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {CARD_STARDUST_DRAGON}
s.listed_series = {0xa3}
s.synchro_tuner_required = 1
s.synchro_nt_required = 1

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- synhcro summon
    Synchro.AddProcedure(c, aux.FilterBoolFunctionEx(Card.IsType, TYPE_SYNCHRO), 1, 1,
        Synchro.NonTunerEx(Card.IsType, TYPE_SYNCHRO), 1, 99)

    -- special summon procedure
    local spr = Effect.CreateEffect(c)
    spr:SetDescription(2)
    spr:SetType(EFFECT_TYPE_FIELD)
    spr:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    spr:SetCode(EFFECT_SPSUMMON_PROC)
    spr:SetRange(LOCATION_EXTRA)
    spr:SetCondition(s.sprcon)
    spr:SetTarget(s.sprtg)
    spr:SetOperation(s.sprop)
    c:RegisterEffect(spr)

    -- special summon
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCode(EVENT_DESTROYED)
    e1:SetCondition(s.e1con)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- negate activation
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 0))
    e2:SetCategory(CATEGORY_NEGATE + CATEGORY_DESTROY)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP + EFFECT_FLAG_DAMAGE_CAL)
    e2:SetCode(EVENT_CHAINING)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCondition(s.e2con)
    e2:SetCost(aux.StardustCost)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)

    -- disable special summon
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 1))
    e3:SetCategory(CATEGORY_DISABLE_SUMMON + CATEGORY_DESTROY)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_SPSUMMON)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCondition(s.e3con)
    e3:SetCost(aux.StardustCost)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)

    -- revive
    local ret = Effect.CreateEffect(c)
    ret:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    ret:SetCode(EVENT_PHASE + PHASE_END)
    ret:SetRange(LOCATION_GRAVE)
    ret:SetCountLimit(1)
    ret:SetCondition(s.retcon)
    ret:SetOperation(s.retop)
    c:RegisterEffect(ret)
end

function s.sprfilter1(c) return c:IsFaceup() and c:IsType(TYPE_TUNER) and c:IsType(TYPE_SYNCHRO) and c:IsAbleToDeckOrExtraAsCost() end

function s.sprfilter2(c) return c:IsFaceup() and c:IsCode(CARD_STARDUST_DRAGON) and c:IsAbleToDeckOrExtraAsCost() end

function s.sprescon(sg, e, tp)
    return Duel.GetLocationCountFromEx(tp, tp, sg, e:GetHandler()) > 0 and sg:FilterCount(s.sprfilter1, nil) >= 1 and
               sg:FilterCount(s.sprfilter2, nil) >= 1
end

function s.sprcon(e, c)
    if c == nil then return true end
    local tp = c:GetControler()
    local g1 = Duel.GetMatchingGroup(s.sprfilter1, tp, LOCATION_MZONE + LOCATION_GRAVE, 0, nil)
    local g2 = Duel.GetMatchingGroup(s.sprfilter2, tp, LOCATION_ONFIELD + LOCATION_GRAVE, 0, nil)
    local g = g1:Clone():Merge(g2)
    return #g1 > 0 and #g2 > 0 and aux.SelectUnselectGroup(g, e, tp, 2, 2, s.sprescon, 0)
end

function s.sprtg(e, tp, eg, ep, ev, re, r, rp, c)
    local g1 = Duel.GetMatchingGroup(s.sprfilter1, tp, LOCATION_MZONE + LOCATION_GRAVE, 0, nil, tp)
    local g2 = Duel.GetMatchingGroup(s.sprfilter2, tp, LOCATION_ONFIELD + LOCATION_GRAVE, 0, nil, tp)
    local rg = g1:Clone():Merge(g2)
    local g = aux.SelectUnselectGroup(rg, e, tp, 2, 2, s.sprescon, 1, tp, HINTMSG_TODECK, nil, nil, true)
    if #g > 0 then
        g:KeepAlive()
        e:SetLabelObject(g)
        return true
    end
    return false
end

function s.sprop(e, tp, eg, ep, ev, re, r, rp, c)
    local g = e:GetLabelObject()
    if not g then return end

    Duel.SendtoDeck(g, nil, 0, REASON_COST)
    g:DeleteGroup()
end

function s.e1filter(c, e, tp)
    return
        c:IsSetCard(0xa3) and c:IsLevelBelow(8) and c:IsType(TYPE_SYNCHRO) and Duel.GetLocationCountFromEx(tp, tp, nil, c) > 0 and
            c:IsCanBeSpecialSummoned(e, SUMMON_TYPE_SYNCHRO, tp, false, false)
end

function s.e1con(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    return c:IsReason(REASON_BATTLE) or (rp == 1 - tp and c:IsReason(REASON_EFFECT) and c:IsPreviousControler(tp))
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and
                   Duel.IsExistingMatchingCard(s.e1filter, tp, LOCATION_EXTRA, 0, 1, nil, e, tp)
    end

    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_EXTRA)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    if Duel.GetLocationCount(tp, LOCATION_MZONE) <= 0 then return end

    local tc = Utility.SelectMatchingCard(HINTMSG_SPSUMMON, tp, s.e1filter, tp, LOCATION_EXTRA, 0, 1, 1, nil, e, tp):GetFirst()
    if tc then
        Duel.SpecialSummon(tc, SUMMON_TYPE_SYNCHRO, tp, tp, false, false, POS_FACEUP)
        tc:CompleteProcedure()
    end
end

function s.e2con(e, tp, eg, ep, ev, re, r, rp)
    return rp ~= tp and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev)
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local rc = re:GetHandler()
    if chk == 0 then return true end

    Duel.SetOperationInfo(0, CATEGORY_NEGATE, eg, #eg, 0, 0)
    if rc:IsDestructable() and rc:IsRelateToEffect(re) then Duel.SetOperationInfo(0, CATEGORY_DESTROY, eg, #eg, 0, 0) end
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    c:RegisterFlagEffect(id, RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END, 0, 0)

    if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then Duel.Destroy(eg, REASON_EFFECT) end
end

function s.e3con(e, tp, eg, ep, ev, re, r, rp) return tp ~= ep and Duel.GetCurrentChain() == 0 end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return true end

    Duel.SetOperationInfo(0, CATEGORY_DISABLE_SUMMON, eg, #eg, 0, 0)
    Duel.SetOperationInfo(0, CATEGORY_DESTROY, eg, #eg, 0, 0)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    c:RegisterFlagEffect(id, RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END, 0, 0)

    Duel.NegateSummon(eg)
    Duel.Destroy(eg, REASON_EFFECT)
end

function s.retcon(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    return c:GetFlagEffect(id) > 0 and Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and
               c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end

function s.retop(e, tp, eg, ep, ev, re, r, rp) Duel.SpecialSummon(e:GetHandler(), 0, tp, tp, false, false, POS_FACEUP) end
