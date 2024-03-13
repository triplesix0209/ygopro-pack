-- Palladium Spirit Kuriboh
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {CARD_MONSTER_REBORN}

function s.initial_effect(c)
    -- avoid damage
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
    e1:SetRange(LOCATION_HAND)
    e1:SetCost(s.e1cost)
    e1:SetCondition(s.e1con1)
    e1:SetOperation(s.e1op1)
    c:RegisterEffect(e1)
    local e1b = e1:Clone()
    e1b:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1b:SetCode(EVENT_CHAINING)
    e1b:SetCondition(s.e1con2)
    e1b:SetOperation(s.e1op2)
    c:RegisterEffect(e1b)

    -- search "monster reborn"
    local e2 = Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH)
    e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_TO_GRAVE)
    e2:SetCountLimit(1, id)
    e2:SetCondition(s.e2con)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)
end

function s.e1cost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return c:IsDiscardable() end

    Duel.SendtoGrave(c, REASON_COST + REASON_DISCARD)
end

function s.e1con1(e, tp, eg, ep, ev, re, r, rp) return Duel.GetBattleDamage(tp) > 0 end

function s.e1op1(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()

    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    ec1:SetCode(EVENT_PRE_BATTLE_DAMAGE)
    ec1:SetOperation(function(e, tp, eg, ep, ev, re, r, rp) Duel.ChangeBattleDamage(tp, 0) end)
    ec1:SetReset(RESET_PHASE + PHASE_DAMAGE)
    Duel.RegisterEffect(ec1, tp)
end

function s.e1con2(e, tp, eg, ep, ev, re, r, rp) return aux.damcon1(e, tp, eg, ep, ev, re, r, rp) and re:IsActiveType(TYPE_MONSTER) end

function s.e1op2(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local cid = Duel.GetChainInfo(ev, CHAININFO_CHAIN_ID)

    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_FIELD)
    ec1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    ec1:SetCode(EFFECT_CHANGE_DAMAGE)
    ec1:SetTargetRange(1, 0)
    ec1:SetLabel(cid)
    ec1:SetValue(function(e, re, val, r, rp, rc)
        local cc = Duel.GetCurrentChain()
        if cc == 0 or r & REASON_EFFECT == 0 then return end

        local cid = Duel.GetChainInfo(0, CHAININFO_CHAIN_ID)
        if cid == e:GetLabel() then
            e:SetLabel(val)
            return 0
        else
            return val
        end
    end)
    ec1:SetReset(RESET_CHAIN)
    Duel.RegisterEffect(ec1, tp)
end

function s.e2con(e, tp, eg, ep, ev, re, r, rp) return e:GetHandler():IsPreviousLocation(LOCATION_HAND + LOCATION_ONFIELD) end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return true end
    Duel.SetPossibleOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK + LOCATION_GRAVE)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    ec1:SetCode(EVENT_PHASE + PHASE_END)
    ec1:SetCountLimit(1)
    ec1:SetCondition(s.e2thcon)
    ec1:SetOperation(s.e2thop)
    ec1:SetReset(RESET_PHASE + PHASE_END)
    Duel.RegisterEffect(ec1, tp)
end

function s.e2thfilter(c) return c:IsCode(CARD_MONSTER_REBORN) and c:IsAbleToHand() end

function s.e2thcon(e, tp, eg, ep, ev, re, r, rp) return Duel.IsExistingMatchingCard(s.e2thfilter, tp, LOCATION_DECK + LOCATION_GRAVE, 0, 1, nil) end

function s.e2thop(e, tp, eg, ep, ev, re, r, rp)
    Utility.HintCard(e)
    local g = Utility.SelectMatchingCard(HINTMSG_ATOHAND, tp, s.e2thfilter, tp, LOCATION_DECK + LOCATION_GRAVE, 0, 1, 1, nil)
    if #g > 0 then
        Duel.SendtoHand(g, nil, REASON_EFFECT)
        Duel.ConfirmCards(1 - tp, g)
    end
end
