-- Frey of the Nordic Champions
local s, id = GetID()
Duel.LoadScript("util.lua")
Duel.LoadScript("util_nordic.lua")

s.listed_series = {0x42}

function s.initial_effect(c)
    -- summon
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    e1:SetCode(EFFECT_SUMMON_PROC)
    e1:SetRange(LOCATION_HAND)
    e1:SetCondition(s.e1con)
    c:RegisterEffect(e1)

    -- search
    local e2 = Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH)
    e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY + EFFECT_FLAG_DAMAGE_STEP)
    e2:SetCode(EVENT_SUMMON_SUCCESS)
    e2:SetCountLimit(1, id)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)

    -- cannot disable summon
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    e3:SetCode(EFFECT_CANNOT_DISABLE_SUMMON)
    c:RegisterEffect(e3)
    local e3b = Effect.CreateEffect(c)
    e3b:SetType(EFFECT_TYPE_FIELD)
    e3b:SetProperty(EFFECT_FLAG_IGNORE_RANGE + EFFECT_FLAG_SET_AVAILABLE)
    e3b:SetCode(EFFECT_CANNOT_DISABLE_SUMMON)
    e3b:SetRange(LOCATION_MZONE)
    e3b:SetTargetRange(1, 0)
    e3b:SetTarget(function(e, c) return c:IsSetCard(0x42) end)
    c:RegisterEffect(e3b)

    -- act limit
    local e4 = Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e4:SetCode(EVENT_SUMMON_SUCCESS)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCondition(s.e4con)
    e4:SetOperation(s.e4op1)
    c:RegisterEffect(e4)
    local e4b = e4:Clone()
    e4b:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e4b)
    local e4c = Effect.CreateEffect(c)
    e4c:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e4c:SetRange(LOCATION_MZONE)
    e4c:SetCode(EVENT_CHAIN_END)
    e4c:SetOperation(s.e4op2)
    c:RegisterEffect(e4c)
end

function s.e1con(e, c)
    if c == nil then return true end
    local tp = c:GetControler()
    return Duel.GetFieldGroupCount(tp, LOCATION_MZONE, 0) == 0 and
               Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
end

function s.e2filter(c)
    return c:IsSetCard(0x42) and c:IsType(TYPE_MONSTER) and not c:IsCode(id) and
               c:IsAbleToHand()
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local g = Duel.GetMatchingGroup(s.e2filter, tp, LOCATION_DECK, 0, nil)
    if chk == 0 then return g:GetClassCount(Card.GetCode) >= 2 end
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 2, tp, LOCATION_DECK)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local g = Duel.GetMatchingGroup(s.e2filter, tp, LOCATION_DECK, 0, nil)
    g = aux.SelectUnselectGroup(g, e, tp, 2, 2, aux.dncheck, 1, tp,
                                HINTMSG_ATOHAND)
    if #g > 0 then
        Duel.SendtoHand(g, nil, REASON_EFFECT)
        Duel.ConfirmCards(1 - tp, g)
    end
end

function s.e4filter(c, tp) return c:IsSummonPlayer(tp) and c:IsSetCard(0x42) end

function s.e4con(e, tp, eg, ep, ev, re, r, rp)
    return eg:IsExists(s.e4filter, 1, nil, tp)
end

function s.e4op1(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if Duel.GetCurrentChain() == 0 then
        Duel.SetChainLimitTillChainEnd(s.e4chainlm)
    elseif Duel.GetCurrentChain() == 1 then
        c:RegisterFlagEffect(id, RESET_EVENT + RESETS_STANDARD + RESET_PHASE +
                                 PHASE_END, 0, 1)
    end
end

function s.e4op2(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if c:GetFlagEffect(id) ~= 0 then
        Duel.SetChainLimitTillChainEnd(s.e4chainlm)
    end
    c:ResetFlagEffect(id)
end

function s.e4chainlm(e, rp, tp) return tp == rp end
