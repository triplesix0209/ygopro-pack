-- Supreme King Gate Hope
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {CARD_ZARC, 900005013}
s.listed_series = {SET_SUPREME_KING_GATE}

function s.initial_effect(c)
    Pendulum.AddProcedure(c)

    -- change scale
    local pe1 = Effect.CreateEffect(c)
    pe1:SetType(EFFECT_TYPE_SINGLE)
    pe1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    pe1:SetCode(EFFECT_CHANGE_LSCALE)
    pe1:SetRange(LOCATION_PZONE)
    pe1:SetCondition(function(e)
        local c = e:GetHandler()
        local tp = e:GetHandlerPlayer()
        return not Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode, CARD_ZARC), tp, LOCATION_PZONE, 0, 1, c) and
                   not Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard, SET_SUPREME_KING_GATE), tp, LOCATION_PZONE, 0, 1, c)
    end)
    pe1:SetValue(4)
    c:RegisterEffect(pe1)
    local pe1b = pe1:Clone()
    pe1b:SetCode(EFFECT_CHANGE_RSCALE)
    c:RegisterEffect(pe1b)

    -- cannot disable pendulum summon
    local pe2 = Effect.CreateEffect(c)
    pe2:SetType(EFFECT_TYPE_FIELD)
    pe2:SetProperty(EFFECT_FLAG_IGNORE_RANGE + EFFECT_FLAG_SET_AVAILABLE)
    pe2:SetCode(EFFECT_CANNOT_DISABLE_SPSUMMON)
    pe2:SetRange(LOCATION_PZONE)
    pe2:SetTargetRange(1, 0)
    pe2:SetTarget(function(e, c) return c:IsSummonType(SUMMON_TYPE_PENDULUM) end)
    c:RegisterEffect(pe2)

    -- recover
    local pe3 = Effect.CreateEffect(c)
    pe3:SetCategory(CATEGORY_RECOVER)
    pe3:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    pe3:SetCode(900005013)
    pe3:SetRange(LOCATION_PZONE)
    pe3:SetOperation(s.pe3op)
    c:RegisterEffect(pe3)

    -- special summon a dragon
    local me1 = Effect.CreateEffect(c)
    me1:SetDescription(aux.Stringid(id, 0))
    me1:SetCategory(CATEGORY_DESTROY + CATEGORY_SPECIAL_SUMMON)
    me1:SetType(EFFECT_TYPE_IGNITION)
    me1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    me1:SetRange(LOCATION_MZONE)
    me1:SetCountLimit(1)
    me1:SetTarget(s.me1tg)
    me1:SetOperation(s.me1op)
    c:RegisterEffect(me1)

    -- place into pendulum zone
    local me2 = Effect.CreateEffect(c)
    me2:SetDescription(2203)
    me2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    me2:SetCode(EVENT_DESTROYED)
    me2:SetProperty(EFFECT_FLAG_DELAY)
    me2:SetCondition(function(e, tp, eg, ep, ev, re, r, rp) return e:GetHandler():IsPreviousLocation(LOCATION_MZONE) and e:GetHandler():IsFaceup() end)
    me2:SetTarget(function(e, tp, eg, ep, ev, re, r, rp, chk) if chk == 0 then return Duel.CheckPendulumZones(tp) end end)
    me2:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
        if not e:GetHandler():IsRelateToEffect(e) or not Duel.CheckPendulumZones(tp) then return end
        Duel.MoveToField(e:GetHandler(), tp, tp, LOCATION_PZONE, POS_FACEUP, true)
    end)
    c:RegisterEffect(me2)
end

function s.pe3op(e, tp, eg, ep, ev, re, r, rp)
    Utility.HintCard(e)
    Duel.Recover(tp, ev, REASON_EFFECT)
end

function s.me1filter1(c, e, tp, mc)
    return c:IsFaceup() and Duel.IsExistingMatchingCard(s.me1filter2, tp, LOCATION_EXTRA, 0, 1, nil, e, tp, Group.FromCards(c, mc))
end

function s.me1filter2(c, e, tp, mg)
    return c:IsType(TYPE_FUSION + TYPE_SYNCHRO + TYPE_XYZ + TYPE_PENDULUM) and c:IsRace(RACE_DRAGON) and
               c:IsCanBeSpecialSummoned(e, 0, tp, false, false) and Duel.GetLocationCountFromEx(tp, tp, mg, c) > 0
end

function s.me1tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    local c = e:GetHandler()
    if chk == 0 then return Duel.IsExistingTarget(s.me1filter1, tp, LOCATION_ONFIELD, 0, 1, c, e, tp, c) end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_DESTROY)
    local g = Duel.SelectTarget(tp, s.me1filter1, tp, LOCATION_ONFIELD, 0, 1, 1, c, e, tp, c)
    g:AddCard(c)

    Duel.SetOperationInfo(0, CATEGORY_DESTROY, g, 2, 0, 0)
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_EXTRA)
end

function s.me1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Duel.GetFirstTarget()
    if not c:IsRelateToEffect(e) or not tc or not tc:IsRelateToEffect(e) then return end

    local dg = Group.FromCards(c, tc)
    if Duel.Destroy(dg, REASON_EFFECT) == 2 then
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
        local sc = Duel.SelectMatchingCard(tp, s.me1filter2, tp, LOCATION_EXTRA, 0, 1, 1, nil, e, tp):GetFirst()
        if not tc then return end

        if Duel.SpecialSummonStep(sc, 0, tp, tp, false, false, POS_FACEUP) then
            -- Negate its effects
            local ec1 = Effect.CreateEffect(c)
            ec1:SetType(EFFECT_TYPE_SINGLE)
            ec1:SetCode(EFFECT_DISABLE)
            ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
            sc:RegisterEffect(ec1, true)
            local ec1b = ec1:Clone()
            ec1b:SetCode(EFFECT_DISABLE_EFFECT)
            sc:RegisterEffect(ec1b, true)

            -- ATK/DEF becomes 0
            local ec2 = Effect.CreateEffect(c)
            ec2:SetType(EFFECT_TYPE_SINGLE)
            ec2:SetCode(EFFECT_SET_ATTACK_FINAL)
            ec2:SetValue(0)
            ec2:SetReset(RESET_EVENT + RESETS_STANDARD)
            sc:RegisterEffect(ec2, true)
            local ec2b = ec2:Clone()
            ec2b:SetCode(EFFECT_SET_DEFENSE_FINAL)
            sc:RegisterEffect(ec2b, true)

            -- Cannot be used as material
            local ec3 = Effect.CreateEffect(c)
            ec3:SetDescription(3310)
            ec3:SetType(EFFECT_TYPE_SINGLE)
            ec3:SetProperty(EFFECT_FLAG_CLIENT_HINT)
            ec3:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
            ec3:SetValue(1)
            ec3:SetReset(RESET_EVENT + RESETS_STANDARD)
            sc:RegisterEffect(ec3, true)
            local ec3b = ec3:Clone()
            ec3b:SetDescription(3311)
            ec3b:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
            sc:RegisterEffect(ec3b, true)

            sc:CompleteProcedure()
        end
        Duel.SpecialSummonComplete()
    end
end
