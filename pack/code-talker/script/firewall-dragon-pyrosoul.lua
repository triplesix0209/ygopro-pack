-- Firewall Dragon Pyrosoul
Duel.LoadScript("util.lua")
local s, id = GetID()

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- link summon
    Link.AddProcedure(c, nil, 2, 99, function(g, sc, sumtype, tp) return g:CheckDifferentPropertyBinary(Card.GetAttribute, sc, sumtype, tp) end)

    -- destroy, atk up and draw
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_DESTROY + CATEGORY_ATKCHANGE)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET + EFFECT_FLAG_DELAY + EFFECT_FLAG_DAMAGE_STEP + EFFECT_FLAG_NO_TURN_RESET)
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
    e2:SetCountLimit(1, {id, 2})
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
    c:RegisterFlagEffect(0, RESET_EVENT + RESETS_STANDARD, EFFECT_FLAG_CLIENT_HINT, 1, 0, aux.Stringid(id, 1))
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
        ec1:SetReset(RESET_EVENT + RESETS_STANDARD_DISABLE)
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
    if not tc:IsRelateToEffect(e) or Duel.Destroy(tc, REASON_EFFECT) == 0 or not c:IsRelateToEffect(e) or
        Duel.SpecialSummon(c, 0, tp, tp, false, false, POS_FACEUP) == 0 then return end

    local g1 = Duel.GetMatchingGroup(s.e2filter2, tp, LOCATION_GRAVE, 0, nil, e, tp, c, c:GetLinkedZone(tp), tp)
    local g2 = Duel.GetMatchingGroup(s.e2filter2, tp, LOCATION_GRAVE, 0, nil, e, tp, c, c:GetLinkedZone(1 - tp), 1 - tp)
    if Duel.GetLP(tp) <= 2000 and #(g1 + g2) > 0 and Duel.SelectEffectYesNo(tp, c, aux.Stringid(id, 2)) then
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
        local sc = (g1 + g2):Select(tp, 1, 1, nil):GetFirst()
        local b1 = g1:IsContains(sc)
        local b2 = g2:IsContains(sc)
        local op = Duel.SelectEffect(tp, {b1, aux.Stringid(id, 3)}, {b2, aux.Stringid(id, 4)})
        local fp = op == 1 and tp or 1 - tp
        local zone = (c:GetLinkedZone(fp) | (sc:IsLinkMonster() and c:GetToBeLinkedZone(sc, fp) or 0)) & ZONES_MMZ
        Duel.SpecialSummon(sc, 0, tp, fp, false, false, POS_FACEUP, zone)
    end
end
