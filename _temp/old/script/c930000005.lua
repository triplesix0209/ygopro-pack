-- Loki, Aesir of Mischief
Duel.LoadScript("util.lua")
Duel.LoadScript("util_nordic.lua")
local s, id = GetID()

s.listed_series = {0xa042, 0x4b}
s.material_setcode = {0xa042}

function s.initial_effect(c)
    c:EnableReviveLimit()
    UtilNordic.AesirGodEffect(c)

    -- synchro summon
    Synchro.AddProcedure(c, function(c, sc, sumtype, tp)
        return c:IsSetCard(0xa042, sc, sumtype, tp) or
                   c:IsHasEffect(EFFECT_SYNSUB_NORDIC)
    end, 1, 1, Synchro.NonTuner(nil), 2, 99)

    -- negate
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_NEGATE + CATEGORY_DESTROY)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP + EFFECT_FLAG_DAMAGE_CAL)
    e1:SetCode(EVENT_CHAINING)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1)
    e1:SetCondition(s.e1con)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- return trap
    local e2 = Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_TOHAND)
    e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetCondition(UtilNordic.RebornCondition)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)
end

function s.e1con(e, tp, eg, ep, ev, re, r, rp)
    if e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) then return false end
    return rp ~= tp and Duel.GetTurnPlayer() == tp and
               re:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.IsChainNegatable(ev)
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local rc = re:GetHandler()
    if chk == 0 then return true end

    Duel.SetOperationInfo(0, CATEGORY_NEGATE, eg, 1, 0, 0)
    if rc:IsDestructable() and rc:IsRelateToEffect(re) then
        Duel.SetOperationInfo(0, CATEGORY_DESTROY, eg, 1, 0, 0)
    end
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local rc = re:GetHandler()
    if not Duel.NegateActivation(ev) then return end
    if not rc:IsRelateToEffect(re) or Duel.Destroy(eg, REASON_EFFECT) == 0 then
        return
    end

    if rc:IsType(TYPE_SPELL + TYPE_TRAP) and
        not rc:IsLocation(LOCATION_HAND + LOCATION_DECK) and aux.nvfilter(rc) and
        (rc:IsType(TYPE_FIELD) or Duel.GetLocationCount(tp, LOCATION_SZONE) > 0) and
        rc:IsSSetable() and Duel.SelectYesNo(tp, aux.Stringid(id, 1)) then
        Duel.BreakEffect()
        Duel.SSet(tp, rc)
    end
end

function s.e2filter(c)
    return c:IsType(TYPE_TRAP) and (c:IsAbleToHand() or c:IsSSetable(false))
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.e2filter, tp,
                                           LOCATION_GRAVE + LOCATION_REMOVED, 0,
                                           1, nil)
    end
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, 0,
                          LOCATION_GRAVE + LOCATION_REMOVED)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SELECT)
    local g = Duel.SelectTarget(tp, s.e2filter, tp,
                                LOCATION_GRAVE + LOCATION_REMOVED, 0, 1, 1, nil)
    if #g == 0 then return end

    aux.ToHandOrElse(g, tp, function(tc)
        return tc:IsSSetable(false) and
                   Duel.GetLocationCount(tp, LOCATION_SZONE) > 0
    end, function(g) Duel.SSet(tp, g) end, 1159)
end
