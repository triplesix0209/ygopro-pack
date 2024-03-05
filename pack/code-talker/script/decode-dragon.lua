-- Decode Dragon
Duel.LoadScript("util.lua")
local s, id = GetID()

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- link summon
    Link.AddProcedure(c, aux.FilterBoolFunctionEx(Card.IsRace, RACE_CYBERSE), 2)

    -- negate activation
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_DESTROY + CATEGORY_NEGATE)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP + EFFECT_FLAG_DAMAGE_CAL)
    e1:SetCode(EVENT_CHAINING)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCondition(s.e1con)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- shuffle card
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 1))
    e2:SetCategory(CATEGORY_TODECK)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1, {id, 1})
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)
end

function s.effchainlimit(e, ep, tp) return tp == ep end

function s.e1filter(c) return not c:IsStatus(STATUS_BATTLE_DESTROYED) end

function s.e1con(e, tp, eg, ep, ev, re, r, rp) return rp ~= tp and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev) end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    local rc = re:GetHandler()
    local lg = c:GetLinkedGroup():Filter(s.e1filter, nil)
    if chk == 0 then return #lg > 0 end

    Duel.SetOperationInfo(0, CATEGORY_DESTROY, lg, 1, 0, 0)
    Duel.SetOperationInfo(0, CATEGORY_NEGATE, eg, 1, 0, 0)
    Duel.SetChainLimit(s.effchainlimit)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local rc = re:GetHandler()
    local lg = c:GetLinkedGroup():Filter(s.e1filter, nil)

    local tc = Utility.GroupSelect(HINTMSG_DESTROY, lg, tp):GetFirst()
    if not tc or Duel.Destroy(tc, REASON_EFFECT) == 0 then return end
    Duel.NegateActivation(ev)
end

function s.e2filter(c) return c:IsFaceup() and c:IsAbleToDeck() end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    local c = e:GetHandler()
    local ct = #(c:GetMutualLinkedGroup():Filter(Card.IsMonster, nil))
    if chk == 0 then
        return ct > 0 and Duel.IsExistingTarget(s.e2filter, tp, LOCATION_GRAVE + LOCATION_REMOVED, LOCATION_GRAVE + LOCATION_REMOVED, 1, nil)
    end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TODECK)
    local g = Duel.SelectTarget(tp, s.e2filter, tp, LOCATION_GRAVE + LOCATION_REMOVED, LOCATION_GRAVE + LOCATION_REMOVED, 1, ct, nil)
    Duel.SetOperationInfo(0, CATEGORY_TODECK, g, #g, 0, 0)
    Duel.SetChainLimit(s.effchainlimit)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local g = Duel.GetTargetCards(e)
    if #g > 0 then Duel.SendtoDeck(g, nil, SEQ_DECKSHUFFLE, REASON_EFFECT) end
end
