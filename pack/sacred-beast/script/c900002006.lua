-- Yubel - Desperate Incarnate
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {78371393, 31764700}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- special summon limit
    local splimit = Effect.CreateEffect(c)
    splimit:SetType(EFFECT_TYPE_SINGLE)
    splimit:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    splimit:SetCode(EFFECT_SPSUMMON_CONDITION)
    c:RegisterEffect(splimit)

    -- search
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1, id)
    e1:SetCost(s.e1cost)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- indes & avoid damage
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
    e2:SetValue(1)
    c:RegisterEffect(e2)
    local e2b = e2:Clone()
    e2b:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
    c:RegisterEffect(e2b)

    -- damage & destroy
    local e3reg = Effect.CreateEffect(c)
    e3reg:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
    e3reg:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e3reg:SetCode(EVENT_BATTLED)
    e3reg:SetOperation(s.e3regop)
    c:RegisterEffect(e3reg)
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 0))
    e3:SetCategory(CATEGORY_DAMAGE + CATEGORY_DESTROY)
    e3:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_F)
    e3:SetCode(EVENT_DAMAGE_STEP_END)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    e3:SetLabelObject(e3reg)
    c:RegisterEffect(e3)

    -- special summon
    local e4 = Effect.CreateEffect(c)
    e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e4:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e4:SetProperty(EFFECT_FLAG_DELAY + EFFECT_FLAG_DAMAGE_STEP + EFFECT_FLAG_DAMAGE_CAL)
    e4:SetCode(EVENT_LEAVE_FIELD)
    e4:SetCondition(s.e4con)
    e4:SetTarget(s.e4tg)
    e4:SetOperation(s.e4op)
    c:RegisterEffect(e4)
end

function s.e1filter(c) return c:IsAbleToHand() and not c:IsCode(id) and (c:IsCode(78371393) or c:ListsCode(78371393)) end

function s.e1cost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return c:IsDiscardable() end

    Duel.SendtoGrave(c, REASON_COST + REASON_DISCARD)
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.e1filter, tp, LOCATION_DECK, 0, 1, nil) end

    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp, chk)
    local g = Utility.SelectMatchingCard(HINTMSG_ATOHAND, tp, s.e1filter, tp, LOCATION_DECK, 0, 1, 1, nil)
    if #g > 0 then
        Duel.SendtoHand(g, nil, REASON_EFFECT)
        Duel.ConfirmCards(1 - tp, g)
    end
end

function s.e3regop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local bc = c:GetBattleTarget()
    if bc and c:IsAttackPos() then
        e:SetLabelObject(bc)
    else
        e:SetLabelObject(nil)
    end
end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local bc = e:GetLabelObject():GetLabelObject()
    if chk == 0 then return bc end

    Duel.SetOperationInfo(0, CATEGORY_DAMAGE, nil, 0, 1 - tp, bc:GetAttack())
    Duel.SetOperationInfo(0, CATEGORY_DESTROY, nil, 1, 0, LOCATION_ONFIELD)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local bc = e:GetLabelObject():GetLabelObject()
    Duel.Damage(1 - tp, bc:GetAttack(), REASON_EFFECT)

    local g = Utility.SelectMatchingCard(HINTMSG_DESTROY, tp, nil, tp, LOCATION_ONFIELD, LOCATION_ONFIELD, 1, 1, c)
    if #g > 0 then
        Duel.HintSelection(g)
        Duel.Destroy(g, REASON_EFFECT)
    end
end

function s.e4sumtype(c)
    if c:IsType(TYPE_FUSION) then
        return SUMMON_TYPE_FUSION
    else
        return 0
    end
end

function s.e4sumlimit(c)
    if c:IsCode(31764700) then
        return true
    else
        return false
    end
end

function s.e4filter(c, e, tp)
    return (c:IsCode(31764700) or (c:IsType(TYPE_FUSION) and c:ListsCodeAsMaterial(31764700))) and
               c:IsCanBeSpecialSummoned(e, s.e4sumtype(c), tp, true, s.e4sumlimit(c))
end

function s.e4con(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    return c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousLocation(LOCATION_ONFIELD)
end

function s.e4tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local loc = LOCATION_HAND + LOCATION_DECK + LOCATION_GRAVE + LOCATION_EXTRA
    if chk == 0 then
        return
            Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and Duel.IsExistingMatchingCard(s.e4filter, tp, loc, 0, 1, nil, e, tp)
    end

    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, loc)
end

function s.e4op(e, tp, eg, ep, ev, re, r, rp)
    if Duel.GetLocationCount(tp, LOCATION_MZONE) <= 0 then return end

    local loc = LOCATION_HAND + LOCATION_DECK + LOCATION_GRAVE + LOCATION_EXTRA
    local tc =
        Utility.SelectMatchingCard(HINTMSG_SPSUMMON, tp, aux.NecroValleyFilter(s.e4filter), tp, loc, 0, 1, 1, nil, e, tp):GetFirst()
    if tc then
        Duel.SpecialSummon(tc, s.e4sumtype(tc), tp, tp, true, s.e4sumlimit(tc), POS_FACEUP)
        tc:CompleteProcedure()
    end
end
