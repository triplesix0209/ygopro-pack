-- Dragon's Elysium
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {900007001}

function s.initial_effect(c)
    -- activate
    local act = Effect.CreateEffect(c)
    act:SetType(EFFECT_TYPE_ACTIVATE)
    act:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(act)

    -- cannot be targeted & immune
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE + EFFECT_FLAG_CANNOT_DISABLE)
    e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e1:SetRange(LOCATION_FZONE)
    e1:SetCondition(function(e)
        return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode, 900007001), e:GetHandlerPlayer(), LOCATION_MZONE, 0, 1, nil)
    end)
    e1:SetValue(aux.tgoval)
    c:RegisterEffect(e1)
    local e1b = e1:Clone()
    e1b:SetCode(EFFECT_IMMUNE_EFFECT)
    e1b:SetValue(function(e, te) return e:GetOwnerPlayer() ~= te:GetOwnerPlayer() end)
    c:RegisterEffect(e1b)

    -- activate 1 of these effects
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 0))
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_FZONE)
    e2:SetCountLimit(1)
    e2:SetCost(s.e2cost)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)
end

function s.e2filter1(c, attribute) return c:IsLevelBelow(4) and c:IsAttribute(attribute) and c:IsRace(RACE_DRAGON) and c:IsAbleToHand() end

function s.e2filter2(c) return c:IsRace(RACE_DRAGON) and c:IsAbleToGrave() end

function s.e2cost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable, tp, LOCATION_HAND, 0, 1, nil) end
    local tc = Utility.SelectMatchingCard(HINTMSG_DISCARD, tp, Card.IsDiscardable, tp, LOCATION_HAND, 0, 1, 1, nil):GetFirst()
    Duel.SendtoGrave(tc, REASON_COST + REASON_DISCARD)
    e:SetLabelObject(tc)
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local dc = e:GetLabelObject()
    local b1 = dc:IsMonster() and Duel.IsExistingMatchingCard(s.e2filter1, tp, LOCATION_DECK, 0, 1, nil, dc:GetAttribute())
    local b2 = Duel.IsExistingMatchingCard(s.e2filter2, tp, LOCATION_DECK, 0, 1, nil)
    if chk == 0 then return b1 or b2 end

    local op = Duel.SelectEffect(tp, {b1, aux.Stringid(id, 1)}, {b2, aux.Stringid(id, 2)})
    e:SetLabel(op)
    if op == 1 then
        e:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH)
        Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK)
    elseif op == 2 then
        e:SetCategory(CATEGORY_TOGRAVE)
        Duel.SetOperationInfo(0, CATEGORY_TOGRAVE, nil, 1, tp, LOCATION_DECK)
    end
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local dc = e:GetLabelObject()
    local op = e:GetLabel()
    if op == 1 then
        local g = Utility.SelectMatchingCard(HINTMSG_ATOHAND, tp, s.e2filter1, tp, LOCATION_DECK, 0, 1, 1, nil, dc:GetAttribute())
        if #g > 0 then
            Duel.SendtoHand(g, nil, REASON_EFFECT)
            Duel.ConfirmCards(1 - tp, g)
        end
    elseif op == 2 then
        local g = Utility.SelectMatchingCard(HINTMSG_TOGRAVE, tp, s.e2filter2, tp, LOCATION_DECK, 0, 1, 1, nil)
        if #g > 0 then Duel.SendtoGrave(g, REASON_EFFECT) end
    end
end
