-- Halo, Dragon Ruler of Shines
Duel.LoadScript("util.lua")
Duel.LoadScript("util_dragon_ruler.lua")
local s, id = GetID()

function s.initial_effect(c)
    -- special summon
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(2)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_HAND + LOCATION_GRAVE)
    e1:SetCountLimit(1, id)
    e1:SetCost(s.e1cost)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- return
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 0))
    e2:SetCategory(CATEGORY_TOHAND)
    e2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_F)
    e2:SetCode(EVENT_PHASE + PHASE_END)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1, id)
    e2:SetCondition(s.e2con)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)

    -- add banished card
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 1))
    e3:SetCategory(CATEGORY_REMOVE)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e3:SetRange(LOCATION_HAND)
    e3:SetCountLimit(1, id)
    e3:SetCost(s.e3cost)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)

    -- search
    local e4 = Effect.CreateEffect(c)
    e4:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH)
    e4:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP + EFFECT_FLAG_DELAY)
    e4:SetCode(EVENT_REMOVE)
    e4:SetCountLimit(1, id)
    e4:SetTarget(s.e4tg)
    e4:SetOperation(s.e4op)
    c:RegisterEffect(e4)
end

function s.e1filter(c)
    return (c:IsRace(RACE_DRAGON) or c:IsAttribute(ATTRIBUTE_LIGHT)) and c:IsAbleToRemoveAsCost() and
               (c:IsLocation(LOCATION_HAND) or aux.SpElimFilter(c, true))
end

function s.e1cost(e, tp, eg, ep, ev, re, r, rp, chk)
    local rg = Duel.GetMatchingGroup(s.e1filter, tp, LOCATION_HAND + LOCATION_MZONE + LOCATION_GRAVE, 0, e:GetHandler())
    if chk == 0 then
        return Duel.GetLocationCount(tp, LOCATION_MZONE) > -2 and #rg > 1 and aux.SelectUnselectGroup(rg, e, tp, 2, 2, aux.ChkfMMZ(1), 0)
    end

    local g = aux.SelectUnselectGroup(rg, e, tp, 2, 2, aux.ChkfMMZ(1), 1, tp, HINTMSG_REMOVE)
    Duel.Remove(g, POS_FACEUP, REASON_COST)
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return c:IsCanBeSpecialSummoned(e, 0, tp, false, false) end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, c, 1, 0, 0)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if c:IsRelateToEffect(e) then Duel.SpecialSummon(c, 0, tp, tp, false, false, POS_FACEUP) end
end

function s.e2con(e, tp, eg, ep, ev, re, r, rp) return Duel.GetTurnPlayer() ~= tp and e:GetHandler():IsSummonType(SUMMON_TYPE_SPECIAL) end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return true end
    Duel.SetOperationInfo(0, CATEGORY_TOGRAVE, e:GetHandler(), 1, 0, 0)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if c:IsRelateToEffect(e) and c:IsFaceup() then Duel.SendtoHand(c, nil, REASON_EFFECT) end
end

function s.e3filter1(c) return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsDiscardable() and c:IsAbleToGraveAsCost() end

function s.e3filter2(c) return c:IsFaceup() and c:IsMonster() and c:IsAbleToHand() end

function s.e3cost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return c:IsDiscardable() and c:IsAbleToGraveAsCost() and Duel.IsExistingMatchingCard(s.e3filter1, tp, LOCATION_HAND, 0, 1, c) end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_DISCARD)
    local g = Duel.SelectMatchingCard(tp, s.e3filter1, tp, LOCATION_HAND, 0, 1, 1, c)
    g:AddCard(c)

    Duel.SendtoGrave(g, REASON_COST + REASON_DISCARD)
end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chk == 0 then return Duel.IsExistingTarget(s.e3filter2, tp, LOCATION_REMOVED, 0, 1, nil) end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_RTOHAND)
    local g = Duel.SelectTarget(tp, s.e3filter2, tp, LOCATION_REMOVED, 0, 1, 1, nil)

    Duel.SetOperationInfo(0, CATEGORY_TOHAND, g, #g, 0, 0)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local tc = Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
        Duel.SendtoHand(tc, nil, REASON_EFFECT)
        Duel.ConfirmCards(1 - tp, tc)
    end
end

function s.e4filter(c) return c:IsRace(RACE_DRAGON) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsAbleToHand() end

function s.e4tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.e4filter, tp, LOCATION_DECK, 0, 1, nil) end
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK)
end

function s.e4op(e, tp, eg, ep, ev, re, r, rp)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
    local g = Duel.SelectMatchingCard(tp, s.e4filter, tp, LOCATION_DECK, 0, 1, 1, nil)
    if #g > 0 then
        Duel.SendtoHand(g, nil, REASON_EFFECT)
        Duel.ConfirmCards(1 - tp, g)
    end
end
