-- Presence of the Supreme King
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {CARD_ZARC}
s.listed_series = {SET_SUPREME_KING_GATE, SET_SUPREME_KING_DRAGON}

function s.initial_effect(c)
    -- activate
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetProperty(EFFECT_FLAG_CANNOT_INACTIVATE + EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_CANNOT_NEGATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1, {id, 1}, EFFECT_COUNT_CODE_OATH)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- untargetable & indes
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e2:SetRange(LOCATION_SZONE)
    e2:SetCondition(function(e)
        return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode, CARD_ZARC), e:GetHandlerPlayer(), LOCATION_ONFIELD, 0, 1, nil)
    end)
    e2:SetValue(aux.tgoval)
    c:RegisterEffect(e2)
    local e2b = e2:Clone()
    e2b:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e2b:SetValue(1)
    c:RegisterEffect(e2b)

    -- send pendulum to extra
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_F)
    e3:SetCode(EVENT_PHASE + PHASE_END)
    e3:SetRange(LOCATION_SZONE)
    e3:SetCountLimit(1)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)

    -- multi-attack
    local e4 = Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id, 1))
    e4:SetType(EFFECT_TYPE_IGNITION)
    e4:SetProperty(EFFECT_FLAG_CANNOT_INACTIVATE + EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_CANNOT_NEGATE)
    e4:SetRange(LOCATION_SZONE)
    e4:SetCountLimit(1, {id, 2})
    e4:SetCost(s.e4cost)
    e4:SetTarget(s.e4tg)
    e4:SetOperation(s.e4op)
    c:RegisterEffect(e4)

    -- place in pendulum zone
    local e5 = Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(id, 3))
    e5:SetType(EFFECT_TYPE_QUICK_O)
    e5:SetProperty(EFFECT_FLAG_CANNOT_INACTIVATE + EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_CANNOT_NEGATE)
    e5:SetCode(EVENT_FREE_CHAIN)
    e5:SetRange(LOCATION_SZONE)
    e5:SetHintTiming(0, TIMING_END_PHASE)
    e5:SetCountLimit(1, {id, 2})
    e5:SetTarget(s.e5tg)
    e5:SetOperation(s.e5op)
    c:RegisterEffect(e5)

    -- special summon from pendulum zone
    local e6 = Effect.CreateEffect(c)
    e6:SetDescription(aux.Stringid(id, 4))
    e6:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e6:SetType(EFFECT_TYPE_QUICK_O)
    e6:SetProperty(EFFECT_FLAG_CANNOT_INACTIVATE + EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_CANNOT_NEGATE)
    e6:SetCode(EVENT_FREE_CHAIN)
    e6:SetRange(LOCATION_SZONE)
    e6:SetHintTiming(0, TIMING_END_PHASE)
    e6:SetCountLimit(1, {id, 2})
    e6:SetTarget(s.e6tg)
    e6:SetOperation(s.e6op)
    c:RegisterEffect(e6)
end

function s.countFreePendulumZones(tp)
    local count = 0
    if Duel.CheckLocation(tp, LOCATION_PZONE, 0) then count = count + 1 end
    if Duel.CheckLocation(tp, LOCATION_PZONE, 1) then count = count + 1 end
    return count
end

function s.e1filter1(c)
    if not c:IsType(TYPE_PENDULUM) or c:IsForbidden() then return false end
    if c:IsLocation(LOCATION_EXTRA) and c:IsFacedown() then return false end
    return c:IsSetCard(SET_SUPREME_KING_GATE)
end

function s.e1filter2(c, lsc, rsc)
    if c:IsLocation(LOCATION_EXTRA) and c:IsFacedown() then return false end
    return c:IsSetCard(SET_SUPREME_KING_DRAGON) and lsc < c:GetLevel() and c:GetLevel() < rsc and c:IsAbleToHand()
end

function s.e1check(sg, e, tp) return sg:GetClassCount(Card.GetCode) == 2 end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    local g = Duel.GetMatchingGroup(s.e1filter1, tp, LOCATION_HAND + LOCATION_DECK + LOCATION_GRAVE + LOCATION_EXTRA, 0, nil)
    if chk == 0 then
        return s.countFreePendulumZones(tp) >= 2 and (Duel.GetLocationCount(tp, LOCATION_SZONE) >= 2 or c:IsLocation(LOCATION_SZONE)) and
                   aux.SelectUnselectGroup(g, e, tp, 2, 2, s.e1check, 0)
    end

    Duel.SetPossibleOperationInfo(0, CATEGORY_TOHAND, nil, 1, 0, LOCATION_DECK)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) or s.countFreePendulumZones(tp) < 2 then return end
    local pg = aux.SelectUnselectGroup(Duel.GetMatchingGroup(aux.NecroValleyFilter(s.e1filter1), tp,
        LOCATION_HAND + LOCATION_DECK + LOCATION_GRAVE + LOCATION_EXTRA, 0, nil), e, tp, 2, 2, s.e1check, 1, tp, HINTMSG_ATOHAND)
    if #pg < 2 then return end
    for tc in pg:Iter() do Duel.MoveToField(tc, tp, tp, LOCATION_PZONE, POS_FACEUP, true) end

    if Duel.GetFieldCard(tp, LOCATION_PZONE, 0) and Duel.GetFieldCard(tp, LOCATION_PZONE, 1) then
        local lsc = Duel.GetFieldCard(tp, LOCATION_PZONE, 0):GetLeftScale()
        local rsc = Duel.GetFieldCard(tp, LOCATION_PZONE, 1):GetRightScale()
        if lsc > rsc then lsc, rsc = rsc, lsc end
        if Duel.IsExistingMatchingCard(s.e1filter2, tp, LOCATION_DECK + LOCATION_EXTRA, 0, 1, nil, lsc, rsc) and
            Duel.SelectEffectYesNo(tp, c, aux.Stringid(id, 0)) then
            local sg = Utility.SelectMatchingCard(HINTMSG_ATOHAND, tp, s.e1filter2, tp, LOCATION_DECK + LOCATION_EXTRA, 0, 1, 1, nil, lsc, rsc)
            Duel.SendtoHand(sg, nil, REASON_EFFECT)
            Duel.ConfirmCards(1 - tp, sg)
        end
    end
