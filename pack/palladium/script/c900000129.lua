-- Swords of Palladium Light
Duel.LoadScript("util.lua")
local s, id = GetID()

s.counter_place_list = {COUNTER_SPELL}

function s.initial_effect(c)
    c:SetUniqueOnField(1, 0, id)
    c:EnableCounterPermit(COUNTER_SPELL)
    c:SetCounterLimit(COUNTER_SPELL, 3)

    -- activate
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_COUNTER + CATEGORY_POSITION)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetHintTiming(TIMINGS_CHECK_MONSTER + TIMING_MAIN_END)
    e1:SetCondition(s.e1con)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)
    local e1b = Effect.CreateEffect(c)
    e1b:SetType(EFFECT_TYPE_SINGLE)
    e1b:SetCode(EFFECT_REMAIN_FIELD)
    c:RegisterEffect(e1b)

    -- remove counter
    local e2 = Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_COUNTER)
    e2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e2:SetRange(LOCATION_SZONE)
    e2:SetCode(EVENT_PHASE + PHASE_END)
    e2:SetCountLimit(1)
    e2:SetCondition(function(e, tp)
        local c = e:GetHandler()
        return Duel.GetTurnPlayer() == 1 - tp and c:IsCanRemoveCounter(tp, COUNTER_SPELL, 1, REASON_EFFECT)
    end)
    e2:SetOperation(function(e, tp) e:GetHandler():RemoveCounter(tp, COUNTER_SPELL, 1, REASON_EFFECT) end)
    c:RegisterEffect(e2)

    -- cannot attack
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetRange(LOCATION_SZONE)
    e3:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
    e3:SetTargetRange(0, LOCATION_MZONE)
    e3:SetCondition(function(e) return e:GetHandler():GetCounter(COUNTER_SPELL) > 0 end)
    c:RegisterEffect(e3)

    -- draw
    local e4 = Effect.CreateEffect(c)
    e4:SetDescription(1108)
    e4:SetCategory(CATEGORY_DRAW)
    e4:SetType(EFFECT_TYPE_IGNITION)
    e4:SetRange(LOCATION_SZONE)
    e4:SetCondition(s.e4con)
    e4:SetCost(s.e4cost)
    e4:SetTarget(s.e4tg)
    e4:SetOperation(s.e4op)
    c:RegisterEffect(e4)
end

function s.e1con(e, tp, eg, ep, ev, re, r, rp) return Duel.GetCurrentPhase() == PHASE_MAIN1 end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return e:IsHasType(EFFECT_TYPE_ACTIVATE) end
    local g = Duel.GetMatchingGroup(Card.IsFacedown, tp, 0, LOCATION_MZONE, nil)
    Duel.SetOperationInfo(0, CATEGORY_POSITION, g, #g, 0, 0)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    c:AddCounter(COUNTER_SPELL, 3)

    local g = Duel.GetMatchingGroup(Card.IsFacedown, tp, 0, LOCATION_MZONE, nil)
    if #g > 0 then Duel.ChangePosition(g, POS_FACEUP_ATTACK, POS_FACEUP_ATTACK, POS_FACEUP_DEFENSE, POS_FACEUP_DEFENSE, true) end
end

function s.e4con(e, tp, eg, ep, ev, re, r, rp) return e:GetHandler():GetCounter(COUNTER_SPELL) == 0 end

function s.e4cost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return e:GetHandler():IsAbleToGraveAsCost() end
    Duel.SendtoGrave(e:GetHandler(), REASON_COST)
end

function s.e4tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsPlayerCanDraw(tp, 3) end
    Duel.SetTargetPlayer(tp)
    Duel.SetTargetParam(3)
    Duel.SetOperationInfo(0, CATEGORY_DRAW, nil, 0, tp, 3)
end

function s.e4op(e, tp, eg, ep, ev, re, r, rp)
    local p, d = Duel.GetChainInfo(0, CHAININFO_TARGET_PLAYER, CHAININFO_TARGET_PARAM)
    Duel.Draw(p, d, REASON_EFFECT)
end
