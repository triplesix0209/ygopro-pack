-- Elemental HERO Miracle Neos
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {CARD_NEOS}
s.listed_series = {SET_NEO_SPACIAN, SET_NEOS}
s.material_setcode = {SET_NEOS, SET_NEO_SPACIAN}

function s.initial_effect(c)
    c:EnableReviveLimit()
    c:SetUniqueOnField(1, 0, id)

    -- fusion summon
    Fusion.AddProcMixRep(c, false, false, s.fusfilter, 4, 99, function(c, fc, st, tp)
        return c:IsLevel(7) and c:IsType(TYPE_NORMAL, fc, st, tp) and c:IsSetCard(SET_NEOS, fc, st, tp)
    end)

    -- special summon limit
    local splimit = Effect.CreateEffect(c)
    splimit:SetType(EFFECT_TYPE_SINGLE)
    splimit:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    splimit:SetCode(EFFECT_SPSUMMON_CONDITION)
    splimit:SetValue(aux.fuslimit)
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

    -- "Neos" fusions can choose to not return
    local neospace = Effect.CreateEffect(c)
    neospace:SetType(EFFECT_TYPE_FIELD)
    neospace:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    neospace:SetCode(42015635)
    neospace:SetRange(LOCATION_MZONE)
    neospace:SetTargetRange(LOCATION_MZONE, LOCATION_MZONE)
    c:RegisterEffect(neospace)

    -- material check
    local matcheck = Effect.CreateEffect(c)
    matcheck:SetType(EFFECT_TYPE_SINGLE)
    matcheck:SetCode(EFFECT_MATERIAL_CHECK)
    matcheck:SetValue(s.matcheck)
    c:RegisterEffect(matcheck)

    -- gain effect & atk
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_REMOVE + CATEGORY_ATKCHANGE)
    e1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCondition(s.e1con)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- immune
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e2:SetCode(EFFECT_IMMUNE_EFFECT)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCondition(function(e) return e:GetHandler():GetFlagEffect(id) ~= 0 end)
    e2:SetValue(function(e, te) return te:GetOwner() ~= e:GetOwner() end)
    c:RegisterEffect(e2)
end

function s.fusfilter(c, fc, st, tp, sub, mg, sg)
    return c:IsSetCard(SET_NEO_SPACIAN, fc, st, tp) and c:GetAttribute(fc, st, tp) ~= 0 and
               (not sg or not sg:IsExists(function(c, attr, fc, st, tp)
            return c:IsSetCard(SET_NEO_SPACIAN, fc, st, tp) and c:IsAttribute(attr, fc, st, tp) and not c:IsHasEffect(511002961)
        end, 1, c, c:GetAttribute(fc, st, tp), fc, st, tp))
end

function s.matcheck(e, c)
    local g = c:GetMaterial():Filter(Card.IsSetCard, nil, SET_NEO_SPACIAN)
    if #g >= 6 then
        c:RegisterFlagEffect(id, RESET_EVENT | RESETS_STANDARD & ~(RESET_TOFIELD | RESET_TEMP_REMOVE | RESET_LEAVE), EFFECT_FLAG_CLIENT_HINT, 1, 0,
            aux.Stringid(id, 0))
    end
end

function s.e1filter(c)
    if not c:IsAbleToRemove() or (c:IsLocation(LOCATION_GRAVE) and not aux.SpElimFilter(c, true)) then return false end
    return c:IsSetCard(SET_NEO_SPACIAN) or (c:IsLevel(7) and c:IsType(TYPE_FUSION) and c:ListsCodeAsMaterial(CARD_NEOS))
end

function s.e1con(e, tp, eg, ep, ev, re, r, rp) return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION) end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    local ct = #c:GetMaterial()
    if chk == 0 then return ct > 0 and Duel.IsExistingMatchingCard(s.e1filter, tp, LOCATION_EXTRA + LOCATION_GRAVE, 0, 1, nil) end

    Duel.SetOperationInfo(0, CATEGORY_REMOVE, nil, ct, 0, LOCATION_EXTRA + LOCATION_GRAVE)
    Duel.SetChainLimit(function(e, rp, tp) return tp == rp end)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local max = #c:GetMaterial()
    local g = Utility.SelectMatchingCard(HINTMSG_REMOVE, tp, s.e1filter, tp, LOCATION_EXTRA + LOCATION_GRAVE, 0, 1, max, nil)
    Duel.Remove(g, POS_FACEUP, REASON_EFFECT)
    local og = Duel.GetOperatedGroup()
    if #og == 0 then return end

    for tc in og:Iter() do
        local code = tc:GetOriginalCode()
        c:CopyEffect(code, RESET_EVENT + RESETS_STANDARD)
    end

    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetProperty(EFFECT_FLAG_COPY_INHERIT)
    ec1:SetCode(EFFECT_SET_BASE_ATTACK)
    ec1:SetValue(c:GetBaseAttack() + #og * 500)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD_DISABLE)
    c:RegisterEffect(ec1)
    local ec1b = ec1:Clone()
    ec1b:SetCode(EFFECT_SET_BASE_DEFENSE)
    ec1b:SetValue(c:GetBaseDefense() + #og * 500)
    c:RegisterEffect(ec1b)
end
