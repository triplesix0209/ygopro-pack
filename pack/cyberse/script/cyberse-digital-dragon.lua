-- Cyberse Digital Dragon
Duel.LoadScript("util.lua")
local s, id = GetID()

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- xyz summon
    Xyz.AddProcedure(c, nil, 4, 2)

    -- target & attack limit
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
    e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e1:SetRange(LOCATION_MZONE)
    e1:SetTargetRange(LOCATION_MZONE, 0)
    e1:SetCondition(s.e1con)
    e1:SetTarget(s.e1tg)
    e1:SetValue(aux.tgoval)
    c:RegisterEffect(e1)
    local e1b = Effect.CreateEffect(c)
    e1b:SetType(EFFECT_TYPE_FIELD)
    e1b:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
    e1b:SetRange(LOCATION_MZONE)
    e1b:SetTargetRange(0, LOCATION_MZONE)
    e1b:SetCondition(s.e1con)
    e1b:SetValue(s.e1tg)
    c:RegisterEffect(e1b)

    -- atk down
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 0))
    e2:SetCategory(CATEGORY_ATKCHANGE)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1)
    e2:SetCost(s.e2cost)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2, false, REGISTER_FLAG_DETACH_XMAT)

    -- destroy
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 1))
    e3:SetCategory(CATEGORY_DESTROY)
    e3:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_BATTLE_CONFIRM)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)
end

function s.e1con(e) return Duel.IsExistingMatchingCard(Card.IsType, e:GetHandlerPlayer(), LOCATION_MZONE, 0, 1, nil, TYPE_LINK) end

function s.e1tg(e, c) return c ~= e:GetHandler() end

function s.e2cost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return e:GetHandler():CheckRemoveOverlayCard(tp, 1, REASON_COST) end
    e:GetHandler():RemoveOverlayCard(tp, 1, 1, REASON_COST)
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chk == 0 then return Duel.IsExistingTarget(Card.HasNonZeroAttack, tp, 0, LOCATION_MZONE, 1, nil) end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_FACEUP)
    Duel.SelectTarget(tp, Card.HasNonZeroAttack, tp, 0, LOCATION_MZONE, 1, 1, nil)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Duel.GetFirstTarget()
    if tc:IsFaceup() and tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) then
        local ec1 = Effect.CreateEffect(c)
        ec1:SetType(EFFECT_TYPE_SINGLE)
        ec1:SetCode(EFFECT_SET_ATTACK_FINAL)
        ec1:SetValue(0)
        ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
        tc:RegisterEffect(ec1)
    end
end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local d = Duel.GetAttackTarget()
    if chk == 0 then return Duel.GetAttacker() == e:GetHandler() and d and d:IsDefensePos() and d:IsRelateToBattle() end
    Duel.SetOperationInfo(0, CATEGORY_DESTROY, d, 1, 0, 0)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local d = Duel.GetAttackTarget()
    if d ~= nil and d:IsRelateToBattle() and d:IsDefensePos() then Duel.Destroy(d, REASON_EFFECT) end
end
