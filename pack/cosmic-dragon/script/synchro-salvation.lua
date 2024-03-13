-- Synchro Salvation
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {CARD_CRIMSON_DRAGON}

function s.initial_effect(c)
    c:SetUniqueOnField(1, 0, id)

    -- activate
    aux.AddEquipProcedure(c, nil, aux.FilterBoolFunction(s.eqfilter))

    -- untargetable
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_EQUIP)
    e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
    e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e1:SetValue(aux.tgoval)
    c:RegisterEffect(e1)

    -- no return
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_EQUIP)
    e2:SetCode(EFFECT_CANNOT_TO_DECK)
    c:RegisterEffect(e2)

    -- cannot disable
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_EQUIP)
    e3:SetCode(EFFECT_CANNOT_DISABLE)
    c:RegisterEffect(e3)
    local e3b = Effect.CreateEffect(c)
    e3b:SetType(EFFECT_TYPE_FIELD)
    e3b:SetCode(EFFECT_CANNOT_DISEFFECT)
    e3b:SetRange(LOCATION_SZONE)
    e3b:SetValue(function(e, ct)
        local te = Duel.GetChainInfo(ct, CHAININFO_TRIGGERING_EFFECT)
        return te:GetHandler() == e:GetHandler():GetEquipTarget()
    end)
    c:RegisterEffect(e3b)

    -- special summon The Crimsom Dragon
    local e4 = Effect.CreateEffect(c)
    e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e4:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e4:SetProperty(EFFECT_FLAG_DELAY)
    e4:SetCode(EVENT_DESTROYED)
    e4:SetCountLimit(1, id)
    e4:SetCondition(s.e4con)
    e4:SetTarget(s.e4tg)
    e4:SetOperation(s.e4op)
    c:RegisterEffect(e4)
end

function s.eqfilter(c)
    local mt = c:GetMetatable()
    local ct = 0
    if mt.synchro_tuner_required then ct = ct + mt.synchro_tuner_required end
    if mt.synchro_nt_required then ct = ct + mt.synchro_nt_required end
    return c:IsRace(RACE_DRAGON) and c:IsType(TYPE_SYNCHRO) and ct > 0
end

function s.e4filter(c, e, tp)
    return c:IsCode(CARD_CRIMSON_DRAGON) and c:IsCanBeSpecialSummoned(e, 0, tp, false, false) and Duel.GetLocationCountFromEx(tp, tp, nil, c)
end

function s.e4con(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    return rp == 1 - tp and c:IsReason(REASON_EFFECT) and c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousControler(tp)
end

function s.e4tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.e4filter, tp, LOCATION_EXTRA, 0, 1, nil, e, tp) end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_EXTRA)
end

function s.e4op(e, tp, eg, ep, ev, re, r, rp)
    local g = Utility.SelectMatchingCard(HINTMSG_SPSUMMON, tp, s.e4filter, tp, LOCATION_EXTRA, 0, 1, 1, nil, e, tp)
    if #g > 0 then Duel.SpecialSummon(g, 0, tp, tp, false, false, POS_FACEUP) end
end
