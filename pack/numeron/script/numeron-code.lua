-- Numeron Code
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_series = {SET_NUMBER, SET_NUMERON}

function s.initial_effect(c)
    -- activation and effect cannot be negated
    local nonegate = Effect.CreateEffect(c)
    nonegate:SetType(EFFECT_TYPE_FIELD)
    nonegate:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    nonegate:SetCode(EFFECT_CANNOT_INACTIVATE)
    nonegate:SetRange(LOCATION_ONFIELD)
    nonegate:SetTargetRange(1, 0)
    nonegate:SetValue(function(e, ct)
        local te = Duel.GetChainInfo(ct, CHAININFO_TRIGGERING_EFFECT)
        return te:GetHandler() == e:GetHandler()
    end)
    c:RegisterEffect(nonegate)
    local nodiseff = nonegate:Clone()
    nodiseff:SetCode(EFFECT_CANNOT_DISEFFECT)
    c:RegisterEffect(nodiseff)
    local nodis = Effect.CreateEffect(c)
    nodis:SetType(EFFECT_TYPE_SINGLE)
    nodis:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    nodis:SetCode(EFFECT_CANNOT_DISABLE)
    c:RegisterEffect(nodis)

    -- place field
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_CANNOT_NEGATE + EFFECT_FLAG_CANNOT_INACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1, {id, 1}, EFFECT_COUNT_CODE_OATH)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- untargetable
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e2:SetRange(LOCATION_FZONE)
    e2:SetValue(1)
    c:RegisterEffect(e2)

    -- cannot disable summon
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetProperty(EFFECT_FLAG_IGNORE_RANGE + EFFECT_FLAG_SET_AVAILABLE)
    e3:SetCode(EFFECT_CANNOT_DISABLE_SPSUMMON)
    e3:SetRange(LOCATION_FZONE)
    e3:SetTarget(function(e, c) return c:IsSetCard(SET_NUMBER) and c:IsType(TYPE_XYZ) and c:IsControler(e:GetHandlerPlayer()) end)
    c:RegisterEffect(e3)

    -- detaching cost is optional
    local e4 = Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,1))
    e4:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e4:SetCode(EFFECT_OVERLAY_REMOVE_REPLACE)
    e4:SetRange(LOCATION_FZONE)
    e4:SetCondition(function(e, tp, eg, ep, ev, re, r, rp)
        local rc = re:GetHandler()
        return (r & REASON_COST) ~= 0 and re:IsActivated() and re:IsActiveType(TYPE_XYZ) and rc:IsSetCard(SET_NUMERON) and
                   rc:IsControler(e:GetOwnerPlayer())
    end)
    e4:SetOperation(function(e, tp, eg, ep, ev, re, r, rp) return ev end)
    c:RegisterEffect(e4)

    -- copy effect
    local e5 = Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(id, 2))
    e5:SetType(EFFECT_TYPE_QUICK_O)
    e5:SetCode(EVENT_FREE_CHAIN)
    e5:SetRange(LOCATION_FZONE)
    e5:SetHintTiming(TIMINGS_CHECK_MONSTER + TIMING_BATTLE_START + TIMING_MAIN_END)
    e5:SetCountLimit(1, id)
    e5:SetCost(function(e)
        e:SetLabel(1)
        return true
    end)
    e5:SetTarget(s.e5tg)
    e5:SetOperation(s.e5op)
    c:RegisterEffect(e5)
    local e5b = e5:Clone()
    e5b:SetCode(EVENT_SPSUMMON)
    c:RegisterEffect(e5b)
end

function s.e1filter1(c) return not c:IsCode(id) and c:IsFieldSpell() end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chk == 0 then return true end
    Duel.SetPossibleOperationInfo(0, CATEGORY_LEAVE_GRAVE, nil, 1, 0, 0)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) or not Duel.SelectEffectYesNo(tp, c, aux.Stringid(id, 0)) then return end
    local tc =
        Utility.SelectMatchingCard(HINTMSG_SELECT, tp, s.e1filter1, tp, LOCATION_HAND + LOCATION_DECK + LOCATION_GRAVE, 0, 1, 1, nil):GetFirst()
    if not tc or tc:IsImmuneToEffect(e) then return end
    Duel.Overlay(c, tc)
    c:CopyEffect(tc:GetOriginalCode(), RESET_EVENT + RESETS_STANDARD)
end

function s.e5filter(c, tp)
    return c:IsSetCard(SET_NUMERON) and c:IsSpellTrap() and c:IsAbleToGraveAsCost() and c:CheckActivateEffect(true, true, true) ~= nil and
               (Duel.GetTurnPlayer() == tp or not c:IsSpell())
end

function s.e5tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        if e:GetLabel() == 0 then return false end
        e:SetLabel(0)
        return Duel.IsExistingMatchingCard(s.e5filter, tp, LOCATION_HAND + LOCATION_DECK, 0, 1, nil, tp)
    end

    e:SetLabel(0)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_CONFIRM)
    local tc = Duel.SelectMatchingCard(tp, s.e5filter, tp, LOCATION_HAND + LOCATION_DECK, 0, 1, 1, nil, tp):GetFirst()
    local te, ceg, cep, cev, cre, cr, crp = tc:CheckActivateEffect(true, true, true)
    Duel.SendtoGrave(tc, REASON_COST)

    e:SetProperty(te:GetProperty())
    local tg = te:GetTarget()
    if tg then tg(e, tp, ceg, cep, cev, cre, cr, crp, 1) end
    te:SetLabelObject(e:GetLabelObject())
    e:SetLabelObject(te)
    Duel.ClearOperationInfo(0)
end

function s.e5op(e, tp, eg, ep, ev, re, r, rp)
    if not e:GetHandler():IsRelateToEffect(e) then return end
    local te = e:GetLabelObject()
    if not te then return end

    e:SetLabelObject(te:GetLabelObject())
    local op = te:GetOperation()
    if op then op(e, tp, eg, ep, ev, re, r, rp) end
end
