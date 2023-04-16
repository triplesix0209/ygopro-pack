-- Palladium Mirror Force
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_series = {0x13a}

function s.initial_effect(c)
    -- activate (target)
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_DISABLE + CATEGORY_DESTROY)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_CHAINING)
    e1:SetCondition(s.e1con)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- activate (attack)
    local e2 = Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_DESTROY)
    e2:SetType(EFFECT_TYPE_ACTIVATE)
    e2:SetCode(EVENT_ATTACK_ANNOUNCE)
    e2:SetCondition(s.e2con)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)

    -- set
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetCode(EVENT_TO_GRAVE)
    e3:SetCondition(s.e3con)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)
end

function s.e1con(e, tp, eg, ep, ev, re, r, rp)
    local tg = Duel.GetChainInfo(ev, CHAININFO_TARGET_CARDS)
    if rp == tp or not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) or not tg then return false end

    return re:IsActiveType(TYPE_MONSTER) and Duel.IsChainDisablable(ev) and
               tg:IsExists(function(c, tp) return c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) end, 1, nil, tp)
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return not re:GetHandler():IsDisabled() or Duel.IsExistingMatchingCard(Card.IsAttackPos, tp, 0, LOCATION_MZONE, 1, nil) end

    local g = Duel.GetMatchingGroup(Card.IsAttackPos, tp, 0, LOCATION_MZONE, nil)
    Duel.SetOperationInfo(0, CATEGORY_DESTROY, g, #g, 0, 0)
    Duel.SetOperationInfo(0, CATEGORY_DISABLE, eg, 1, 0, 0)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    Duel.NegateEffect(ev)
    local g = Duel.GetMatchingGroup(Card.IsAttackPos, tp, 0, LOCATION_MZONE, nil)
    if #g > 0 then Duel.Destroy(g, REASON_EFFECT) end
end

function s.e2con(e, tp) return tp ~= Duel.GetTurnPlayer() end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(Card.IsAttackPos, tp, 0, LOCATION_MZONE, 1, nil) end

    local g = Duel.GetMatchingGroup(Card.IsAttackPos, tp, 0, LOCATION_MZONE, nil)
    Duel.SetOperationInfo(0, CATEGORY_DESTROY, g, #g, 0, 0)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    Duel.NegateAttack()
    local g = Duel.GetMatchingGroup(Card.IsAttackPos, tp, 0, LOCATION_MZONE, nil)
    if #g > 0 then Duel.Destroy(g, REASON_EFFECT) end
end

function s.e3filter(c) return not c:IsCode(id) and c:IsSetCard(0x13a) and c:IsSpellTrap() and c:IsSSetable() end

function s.e3con(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    return rp == 1 - tp and c:IsReason(REASON_EFFECT) and c:IsReason(REASON_DESTROY) and c:IsPreviousControler(tp) and
               c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousPosition(POS_FACEDOWN)
end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then
        return Duel.GetLocationCount(tp, LOCATION_SZONE) > 1 and e:GetHandler():IsSSetable() and
                   Duel.IsExistingMatchingCard(s.e3filter, tp, LOCATION_HAND + LOCATION_DECK + LOCATION_GRAVE, 0, 1, nil)
    end
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if Duel.GetLocationCount(tp, LOCATION_SZONE) < 2 or not c:IsRelateToEffect(e) or not c:IsSSetable() then return end

    local tc = Utility.SelectMatchingCard(HINTMSG_SET, tp, aux.NecroValleyFilter(s.e3filter), tp, LOCATION_HAND + LOCATION_DECK + LOCATION_GRAVE, 0,
        1, 1, nil):GetFirst()
    if not tc then return end

    Duel.SSet(tp, Group.FromCards(c, tc))
    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
    ec1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
    c:RegisterEffect(ec1)
    if tc:IsTrap() or tc:IsQuickPlaySpell() then
        local ec1b = ec1:Clone()
        ec1:SetCode(tc:IsTrap() and EFFECT_TRAP_ACT_IN_SET_TURN or EFFECT_QP_ACT_IN_SET_TURN)
        tc:RegisterEffect(ec1b)
    end
end
