-- Xtra HERO Infernal Caller
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {CARD_DARK_FUSION}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- link summon
    Link.AddProcedure(c, aux.FilterBoolFunctionEx(Card.IsRace, RACE_FIEND), 2)

    -- apply effect
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_REMOVE)
    e1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET + EFFECT_FLAG_DELAY)
    e1:SetRange(EVENT_SPSUMMON_SUCCESS)
    e1:SetCountLimit(1, id)
    e1:SetCondition(s.e1con)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- draw
    local e2 = Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_DRAW)
    e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_BE_MATERIAL)
    e2:SetCondition(s.e2con)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)
end

function s.e1filter(c)
    return (c:IsCode(CARD_DARK_FUSION) or (c:IsSpellTrap() and c:ListsCode(CARD_DARK_FUSION))) and c:IsAbleToRemove() and
               c:CheckActivateEffect(true, true, false) ~= nil
end

function s.e1con(e, tp, eg, ep, ev, re, r, rp) return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK) end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chk == 0 then return Duel.IsExistingTarget(s.e1filter, tp, LOCATION_GRAVE, 0, 1, nil) end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_REMOVE)
    local tc = Duel.SelectTarget(tp, s.e1filter, tp, LOCATION_GRAVE, 0, 1, 1, nil):GetFirst()
    e:SetLabelObject(tc)

    local te = tc:CheckActivateEffect(true, true, false)
    e:SetProperty(EFFECT_FLAG_CARD_TARGET | te:GetProperty())
    local tg = te:GetTarget()
    if tg then tg(e, tp, eg, ep, ev, re, r, rp, 1) end

    Duel.SetOperationInfo(0, CATEGORY_REMOVE, tc, 1, tp, 0)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = e:GetLabelObject()
    if not tc:IsRelateToEffect(e) or Duel.Remove(tc, POS_FACEUP, REASON_EFFECT) == 0 then return end

    local te = tc:CheckActivateEffect(true, true, false)
    local op = te:GetOperation()
    if op then op(e, tp, eg, ep, ev, re, r, rp) end

    local ec1 = Effect.CreateEffect(c)
    ec1:SetDescription(aux.Stringid(id, 0))
    ec1:SetType(EFFECT_TYPE_FIELD)
    ec1:SetProperty(EFFECT_FLAG_PLAYER_TARGET + EFFECT_FLAG_CLIENT_HINT)
    ec1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    ec1:SetTargetRange(1, 0)
    ec1:SetReset(RESET_PHASE + PHASE_END)
    Duel.RegisterEffect(ec1, tp)
end

function s.e2con(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    return (r & REASON_FUSION) == REASON_FUSION and c:IsLocation(LOCATION_GRAVE + LOCATION_REMOVED) and c:IsFaceup()
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chk == 0 then return Duel.IsPlayerCanDraw(tp, 1) end
    Duel.SetTargetPlayer(tp)
    Duel.SetTargetParam(1)
    Duel.SetOperationInfo(0, CATEGORY_DRAW, nil, 0, tp, 1)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp, chk)
    local p, d = Duel.GetChainInfo(0, CHAININFO_TARGET_PLAYER, CHAININFO_TARGET_PARAM)
    Duel.Draw(p, d, REASON_EFFECT)
end
