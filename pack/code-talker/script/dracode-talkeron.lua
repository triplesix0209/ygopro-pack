-- Dracode Talkeron
Duel.LoadScript("util.lua")
local s, id = GetID()

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- link summon
    Link.AddProcedure(c, aux.FilterBoolFunctionEx(Card.IsType, TYPE_EFFECT), 2)

    -- ATK up
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetRange(LOCATION_MZONE)
    e1:SetValue(function(e, c) return c:GetLinkedGroup():FilterCount(aux.FilterBoolFunction(Card.IsMonster), nil) * 500 end)
    c:RegisterEffect(e1)

    -- shuffle card
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 0))
    e2:SetCategory(CATEGORY_TODECK)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1, {id, 1})
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)

    -- negate activation
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 1))
    e3:SetCategory(CATEGORY_DESTROY + CATEGORY_NEGATE)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP + EFFECT_FLAG_DAMAGE_CAL)
    e3:SetCode(EVENT_CHAINING)
    e3:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1, {id, 2})
    e3:SetCondition(s.e3con)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)
end

function s.e2filter(c) return c:IsAbleToDeck() end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    local c = e:GetHandler()
    local ct = #(c:GetMutualLinkedGroup():Filter(Card.IsMonster, nil))
    if chk == 0 then return ct > 0 and Duel.IsExistingTarget(s.e2filter, tp, LOCATION_GRAVE, LOCATION_GRAVE, 1, nil) end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TODECK)
    local g = Duel.SelectTarget(tp, s.e2filter, tp, LOCATION_GRAVE, LOCATION_GRAVE, 1, ct, nil)
    Duel.SetOperationInfo(0, CATEGORY_TODECK, g, #g, 0, 0)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local g = Duel.GetTargetCards(e)
    if #g > 0 then Duel.SendtoDeck(g, nil, SEQ_DECKSHUFFLE, REASON_EFFECT) end
end

function s.e3filter(c) return not c:IsStatus(STATUS_BATTLE_DESTROYED) end

function s.e3con(e, tp, eg, ep, ev, re, r, rp) return rp ~= tp and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev) end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    local rc = re:GetHandler()
    local lg = c:GetLinkedGroup():Filter(s.e3filter, nil)
    if chk == 0 then return #lg > 0 end

    Duel.SetOperationInfo(0, CATEGORY_DESTROY, lg, 1, 0, 0)
    Duel.SetOperationInfo(0, CATEGORY_NEGATE, eg, 1, 0, 0)
    if rc:IsDestructable() and rc:IsRelateToEffect(re) then Duel.SetOperationInfo(0, CATEGORY_DESTROY, eg, 1, 0, 0) end
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local rc = re:GetHandler()
    local lg = c:GetLinkedGroup():Filter(s.e3filter, nil)

    local tc = Utility.GroupSelect(HINTMSG_DESTROY, lg, tp):GetFirst()
    if not tc or Duel.Destroy(tc, REASON_EFFECT) == 0 then return end
    if Duel.NegateActivation(ev) and rc:IsRelateToEffect(re) then Duel.Destroy(eg, REASON_EFFECT) end
end

function s.discost(e, tp, eg, ep, ev, re, r, rp, chk)
    local lg = e:GetHandler():GetLinkedGroup()
    if chk == 0 then return Duel.CheckReleaseGroupCost(tp, s.cfilter, 1, false, nil, nil, lg) end
    local g = Duel.SelectReleaseGroupCost(tp, s.cfilter, 1, 1, false, nil, nil, lg)
    Duel.Release(g, REASON_COST)
end
