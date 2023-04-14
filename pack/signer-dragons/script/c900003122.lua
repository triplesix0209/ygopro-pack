-- Junk Accelerator
Duel.LoadScript("util.lua")
local s, id = GetID()

s.material_setcode = {0x1017}
s.listed_names = {63977008}
s.listed_series = {0x1017}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- synchro summon
    Synchro.AddProcedure(c, function(c, sc, stype, tp) return c:IsSetCard(0x1017, sc, stype, tp) or c:IsHasEffect(20932152) end,
        1, 1, Synchro.NonTuner(nil), 1, 99)

    -- special summon limit
    local splimit = Effect.CreateEffect(c)
    splimit:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
    splimit:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    splimit:SetCode(EVENT_SPSUMMON_SUCCESS)
    splimit:SetCondition(s.splimitcon)
    splimit:SetOperation(s.splimitop)
    c:RegisterEffect(splimit)

    -- material check
    local matcheck = Effect.CreateEffect(c)
    matcheck:SetType(EFFECT_TYPE_SINGLE)
    matcheck:SetCode(EFFECT_MATERIAL_CHECK)
    matcheck:SetValue(function(e, c)
        local g = c:GetMaterial()
        if g:IsExists(Card.IsCode, 1, nil, 63977008) then
            e:SetLabel(1)
            c:RegisterFlagEffect(id, RESET_EVENT + RESETS_STANDARD - RESET_TOFIELD, EFFECT_FLAG_CLIENT_HINT, 1, 0,
                aux.Stringid(id, 0))
        else
            e:SetLabel(0)
        end
    end)
    c:RegisterEffect(matcheck)

    -- special summon cannot be negated
    local spsafe = Effect.CreateEffect(c)
    spsafe:SetType(EFFECT_TYPE_SINGLE)
    spsafe:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    spsafe:SetCode(EFFECT_CANNOT_DISABLE_SPSUMMON)
    spsafe:SetLabelObject(matcheck)
    spsafe:SetCondition(function(e)
        return e:GetHandler():GetSummonType() == SUMMON_TYPE_SYNCHRO and e:GetLabelObject():GetLabel() > 0
    end)
    c:RegisterEffect(spsafe)

    -- special summon
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 1))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetLabelObject(matcheck)
    e1:SetCondition(s.e1con)
    e1:SetCost(s.e1cost)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)
    Duel.AddCustomActivityCounter(id, ACTIVITY_SPSUMMON, s.e1counterfilter)

    -- level
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 3))
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1)
    e2:SetLabelObject(matcheck)
    e2:SetCost(s.e2cost)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)
end

function s.splimitcon(e, tp, eg, ep, ev, re, r, rp) return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO) end

function s.splimitop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_FIELD)
    ec1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    ec1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    ec1:SetTargetRange(1, 0)
    ec1:SetTarget(function(e, tc, sump, sumtype, sumpos, targetp, se)
        return tc:IsCode(id) and (sumtype & SUMMON_TYPE_SYNCHRO) == SUMMON_TYPE_SYNCHRO
    end)
    ec1:SetReset(RESET_PHASE + PHASE_END)
    Duel.RegisterEffect(ec1, tp)
end

function s.e1counterfilter(c) return not c:IsSummonLocation(LOCATION_EXTRA) or c:IsType(TYPE_SYNCHRO) end

function s.e1filter(c, e, tp) return c:IsSetCard(0x1017) and c:IsCanBeSpecialSummoned(e, 0, tp, false, false, POS_FACEUP_DEFENSE) end

function s.e1con(e, tp, eg, ep, ev, re, r, rp) return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO) end

function s.e1cost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return Duel.GetCustomActivityCount(id, tp, ACTIVITY_SPSUMMON) == 0 end

    local ec1 = Effect.CreateEffect(c)
    ec1:SetDescription(aux.Stringid(id, 2))
    ec1:SetType(EFFECT_TYPE_FIELD)
    ec1:SetProperty(EFFECT_FLAG_PLAYER_TARGET + EFFECT_FLAG_OATH + EFFECT_FLAG_CLIENT_HINT)
    ec1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    ec1:SetTargetRange(1, 0)
    ec1:SetTarget(function(e, tc, sump, sumtype, sumpos, targetp, se)
        return tc:IsLocation(LOCATION_EXTRA) and not tc:IsType(TYPE_SYNCHRO)
    end)
    ec1:SetReset(RESET_PHASE + PHASE_END)
    Duel.RegisterEffect(ec1, tp)

    aux.addTempLizardCheck(e:GetHandler(), tp, function(e, c) return not c:IsOriginalType(TYPE_SYNCHRO) end)
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        local ct = Duel.GetLocationCount(tp, LOCATION_MZONE, tp, LOCATION_REASON_TOFIELD)
        return ct > 0 and
                   Duel.IsExistingMatchingCard(s.e1filter, tp, LOCATION_HAND + LOCATION_DECK + LOCATION_GRAVE, 0, 1, nil, e, tp)
    end

    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_HAND + LOCATION_DECK + LOCATION_GRAVE)
    if e:GetLabelObject():GetLabel() > 0 then Duel.SetChainLimit(function(e, ep, tp) return tp == ep end) end
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local g = Duel.GetMatchingGroup(aux.NecroValleyFilter(s.e1filter), tp, LOCATION_HAND + LOCATION_DECK + LOCATION_GRAVE, 0, nil,
        e, tp)
    local ct = math.min(Duel.GetLocationCount(tp, LOCATION_MZONE), g:GetClassCount(Card.GetLevel))
    if ct <= 0 then return end
    if Duel.IsPlayerAffectedByEffect(tp, CARD_BLUEEYES_SPIRIT) then ct = 1 end

    local sg = aux.SelectUnselectGroup(g, e, tp, ct, ct, aux.dpcheck(Card.GetLevel), 1, tp, HINTMSG_SPSUMMON)
    if #sg > 0 then Duel.SpecialSummon(sg, 0, tp, tp, false, false, POS_FACEUP_DEFENSE) end
end

function s.e2filter(c) return c:HasLevel() and c:GetLevel() ~= 0 and c:IsSetCard(0x1017) and c:IsAbleToGraveAsCost() end

function s.e2cost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.e2filter, tp, LOCATION_HAND + LOCATION_DECK, 0, 1, nil) end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOGRAVE)
    local tc = Duel.SelectMatchingCard(tp, s.e2filter, tp, LOCATION_HAND + LOCATION_DECK, 0, 1, 1, nil):GetFirst()
    Duel.SendtoGrave(tc, REASON_COST)
    e:SetLabel(tc:GetLevel())
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return c:HasLevel() end

    local lv = c:GetLevel()
    local opt
    if e:GetLabel() < lv then
        opt = Duel.SelectOption(tp, aux.Stringid(id, 4), aux.Stringid(id, 5))
    else
        opt = Duel.SelectOption(tp, aux.Stringid(id, 4))
    end

    if opt == 0 then
        e:SetLabel(e:GetLabel())
    else
        e:SetLabel(-e:GetLabel())
    end

    if e:GetLabelObject():GetLabel() > 0 then Duel.SetChainLimit(function(e, ep, tp) return tp == ep end) end
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) or c:IsFacedown() then return end

    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetCode(EFFECT_UPDATE_LEVEL)
    ec1:SetValue(e:GetLabel())
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD_DISABLE)
    c:RegisterEffect(ec1)
end
