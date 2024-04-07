-- Compilecode Talker
Duel.LoadScript("util.lua")
local s, id = GetID()

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- link summon
    Link.AddProcedure(c, aux.NOT(aux.FilterBoolFunctionEx(Card.IsType, TYPE_TOKEN)), 2, 99,
        function(g, sc, st, tp) return g:CheckDifferentProperty(Card.GetCode, sc, st, tp) end)

    -- you take no effect damage
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetCode(EFFECT_CHANGE_DAMAGE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetTargetRange(1, 0)
    e1:SetCondition(function(e) return e:GetHandler():GetMutualLinkedGroupCount() > 0 end)
    e1:SetValue(function(e, re, val, r, rp, rc) return (r & REASON_EFFECT) == 0 and val or 0 end)
    c:RegisterEffect(e1)
    local e1b = e1:Clone()
    e1b:SetCode(EFFECT_NO_EFFECT_DAMAGE)
    c:RegisterEffect(e1b)

    -- ATK up & special summon
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 0))
    e2:SetCategory(CATEGORY_ATKCHANGE + CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1, id)
    e2:SetCost(s.e2cost)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)
end

function s.e2filter1(c, lg) return lg:IsContains(c) and c:GetTextAttack() > 0 end

function s.e2filter2(c, e, tp, mc)
    return not c:IsCode({id, mc:GetCode()}) and c:IsRace(RACE_CYBERSE) and c:IsLinkMonster() and c:IsLinkBelow(mc:GetLink()) and
               c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end

function s.e2cost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    local lg = c:GetLinkedGroup()
    if chk == 0 then return Duel.CheckReleaseGroupCost(tp, s.e2filter1, 1, false, nil, c, lg) end
    local g = Duel.SelectReleaseGroupCost(tp, s.e2filter1, 1, 1, false, nil, c, lg)

    e:SetLabelObject(g:GetFirst())
    Duel.Release(g, REASON_COST)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local rc = e:GetLabelObject()
    if not rc then return end

    if c:IsFaceup() and c:IsRelateToEffect(e) then
        local ec1 = Effect.CreateEffect(c)
        ec1:SetType(EFFECT_TYPE_SINGLE)
        ec1:SetCode(EFFECT_UPDATE_ATTACK)
        ec1:SetValue(rc:GetTextAttack())
        ec1:SetReset(RESET_EVENT + RESETS_STANDARD_DISABLE + RESET_PHASE + PHASE_END)
        c:RegisterEffect(ec1)
    end

    if rc:IsLinkMonster() and Duel.IsExistingMatchingCard(s.e2filter2, tp, LOCATION_GRAVE, 0, 1, nil, e, tp, c) and
        Duel.SelectEffectYesNo(tp, c, aux.Stringid(id, 1)) then
        Duel.BreakEffect()
        local tc = Utility.SelectMatchingCard(HINTMSG_SPSUMMON, tp, s.e2filter2, tp, LOCATION_GRAVE, 0, 1, 1, nil, e, tp, rc):GetFirst()
        if tc and Duel.SpecialSummon(tc, 0, tp, tp, false, false, POS_FACEUP) > 0 then
            local ec1 = Effect.CreateEffect(c)
            ec1:SetDescription(3206)
            ec1:SetType(EFFECT_TYPE_SINGLE)
            ec1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
            ec1:SetCode(EFFECT_CANNOT_ATTACK)
            ec1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
            tc:RegisterEffect(ec1)
        end
    end
end
