-- Palladium Shattering Arrow
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {71703785}
s.listed_series = {0x13a}

function s.initial_effect(c)
    -- activate
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCategory(CATEGORY_NEGATE + CATEGORY_DESTROY)
    e1:SetCode(EVENT_CHAINING)
    e1:SetCondition(s.e1con)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- disable
    local e2 = Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_DISABLE)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetHintTiming(0, TIMINGS_CHECK_MONSTER)
    e2:SetCondition(s.e2con)
    e2:SetCost(s.e2cost)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)
end

function s.e1con(e, tp, eg, ep, ev, re, r, rp)
    if not Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard, 0x13a), tp, LOCATION_MZONE, 0, 1, nil) then
        return false
    end

    for i = 1, ev do
        local te, tgp = Duel.GetChainInfo(i, CHAININFO_TRIGGERING_EFFECT, CHAININFO_TRIGGERING_PLAYER)
        if tgp ~= tp and (te:IsActiveType(TYPE_MONSTER) or te:IsHasType(EFFECT_TYPE_ACTIVATE)) and Duel.IsChainNegatable(i) then
            return true
        end
    end

    return false
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return true end

    local ng = Group.CreateGroup()
    local dg = Group.CreateGroup()
    for i = 1, ev do
        local te, tgp = Duel.GetChainInfo(i, CHAININFO_TRIGGERING_EFFECT, CHAININFO_TRIGGERING_PLAYER)
        if tgp ~= tp and (te:IsActiveType(TYPE_MONSTER) or te:IsHasType(EFFECT_TYPE_ACTIVATE)) and Duel.IsChainNegatable(i) then
            local tc = te:GetHandler()
            ng:AddCard(tc)
            if tc:IsOnField() and tc:IsRelateToEffect(te) then dg:AddCard(tc) end
        end
    end

    Duel.SetTargetCard(dg)
    Duel.SetOperationInfo(0, CATEGORY_NEGATE, ng, #ng, 0, 0)
    Duel.SetOperationInfo(0, CATEGORY_DESTROY, dg, #dg, 0, 0)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local dg = Group.CreateGroup()
    local effs = {}

    for i = 1, ev do
        local te, tgp = Duel.GetChainInfo(i, CHAININFO_TRIGGERING_EFFECT, CHAININFO_TRIGGERING_PLAYER)
        if tgp ~= tp and (te:IsActiveType(TYPE_MONSTER) or te:IsHasType(EFFECT_TYPE_ACTIVATE)) and Duel.NegateActivation(i) then
            local tc = te:GetHandler()
            if tc:IsRelateToEffect(e) and tc:IsRelateToEffect(te) then dg:AddCard(tc) end
            if te:IsHasProperty(EFFECT_FLAG_CARD_TARGET) and Utility.CheckEffectCanApply(te, e, tp) then
                table.insert(effs, te)
            end
        end
    end

    Duel.Destroy(dg, REASON_EFFECT)
    if #effs > 0 and Duel.SelectEffectYesNo(tp, c, aux.Stringid(id, 0)) then
        local te
        local g = Group.CreateGroup()
        for _, eff in ipairs(effs) do g:AddCard(eff:GetHandler()) end
        local tc = Utility.GroupSelect(HINTMSG_EFFECT, g, tp):GetFirst()
        for _, eff in ipairs(effs) do
            if eff:GetHandler() == tc then
                te = eff
                break
            end
        end

        Utility.HintCard(te)
        Utility.ApplyEffect(te, e, tp, c)
    end
end

function s.e2con(e, tp, eg, ep, ev, re, r, rp)
    return aux.exccon(e) and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode, 71703785), tp, LOCATION_ONFIELD, 0, 1, nil)

end

function s.e2cost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return e:GetHandler():IsAbleToDeckAsCost() end
    Duel.SendtoDeck(e:GetHandler(), nil, SEQ_DECKBOTTOM, REASON_COST)
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingTarget(Card.IsNegatable, tp, 0, LOCATION_ONFIELD, 1, nil) end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_NEGATE)
    Duel.SelectTarget(tp, Card.IsNegatable, tp, 0, LOCATION_ONFIELD, 1, 1, nil)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Duel.GetFirstTarget()
    if not tc and not tc:IsRelateToEffect(e) or tc:IsFacedown() or tc:IsDisabled() then return end

    Duel.NegateRelatedChain(tc, RESET_TURN_SET)
    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetCode(EFFECT_DISABLE)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
    tc:RegisterEffect(ec1)
    local ec1b = ec1:Clone()
    ec1b:SetCode(EFFECT_DISABLE_EFFECT)
    ec1b:SetValue(RESET_TURN_SET)
    tc:RegisterEffect(ec1b)
    if tc:IsType(TYPE_TRAPMONSTER) then
        local ec1c = ec1:Clone()
        ec1c:SetCode(EFFECT_DISABLE_TRAPMONSTER)
        tc:RegisterEffect(ec1c)
    end
end
