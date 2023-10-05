-- Armityle, the Chaos Phantasm Ruler
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {6007213, 32491822, 69890967}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- fusion summon
    Fusion.AddProcMix(c, true, true, 6007213, 32491822, 69890967)
    Fusion.AddContactProc(c, s.fusfilter, s.fusop, s.splimit)

    -- special summon cannot be negated
    local spsafe = Effect.CreateEffect(c)
    spsafe:SetType(EFFECT_TYPE_SINGLE)
    spsafe:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    spsafe:SetCode(EFFECT_CANNOT_DISABLE_SPSUMMON)
    c:RegisterEffect(spsafe)

    -- no change battle position
    local nopos = Effect.CreateEffect(c)
    nopos:SetType(EFFECT_TYPE_SINGLE)
    nopos:SetProperty(EFFECT_FLAG_SINGLE_RANGE + EFFECT_FLAG_CANNOT_DISABLE)
    nopos:SetCode(EFFECT_CANNOT_CHANGE_POS_E)
    nopos:SetRange(LOCATION_MZONE)
    c:RegisterEffect(nopos)

    -- cannot be tributed, or be used as a material
    local norelease = Effect.CreateEffect(c)
    norelease:SetType(EFFECT_TYPE_FIELD)
    norelease:SetProperty(EFFECT_FLAG_PLAYER_TARGET + EFFECT_FLAG_CANNOT_DISABLE)
    norelease:SetCode(EFFECT_CANNOT_RELEASE)
    norelease:SetRange(LOCATION_MZONE)
    norelease:SetTargetRange(0, 1)
    norelease:SetTarget(function(e, tc) return tc == e:GetHandler() end)
    c:RegisterEffect(norelease)
    local nomaterial = Effect.CreateEffect(c)
    nomaterial:SetType(EFFECT_TYPE_SINGLE)
    nomaterial:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    nomaterial:SetCode(EFFECT_CANNOT_BE_MATERIAL)
    nomaterial:SetValue(function(e, tc) return tc and tc:GetControler() ~= e:GetHandlerPlayer() end)
    c:RegisterEffect(nomaterial)

    -- self disable
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
    e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE + EFFECT_CANNOT_DISABLE)
    e1:SetCode(EVENT_CONTROL_CHANGED)
    e1:SetCountLimit(1)
    e1:SetCondition(s.e1con)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- banish
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
    e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE + EFFECT_CANNOT_DISABLE)
    e2:SetCode(EVENT_CONTROL_CHANGED)
    e2:SetCountLimit(1)
    e2:SetOperation(s.e2regop)
    c:RegisterEffect(e2)

    -- cannot be destroyed by battle
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
    e3:SetValue(1)
    c:RegisterEffect(e3)

    -- increase ATK
    local e4 = Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_SINGLE)
    e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e4:SetCode(EFFECT_UPDATE_ATTACK)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCondition(function(e) return Duel.GetTurnPlayer() == e:GetHandlerPlayer() end)
    e4:SetValue(10000)
    c:RegisterEffect(e4)

    -- give control
    local e5 = Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(id, 2))
    e5:SetCategory(CATEGORY_CONTROL)
    e5:SetType(EFFECT_TYPE_IGNITION)
    e5:SetRange(LOCATION_MZONE)
    e5:SetCountLimit(1)
    e5:SetTarget(s.e5tg)
    e5:SetOperation(s.e5op)
    c:RegisterEffect(e5)
end

function s.splimit(e, se, sp, st) return not e:GetHandler():IsLocation(LOCATION_EXTRA) end

function s.fusfilter(tp) return Duel.GetMatchingGroup(Card.IsAbleToDeckOrExtraAsCost, tp, LOCATION_ONFIELD, 0, nil) end

function s.fusop(g, tp)
    Duel.ConfirmCards(1 - tp, g)
    Duel.Remove(g, POS_FACEUP, REASON_COST + REASON_MATERIAL)
end

