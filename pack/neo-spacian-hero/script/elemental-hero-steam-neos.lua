-- Elemental HERO Steam Neos
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {CARD_NEOS}
s.material_setcode = {SET_HERO, SET_ELEMENTAL_HERO, SET_NEOS, SET_NEO_SPACIAN}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- fusion summon
    Fusion.AddProcMix(c, true, true, CARD_NEOS, 17955766, 89621922)
    Fusion.AddContactProc(c, function(tp) return Duel.GetMatchingGroup(Card.IsAbleToDeckOrExtraAsCost, tp, LOCATION_ONFIELD, 0, nil) end,
        function(g, tp)
            Duel.ConfirmCards(1 - tp, g)
            Duel.SendtoDeck(g, nil, SEQ_DECKSHUFFLE, REASON_COST + REASON_MATERIAL)
        end, function(e) return not e:GetHandler():IsLocation(LOCATION_EXTRA) end)

    -- negate and destroy
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_NEGATE + CATEGORY_DESTROY + CATEGORY_ATKCHANGE)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP + EFFECT_FLAG_DAMAGE_CAL)
    e1:SetCode(EVENT_CHAINING)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1)
    e1:SetCondition(s.e1con)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- negate effect
    aux.EnableNeosReturn(c, CATEGORY_DISABLE, nil, s.e2op)
end

function s.e1con(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    return not c:IsStatus(STATUS_BATTLE_DESTROYED) and re:GetHandler() ~= c and Duel.IsChainNegatable(ev)
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local rc = re:GetHandler()
    if chk == 0 then return true end

    Duel.SetOperationInfo(0, CATEGORY_NEGATE, eg, 1, 0, 0)
    if rc:IsDestructable() and rc:IsRelateToEffect(re) then Duel.SetOperationInfo(0, CATEGORY_DESTROY, eg, 1, 0, 0) end
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local rc = re:GetHandler()
    if Duel.NegateActivation(ev) and rc:IsRelateToEffect(re) and Duel.Destroy(rc, REASON_EFFECT) ~= 0 and c:IsRelateToEffect(e) and c:IsFaceup() then
        local ec1 = Effect.CreateEffect(c)
        ec1:SetType(EFFECT_TYPE_SINGLE)
        ec1:SetCode(EFFECT_UPDATE_ATTACK)
        ec1:SetValue(400)
        ec1:SetReset(RESET_EVENT + RESETS_STANDARD_DISABLE)
        c:RegisterEffect(ec1)
    end
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local g = Duel.GetMatchingGroup(Card.IsFaceup, tp, LOCATION_MZONE, LOCATION_MZONE, nil)
    for tc in g:Iter() do
        local ec1 = Effect.CreateEffect(c)
        ec1:SetType(EFFECT_TYPE_SINGLE)
        ec1:SetCode(EFFECT_DISABLE)
        ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
        tc:RegisterEffect(ec1)
        local ec1b = ec1:Clone()
        ec1b:SetCode(EFFECT_DISABLE_EFFECT)
        tc:RegisterEffect(ec1b)
    end
end
