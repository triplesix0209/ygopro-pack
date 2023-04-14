-- Sinister Call
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_series = {0x6008}

function s.initial_effect(c)
    -- search
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH + CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1, {id, 1})
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- destroy spell/trap
    local e2 = Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_DESTROY)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_GRAVE)
    e1:SetCountLimit(1, {id, 2})
    e2:SetCost(aux.bfgcost)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)
end

function s.e1extracheck(tp) return not Duel.IsExistingMatchingCard(Card.IsFaceup, tp, LOCATION_MZONE, 0, 1, nil) end

function s.e1filter(c, e, tp)
    return c:IsSetCard(0x6008) and c:IsMonster() and
               (c:IsAbleToHand() or (s.e1extracheck(tp) and c:IsCanBeSpecialSummoned(e, 0, tp, false, false)))
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.e1filter, tp, LOCATION_DECK, 0, 1, nil, e, tp) end
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK)
    Duel.SetOperationInfo(0, CATEGORY_SUMMON, nil, 1, tp, LOCATION_DECK)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local tc = Utility.SelectMatchingCard(HINTMSG_ATOHAND, tp, s.e1filter, tp, LOCATION_DECK, 0, 1, 1, nil, e, tp):GetFirst()
    if not tc then return end

    if not s.e1extracheck(tp) then
        Duel.SendtoHand(tc, nil, REASON_EFFECT)
        Duel.ConfirmCards(1 - tp, tc)
        return
    end

    aux.ToHandOrElse(tc, tp, function(tc)
        return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and tc:IsCanBeSpecialSummoned(e, 0, tp, false, false, POS_FACEUP)
    end, function(tc)
        if Duel.SpecialSummon(tc, 0, tp, tp, false, false, POS_FACEUP) > 0 and tc:IsLevelAbove(5) then
            Duel.SetLP(tp, math.ceil(Duel.GetLP(tp) / 2))
        end
    end, 2)
end

function s.e2filter1(c) return c:IsFaceup() and c:IsSetCard(0x6008) end

function s.e2filter2(c) return c:IsSpellTrap() end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.e2filter1, tp, LOCATION_MZONE, 0, 1, nil) and
                   Duel.IsExistingMatchingCard(s.e2filter2, tp, LOCATION_ONFIELD, LOCATION_ONFIELD, 1, nil)
    end

    local g = Duel.GetMatchingGroup(s.e2filter2, tp, LOCATION_ONFIELD, LOCATION_ONFIELD, c)
    Duel.SetOperationInfo(0, CATEGORY_DESTROY, g, 1, 0, 0)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local ct = Duel.GetMatchingGroupCount(s.e2filter1, tp, LOCATION_MZONE, 0, nil)
    if ct <= 0 then return end

    local g = Utility.SelectMatchingCard(HINTMSG_DESTROY, tp, s.e2filter2, tp, LOCATION_ONFIELD, LOCATION_ONFIELD, 1, ct, nil)
    Duel.HintSelection(g)
    Duel.Destroy(g, REASON_EFFECT)
end
