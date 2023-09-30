-- Elemental HERO Abyss Neos
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {CARD_NEOS}
s.material_setcode = {SET_HERO, SET_ELEMENTAL_HERO, SET_NEOS, SET_NEO_SPACIAN}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- fusion summon
    Fusion.AddProcMix(c, true, true, CARD_NEOS, 43237273, 17955766)
    Fusion.AddContactProc(c, function(tp) return Duel.GetMatchingGroup(Card.IsAbleToDeckOrExtraAsCost, tp, LOCATION_ONFIELD, 0, nil) end,
        function(g, tp)
            Duel.ConfirmCards(1 - tp, g)
            Duel.SendtoDeck(g, nil, SEQ_DECKSHUFFLE, REASON_COST + REASON_MATERIAL)
        end, function(e) return not e:GetHandler():IsLocation(LOCATION_EXTRA) end)

    -- banish
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_REMOVE)
    e1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_F)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetCondition(s.e1con)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- attack limit
    aux.EnableNeosReturn(c, nil, nil, s.e2op)
end

function s.e1con(e, tp, eg, ep, ev, re, r, rp) return e:GetHandler():IsPreviousLocation(LOCATION_EXTRA) end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return true end

    local g = Duel.GetMatchingGroup(aux.TRUE, tp, 0, LOCATION_ONFIELD, nil)
    Duel.SetOperationInfo(0, CATEGORY_REMOVE, g, #g, 0, 0)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local g1 = Duel.GetMatchingGroup(aux.TRUE, tp, 0, LOCATION_MZONE, nil)
    local g2 = Duel.GetMatchingGroup(aux.TRUE, tp, 0, LOCATION_SZONE, nil)

    local op = 0
    if (#g1 > #g2) then
        op = 1
    elseif (#g2 > #g1) then
        op = 2
    else
        op = Duel.SelectEffect(tp, {true, aux.Stringid(id, 1)}, {true, aux.Stringid(id, 2)})
    end

    if op == 1 then
        Duel.Remove(g1, POS_FACEUP, REASON_EFFECT)
    elseif op == 2 then
        Duel.Remove(g2, POS_FACEUP, REASON_EFFECT)
    end
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local ec1 = Effect.CreateEffect(c)
    ec1:SetDescription(aux.Stringid(id, 3))
    ec1:SetType(EFFECT_TYPE_FIELD)
    ec1:SetProperty(EFFECT_FLAG_PLAYER_TARGET + EFFECT_FLAG_CLIENT_HINT)
    ec1:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
    ec1:SetTargetRange(1, 1)
    ec1:SetReset(RESET_PHASE + PHASE_END, 2)
    Duel.RegisterEffect(ec1, tp)
end
