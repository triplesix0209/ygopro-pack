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

    -- pendulum set/spsummon
    local pe1 = Effect.CreateEffect(c)
    pe1:SetDescription(aux.Stringid(id, 0))
    pe1:SetCategory(CATEGORY_DESTROY + CATEGORY_SPECIAL_SUMMON)
    pe1:SetType(EFFECT_TYPE_IGNITION)
    pe1:SetRange(LOCATION_PZONE)
    pe1:SetCountLimit(1, id)
    pe1:SetTarget(s.pe1tg)
    pe1:SetOperation(s.pe1op)
    c:RegisterEffect(pe1)

    -- search
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

    -- place into pendulum zone
    local me9 = Effect.CreateEffect(c)
    me9:SetDescription(2203)
    me9:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    me9:SetCode(EVENT_DESTROYED)
    me9:SetProperty(EFFECT_FLAG_DELAY)
    me9:SetCondition(function(e, tp, eg, ep, ev, re, r, rp)
        local c = e:GetHandler()
        return c:IsPreviousLocation(LOCATION_MZONE) and c:IsFaceup()
    end)
    me9:SetTarget(function(e, tp, eg, ep, ev, re, r, rp, chk) if chk == 0 then return Duel.CheckPendulumZones(tp) end end)
    me9:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
        if not Duel.CheckPendulumZones(tp) then return end
        local c = e:GetHandler()
        if c:IsRelateToEffect(e) then Duel.MoveToField(c, tp, tp, LOCATION_PZONE, POS_FACEUP, true) end
    end)
    c:RegisterEffect(me9)
end

function s.fusfilter(c, sc, sumtype, tp) return c:IsRace(RACE_SPELLCASTER, sc, sumtype, tp) and c:IsType(TYPE_PENDULUM, sc, sumtype, tp) end

function s.pe1filter(c, e, tp)
    if c:IsCode(id) or not c:IsType(TYPE_PENDULUM) then return false end
    if c:IsLocation(LOCATION_EXTRA) and c:IsFacedown() then return false end
    return not c:IsForbidden() or
               (c:IsCanBeSpecialSummoned(e, 0, tp, false, false) and
                   ((c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp, tp, nil, c) > 0) or
                       (not c:IsLocation(LOCATION_EXTRA) and Duel.GetMZoneCount(tp) > 0)))
end

function s.pe1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return Duel.IsExistingMatchingCard(s.pe1filter, tp, LOCATION_HAND + LOCATION_DECK + LOCATION_EXTRA, 0, 1, nil, e, tp) end

    Duel.SetOperationInfo(0, CATEGORY_DESTROY, c, 1, 0, 0)
    Duel.SetPossibleOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_DECK + LOCATION_HAND + LOCATION_EXTRA)
end

function s.pe1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if c:IsRelateToEffect(e) and Duel.Destroy(c, REASON_EFFECT) > 0 then
        local tc =
            Utility.SelectMatchingCard(HINTMSG_SELECT, tp, s.pe1filter, tp, LOCATION_DECK + LOCATION_HAND + LOCATION_EXTRA, 0, 1, 1, nil):GetFirst()

        local op = 0
        if tc:IsCanBeSpecialSummoned(e, 0, tp, false, false) and
            ((tc:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp, tp, nil, tc) > 0) or
                (not tc:IsLocation(LOCATION_EXTRA) and Duel.GetMZoneCount(tp) > 0)) then
            op = Duel.SelectOption(tp, 2203, 2)
        else
            op = Duel.SelectOption(tp, 2203)
        end

        if op == 0 then
            Duel.MoveToField(tc, tp, tp, LOCATION_PZONE, POS_FACEUP, true)
        else
            Duel.SpecialSummon(tc, 0, tp, tp, false, false, POS_FACEUP)
        end
    end
end

function s.me1filter1(c, sc) return c:IsType(TYPE_PENDULUM, sc, SUMMON_TYPE_FUSION) and c:IsSummonType(SUMMON_TYPE_PENDULUM) end

function s.me1filter2(c) return c:IsAbleToHand() and c:IsSpellTrap() end

function s.me1check(e, c)
    local g = c:GetMaterial()
    if g:IsExists(s.me1filter1, 1, nil, c) then
        e:GetLabelObject():SetLabel(1)
    else
        e:GetLabelObject():SetLabel(0)
    end
end

function s.me1con(e, tp, eg, ep, ev, re, r, rp) return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION) and e:GetLabel() == 1 end

function s.me1tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.me1filter2, tp, LOCATION_DECK + LOCATION_GRAVE, 0, 1, nil) end
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK + LOCATION_GRAVE)
end

function s.me1op(e, tp, eg, ep, ev, re, r, rp)
    local g = Utility.SelectMatchingCard(HINTMSG_SET, tp, s.me1filter2, tp, LOCATION_DECK + LOCATION_GRAVE, 0, 1, 1, nil)
    if #g > 0 then
        Duel.SendtoHand(g, nil, REASON_EFFECT)
        Duel.ConfirmCards(1 - tp, g)
    end
end
