-- Divinity Neos
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {CARD_NEOS}
s.listed_series = {SET_NEO_SPACIAN}
s.material_setcode = {SET_NEOS, SET_NEO_SPACIAN}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- fusion summon
    Fusion.AddProcMixRep(c, false, false, s.fusfilter, 4, 99,
        function(c, fc, sumtype, tp) return c:IsLevel(7) and c:IsSetCard(SET_NEOS, fc, sumtype, tp) end)

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

    -- material check
    local matcheck = Effect.CreateEffect(c)
    matcheck:SetType(EFFECT_TYPE_SINGLE)
    matcheck:SetCode(EFFECT_MATERIAL_CHECK)
    matcheck:SetValue(s.matcheck)
    c:RegisterEffect(matcheck)

    -- "Neos" fusions can choose to not return
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    e1:SetCode(42015635)
    e1:SetRange(LOCATION_MZONE)
    e1:SetTargetRange(LOCATION_MZONE, LOCATION_MZONE)
    c:RegisterEffect(e1)

    -- fusion summoned
    local e2 = Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_REMOVE + CATEGORY_ATKCHANGE)
    e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCondition(s.e2con)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)

    -- immune
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e3:SetCode(EFFECT_IMMUNE_EFFECT)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCondition(function(e) return e:GetHandler():GetFlagEffect(id) ~= 0 end)
    e3:SetValue(function(e, te) return te:GetOwner() ~= e:GetOwner() end)
    c:RegisterEffect(e3)
end

function s.fusfilter(c, fc, sumtype, tp, sub, mg, sg)
    return c:IsSetCard(SET_NEO_SPACIAN, fc, sumtype, tp) and c:GetAttribute(fc, sumtype, tp) ~= 0 and
               (not sg or not sg:IsExists(function(c, attr, fc, sumtype, tp)
            return c:IsSetCard(SET_NEO_SPACIAN, fc, sumtype, tp) and c:IsAttribute(attr, fc, sumtype, tp) and not c:IsHasEffect(511002961)
        end, 1, c, c:GetAttribute(fc, sumtype, tp), fc, sumtype, tp))
end

function s.matcheck(e, c)
    local g = c:GetMaterial():Filter(Card.IsSetCard, nil, SET_NEO_SPACIAN)
    if #g >= 6 then
        c:RegisterFlagEffect(id, RESET_EVENT | RESETS_STANDARD & ~(RESET_TOFIELD | RESET_TEMP_REMOVE | RESET_LEAVE), EFFECT_FLAG_CLIENT_HINT, 1, 0,
            aux.Stringid(id, 0))
    end
end

function s.e2filter(c)
    if not c:IsAbleToRemove() or not aux.SpElimFilter(c, true) or not c:IsLevelBelow(7) then return false end
    return c:IsSetCard(SET_NEO_SPACIAN) or (c:IsType(TYPE_FUSION) and c:ListsCodeAsMaterial(CARD_NEOS))
end

function s.e2con(e, tp, eg, ep, ev, re, r, rp) return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION) end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return Duel.IsExistingMatchingCard(s.e2filter, tp, LOCATION_EXTRA + LOCATION_GRAVE, 0, 1, nil) end

    Duel.SetOperationInfo(0, CATEGORY_REMOVE, nil, #c:GetMaterial(), 0, LOCATION_EXTRA + LOCATION_GRAVE)
    Duel.SetChainLimit(function(e, rp, tp) return tp == rp end)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local max = #c:GetMaterial()
    local g = Utility.SelectMatchingCard(HINTMSG_REMOVE, tp, s.e2filter, tp, LOCATION_EXTRA + LOCATION_GRAVE, 0, 1, max, nil)
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
