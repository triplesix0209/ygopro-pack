-- Synchro Salvation
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {CARD_CRIMSON_DRAGON}

function s.initial_effect(c)
    c:SetUniqueOnField(1, 0, id)

    -- activate
    aux.AddEquipProcedure(c, nil, aux.FilterBoolFunction(s.eqfilter))

    -- cannot be tributed, nor be used as a material
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetCode(EFFECT_CANNOT_RELEASE)
    e1:SetRange(LOCATION_SZONE)
    e1:SetTargetRange(0, 1)
    e1:SetTarget(function(e, tc) return tc == e:GetHandler():GetEquipTarget() end)
    c:RegisterEffect(e1)
    local e1b = Effect.CreateEffect(c)
    e1b:SetType(EFFECT_TYPE_EQUIP)
    e1b:SetCode(EFFECT_CANNOT_BE_MATERIAL)
    e1b:SetValue(function(e, tc) return tc and tc:GetControler() ~= e:GetHandlerPlayer() end)
    c:RegisterEffect(e1b)

    -- untargetable
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_EQUIP)
    e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
    e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e2:SetValue(aux.tgoval)
    c:RegisterEffect(e2)

    -- no return
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_EQUIP)
    e3:SetCode(EFFECT_CANNOT_TO_DECK)
    c:RegisterEffect(e3)

    -- cannot disable
    local e4 = Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_EQUIP)
    e4:SetCode(EFFECT_CANNOT_DISABLE)
    c:RegisterEffect(e4)
    local e4b = Effect.CreateEffect(c)
    e4b:SetType(EFFECT_TYPE_FIELD)
    e4b:SetCode(EFFECT_CANNOT_DISEFFECT)
    e4b:SetRange(LOCATION_SZONE)
    e4b:SetValue(function(e, ct)
        local te = Duel.GetChainInfo(ct, CHAININFO_TRIGGERING_EFFECT)
        return te:GetHandler() == e:GetHandler():GetEquipTarget()
    end)
    c:RegisterEffect(e4b)

    -- special summon The Crimsom Dragon
    local e5 = Effect.CreateEffect(c)
    e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e5:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e5:SetProperty(EFFECT_FLAG_DELAY)
    e5:SetCode(EVENT_DESTROYED)
    e5:SetCountLimit(1, id)
    e5:SetCondition(s.e5con)
    e5:SetTarget(s.e5tg)
    e5:SetOperation(s.e5op)
    c:RegisterEffect(e5)
end

function s.eqfilter(c)
    local mt = c:GetMetatable()
    local ct = 0
    if mt.synchro_tuner_required then ct = ct + mt.synchro_tuner_required end
    if mt.synchro_nt_required then ct = ct + mt.synchro_nt_required end
    return c:IsRace(RACE_DRAGON) and c:IsType(TYPE_SYNCHRO) and ct > 0
end

function s.e5filter(c, e, tp)
    return c:IsCode(CARD_CRIMSON_DRAGON) and c:IsCanBeSpecialSummoned(e, 0, tp, false, false) and Duel.GetLocationCountFromEx(tp, tp, nil, c)
end

function s.e5con(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    return rp == 1 - tp and c:IsReason(REASON_EFFECT) and c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousControler(tp)
end

function s.e5tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.e5filter, tp, LOCATION_EXTRA, 0, 1, nil, e, tp) end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_EXTRA)
end

function s.e5op(e, tp, eg, ep, ev, re, r, rp)
    local g = Utility.SelectMatchingCard(HINTMSG_SPSUMMON, tp, s.e5filter, tp, LOCATION_EXTRA, 0, 1, 1, nil, e, tp)
    if #g > 0 then Duel.SpecialSummon(g, 0, tp, tp, false, false, POS_FACEUP) end
end
