-- Sinister Flame
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_series = {0x6008}

function s.initial_effect(c)
    -- negate
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_NEGATE + CATEGORY_REMOVE)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_CHAINING)
    e1:SetCountLimit(1, {id, 1})
    e1:SetCondition(s.e1con)
    e1:SetCost(s.e1cost)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- destroy
    local e2 = Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_DESTROY + CATEGORY_DAMAGE)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1, {id, 2})
    e2:SetCondition(s.e2con)
    e2:SetCost(aux.bfgcost)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)
end

function s.e1filter(c) return c:IsFaceup() and c:IsSetCard(0x6008) and c:IsAbleToRemoveAsCost() end

function s.e1con(e, tp, eg, ep, ev, re, r, rp)
    return ep ~= tp and (re:IsActiveType(TYPE_MONSTER) or re:IsHasType(EFFECT_TYPE_ACTIVATE)) and Duel.IsChainNegatable(ev)
end

function s.e1cost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return Duel.IsExistingMatchingCard(s.e1filter, tp, LOCATION_MZONE, 0, 1, nil) end

    local tc = Utility.SelectMatchingCard(HINTMSG_REMOVE, tp, s.e1filter, tp, LOCATION_MZONE, 0, 1, 1, nil):GetFirst()
    if Duel.Remove(tc, POS_FACEUP, REASON_COST + REASON_TEMPORARY) > 0 then
        tc:RegisterFlagEffect(id, RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END, 0, 1)
        local ec1 = Effect.CreateEffect(c)
        ec1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
        ec1:SetCode(EVENT_PHASE + PHASE_END)
        ec1:SetLabelObject(tc)
        ec1:SetCountLimit(1)
        ec1:SetCondition(function(e) return e:GetLabelObject():GetFlagEffect(id) > 0 end)
        ec1:SetOperation(function(e) Duel.ReturnToField(e:GetLabelObject()) end)
        ec1:SetReset(RESET_PHASE + PHASE_END)
        Duel.RegisterEffect(ec1, tp)
    end
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return true end
    Duel.SetOperationInfo(0, CATEGORY_NEGATE, eg, 1, 0, 0)
    if re:GetHandler():IsRelateToEffect(re) then Duel.SetOperationInfo(0, CATEGORY_REMOVE, eg, 1, 0, 0) end
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then Duel.Remove(eg, POS_FACEUP, REASON_EFFECT) end
end

function s.e2filter1(c, tp)
    return c:IsFaceup() and c:IsSetCard(0x6008) and c:IsType(TYPE_FUSION) and
               Duel.IsExistingMatchingCard(s.e2filter2, tp, 0, LOCATION_MZONE, 1, nil, c)
end

function s.e2filter2(c, sc) return c:IsFaceup() and c:GetAttack() > sc:GetAttack() end

function s.e2con(e, tp, eg, ep, ev, re, r, rp) return Duel.IsTurnPlayer(tp) and Duel.IsMainPhase() and aux.exccon(e) end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chk == 0 then return Duel.IsExistingTarget(s.e2filter1, tp, LOCATION_MZONE, 0, 1, nil, tp) end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TARGET)
    local tc = Duel.SelectTarget(tp, s.e2filter1, tp, LOCATION_MZONE, 0, 1, 1, nil, tp):GetFirst()
    local g = Duel.GetMatchingGroup(s.e2filter2, tp, 0, LOCATION_MZONE, nil, tc)

    local _, dmg = g:GetMaxGroup(Card.GetBaseAttack)
    Duel.SetOperationInfo(0, CATEGORY_DESTROY, g, #g, 0, 0)
    Duel.SetOperationInfo(0, CATEGORY_DAMAGE, nil, 1, 1 - tp, dmg)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local tc = Duel.GetFirstTarget()
    if not tc or not tc:IsRelateToEffect(e) or tc:IsFacedown() then return end

    local g = Duel.GetMatchingGroup(s.e2filter2, tp, 0, LOCATION_MZONE, nil, tc)
    if #g > 0 and Duel.Destroy(g, REASON_EFFECT) > 0 then
        local og = Duel.GetOperatedGroup()
        if #og > 0 then
            local _, dmg = og:GetMaxGroup(Card.GetBaseAttack)
            Duel.Damage(1 - tp, dmg, REASON_EFFECT)
        end
    end
end
