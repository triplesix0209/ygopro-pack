-- Sorcerer of Sky Iris
Duel.LoadScript("util.lua")
Duel.LoadScript("util_pendulum.lua")
local s, id = GetID()

s.listed_series = {0x98}
s.material_setcode = 0x98

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- fusion summon
    Fusion.AddProcMix(c, false, false, function(c, sc, sumtype, tp)
        return c:IsSetCard(0x98, sc, sumtype, tp) and
                   c:IsType(TYPE_PENDULUM, sc, sumtype, tp)
    end, function(c)
        return c:IsSummonLocation(LOCATION_EXTRA) and
                   c:IsLocation(LOCATION_MZONE)
    end)

    -- pendulum
    Pendulum.AddProcedure(c, false)

    -- atk & def up
    local pe1 = Effect.CreateEffect(c)
    pe1:SetType(EFFECT_TYPE_FIELD)
    pe1:SetCode(EFFECT_UPDATE_ATTACK)
    pe1:SetRange(LOCATION_PZONE)
    pe1:SetTargetRange(LOCATION_MZONE, 0)
    pe1:SetValue(function(e, c)
        local g = Duel.GetMatchingGroup(function(c)
            return c:IsFaceup() and c:IsType(TYPE_PENDULUM)
        end, c:GetControler(), LOCATION_EXTRA, 0, nil)
        return g:GetClassCount(Card.GetCode) * 100
    end)
    c:RegisterEffect(pe1)
    local pe1b = pe1:Clone()
    pe1b:SetCode(EFFECT_UPDATE_DEFENSE)
    c:RegisterEffect(pe1b)

    -- special summon (pendulum zone)
    local pe2 = Effect.CreateEffect(c)
    pe2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    pe2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    pe2:SetProperty(EFFECT_FLAG_DELAY + EFFECT_FLAG_DAMAGE_STEP)
    pe2:SetCode(EVENT_DESTROYED)
    pe2:SetRange(LOCATION_PZONE)
    pe2:SetCountLimit(1, id + 1000000)
    pe2:SetCondition(s.pe2con)
    pe2:SetTarget(s.pe2tg)
    pe2:SetOperation(s.pe2op)
    c:RegisterEffect(pe2)

    -- search
    local me1 = Effect.CreateEffect(c)
    me1:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH)
    me1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    me1:SetProperty(EFFECT_FLAG_DELAY)
    me1:SetCode(EVENT_SPSUMMON_SUCCESS)
    me1:SetCountLimit(1, id + 2000000)
    me1:SetCondition(s.me1con)
    me1:SetTarget(s.me1tg)
    me1:SetOperation(s.me1op)
    c:RegisterEffect(me1)

    -- special summon from pendulum zone
    local me2 = Effect.CreateEffect(c)
    me2:SetDescription(aux.Stringid(id, 1))
    me2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    me2:SetType(EFFECT_TYPE_IGNITION)
    me2:SetRange(LOCATION_MZONE)
    me2:SetCountLimit(1, id + 3000000)
    me2:SetTarget(s.me2tg)
    me2:SetOperation(s.me2op)
    c:RegisterEffect(me2)

    -- special summon destroyed
    local me3 = Effect.CreateEffect(c)
    me3:SetCategory(CATEGORY_SPECIAL_SUMMON)
    me3:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    me3:SetCode(EVENT_PHASE + PHASE_END)
    me3:SetRange(LOCATION_MZONE)
    me3:SetHintTiming(0, TIMING_END_PHASE)
    me3:SetCountLimit(1, id + 4000000)
    me3:SetTarget(s.me3tg)
    me3:SetOperation(s.me3op)
    c:RegisterEffect(me3)
    aux.GlobalCheck(s, function()
        local me3reg = Effect.CreateEffect(c)
        me3reg:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
        me3reg:SetCode(EVENT_DESTROYED)
        me3reg:SetOperation(s.me3regop)
        Duel.RegisterEffect(me3reg, 0)
    end)
end

function s.pe2filter(c, tp)
    return c:IsReason(REASON_BATTLE + REASON_EFFECT) and
               c:IsPreviousControler(tp) and
               c:IsPreviousLocation(LOCATION_ONFIELD) and
               c:IsType(TYPE_PENDULUM)
end

function s.pe2con(e, tp, eg, ep, ev, re, r, rp)
    return eg:IsExists(s.pe2filter, 1, nil, tp)
end

function s.pe2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then
        return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and
                   c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
    end

    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, c, 1, 0, 0)
end

function s.pe2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) then return end

    if Duel.SpecialSummon(c, 0, tp, tp, false, false, POS_FACEUP_DEFENSE) > 0 and
        UtilPendulum.CountFreePendulumZones(tp) > 0 and
        Duel.SelectYesNo(tp, aux.Stringid(id, 0)) then
        Duel.BreakEffect()
        Duel.Hint(HINT_SELECTMSG, tp, aux.Stringid(id, 0))
        local tc = eg:Filter(s.pe2filter, nil, tp):Select(tp, 1, 1, nil)
                       :GetFirst()

        Duel.MoveToField(tc, tp, tp, LOCATION_PZONE, POS_FACEUP, true)
    end
