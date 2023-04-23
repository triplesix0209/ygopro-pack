-- Sacred Palladium Oracle Mahad
Duel.LoadScript("util.lua")
local s, id = GetID()

function s.initial_effect(c)
    -- special summon
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DELAY + EFFECT_FLAG_DAMAGE_STEP)
    e1:SetCode(EVENT_TO_HAND)
    e1:SetRange(LOCATION_HAND)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- search
    local e2 = Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH + CATEGORY_TODECK)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_HAND)
    e2:SetCountLimit(1, id)
    e2:SetCost(s.e2cost)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)

    -- atk up
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e3:SetCode(EFFECT_SET_ATTACK_FINAL)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCondition(s.e3con)
    e3:SetValue(s.e3val)
    c:RegisterEffect(e3)
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and c:IsCanBeSpecialSummoned(e, 0, tp, false, false) end

    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, c, 1, 0, 0)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) then return end

    Duel.SpecialSummon(c, 0, tp, tp, false, false, POS_FACEUP)
end

function s.e2filter(c) return c:IsSpellTrap() and c:ListsCode(71703785) and c:IsAbleToHand() end

function s.e2cost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return not c:IsPublic() end
    Duel.ConfirmCards(1 - tp, c)
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.e2filter, tp, LOCATION_DECK, 0, 1, nil) end

    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK)
    Duel.SetOperationInfo(0, CATEGORY_TODECK, nil, 1, tp, LOCATION_HAND)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local tc = Utility.SelectMatchingCard(HINTMSG_ATOHAND, tp, s.e2filter, tp, LOCATION_DECK, 0, 1, 1, nil):GetFirst()
    if tc and Duel.SendtoHand(tc, nil, REASON_EFFECT) > 0 and tc:IsLocation(LOCATION_HAND) then
        Duel.ConfirmCards(1 - tp, tc)
        Duel.ShuffleHand(tp)
        Duel.ShuffleDeck(tp)
        Duel.BreakEffect()

        local g = Utility.SelectMatchingCard(HINTMSG_TODECK, tp, Card.IsAbleToDeck, tp, LOCATION_HAND, 0, 1, 1, nil)
        Duel.SendtoDeck(g, nil, SEQ_DECKTOP, REASON_EFFECT)
    end
end

function s.e3con(e, tp, eg, ep, ev, re, r, rp)
    local ph = Duel.GetCurrentPhase()
    local bc = e:GetHandler():GetBattleTarget()
    return (ph == PHASE_DAMAGE or ph == PHASE_DAMAGE_CAL) and bc and bc:IsAttribute(ATTRIBUTE_DARK)
end

function s.e3val(e, c) return e:GetHandler():GetAttack() * 2 end