end

function s.e3filter(c) return c:IsType(TYPE_PENDULUM) and not c:IsForbidden() end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local g = Duel.GetMatchingGroup(s.e3filter, tp, LOCATION_GRAVE, 0, nil)
    if chk == 0 then return #g > 0 end

    Duel.SetOperationInfo(0, CATEGORY_LEAVE_GRAVE, g, #g, 0, 0)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local g = Duel.GetMatchingGroup(s.e3filter, tp, LOCATION_GRAVE, 0, nil)
    if #g > 0 then Duel.SendtoExtraP(g, nil, REASON_EFFECT) end
end

function s.e4filter(c) return c:IsFaceup() and c:IsCode(CARD_ZARC) end

function s.e4cost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return c:IsAbleToGraveAsCost() end
    Duel.SendtoGrave(c, REASON_COST)
end

function s.e4tg(e, tp, eg, ep, ev, re, r, rp, chk) if chk == 0 then return Duel.IsExistingMatchingCard(s.e4filter, tp, LOCATION_MZONE, 0, 1, nil) end end

function s.e4op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Utility.SelectMatchingCard(HINTMSG_SELECT, tp, s.e4filter, tp, LOCATION_MZONE, 0, 1, 1, nil):GetFirst()
    if not tc then return end
    Duel.HintSelection(tc)

    -- multi-attack
    local ec1 = Effect.CreateEffect(c)
    ec1:SetDescription(aux.Stringid(id, 2))
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
    ec1:SetCode(EFFECT_ATTACK_ALL)
    ec1:SetValue(1)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
    tc:RegisterEffect(ec1)

    -- act limit
    local ec2 = Effect.CreateEffect(c)
    ec2:SetType(EFFECT_TYPE_FIELD)
    ec2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    ec2:SetCode(EFFECT_CANNOT_ACTIVATE)
    ec2:SetRange(LOCATION_MZONE)
    ec2:SetTargetRange(0, 1)
    ec2:SetValue(function(e, re, tp) return re:IsHasType(EFFECT_TYPE_ACTIVATE) end)
    ec2:SetCondition(function(e) return Duel.GetAttacker() == e:GetHandler() end)
    ec2:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
    c:RegisterEffect(ec2)
end

function s.e5filter(c) return c:IsFaceup() and c:IsType(TYPE_PENDULUM) end

function s.e5tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chk == 0 then
        return (Duel.CheckLocation(tp, LOCATION_PZONE, 0) or Duel.CheckLocation(tp, LOCATION_PZONE, 1)) and
                   Duel.IsExistingMatchingCard(s.e5filter, tp, LOCATION_MZONE, 0, 1, nil)
    end
end

function s.e5op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) or not (Duel.CheckLocation(tp, LOCATION_PZONE, 0) or Duel.CheckLocation(tp, LOCATION_PZONE, 1)) then return end

    local g = Utility.SelectMatchingCard(aux.Stringid(id, 1), tp, s.e5filter, tp, LOCATION_MZONE, 0, 1, 1, nil)
    Duel.HintSelection(g)

    if #g > 0 then Duel.MoveToField(g:GetFirst(), tp, tp, LOCATION_PZONE, POS_FACEUP, true) end
end

function s.e6filter(c, e, tp) return c:IsCanBeSpecialSummoned(e, SUMMON_TYPE_PENDULUM, tp, false, false) end

function s.e6tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chk == 0 then
        return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and Duel.IsExistingMatchingCard(s.e6filter, tp, LOCATION_PZONE, 0, 1, nil, e, tp)
    end

    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, 0, LOCATION_PZONE)
end

function s.e6op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) then return end

    local g = Utility.SelectMatchingCard(HINTMSG_SPSUMMON, tp, s.e6filter, tp, LOCATION_PZONE, 0, 1, 1, nil, e, tp)
    Duel.HintSelection(g)

    if #g > 0 then Duel.SpecialSummon(g, SUMMON_TYPE_PENDULUM, tp, tp, false, false, POS_FACEUP) end
end
