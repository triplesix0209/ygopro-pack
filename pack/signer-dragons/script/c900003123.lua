-- Starjunk Warrior
Duel.LoadScript("util.lua")
local s, id = GetID()

s.material = {63977008}
s.material_setcode = {0x1017}
s.listed_names = {63977008}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- synchro summon
    Synchro.AddProcedure(c, function(c, sc, stype, tp)
        return c:IsSummonCode(sc, stype, tp, 63977008) or c:IsHasEffect(20932152) or c:IsSetCard(0x1017)
    end, 1, 1, Synchro.NonTuner(nil), 1, 99)

    -- add code
    local code = Effect.CreateEffect(c)
    code:SetType(EFFECT_TYPE_SINGLE)
    code:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    code:SetCode(EFFECT_ADD_CODE)
    code:SetValue(60800381)
    c:RegisterEffect(code)

    -- material check
    local matcheck = Effect.CreateEffect(c)
    matcheck:SetType(EFFECT_TYPE_SINGLE)
    matcheck:SetCode(EFFECT_MATERIAL_CHECK)
    matcheck:SetValue(function(e, c)
        local g = c:GetMaterial()
        if g:IsExists(Card.IsCode, 1, nil, 63977008) then
            e:SetLabel(1)
            c:RegisterFlagEffect(id, RESET_EVENT + RESETS_STANDARD - RESET_TOFIELD, EFFECT_FLAG_CLIENT_HINT, 1, 0,
                aux.Stringid(id, 0))
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

    -- destroy at end damage step
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
    e3:SetCode(EVENT_DAMAGE_STEP_END)
    e3:SetLabelObject(matcheck)
    e3:SetCondition(s.e3con)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)
end

function s.e1con(e) return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO) end

function s.e1filter(c, e, tp)
    return c:IsLevelBelow(2) and c:IsRace(RACE_WARRIOR + RACE_MACHINE) and c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and
                   Duel.IsExistingMatchingCard(s.e1filter, tp, LOCATION_HAND + LOCATION_DECK + LOCATION_GRAVE, 0, 1, nil, e, tp)
    end

    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_HAND + LOCATION_DECK + LOCATION_GRAVE)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    if Duel.GetLocationCount(tp, LOCATION_MZONE) <= 0 then return end

    local g = Utility.SelectMatchingCard(HINTMSG_SPSUMMON, tp, aux.NecroValleyFilter(s.e1filter), tp,
        LOCATION_HAND + LOCATION_DECK + LOCATION_GRAVE, 0, 1, 1, nil, e, tp)
    if #g > 0 then Duel.SpecialSummon(g, 0, tp, tp, false, false, POS_FACEUP) end
end

function s.e2filter(c) return c:IsFaceup() and c:IsLevelBelow(2) end

function s.e2con(e, tp, eg, ep, ev, re, r, rp) return e:GetLabelObject():GetLabel() > 0 end

function s.e2val(e, c) return Duel.GetMatchingGroup(s.e2filter, c:GetControler(), LOCATION_MZONE, 0, c):GetSum(Card.GetAttack) end

function s.e3con(e, tp, eg, ep, ev, re, r, rp)
    local tc = e:GetHandler():GetBattleTarget()
    return e:GetLabelObject():GetLabel() > 0 and tc and tc:IsRelateToBattle() and e:GetOwnerPlayer() == tp
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local tc = e:GetHandler():GetBattleTarget()
    Duel.Destroy(tc, REASON_EFFECT)
end
