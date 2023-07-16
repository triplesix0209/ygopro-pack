-- Starjunk Warrior
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {63977008}
s.material = {63977008}
s.material_setcode = {SET_SYNCHRON}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- synchro summon
    Synchro.AddProcedure(c, function(c, sc, stype, tp)
        return c:IsSummonCode(sc, stype, tp, 63977008) or c:IsSetCard(SET_SYNCHRON, sc, stype, tp) or c:IsHasEffect(20932152)
    end, 1, 1, Synchro.NonTuner(nil), 1, 99)

    -- material check
    local matcheck = Effect.CreateEffect(c)
    matcheck:SetType(EFFECT_TYPE_SINGLE)
    matcheck:SetCode(EFFECT_MATERIAL_CHECK)
    matcheck:SetValue(function(e, c)
        local g = c:GetMaterial()
        if g:IsExists(Card.IsCode, 1, nil, 63977008) then
            e:SetLabel(1)
            c:RegisterFlagEffect(id, RESET_EVENT + RESETS_STANDARD - RESET_TOFIELD, EFFECT_FLAG_CLIENT_HINT, 1, 0, aux.Stringid(id, 0))
        else
            e:SetLabel(0)
        end
    end)
    c:RegisterEffect(matcheck)

    -- special summon
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 1))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetCountLimit(1, id)
    e1:SetCondition(s.e1con)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- atk up
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e2:SetCode(EFFECT_UPDATE_ATTACK)
    e2:SetRange(LOCATION_MZONE)
    e2:SetLabelObject(matcheck)
    e2:SetCondition(s.e2con)
    e2:SetValue(s.e2val)
    c:RegisterEffect(e2)
end

function s.e1con(e) return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO) end

function s.e1filter(c, e, tp) return c:IsLevelBelow(2) and c:IsRace(RACE_WARRIOR + RACE_MACHINE) and c:IsCanBeSpecialSummoned(e, 0, tp, false, false) end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and
                   Duel.IsExistingMatchingCard(s.e1filter, tp, LOCATION_HAND + LOCATION_DECK, 0, 1, nil, e, tp)
    end

    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_HAND + LOCATION_DECK)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    if Duel.GetLocationCount(tp, LOCATION_MZONE) <= 0 then return end

    local g = Utility.SelectMatchingCard(HINTMSG_SPSUMMON, tp, s.e1filter, tp, LOCATION_HAND + LOCATION_DECK, 0, 1, 1, nil, e, tp)
    if #g > 0 then Duel.SpecialSummon(g, 0, tp, tp, false, false, POS_FACEUP) end
end

function s.e2filter(c) return c:IsFaceup() and c:IsLevelBelow(2) end

function s.e2con(e, tp, eg, ep, ev, re, r, rp) return e:GetLabelObject():GetLabel() > 0 end

function s.e2val(e, c) return Duel.GetMatchingGroup(s.e2filter, c:GetControler(), LOCATION_MZONE, 0, c):GetSum(Card.GetAttack) end
