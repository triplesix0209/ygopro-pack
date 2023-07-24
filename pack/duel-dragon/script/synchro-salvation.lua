-- Synchro Salvation
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {CARD_CRIMSON_DRAGON}
s.listed_series = {SET_MAJESTIC}

function s.initial_effect(c)
    c:SetUniqueOnField(1, 0, id)

    -- activate
    aux.AddEquipProcedure(c, nil, aux.FilterBoolFunction(s.eqfilter))

    -- act limit
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e1:SetCode(EVENT_CHAINING)
    e1:SetRange(LOCATION_SZONE)
    e1:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
        if re:GetHandler() == e:GetHandler():GetEquipTarget() then Duel.SetChainLimit(function(e, rp, tp) return tp == rp end) end
    end)
    c:RegisterEffect(e1)

    -- cannot be tributed, nor be used as a material
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e2:SetCode(EFFECT_CANNOT_RELEASE)
    e2:SetRange(LOCATION_SZONE)
    e2:SetTargetRange(0, 1)
    e2:SetTarget(function(e, tc) return tc == e:GetHandler():GetEquipTarget() end)
    c:RegisterEffect(e2)
    local e2b = Effect.CreateEffect(c)
    e2b:SetType(EFFECT_TYPE_EQUIP)
    e2b:SetCode(EFFECT_CANNOT_BE_MATERIAL)
    e2b:SetValue(function(e, tc) return tc and tc:GetControler() ~= e:GetHandlerPlayer() end)
    c:RegisterEffect(e2b)

    -- untargetable
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_EQUIP)
    e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
    e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e3:SetValue(aux.tgoval)
    c:RegisterEffect(e3)

    -- no return
    local e4 = Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_EQUIP)
    e4:SetCode(EFFECT_CANNOT_TO_DECK)
    c:RegisterEffect(e4)

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

function s.eqfilter(c) return c:IsSetCard(SET_MAJESTIC) and c:IsRace(RACE_DRAGON) and c:IsType(TYPE_SYNCHRO) end

function s.e5filter(c, e, tp)
    return c:IsCode(CARD_CRIMSON_DRAGON) and c:IsCanBeSpecialSummoned(e, 0, tp, false, false) and Duel.GetLocationCountFromEx(tp, tp, nil, c)
end

function s.e5con(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    return rp == 1 - tp and c:IsReason(REASON_EFFECT) and c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousControler(tp) and
               c:IsPreviousPosition(POS_FACEUP)
end

function s.e5tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.e5filter, tp, LOCATION_EXTRA, 0, 1, nil, e, tp) end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_EXTRA)
end

function s.e5op(e, tp, eg, ep, ev, re, r, rp)
    local g = Utility.SelectMatchingCard(HINTMSG_SPSUMMON, tp, s.e5filter, tp, LOCATION_EXTRA, 0, 1, 1, nil, e, tp)
    if #g > 0 then Duel.SpecialSummon(g, 0, tp, tp, false, false, POS_FACEUP) end
end
