-- The Supreme King HERO
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {CARD_SUPER_POLYMERIZATION, CARD_DARK_FUSION}
s.listed_series = {SET_FUSION}

function s.initial_effect(c)
    c:EnableReviveLimit()
    c:SetUniqueOnField(1, 0, id)

    -- fusion summon
    Fusion.AddProcMixRep(c, false, false, aux.FilterBoolFunctionEx(Card.IsType, TYPE_EFFECT), 1, 99,
        function(c, sc, st, tp) return c:IsType(TYPE_FUSION, sc, st, tp) and c.dark_calling end)

    -- special summon limit
    local splimit = Effect.CreateEffect(c)
    splimit:SetType(EFFECT_TYPE_SINGLE)
    splimit:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    splimit:SetCode(EFFECT_SPSUMMON_CONDITION)
    splimit:SetValue(function(e, se, sp, st)
        return se:GetHandler():IsCode(CARD_SUPER_POLYMERIZATION) and st & SUMMON_TYPE_FUSION == SUMMON_TYPE_FUSION
    end)
    c:RegisterEffect(splimit)

    -- summon cannot be negated
    local spsafe = Effect.CreateEffect(c)
    spsafe:SetType(EFFECT_TYPE_SINGLE)
    spsafe:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    spsafe:SetCode(EFFECT_CANNOT_DISABLE_SPSUMMON)
    spsafe:SetCondition(function(e) return e:GetHandler():GetSummonType() == SUMMON_TYPE_FUSION end)
    c:RegisterEffect(spsafe)

    -- cannot be tributed, be used as a material
    local norelease = Effect.CreateEffect(c)
    norelease:SetType(EFFECT_TYPE_FIELD)
    norelease:SetProperty(EFFECT_FLAG_PLAYER_TARGET + EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    norelease:SetCode(EFFECT_CANNOT_RELEASE)
    norelease:SetRange(LOCATION_MZONE)
    norelease:SetTargetRange(0, 1)
    norelease:SetTarget(function(e, tc) return tc == e:GetHandler() end)
    c:RegisterEffect(norelease)
    local nomaterial = Effect.CreateEffect(c)
    nomaterial:SetType(EFFECT_TYPE_SINGLE)
    nomaterial:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    nomaterial:SetCode(EFFECT_CANNOT_BE_MATERIAL)
    nomaterial:SetValue(function(e, tc) return tc and tc:GetControler() ~= e:GetHandlerPlayer() end)
    c:RegisterEffect(nomaterial)

    -- control cannot switch
    local noswitch = Effect.CreateEffect(c)
    noswitch:SetType(EFFECT_TYPE_SINGLE)
    noswitch:SetProperty(EFFECT_FLAG_SINGLE_RANGE + EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    noswitch:SetCode(EFFECT_CANNOT_CHANGE_CONTROL)
    noswitch:SetRange(LOCATION_MZONE)
    c:RegisterEffect(noswitch)

    -- cannot be fusion material
    local nofusmaterial = Effect.CreateEffect(c)
    nofusmaterial:SetType(EFFECT_TYPE_SINGLE)
    nofusmaterial:SetProperty(EFFECT_FLAG_SINGLE_RANGE + EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    nofusmaterial:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
    nofusmaterial:SetRange(LOCATION_MZONE)
    nofusmaterial:SetValue(1)
    c:RegisterEffect(nofusmaterial)

    -- immune
    local immune1 = Effect.CreateEffect(c)
    immune1:SetType(EFFECT_TYPE_SINGLE)
    immune1:SetProperty(EFFECT_FLAG_SINGLE_RANGE + EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    immune1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    immune1:SetRange(LOCATION_MZONE)
    immune1:SetValue(1)
    c:RegisterEffect(immune1)
    local immune2 = Effect.CreateEffect(c)
    immune2:SetType(EFFECT_TYPE_FIELD)
    immune2:SetProperty(EFFECT_FLAG_PLAYER_TARGET + EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    immune2:SetCode(EFFECT_CANNOT_REMOVE)
    immune2:SetRange(LOCATION_MZONE)
    immune2:SetTargetRange(1, 1)
    immune2:SetTarget(function(e, c, tp, r) return c == e:GetHandler() and r == REASON_EFFECT end)
    c:RegisterEffect(immune2)

    -- fusion monsters you control cannot be targeted by opponent's effects
    local untarget = Effect.CreateEffect(c)
    untarget:SetType(EFFECT_TYPE_FIELD)
    untarget:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE + EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    untarget:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    untarget:SetRange(LOCATION_MZONE)
    untarget:SetTargetRange(LOCATION_MZONE, 0)
    untarget:SetTarget(aux.TargetBoolFunction(Card.IsType, TYPE_FUSION))
    untarget:SetValue(aux.tgoval)
    c:RegisterEffect(untarget)

    -- equip
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_EQUIP)
    e1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DELAY + EFFECT_FLAG_DAMAGE_STEP)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetCondition(function(e) return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION) end)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- apply fusion effect
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 0))
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1, id)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)
end

function s.e1filter(c, ec) return c:IsType(TYPE_EQUIP) and c:CheckEquipTarget(ec) end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    local c = e:GetHandler()
    if chk == 0 then
        return Duel.GetLocationCount(tp, LOCATION_SZONE) > 0 and
                   Duel.IsExistingTarget(s.file1filterter, tp, LOCATION_HAND + LOCATION_DECK + LOCATION_GRAVE, 0, 1, nil, c)
    end

    Duel.SetOperationInfo(0, CATEGORY_LEAVE_GRAVE, nil, 1, 0, 0)
    Duel.SetOperationInfo(0, CATEGORY_EQUIP, nil, 1, 0, LOCATION_HAND + LOCATION_DECK + LOCATION_GRAVE)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
    local tc =
        Utility.SelectMatchingCard(HINTMSG_EQUIP, tp, s.e1filter, tp, LOCATION_HAND + LOCATION_DECK + LOCATION_GRAVE, 0, 1, 1, nil, c):GetFirst()
    if tc then Duel.Equip(tp, tc, c) end
end

function s.e2filter(c)
    return c:IsAbleToGraveAsCost() and (c:IsSetCard(SET_FUSION) or c:ListsCode(CARD_DARK_FUSION)) and
               (c:GetType() == TYPE_SPELL or c:GetType() == TYPE_SPELL + TYPE_QUICKPLAY) and c:CheckActivateEffect(true, true, false) ~= nil
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.e2filter, tp, LOCATION_HAND + LOCATION_DECK, 0, 1, nil) end

    local tc = Utility.SelectMatchingCard(HINTMSG_TOGRAVE, tp, s.e2filter, tp, LOCATION_HAND + LOCATION_DECK, 0, 1, 1, nil):GetFirst()
    if not tc or not Duel.SendtoGrave(tc, REASON_COST) then return end

    local te = tc:CheckActivateEffect(true, true, false)
    e:SetLabel(te:GetLabel())
    e:SetLabelObject(te:GetLabelObject())
    local tg = te:GetTarget()
    if tg then tg(e, tp, eg, ep, ev, re, r, rp, 1) end
    te:SetLabel(e:GetLabel())
    te:SetLabelObject(e:GetLabelObject())
    e:SetLabelObject(te)
    Duel.ClearOperationInfo(0)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local te = e:GetLabelObject()
    if te then
        e:SetLabel(te:GetLabel())
        e:SetLabelObject(te:GetLabelObject())
        local op = te:GetOperation()
        if op then op(e, tp, eg, ep, ev, re, r, rp) end
        te:SetLabel(e:GetLabel())
        te:SetLabelObject(e:GetLabelObject())
    end
end
