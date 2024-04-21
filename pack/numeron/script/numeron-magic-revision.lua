-- Numeron Magic Revision
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {CARD_NUMERON_NETWORK}

function s.initial_effect(c)
    -- Activate
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_CHAINING)
    e1:SetCondition(s.e1con)
    e1:SetCost(function(e)
        e:SetLabel(1)
        return true
    end)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)
end

function s.e1filter(c, tc)
    return not c:IsCode(tc:GetCode()) and c:IsSpell() and c:IsAbleToGraveAsCost() and c:CheckActivateEffect(false, true, true) ~= nil
end

function s.e1con(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    return not Duel.IsExistingMatchingCard(function(c) return c:IsSpellTrap() and not c:IsCode(CARD_NUMERON_NETWORK) end, tp, LOCATION_ONFIELD, 0, 1,
        c) and rp == 1 - tp and re:IsSpellEffect()
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local ec = re:GetHandler()
    if chk == 0 then
        if e:GetLabel() == 0 then return false end
        e:SetLabel(0)
        return Duel.IsExistingMatchingCard(s.e1filter, tp, 0, LOCATION_DECK, 1, nil, ec)
    end

    e:SetLabel(0)
    local tc = Utility.SelectMatchingCard(HINTMSG_TOGRAVE, tp, s.e1filter, tp, 0, LOCATION_DECK, 1, 1, nil, ec):GetFirst()
    local te, ceg, cep, cev, cre, cr, crp = tc:CheckActivateEffect(false, true, true)
    Duel.SendtoGrave(tc, REASON_COST)

    local tg = te:GetTarget()
    if tg then tg(e, tp, ceg, cep, cev, cre, cr, crp, 1) end
    te:SetLabelObject(e:GetLabelObject())
    e:SetLabelObject(te)
    Duel.ClearOperationInfo(0)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local te = e:GetLabelObject()
    if not te then return end
    Utility.HintCard(te)

    local op = te:GetOperation()
    if op then
        Duel.ChangeChainOperation(ev, aux.FALSE)
        op(e, tp, eg, ep, ev, re, r, rp)
    end
end
