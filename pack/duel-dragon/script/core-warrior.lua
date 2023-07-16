-- Synchron Warrior
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_series = {0x1017}
s.listed_names = {62125439}

function s.initial_effect(c)
    -- search & summon
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH + CATEGORY_SUMMON)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1, id)
    e1:SetCost(s.e1cost)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- token
    local e2 = Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON + CATEGORY_TOKEN)
    e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_BE_MATERIAL)
    e2:SetCondition(s.e2con)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)
end

function s.e1filter1(c) return c:IsSetCard(0x1017) and c:IsMonster() and c:IsAbleToHand() end

function s.e1filter2(c) return c:IsSummonable(true, nil) and c:IsType(TYPE_TUNER) end

function s.e1cost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return c:IsDiscardable() end

    Duel.SendtoGrave(c, REASON_COST + REASON_DISCARD)
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.e1filter1, tp, LOCATION_DECK, 0, 1, nil) end

    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK)
    Duel.SetPossibleOperationInfo(0, CATEGORY_SUMMON, nil, 1, 0, 0)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local g = Utility.SelectMatchingCard(HINTMSG_ATOHAND, tp, s.e1filter1, tp, LOCATION_DECK, 0, 1, 1, nil)
    if #g > 0 then
        Duel.SendtoHand(g, nil, REASON_EFFECT)
        Duel.ConfirmCards(1 - tp, g)
    end

    if Duel.IsExistingMatchingCard(s.e1filter2, tp, LOCATION_HAND, 0, 1, nil) and
        Duel.SelectEffectYesNo(tp, c, aux.Stringid(id, 0)) then
        Duel.BreakEffect()
        Duel.ShuffleHand(tp)

        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SUMMON)
        local tc =
            Utility.SelectMatchingCard(HINTMSG_SUMMON, tp, s.e1filter2, tp, LOCATION_HAND + LOCATION_MZONE, 0, 1, 1, nil):GetFirst()
        if tc then Duel.Summon(tp, tc, true, nil) end
    end
end

function s.e2con(e, tp, eg, ep, ev, re, r, rp) return r == REASON_SYNCHRO and e:GetHandler():IsLocation(LOCATION_GRAVE) end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and
                   Duel.IsPlayerCanSpecialSummonMonster(tp, 62125439, 0, TYPES_TOKEN, 1000, 0, 2, RACE_MACHINE, ATTRIBUTE_EARTH)
    end

    Duel.SetOperationInfo(0, CATEGORY_TOKEN, nil, 1, 0, 0)
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, 0)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    if Duel.GetLocationCount(tp, LOCATION_MZONE) < 1 or
        not Duel.IsPlayerCanSpecialSummonMonster(tp, 62125439, 0, TYPES_TOKEN, 1000, 0, 2, RACE_MACHINE, ATTRIBUTE_EARTH) then
        return
    end

    local token = Duel.CreateToken(tp, 62125439)
    Duel.SpecialSummon(token, 0, tp, tp, false, false, POS_FACEUP_ATTACK)
end
