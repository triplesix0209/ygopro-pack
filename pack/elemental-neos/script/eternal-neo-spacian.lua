-- Eternal Neo-Spacian
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_series = {SET_NEOS, SET_YUBEL, SET_NEO_SPACIAN}
s.material_setcode = {SET_HERO}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- link summon
    Link.AddProcedure(c, function(c, sc, sumtype, tp)
        return c:IsSetCard(SET_HERO, sc, sumtype, tp) or (c:IsRace(RACE_FIEND, sc, sumtype, tp) and c:IsAttack(0) and c:IsDefense(0))
    end, 1, 1)

    -- special summon
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetCountLimit(1, id)
    e1:SetCondition(s.e1con)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- copy effect
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 0))
    e2:SetCategory(CATEGORY_TOGRAVE)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)
end

function s.e1filter(c, e, tp)
    return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsSetCard(SET_NEOS) and c:IsCanBeSpecialSummoned(e, 0, tp, false, false, POS_FACEUP)
end

function s.e1con(e, tp, eg, ep, ev, re, r, rp) return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK) end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and
                   Duel.IsExistingMatchingCard(s.e1filter, tp, LOCATION_HAND + LOCATION_DECK, 0, 1, nil, e, tp)
    end

    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_HAND + LOCATION_DECK)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if Duel.GetLocationCount(tp, LOCATION_MZONE) <= 0 then return end
    local tc = Utility.SelectMatchingCard(HINTMSG_SPSUMMON, tp, s.e1filter, tp, LOCATION_HAND + LOCATION_DECK, 0, 1, 1, nil, e, tp):GetFirst()
    if tc and Duel.SpecialSummon(tc, 0, tp, tp, false, false, POS_FACEUP) > 0 then
        tc:RegisterFlagEffect(id, RESET_EVENT + RESETS_STANDARD, 0, 1)

        local ec1 = Effect.CreateEffect(c)
        ec1:SetDescription(3206)
        ec1:SetType(EFFECT_TYPE_SINGLE)
        ec1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
        ec1:SetCode(EFFECT_CANNOT_ATTACK)
        ec1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
        tc:RegisterEffect(ec1)
        local ec2 = Effect.CreateEffect(c)
        ec2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
        ec2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
        ec2:SetCode(EVENT_PHASE + PHASE_END)
        ec2:SetLabelObject(tc)
        ec2:SetCountLimit(1)
        ec2:SetCondition(function(e, tp, eg, ep, ev, re, r, rp)
            local tc = e:GetLabelObject()
            if not tc or tc:GetFlagEffect(id) == 0 then
                e:Reset()
                return false
            end
            return true
        end)
        ec2:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
            local tc = e:GetLabelObject()
            if tc then Duel.SendtoDeck(tc, nil, SEQ_DECKSHUFFLE, REASON_EFFECT) end
        end)
        Duel.RegisterEffect(ec2, tp)
    end
end

function s.e2filter(c)
    return not c:IsCode(id) and c:IsAbleToGrave() and c:IsMonster() and ((c:IsLevel(10) and c:IsSetCard(SET_YUBEL)) or c:IsSetCard(SET_NEO_SPACIAN))
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.e2filter, tp, LOCATION_HAND + LOCATION_DECK + LOCATION_EXTRA, 0, 1, nil) end
    Duel.SetOperationInfo(0, CATEGORY_TOGRAVE, nil, 1, tp, LOCATION_HAND + LOCATION_DECK + LOCATION_EXTRA)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc =
        Utility.SelectMatchingCard(HINTMSG_TOGRAVE, tp, s.e2filter, tp, LOCATION_HAND + LOCATION_DECK + LOCATION_EXTRA, 0, 1, 1, nil):GetFirst()
    if tc and Duel.SendtoGrave(tc, REASON_EFFECT) and c:IsRelateToEffect(e) and c:IsFaceup() then
        local code = tc:GetOriginalCode()
        local ec1 = Effect.CreateEffect(c)
        ec1:SetType(EFFECT_TYPE_SINGLE)
        ec1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
        ec1:SetCode(EFFECT_CHANGE_CODE)
        ec1:SetValue(code)
        ec1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
        c:RegisterEffect(ec1)
        if not tc:IsType(TYPE_TRAPMONSTER) then c:CopyEffect(code, RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END, 1) end
    end
end
