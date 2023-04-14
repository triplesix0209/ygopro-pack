-- Ultimaya Black Rose Dragon
Duel.LoadScript("util.lua")
Duel.LoadScript("util_signer_dragon.lua")
local s, id = GetID()

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- synhcro summon
    Synchro.AddProcedure(c, nil, 1, 1, Synchro.NonTuner(nil), 1, 99)

    -- add code
    local code = Effect.CreateEffect(c)
    code:SetType(EFFECT_TYPE_SINGLE)
    code:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    code:SetCode(EFFECT_ADD_CODE)
    code:SetValue(CARD_BLACK_ROSE_DRAGON)
    c:RegisterEffect(code)

    -- destroy
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_DESTROY)
    e1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- down atk/def
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 1))
    e2:SetCategory(CATEGORY_TODECK + CATEGORY_ATKCHANGE + CATEGORY_DEFCHANGE)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(aux.TRUE, tp, 0, LOCATION_ONFIELD, 1, nil) end

    local g = Duel.GetFieldGroup(tp, 0, LOCATION_ONFIELD)
    Duel.SetOperationInfo(0, CATEGORY_DESTROY, g, #g, 0, 0)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local max = Duel.GetMatchingGroupCount(aux.TRUE, tp, 0, LOCATION_ONFIELD, nil)
    local g1 = Utility.SelectMatchingCard(HINTMSG_DESTROY, tp, aux.TRUE, tp, LOCATION_ONFIELD, 0, 1, max, nil)
    Duel.HintSelection(g1)
    local ct = Duel.Destroy(g1, REASON_EFFECT)

    if ct > 0 then
        local g2 = Utility.SelectMatchingCard(HINTMSG_DESTROY, tp, aux.TRUE, tp, 0, LOCATION_ONFIELD, 1, ct, nil)
        Duel.HintSelection(g2)
        Duel.Destroy(g2, REASON_EFFECT)
    end
end

function s.e2filter(c) return (not c:IsLocation(LOCATION_REMOVED) or c:IsFaceup()) and c:IsType(TYPE_TUNER) and c:IsAbleToDeck() end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chk == 0 then
        return Duel.IsExistingTarget(s.e2filter, tp, LOCATION_GRAVE + LOCATION_REMOVED, 0, 1, nil) and
                   Duel.IsExistingTarget(Card.IsFaceup, tp, 0, LOCATION_MZONE, 1, nil)
    end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TODECK)
    local tc1 = Duel.SelectTarget(tp, s.e2filter, tp, LOCATION_GRAVE + LOCATION_REMOVED, 0, 1, 1, nil):GetFirst()
    e:SetLabelObject(tc1)

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_FACEUP)
    Duel.SelectTarget(tp, Card.IsFaceup, tp, 0, LOCATION_MZONE, 1, 1, nil)

    Duel.SetOperationInfo(0, CATEGORY_TODECK, tc1, 1, 0, 0)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc1 = e:GetLabelObject()
    local tg = Duel.GetChainInfo(0, CHAININFO_TARGET_CARDS)
    local tc2 = tg:GetFirst()
    if tc1 == tc2 then tc2 = tg:GetNext() end

    if tc1 and tc1:IsRelateToEffect(e) and Duel.SendtoDeck(tc1, nil, SEQ_DECKSHUFFLE, REASON_EFFECT) ~= 0 then
        if tc2 and tc2:IsRelateToEffect(e) and tc2:IsFaceup() then
            local ec1 = Effect.CreateEffect(c)
            ec1:SetType(EFFECT_TYPE_SINGLE)
            ec1:SetCode(EFFECT_SET_ATTACK_FINAL)
            ec1:SetValue(math.floor(tc2:GetAttack() / 2))
            ec1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
            tc2:RegisterEffect(ec1)
            local ec1b = ec1:Clone()
            ec1b:SetCode(EFFECT_SET_DEFENSE_FINAL)
            ec1b:SetValue(math.floor(tc2:GetDefense() / 2))
            tc2:RegisterEffect(ec1b)
        end
    end
end
