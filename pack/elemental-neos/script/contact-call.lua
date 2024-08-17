-- Contact Call
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {CARD_NEOS}
s.listed_series = {SET_NEO_SPACIAN}

function s.initial_effect(c)
    -- copy effect
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1, id)
    e1:SetCost(s.e1cost)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- to deck
    local e2 = Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_TODECK)
    e2:SetType(EFFECT_TYPE_TRIGGER_O + EFFECT_TYPE_FIELD)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetCode(EVENT_PHASE + PHASE_END)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1, id)
    e2:SetCondition(s.e2con)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)
end

function s.e1filter(c)
    return not c:IsCode(id) and c:IsAbleToGraveAsCost() and c:CheckActivateEffect(true, true, false) ~= nil  and
               c:ListsArchetype(SET_NEO_SPACIAN) and (c:IsNormalSpell() or c:IsNormalTrap())
end

function s.e1cost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.e1filter, tp, LOCATION_HAND + LOCATION_DECK, 0, 1, nil) end
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.e1filter, tp, LOCATION_HAND + LOCATION_DECK, 0, 1, nil) end
    local tc = Duel.SelectMatchingCard(tp, s.e1filter, tp, LOCATION_HAND + LOCATION_DECK, 0, 1, 1, nil):GetFirst()
    if not tc or not Duel.SendtoGrave(tc, REASON_COST) then return end

    local te = tc:CheckActivateEffect(true, true, false)
    if not te then return end
    e:SetLabel(te:GetLabel())
    e:SetLabelObject(te:GetLabelObject())
    local tg = te:GetTarget()
    if tg then tg(e, tp, eg, ep, ev, re, r, rp, 1) end
    te:SetLabel(e:GetLabel())
    te:SetLabelObject(e:GetLabelObject())
    e:SetLabelObject(te)
    Duel.ClearOperationInfo(0)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local te = e:GetLabelObject()
    if te then
        e:SetLabel(te:GetLabel())
        e:SetLabelObject(te:GetLabelObject())
        local op = te:GetOperation()
        if op then op(e, tp, eg, ep, ev, re, r, rp) end
        te:SetLabel(e:GetLabel())
        te:SetLabelObject(e:GetLabelObject())
    end
end

function s.e2filter(c)
    return c:IsFaceup() and not c:IsCode(id) and c:IsSpellTrap() and c:IsAbleToDeck() and
               (c:ListsCode(CARD_NEOS) or c:ListsArchetype(SET_NEO_SPACIAN))
end

function s.e2con(e, tp, eg, ep, ev, re, r, rp) return Duel.GetTurnPlayer() == tp end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    local c = e:GetHandler()
    if chk == 0 then return c:IsAbleToHand() and Duel.IsExistingTarget(s.e2filter, tp, LOCATION_GRAVE + LOCATION_REMOVED, 0, 1, nil) end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TODECK)
    local g = Duel.SelectTarget(tp, s.e2filter, tp, LOCATION_GRAVE + LOCATION_REMOVED, 0, 1, 1, nil)
    g:AddCard(c)

    Duel.SetOperationInfo(0, CATEGORY_TODECK, g, #g, 0, 0)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Duel.GetFirstTarget()
    if not tc or not tc:IsRelateToEffect(e) or not c:IsRelateToEffect(e) then return end

    Duel.SendtoDeck(Group.FromCards(tc, c), nil, SEQ_DECKSHUFFLE, REASON_EFFECT)
end
