-- Palladium Spirit Duos Dracocursed
Duel.LoadScript("util.lua")
local s, id = GetID()

s.material_setcode = {0x13a}
s.listed_names = {900000112}
s.listed_series = {0x13a}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- fusion summon
    Fusion.AddProcMix(c, true, true, s.fusfilter1, s.fusfilter2)

    -- special summon limit
    local splimit = Effect.CreateEffect(c)
    splimit:SetType(EFFECT_TYPE_SINGLE)
    splimit:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    splimit:SetCode(EFFECT_SPSUMMON_CONDITION)
    splimit:SetValue(function(e, se, sp, st) return not e:GetHandler():IsLocation(LOCATION_EXTRA) or aux.fuslimit(e, se, sp, st) end)
    c:RegisterEffect(splimit)

    -- special summon
    local sp = Effect.CreateEffect(c)
    sp:SetType(EFFECT_TYPE_FIELD)
    sp:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    sp:SetCode(EFFECT_SPSUMMON_PROC)
    sp:SetRange(LOCATION_EXTRA)
    sp:SetCondition(s.spcon)
    sp:SetTarget(s.sptg)
    sp:SetOperation(s.spop)
    c:RegisterEffect(sp)

    -- equip
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_EQUIP)
    e1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- protect equip cards
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e2:SetRange(LOCATION_MZONE)
    e2:SetTargetRange(LOCATION_SZONE, 0)
    e2:SetTarget(s.e2tg)
    e2:SetValue(aux.indoval)
    c:RegisterEffect(e2)
    local e2b = e2:Clone()
    e2b:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
    e2b:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e2b:SetValue(aux.tgoval)
    c:RegisterEffect(e2b)

    -- special summon equip monster
    local e3reg = Effect.CreateEffect(c)
    e3reg:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
    e3reg:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e3reg:SetCode(EVENT_LEAVE_FIELD_P)
    e3reg:SetOperation(s.e3regop)
    c:RegisterEffect(e3reg)
    local e3 = Effect.CreateEffect(c)
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e3:SetProperty(EFFECT_FLAG_DELAY + EFFECT_FLAG_DAMAGE_STEP)
    e3:SetCode(EVENT_LEAVE_FIELD)
    e3:SetCountLimit(1, id)
    e3:SetLabelObject(e3reg)
    e3:SetCondition(s.e3con)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)
end

function s.fusfilter1(c, fc, sumtype, tp) return c:IsLevelAbove(5) and c:IsSetCard(0x13a, fc, sumtype, tp) and c:IsRace(RACE_WARRIOR, fc, sumtype, tp) end

function s.fusfilter2(c, fc, sumtype, tp) return c:IsLevelAbove(5) and c:IsRace(RACE_DRAGON, fc, sumtype, tp) end

function s.spfilter1(c) return c:IsCode(900000112) end

function s.spfilter2(c, tp, sc) return c:IsLevelAbove(5) and c:IsRace(RACE_DRAGON, sc, MATERIAL_FUSION, tp) end

function s.spcon(e, c)
    if c == nil then return true end
    local tp = c:GetControler()
    return Duel.CheckReleaseGroup(tp, s.spfilter1, 1, false, 1, true, c, tp, nil, false, nil, tp, c) and
               Duel.CheckReleaseGroup(tp, s.spfilter2, 1, true, 1, true, c, tp, nil, false, nil, tp, c)
end

function s.sptg(e, tp, eg, ep, ev, re, r, rp, chk, c)
    local g = Duel.SelectReleaseGroup(tp, s.spfilter1, 1, 1, false, true, true, c, tp, nil, false, nil, tp, c)
    g:Merge(Duel.SelectReleaseGroup(tp, s.spfilter2, 1, 1, true, true, true, c, tp, nil, false, nil, tp, c))

    if g then
        g:KeepAlive()
        e:SetLabelObject(g)
        return true
    end

    return false
end

function s.spop(e, tp, eg, ep, ev, re, r, rp, c)
    local g = e:GetLabelObject()
    if not g then return end

    Duel.ConfirmCards(1 - tp, g)
    Duel.Release(g, REASON_COST)
    g:DeleteGroup()
end

function s.e1filter(c, tp) return c:IsLevelBelow(7) and c:CheckUniqueOnField(tp) and not c:IsForbidden() end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    local loc = LOCATION_HAND + LOCATION_DECK + LOCATION_MZONE
    if chk == 0 then return Duel.IsExistingMatchingCard(s.e1filter, tp, loc, 0, 1, c, tp) end

    Duel.SetOperationInfo(0, CATEGORY_EQUIP, nil, 1, 0, loc)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc =
        Utility.SelectMatchingCard(HINTMSG_EQUIP, tp, s.e1filter, tp, LOCATION_HAND + LOCATION_DECK + LOCATION_MZONE, 0, 1, 1, c, tp):GetFirst()
    if tc and c:IsFaceup() and c:IsRelateToEffect(e) and Duel.Equip(tp, tc, c, true) then
        local ec0 = Effect.CreateEffect(c)
        ec0:SetType(EFFECT_TYPE_SINGLE)
        ec0:SetCode(EFFECT_EQUIP_LIMIT)
        ec0:SetLabelObject(c)
        ec0:SetValue(function(e, c) return c == e:GetLabelObject() end)
        ec0:SetReset(RESET_EVENT + RESETS_STANDARD)
        tc:RegisterEffect(ec0)

        local ec1 = Effect.CreateEffect(c)
        ec1:SetType(EFFECT_TYPE_EQUIP)
        ec1:SetCode(EFFECT_UPDATE_ATTACK)
        ec1:SetValue(100 * tc:GetLevel())
        ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
        tc:RegisterEffect(ec1)
    end
end

function s.e2tg(e, c) return c:IsType(TYPE_EQUIP) and c:GetEquipTarget() == e:GetHandler() end

function s.e3regop(e, tp, eg, ep, ev, re, r, rp)
    if e:GetLabelObject() then e:GetLabelObject():DeleteGroup() end

    local g = e:GetHandler():GetEquipGroup()
    g:KeepAlive()
    e:SetLabelObject(g)
end

function s.e3filter(c, e, tp) return c:IsCanBeSpecialSummoned(e, 0, tp, false, false) end

function s.e3con(e, tp, eg, ep, ev, re, r, rp) return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD) end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    local g = e:GetLabelObject():GetLabelObject()
    if chk == 0 then return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and g:IsExists(s.e3filter, 1, nil, e, tp) end

    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, g, 1, 0, 0)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local g = e:GetLabelObject():GetLabelObject():Filter(s.e3filter, nil, e, tp)
    local tc = Utility.GroupSelect(HINTMSG_SPSUMMON, g, tp, 1, 1, nil):GetFirst()
    if tc and Duel.SpecialSummon(tc, 0, tp, tp, false, false, POS_FACEUP) > 0 then
        local ec1 = Effect.CreateEffect(c)
        ec1:SetType(EFFECT_TYPE_SINGLE)
        ec1:SetCode(EFFECT_UPDATE_ATTACK)
        ec1:SetValue(tc:GetLevel() * 100)
        ec1:SetReset(RESET_EVENT + RESETS_STANDARD_DISABLE + RESET_PHASE + PHASE_END)
        tc:RegisterEffect(ec1)

        local ec2 = ec1:Clone()
        ec2:SetDescription(3001)
        ec2:SetProperty(EFFECT_FLAG_SINGLE_RANGE + EFFECT_FLAG_CLIENT_HINT)
        ec2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
        ec2:SetRange(LOCATION_MZONE)
        ec2:SetValue(1)
        tc:RegisterEffect(ec2)
    end
end
