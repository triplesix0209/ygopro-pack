-- Astrochrono Sorcerer
Duel.LoadScript("util.lua")
local s, id = GetID()

s.material = {76794549, 12289247}
s.listed_names = {76794549, 12289247}

function s.initial_effect(c)
    c:EnableReviveLimit()
    Pendulum.AddProcedure(c, false)

    -- fusion summon
    Fusion.AddProcMix(c, true, true, {76794549, 12289247}, s.fusfilter)

    -- search (p-zone)
    local pe1 = Effect.CreateEffect(c)
    pe1:SetDescription(aux.Stringid(id, 0))
    pe1:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH + CATEGORY_SPECIAL_SUMMON)
    pe1:SetType(EFFECT_TYPE_IGNITION)
    pe1:SetRange(LOCATION_PZONE)
    pe1:SetCountLimit(1, {id, 1})
    pe1:SetTarget(s.pe1tg)
    pe1:SetOperation(s.pe1op)
    c:RegisterEffect(pe1)

    -- search (summon)
    local me1 = Effect.CreateEffect(c)
    me1:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH)
    me1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    me1:SetProperty(EFFECT_FLAG_DELAY)
    me1:SetCode(EVENT_SPSUMMON_SUCCESS)
    me1:SetCondition(s.me1con)
    me1:SetTarget(s.me1tg)
    me1:SetOperation(s.me1op)
    c:RegisterEffect(me1)
    local me1check = Effect.CreateEffect(c)
    me1check:SetType(EFFECT_TYPE_SINGLE)
    me1check:SetCode(EFFECT_MATERIAL_CHECK)
    me1check:SetValue(s.me1check)
    me1check:SetLabelObject(me1)
    c:RegisterEffect(me1check)

    -- untargetable
    local me2 = Effect.CreateEffect(c)
    me2:SetType(EFFECT_TYPE_FIELD)
    me2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
    me2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    me2:SetRange(LOCATION_MZONE)
    me2:SetTargetRange(LOCATION_MZONE, 0)
    me2:SetTarget(aux.TargetBoolFunction(Card.IsType, TYPE_PENDULUM))
    me2:SetValue(aux.tgoval)
    c:RegisterEffect(me2)

    -- special summon all destroyed
    local me3 = Effect.CreateEffect(c)
    me3:SetCategory(CATEGORY_SPECIAL_SUMMON)
    me3:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    me3:SetCode(EVENT_PHASE + PHASE_END)
    me3:SetRange(LOCATION_MZONE)
    me3:SetHintTiming(0, TIMING_END_PHASE)
    me3:SetCountLimit(1, {id, 2})
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

    -- place into pendulum zone
    local me4 = Effect.CreateEffect(c)
    me4:SetDescription(2203)
    me4:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    me4:SetCode(EVENT_DESTROYED)
    me4:SetProperty(EFFECT_FLAG_DELAY)
    me4:SetCondition(function(e, tp, eg, ep, ev, re, r, rp) return e:GetHandler():IsPreviousLocation(LOCATION_MZONE) and e:GetHandler():IsFaceup() end)
    me4:SetTarget(function(e, tp, eg, ep, ev, re, r, rp, chk) if chk == 0 then return Duel.CheckPendulumZones(tp) end end)
    me4:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
        if not Duel.CheckPendulumZones(tp) then return end
        local c = e:GetHandler()
        if c:IsRelateToEffect(e) then Duel.MoveToField(c, tp, tp, LOCATION_PZONE, POS_FACEUP, true) end
    end)
    c:RegisterEffect(me4)
end

function s.fusfilter(c, sc, st, tp) return c:IsRace(RACE_SPELLCASTER, sc, st, tp) and c:IsType(TYPE_PENDULUM, sc, st, tp) end

function s.pe1filter(c, e, tp)
    if c:IsCode(id) or not c:IsType(TYPE_PENDULUM) then return false end
    if c:IsLocation(LOCATION_EXTRA) and c:IsFacedown() then return false end
    return c:IsAbleToHand() or
               (c:IsCanBeSpecialSummoned(e, 0, tp, false, false) and
                   ((c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp, tp, nil, c) > 0) or
                       (not c:IsLocation(LOCATION_EXTRA) and Duel.GetMZoneCount(tp) > 0)))
