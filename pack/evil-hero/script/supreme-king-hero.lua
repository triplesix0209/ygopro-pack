-- The Supreme King HERO
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {CARD_SUPER_POLYMERIZATION, CARD_DARK_FUSION}
s.listed_series = {SET_FUSION}
s.material_setcode = {SET_HERO}

function s.initial_effect(c)
    c:EnableReviveLimit()
    c:SetUniqueOnField(1, 0, id)

    -- fusion summon
    Fusion.AddProcMixRep(c, false, false, function(c, sc, st, tp) return c:IsType(TYPE_EFFECT, sc, st, tp) end, 1, 99,
        function(c, sc, st, tp) return c:IsSetCard(SET_HERO, sc, st, tp) and c:IsType(TYPE_FUSION, sc, st, tp) end)

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

    -- recover
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_RECOVER)
    e1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DELAY + EFFECT_FLAG_PLAYER_TARGET)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetCondition(function(e) return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION) end)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- immune
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e2:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCondition(s.e2con)
    e2:SetValue(aux.imval1)
    c:RegisterEffect(e2)
    local e2b = e2:Clone()
    e2b:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e2b:SetValue(1)
    c:RegisterEffect(e2b)
    local e2c = e2:Clone()
    e2c:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e2c:SetValue(aux.tgoval)
    c:RegisterEffect(e2c)
    local e3d = Effect.CreateEffect(c)
    e3d:SetType(EFFECT_TYPE_FIELD)
    e3d:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e3d:SetCode(EFFECT_CANNOT_REMOVE)
    e3d:SetRange(LOCATION_MZONE)
    e3d:SetTargetRange(1, 1)
    e3d:SetCondition(s.e2con)
    e3d:SetTarget(function(e, c, tp, r) return c == e:GetHandler() and r == REASON_EFFECT end)
    c:RegisterEffect(e3d)

    -- apply fusion effect
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 0))
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1, id)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local mg = e:GetHandler():GetMaterial()
    if chk == 0 then return mg and #mg > 0 end
    local val = #mg * 1000
    Duel.SetTargetPlayer(tp)
    Duel.SetTargetParam(val)
    Duel.SetOperationInfo(0, CATEGORY_RECOVER, nil, 0, tp, val)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local p, d = Duel.GetChainInfo(0, CHAININFO_TARGET_PLAYER, CHAININFO_TARGET_PARAM)
    Duel.Recover(p, d, REASON_EFFECT)
end

function s.e2con(e)
    return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsType, TYPE_FUSION), e:GetHandlerPlayer(), LOCATION_MZONE, 0, 1, e:GetHandler())
end

function s.e3filter(c)
    return c:IsAbleToGraveAsCost() and (c:IsSetCard(SET_FUSION) or c:ListsCode(CARD_DARK_FUSION)) and
               (c:GetType() == TYPE_SPELL or c:GetType() == TYPE_SPELL + TYPE_QUICKPLAY) and c:CheckActivateEffect(true, true, false) ~= nil
end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.e3filter, tp, LOCATION_HAND + LOCATION_DECK, 0, 1, nil) end

    local tc = Utility.SelectMatchingCard(HINTMSG_TOGRAVE, tp, s.e3filter, tp, LOCATION_HAND + LOCATION_DECK, 0, 1, 1, nil):GetFirst()
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

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
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
