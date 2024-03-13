-- Firewall Dragon Pyrosoul
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_series = {SET_CYNET}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- link summon
    Link.AddProcedure(c, aux.FilterBoolFunctionEx(Card.IsRace, RACE_CYBERSE), 2, 99,
        function(g, sc, sumtype, tp) return g:CheckDifferentPropertyBinary(Card.GetAttribute, sc, sumtype, tp) end)

    -- destroy, atk up and draw
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_DESTROY + CATEGORY_ATKCHANGE)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET + EFFECT_FLAG_DELAY + EFFECT_FLAG_DAMAGE_STEP)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetRange(LOCATION_MZONE)
    e1:SetHintTiming(TIMING_DAMAGE_STEP, TIMING_DAMAGE_STEP + TIMINGS_CHECK_MONSTER_E)
    e1:SetCountLimit(1, {id, 1})
    e1:SetCondition(s.e1con)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- special summon itself
    local e2 = Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_DESTROY + CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1, {id, 1})
    e2:SetCondition(aux.exccon)
    e2:SetCost(s.e2cost)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)
end

function s.e1con(e, tp, eg, ep, ev, re, r, rp) return Duel.GetCurrentPhase() ~= PHASE_DAMAGE or not Duel.IsDamageCalculated() end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    local c = e:GetHandler()
    local ct = #(c:GetMutualLinkedGroup():Filter(Card.IsMonster, nil))
    if chk == 0 then return ct > 0 and Duel.IsExistingTarget(aux.TRUE, tp, LOCATION_ONFIELD, LOCATION_ONFIELD, 1, c) end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_DESTROY)
    local g = Duel.SelectTarget(tp, aux.TRUE, tp, LOCATION_ONFIELD, LOCATION_ONFIELD, 1, ct, c)
    Duel.SetOperationInfo(0, CATEGORY_DESTROY, g, #g, 0, 0)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local g = Duel.GetTargetCards(e)
    local ct = Duel.Destroy(g, REASON_EFFECT)

    if ct > 0 and c:IsFaceup() and c:IsRelateToEffect(e) then
        local ec1 = Effect.CreateEffect(c)
        ec1:SetType(EFFECT_TYPE_SINGLE)
        ec1:SetCode(EFFECT_UPDATE_ATTACK)
        ec1:SetValue(ct * 1000)
        ec1:SetReset(RESET_EVENT + RESETS_STANDARD_DISABLE + RESET_PHASE + PHASE_END)
        c:RegisterEffect(ec1)
    end
end

function s.e2filter1(c, tp) return c:IsFaceup() and c:IsRace(RACE_CYBERSE) and Duel.GetMZoneCount(tp, c) > 0 end

function s.e2filter2(c, e, tp, sc, zones, fp)
    local zone = (zones | (c:IsLinkMonster() and sc:GetToBeLinkedZone(c, fp) or 0)) & ZONES_MMZ
    return zone > 0 and c:IsCanBeSpecialSummoned(e, 0, tp, false, false, POS_FACEUP, fp, zone)
end

function s.e2cost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.CheckLPCost(tp, 1000) end
    Duel.PayLPCost(tp, 1000)
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    local c = e:GetHandler()
    local ft = Duel.GetLocationCount(tp, LOCATION_MZONE)
    if chk == 0 then
        return ft > -1 and c:IsCanBeSpecialSummoned(e, 0, tp, false, false) and Duel.IsExistingTarget(s.e2filter1, tp, LOCATION_MZONE, 0, 1, nil, tp)
    end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_DESTROY)
    local g = Duel.SelectTarget(tp, s.e2filter1, tp, LOCATION_MZONE, 0, 1, 1, nil, tp)
    Duel.SetOperationInfo(0, CATEGORY_DESTROY, g, #g, 0, 0)
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, c, 1, 0, 0)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Duel.GetFirstTarget()
    if not tc:IsRelateToEffect(e) or Duel.Destroy(tc, REASON_EFFECT) == 0 then return end

    -- local g1 = Duel.GetMatchingGroup(s.e2filter2, tp, LOCATION_GRAVE, 0, nil, e, tp, c, c:GetLinkedZone(tp), tp)
    -- local g2 = Duel.GetMatchingGroup(s.e2filter2, tp, LOCATION_GRAVE, 0, nil, e, tp, c, c:GetLinkedZone(1 - tp), 1 - tp)

    if c:IsRelateToEffect(e) and Duel.SpecialSummon(c, 0, tp, tp, false, false, POS_FACEUP) > 0 and Duel.GetLP(tp) <= 2000 and
        Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.e2filter2), tp, LOCATION_DECK + LOCATION_GRAVE, 0, 1, nil) and
        Duel.SelectEffectYesNo(tp, c, aux.Stringid(id, 2)) then
        local tc = Utility.SelectMatchingCard(HINTMSG_SET, tp, aux.NecroValleyFilter(s.e2filter2), tp, LOCATION_DECK + LOCATION_GRAVE, 0, 1, 1, nil,
            false):GetFirst()
        if tc and Duel.SSet(tp, tc) > 0 and (tc:IsTrap() or tc:IsQuickPlaySpell()) then
            local ec1 = Effect.CreateEffect(c)
            ec1:SetDescription(aux.Stringid(id, 3))
            ec1:SetType(EFFECT_TYPE_SINGLE)
            ec1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
            ec1:SetCode(tc:IsTrap() and EFFECT_TRAP_ACT_IN_SET_TURN or EFFECT_QP_ACT_IN_SET_TURN)
            ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
            tc:RegisterEffect(ec1)
        end
    end
end
