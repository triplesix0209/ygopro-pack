-- Palladium Wazir Shimon
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_series = {0x40, 0xde}

function s.initial_effect(c)
    -- special summon
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    e1:SetCode(EFFECT_SPSUMMON_PROC)
    e1:SetRange(LOCATION_HAND)
    e1:SetCondition(s.e1con)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- search
    local e2 = Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH)
    e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_SUMMON_SUCCESS)
    e2:SetCountLimit(1, id)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)
    local e2b = e2:Clone()
    e2b:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e2b)
    local e2c = e2:Clone()
    e2c:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
    c:RegisterEffect(e2c)

    -- extra material
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    e3:SetCode(EFFECT_ADD_EXTRA_TRIBUTE)
    e3:SetTargetRange(0, LOCATION_MZONE)
    e3:SetValue(POS_FACEUP)
    local e3b = Effect.CreateEffect(c)
    e3b:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_GRANT)
    e3b:SetRange(LOCATION_MZONE)
    e3b:SetTargetRange(LOCATION_HAND, 0)
    e3b:SetTarget(function(e, tc) return tc:IsLevelAbove(10) end)
    e3b:SetLabelObject(e3)
    c:RegisterEffect(e3b)
end

function s.e1rescon(sg, e, tp, mg)
    return aux.ChkfMMZ(1)(sg, e, tp, mg) and sg:GetClassCount(Card.GetCode) == #sg, sg:GetClassCount(Card.GetCode) ~= #sg
end

function s.e1con(e, c)
    if c == nil then return true end
    local tp = c:GetControler()
    local g = Duel.GetMatchingGroup(Card.IsAbleToDeckOrExtraAsCost, tp, LOCATION_GRAVE, 0, nil)
    return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and g:GetClassCount(Card.GetCode) >= 5
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk, c)
    local g = Duel.GetMatchingGroup(Card.IsAbleToDeckOrExtraAsCost, tp, LOCATION_GRAVE, 0, nil)
    local rg = aux.SelectUnselectGroup(g, e, tp, 5, 5, s.e1rescon, 1, tp, HINTMSG_TODECK, nil, nil, true)
    if #rg > 0 then
        rg:KeepAlive()
        e:SetLabelObject(rg)
        return true
    end
    return false
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp, c)
    local g = e:GetLabelObject()
    if not g then return end
    Duel.SendtoDeck(g, nil, 2, REASON_COST)
    g:DeleteGroup()
end

function s.e2filter(c) return c:IsSetCard({0x40, 0xde}) and c:IsAbleToHand() end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.e2filter, tp, LOCATION_DECK + LOCATION_GRAVE, 0, 1, nil) end
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local g = Utility.SelectMatchingCard(HINT_SELECTMSG, tp, s.e2filter, tp, LOCATION_DECK, 0, 1, 1, nil)
    if #g > 0 then
        Duel.SendtoHand(g, nil, REASON_EFFECT)
        Duel.ConfirmCards(1 - tp, g)
    end
end