end

function s.me1filter(c)
    if c:IsLocation(LOCATION_EXTRA) and c:IsFacedown() then return false end
    return c:IsType(TYPE_PENDULUM) and c:IsAbleToHand()
end

function s.me1con(e, tp, eg, ep, ev, re, r, rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end

function s.me1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.me1filter, tp,
                                           LOCATION_DECK + LOCATION_EXTRA, 0, 1,
                                           nil)
    end
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp,
                          LOCATION_DECK + LOCATION_EXTRA)
end

function s.me1op(e, tp, eg, ep, ev, re, r, rp)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
    local g = Duel.SelectMatchingCard(tp, s.me1filter, tp,
                                      LOCATION_DECK + LOCATION_EXTRA, 0, 1, 1,
                                      nil)
    if #g > 0 then
        Duel.SendtoHand(g, nil, REASON_EFFECT)
        Duel.ConfirmCards(1 - tp, g)
    end
end

function s.me2filter(c, e, tp)
    return c:IsCanBeSpecialSummoned(e, 0, tp, true, false)
end

function s.me2tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chk == 0 then
        return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and
                   Duel.IsExistingMatchingCard(s.me2filter, tp, LOCATION_PZONE,
                                               0, 1, nil, e, tp)
    end

    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, 0, LOCATION_PZONE)
end

function s.me2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
    local g = Duel.SelectMatchingCard(tp, s.me2filter, tp, LOCATION_PZONE, 0, 1,
                                      1, nil, e, tp)
    if #g > 0 and Duel.SpecialSummon(g, 0, tp, tp, true, false, POS_FACEUP) > 0 and
        UtilPendulum.CountFreePendulumZones(tp) > 0 and c:IsRelateToEffect(e) and
        c:IsFaceup() and Duel.SelectYesNo(tp, 1160) then
        Duel.MoveToField(c, tp, tp, LOCATION_PZONE, POS_FACEUP, true)
    end
end

function s.me3regfilter(c)
    return (c:IsReason(REASON_EFFECT) and c:GetReasonPlayer() == 1 -
               c:GetControler()) or c:IsReason(REASON_BATTLE)
end

function s.me3regop(e, tp, eg, ep, ev, re, r, rp)
    local g = eg:Filter(s.me3regfilter, nil)
    for tc in aux.Next(g) do
        tc:RegisterFlagEffect(id, RESET_EVENT + RESETS_STANDARD + RESET_PHASE +
                                  PHASE_END, 0, 0)
    end
end

function s.me3filter1(c, e, tp)
    if c:IsFacedown() or c:GetFlagEffect(id) == 0 or
        not c:IsCanBeSpecialSummoned(e, 0, tp, false, false) then
        return false
    end

    if c:IsLocation(LOCATION_EXTRA) then
        return Duel.GetLocationCountFromEx(tp, tp, nil, c) > 0
    else
        return Duel.GetMZoneCount(tp, nil) > 0
    end
end

function s.me3rescon(ft1, ft2, ft)
    return function(sg, e, tp, mg)
        local mct =
            sg:FilterCount(aux.NOT(Card.IsLocation), nil, LOCATION_EXTRA)
        local exct = sg:FilterCount(function(c)
            return c:IsLocation(LOCATION_EXTRA) and c:IsFaceup() and
                       c:IsType(TYPE_PENDULUM)
        end, nil)
        local res = ft2 >= exct and ft1 >= mct and ft >= #sg
        return res, not res
    end
end

function s.me3tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.me3filter1, tp,
                                           LOCATION_GRAVE + LOCATION_EXTRA, 0,
                                           1, nil, e, tp)
    end

    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp,
                          LOCATION_GRAVE + LOCATION_EXTRA)
end

function s.me3op(e, tp, eg, ep, ev, re, r, rp)
    local ft1 = Duel.GetLocationCount(tp, LOCATION_MZONE)
    local ft2 = Duel.GetLocationCountFromEx(tp, TYPE_PENDULUM)
    local ft = Duel.GetUsableMZoneCount(tp)
    if Duel.IsPlayerAffectedByEffect(tp, CARD_BLUEEYES_SPIRIT) then
        if ft1 > 0 then ft1 = 1 end
        if ft2 > 0 then ft2 = 1 end
        ft = 1
    end

    local ect = aux.CheckSummonGate(tp)
    if ect then
        ft1 = math.min(ect, ft1)
        ft2 = math.min(ect, ft2)
    end

    local loc = 0
    if ft1 > 0 then loc = loc + LOCATION_GRAVE end
    if ft2 > 0 then loc = loc + LOCATION_EXTRA end
    if loc == 0 then return end
    local g = Duel.GetMatchingGroup(aux.NecroValleyFilter(s.me3filter1), tp,
                                    loc, 0, nil, e, tp)
    if #g == 0 then return end

    local sg = aux.SelectUnselectGroup(g, e, tp, 1, ft,
                                       s.me3rescon(ft1, ft2, ft), 1, tp,
                                       HINTMSG_SPSUMMON)
    Duel.SpecialSummon(sg, 0, tp, tp, true, false, POS_FACEUP)
end
