-- Numeron Magic Revision
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {CARD_NUMERON_NETWORK}

function s.initial_effect(c)
    -- activate
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_TOGRAVE)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_CHAINING)
    e1:SetCountLimit(1, id, EFFECT_COUNT_CODE_OATH)
    e1:SetCondition(s.e1con)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)
end

function s.e1filter(c, e, tp, chain)
    if c:IsCode(e:GetHandler():GetCode()) or c:IsPublic() or not c:IsAbleToGrave() or not (c:IsNormalSpell() or c:IsQuickPlaySpell()) then
        return false
    end
    local te = c:GetActivateEffect()
    if te == nil then return false end

    local eg, ep, ev, re, r, rp
    local condition = te:GetCondition()
    local target = te:GetTarget()

    if te:GetCode() == EVENT_CHAINING then
        if chain <= 0 then return false end
        local te2, p = Duel.GetChainInfo(chain, CHAININFO_TRIGGERING_EFFECT, CHAININFO_TRIGGERING_PLAYER)
        local tc = te2:GetHandler()
        local g = Group.FromCards(tc)
        eg, ep, ev, re, r, rp = g, p, chain, te2, REASON_EFFECT, p
        return (not condition or condition(e, tp, eg, ep, ev, re, r, rp)) and (not target or target(e, tp, eg, ep, ev, re, r, rp, 0))
    elseif te:GetCode() == EVENT_FREE_CHAIN then
        return (not condition or condition(e, tp, eg, ep, ev, re, r, rp)) and (not target or target(e, tp, eg, ep, ev, re, r, rp, 0))
    else
        local res, teg, tep, tev, tre, tr, trp = Duel.CheckEvent(te:GetCode(), true)
        return res and (not condition or condition(e, tp, teg, tep, tev, tre, tr, trp)) and
                   (not target or target(e, tp, teg, tep, tev, tre, tr, trp, 0))
    end
end

function s.e1con(e, tp, eg, ep, ev, re, r, rp)
    local fc = Duel.GetFieldCard(tp, LOCATION_FZONE, 0)
    return fc and fc:IsFaceup() and fc:IsCode(CARD_NUMERON_NETWORK) and Duel.GetFieldGroupCount(tp, LOCATION_MZONE, 0) == 0
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local ec = re:GetHandler()
    local chain = Duel.GetCurrentChain()
    if chk == 0 then
        return rp == 1 - tp and (ec:IsNormalSpell() or ec:IsQuickPlaySpell()) and
                   Duel.IsExistingMatchingCard(s.e1filter, tp, 0, LOCATION_DECK, 1, nil, re, rp, chain)
    end

    chain = chain - 1;
    local g = Duel.GetMatchingGroup(s.e1filter, tp, 0, LOCATION_DECK, 1, 1, nil, re, rp, chain)
    Duel.ConfirmCards(tp, g)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_CONFIRM)
    local tc = g:Select(tp, 1, 1, nil):GetFirst()
    Duel.ConfirmCards(1 - tp, tc)

    Utility.HintCard(tc)
    local te = tc:GetActivateEffect()
    local teg, tep, tev, tre, tr, trp
    if te:GetCode() == EVENT_CHAINING then
        if chain <= 0 then return false end
        local te2, p = Duel.GetChainInfo(chain, CHAININFO_TRIGGERING_EFFECT, CHAININFO_TRIGGERING_PLAYER)
        local tc = te2:GetHandler()
        local g = Group.FromCards(tc)
        teg, tep, tev, tre, tr, trp = g, p, chain, te2, REASON_EFFECT, p
    end
    e:SetLabelObject(te)
    local target = te:GetTarget()
    e:SetProperty(te:GetProperty())
    if target then target(re, tp, teg, tep, tev, tre, tr, trp, 1) end
    Duel.ClearOperationInfo(0)

    Duel.SetOperationInfo(0, CATEGORY_TOGRAVE, tc, 1, 0, 0)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local te = e:GetLabelObject()
    if not te then return end
    if Duel.SendtoGrave(te:GetHandler(), REASON_EFFECT) == 0 then return end

    local operation = te:GetOperation()
    if operation then
        Duel.ChangeChainOperation(ev, aux.FALSE)
        operation(e, rp, eg, ep, ev, re, r, rp)
    end
end