function s.e1con(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    return c:GetControler() ~= c:GetOwner()
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()

    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    ec1:SetCode(EFFECT_DISABLE)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
    c:RegisterEffect(ec1)
    local ec1b = ec1:Clone()
    ec1b:SetCode(EFFECT_DISABLE_EFFECT)
    ec1b:SetValue(RESET_TURN_SET)
    c:RegisterEffect(ec1b)

    local ec2 = Effect.CreateEffect(c)
    ec2:SetDescription(aux.Stringid(id, 0))
    ec2:SetType(EFFECT_TYPE_SINGLE)
    ec2:SetProperty(EFFECT_FLAG_SINGLE_RANGE + EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_CLIENT_HINT)
    ec2:SetCode(EFFECT_CANNOT_CHANGE_CONTROL)
    ec2:SetRange(LOCATION_MZONE)
    ec2:SetReset(RESET_EVENT + RESETS_STANDARD)
    c:RegisterEffect(ec2)
end

function s.e2regop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local ec1 = Effect.CreateEffect(c)
    ec1:SetCategory(CATEGORY_REMOVE + CATEGORY_TOEXTRA + CATEGORY_SPECIAL_SUMMON)
    ec1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_F)
    ec1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    ec1:SetCode(EVENT_PHASE + PHASE_END)
    ec1:SetRange(LOCATION_MZONE)
    ec1:SetCountLimit(1)
    ec1:SetTarget(s.e2tg)
    ec1:SetOperation(s.e2op)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
    c:RegisterEffect(ec1)
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return true end

    local g = Duel.GetMatchingGroup(Card.IsAbleToRemove, tp, LOCATION_ONFIELD, 0, c)
    Duel.SetOperationInfo(0, CATEGORY_REMOVE, g, #g, 0, LOCATION_ONFIELD)
    Duel.SetOperationInfo(0, CATEGORY_TOEXTRA, c, 1, 0, 0)
    Duel.SetPossibleOperationInfo(0, CATEGORY_SPECIAL_SUMMON, c, 1, 0, 0)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()

    local g = Duel.GetMatchingGroup(Card.IsAbleToRemove, tp, LOCATION_ONFIELD, 0, c)
    Duel.Remove(g, POS_FACEUP, REASON_EFFECT)

    if Duel.SendtoDeck(c, nil, SEQ_DECKSHUFFLE, REASON_EFFECT) > 0 then
        local p = e:GetHandler():GetOwner()
        if c:IsCanBeSpecialSummoned(e, SUMMON_TYPE_FUSION, p, true, false) and Duel.GetLocationCountFromEx(p, p, nil, c) > 0 and
            Duel.SelectEffectYesNo(p, c, aux.Stringid(id, 1)) then
            Duel.BreakEffect()
            Duel.SpecialSummon(c, SUMMON_TYPE_FUSION, p, p, true, false, POS_FACEUP)
            c:CompleteProcedure()
        end
    end
end

function s.e4tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    local c = e:GetHandler()
    if chk == 0 then return c:CanAttack() and Duel.IsExistingTarget(nil, tp, 0, LOCATION_MZONE, 1, nil) end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATTACK)
    local tc = Duel.SelectMatchingCard(tp, nil, tp, 0, LOCATION_MZONE, 1, 1, nil):GetFirst()
    Duel.SetTargetCard(tc)
end

function s.e4op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Duel.GetFirstTarget()
    if c:IsRelateToEffect(e) and c:IsFaceup() and tc and tc:IsRelateToEffect(e) and c:CanAttack() and not c:IsImmuneToEffect(e) and
        not tc:IsImmuneToEffect(e) then
        local ec1 = Effect.CreateEffect(c)
        ec1:SetType(EFFECT_TYPE_SINGLE)
        ec1:SetCode(EFFECT_SET_ATTACK_FINAL)
        ec1:SetValue(10000)
        ec1:SetReset(RESET_CHAIN)
        c:RegisterEffect(ec1)
        Duel.CalculateDamage(c, tc)
    end
end

function s.e5tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    local c = e:GetHandler()
    if chk == 0 then return c:IsAbleToChangeControler() and Duel.GetLocationCount(1 - tp, LOCATION_MZONE) > 0 end

    Duel.SetOperationInfo(0, CATEGORY_CONTROL, c, 1, 0, 0)
end

function s.e5op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if c:IsRelateToEffect(e) and c:IsFaceup() then Duel.GetControl(c, 1 - tp) end
end