end

function s.pe1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.pe1filter, tp, LOCATION_DECK + LOCATION_EXTRA, 0, 1, nil, e, tp) end
    Duel.SetPossibleOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_HAND + LOCATION_EXTRA)
    Duel.SetPossibleOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_HAND + LOCATION_EXTRA)
end

function s.pe1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) then return end

    local tc = Utility.SelectMatchingCard(HINTMSG_SELECT, tp, s.pe1filter, tp, LOCATION_DECK + LOCATION_EXTRA, 0, 1, 1, nil, e, tp):GetFirst()
    if not tc then return end
    aux.ToHandOrElse(tc, tp, function(tc)
        return tc:IsCanBeSpecialSummoned(e, 0, tp, false, false) and
                   ((tc:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp, tp, nil, tc) > 0) or
                       (not tc:IsLocation(LOCATION_EXTRA) and Duel.GetMZoneCount(tp) > 0))
    end, function(tc) return Duel.SpecialSummon(tc, 0, tp, tp, false, false, POS_FACEUP) end, 2)
end

function s.me1checkfilter(c, sc) return c:IsType(TYPE_PENDULUM, sc, SUMMON_TYPE_FUSION) and c:IsSummonType(SUMMON_TYPE_PENDULUM) end

function s.me1check(e, c)
    local g = c:GetMaterial()
    if g:IsExists(s.me1checkfilter, 1, nil, c) then
        e:GetLabelObject():SetLabel(1)
    else
        e:GetLabelObject():SetLabel(0)
    end
end

function s.me1filter(c) return c:IsAbleToHand() and c:IsSpellTrap() end

function s.me1con(e, tp, eg, ep, ev, re, r, rp) return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION) and e:GetLabel() == 1 end

function s.me1tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.me1filter, tp, LOCATION_DECK + LOCATION_GRAVE, 0, 1, nil) end
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK)
end

function s.me1op(e, tp, eg, ep, ev, re, r, rp)
    local g = Utility.SelectMatchingCard(HINTMSG_SET, tp, s.me1filter, tp, LOCATION_DECK, 0, 1, 1, nil)
    if #g > 0 then
        Duel.SendtoHand(g, nil, REASON_EFFECT)
        Duel.ConfirmCards(1 - tp, g)
    end
end

function s.me3regfilter(c) return (c:IsReason(REASON_EFFECT) and c:GetReasonPlayer() == 1 - c:GetControler()) or c:IsReason(REASON_BATTLE) end

function s.me3regop(e, tp, eg, ep, ev, re, r, rp)
    local g = eg:Filter(s.me3regfilter, nil)
    for tc in g:Iter() do tc:RegisterFlagEffect(id, RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END, 0, 0) end
end

function s.me3filter(c, e, tp)
    if c:IsFacedown() or c:GetFlagEffect(id) == 0 or not c:IsCanBeSpecialSummoned(e, 0, tp, false, false) then return false end

    if c:IsLocation(LOCATION_EXTRA) then
        return Duel.GetLocationCountFromEx(tp, tp, nil, c) > 0
    else
        return Duel.GetMZoneCount(tp, nil) > 0
    end
end

function s.me3rescon(ft1, ft2, ft)
    return function(sg, e, tp, mg)
        local mct = sg:FilterCount(aux.NOT(Card.IsLocation), nil, LOCATION_EXTRA)
        local exct = sg:FilterCount(function(c) return c:IsLocation(LOCATION_EXTRA) and c:IsFaceup() and c:IsType(TYPE_PENDULUM) end, nil)
        local res = ft2 >= exct and ft1 >= mct and ft >= #sg
        return res, not res
    end
end

function s.me3tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.me3filter, tp, LOCATION_GRAVE + LOCATION_EXTRA, 0, 1, nil, e, tp) end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_GRAVE + LOCATION_EXTRA)
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
    local g = Duel.GetMatchingGroup(s.me3filter, tp, loc, 0, nil, e, tp)
    if #g == 0 then return end

    local sg = aux.SelectUnselectGroup(g, e, tp, 1, ft, s.me3rescon(ft1, ft2, ft), 1, tp, HINTMSG_SPSUMMON)
    Duel.SpecialSummon(sg, 0, tp, tp, true, false, POS_FACEUP)
end
