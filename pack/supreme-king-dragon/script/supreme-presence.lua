-- Supreme Presence of the Overlord
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {CARD_ZARC}
s.listed_series = {SET_ODD_EYES, SET_FUSION}

function s.initial_effect(c)
    -- activate
    local act = Effect.CreateEffect(c)
    act:SetType(EFFECT_TYPE_ACTIVATE)
    act:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(act)

    -- untargetable
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e1:SetRange(LOCATION_FZONE)
    e1:SetValue(aux.tgoval)
    c:RegisterEffect(e1)
    local e1b = e1:Clone()
    e1b:SetType(EFFECT_TYPE_FIELD)
    e1b:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
    e1b:SetTargetRange(LOCATION_PZONE, 0)
    c:RegisterEffect(e1b)

    -- search
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 0))
    e2:SetCategory(CATEGORY_DESTROY + CATEGORY_TOHAND + CATEGORY_SEARCH)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_FZONE)
    e2:SetCountLimit(1, id)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)

    -- pendulum summon
    local e3 = Effect.CreateEffect(c)
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetRange(LOCATION_FZONE)
    e3:SetCountLimit(1)
    e3:SetCondition(s.e3con)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)
    aux.GlobalCheck(s, function()
        local e3reg = Effect.CreateEffect(c)
        e3reg:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
        e3reg:SetCode(EVENT_SPSUMMON_SUCCESS)
        e3reg:SetOperation(s.e3regop)
        Duel.RegisterEffect(e3reg, 0)
    end)

    -- material check
    local eff = Effect.CreateEffect(c)
    eff:SetType(EFFECT_TYPE_FIELD)
    eff:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_SET_AVAILABLE + EFFECT_FLAG_IGNORE_RANGE)
    eff:SetCode(EFFECT_MATERIAL_CHECK)
    eff:SetRange(LOCATION_FZONE)
    eff:SetValue(s.effcheck)
    c:RegisterEffect(eff)

    -- fusion: special summon
    local e4 = Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id, 1))
    e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e4:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    e4:SetCode(EVENT_SPSUMMON_SUCCESS)
    e4:SetRange(LOCATION_FZONE)
    e4:SetLabel(TYPE_FUSION)
    e4:SetCondition(s.effcon)
    e4:SetTarget(s.e4tg)
    e4:SetOperation(s.e4op)
    c:RegisterEffect(e4)

    -- synchro: add fusion spell
    local e5 = e4:Clone()
    e5:SetDescription(aux.Stringid(id, 2))
    e5:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH)
    e5:SetLabel(TYPE_SYNCHRO)
    e5:SetTarget(s.e5tg)
    e5:SetOperation(s.e5op)
    c:RegisterEffect(e5)

    -- xyz: add to hand or special summon
    local e6 = e4:Clone()
    e6:SetDescription(aux.Stringid(id, 3))
    e6:SetCategory(CATEGORY_SPECIAL_SUMMON + CATEGORY_TOHAND + CATEGORY_SEARCH)
    e6:SetLabel(TYPE_XYZ)
    e6:SetTarget(s.e6tg)
    e6:SetOperation(s.e6op)
    c:RegisterEffect(e6)
end

function s.e2filter(c)
    if not c:IsAbleToHand() then return false end
    return c:IsSetCard(SET_ODD_EYES) or c:ListsCode(CARD_ZARC)
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(Card.IsFaceup, tp, LOCATION_ONFIELD, 0, 1, e:GetHandler()) and
                   Duel.IsExistingMatchingCard(s.e2filter, tp, LOCATION_DECK + LOCATION_GRAVE, 0, 1, nil)
    end

    Duel.SetOperationInfo(0, CATEGORY_DESTROY, nil, 1, 0, LOCATION_ONFIELD)
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK + LOCATION_GRAVE)
    Duel.SetChainLimit(aux.FALSE)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) then return end

    local g = Utility.SelectMatchingCard(HINTMSG_DESTROY, tp, Card.IsFaceup, tp, LOCATION_ONFIELD, 0, 1, 1, c)
    Duel.HintSelection(g)

    if Duel.Destroy(g, REASON_EFFECT) ~= 0 then
        local sg = Utility.SelectMatchingCard(HINTMSG_ATOHAND, tp, aux.NecroValleyFilter(s.e2filter), tp, LOCATION_DECK + LOCATION_GRAVE, 0, 1, 1, g)
        if #sg > 0 then
            Duel.SendtoHand(sg, nil, REASON_EFFECT)
            Duel.ConfirmCards(1 - tp, sg)
        end
    end
end

function s.e3regop(e, tp, eg, ep, ev, re, r, rp)
    for tc in eg:Iter() do
        local sumtp = tc:GetSummonPlayer()
        if tc:IsSummonLocation(LOCATION_EXTRA) and tc:IsType(TYPE_PENDULUM) and tc:IsPreviousPosition(POS_FACEDOWN) and tc:IsFaceup() and
            tc:GetOwner() == sumtp then Duel.RegisterFlagEffect(sumtp, id, RESET_PHASE + PHASE_END, 0, 1) end
    end
end

function s.e3con(e, tp, eg, ep, ev, re, r, rp) return Duel.GetFlagEffect(tp, id) ~= 0 end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsPlayerCanPendulumSummon(tp) end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_HAND + LOCATION_EXTRA)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp) Duel.PendulumSummon(tp) end

function s.effcheck(e, c)
    local g = c:GetMaterial()
    if c:IsType(TYPE_FUSION + TYPE_SYNCHRO + TYPE_XYZ) and g:IsExists(Card.IsType, 1, nil, TYPE_PENDULUM) then
        c:RegisterFlagEffect(id, RESET_EVENT + 0x4fe0000 + RESET_PHASE + PHASE_END, 0, 1)
    end
end

function s.efffilter(c, e, tp) return c:GetFlagEffect(id) ~= 0 and c:IsFaceup() and c:IsType(e:GetLabel()) and c:IsSummonPlayer(tp) end

function s.effcon(e, tp, eg, ep, ev, re, r, rp) return #eg == 1 and s.efffilter(eg:GetFirst(), e, tp) end

function s.e4filter(c, e, tp, sc)
    return c:HasLevel() and c:GetOriginalLevel() == sc:GetOriginalLevel() and c:IsCanBeSpecialSummoned(e, 0, tp, false, false, POS_FACEUP_DEFENSE)
end

function s.e4tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local loc = LOCATION_HAND + LOCATION_DECK + LOCATION_GRAVE
    if chk == 0 then
        return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and Duel.IsExistingMatchingCard(s.e4filter, tp, loc, 0, 1, nil, e, tp, eg:GetFirst()) and
                   Duel.GetFlagEffect(tp, id + 1000000000) == 0
    end

    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, loc)
end

function s.e4op(e, tp, eg, ep, ev, re, r, rp)
    if Duel.GetFlagEffect(tp, id + 1000000000) ~= 0 then return end
    Duel.RegisterFlagEffect(tp, id + 1000000000, RESET_PHASE + PHASE_END, 0, 1)

    local c = e:GetHandler()
    local sc = eg:GetFirst()
    if not c:IsRelateToEffect(e) then return end
    if sc:IsFacedown() or Duel.GetLocationCount(tp, LOCATION_MZONE) <= 0 then return end

    local loc = LOCATION_HAND + LOCATION_DECK + LOCATION_GRAVE
    local tc = Duel.SelectMatchingCard(tp, aux.NecroValleyFilter(s.e4filter), tp, loc, 0, 1, 1, nil, e, tp, sc):GetFirst()
    if tc and Duel.SpecialSummonStep(tc, 0, tp, tp, false, false, POS_FACEUP_DEFENSE) then
        local ec1 = Effect.CreateEffect(c)
        ec1:SetDescription(3302)
        ec1:SetType(EFFECT_TYPE_SINGLE)
        ec1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
        ec1:SetCode(EFFECT_CANNOT_TRIGGER)
        ec1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
        tc:RegisterEffect(ec1)
    end
    Duel.SpecialSummonComplete()
end

function s.e5filter(c) return c:IsSetCard(SET_FUSION) and c:IsType(TYPE_SPELL) and c:IsAbleToHand() end

function s.e5tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.e5filter, tp, LOCATION_DECK + LOCATION_GRAVE, 0, 1, nil) and Duel.GetFlagEffect(tp, id + 2000000000) == 0
    end

    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK + LOCATION_GRAVE)
end

function s.e5op(e, tp, eg, ep, ev, re, r, rp)
    if Duel.GetFlagEffect(tp, id + 2000000000) ~= 0 then return end
    Duel.RegisterFlagEffect(tp, id + 2000000000, RESET_PHASE + PHASE_END, 0, 1)

    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) then return end

    local g = Utility.SelectMatchingCard(HINTMSG_ATOHAND, tp, aux.NecroValleyFilter(s.e5filter), tp, LOCATION_DECK + LOCATION_GRAVE, 0, 1, 1, nil)
    if #g > 0 then
        Duel.SendtoHand(g, nil, REASON_EFFECT)
        Duel.ConfirmCards(1 - tp, g)
    end
end

function s.e6filter(c, e, tp, sc)
    local ft = Duel.GetLocationCount(tp, LOCATION_MZONE)
    return c:IsLevelBelow(sc:GetRank()) and c:IsType(TYPE_TUNER) and
               (c:IsAbleToHand() or (ft > 0 and c:IsCanBeSpecialSummoned(e, 0, tp, false, false)))
end

function s.e6tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.e6filter, tp, LOCATION_DECK + LOCATION_GRAVE, 0, 1, nil, e, tp, eg:GetFirst()) and
                   Duel.GetFlagEffect(tp, id + 3000000000) == 0
    end

    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK + LOCATION_GRAVE)
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_DECK + LOCATION_GRAVE)
end

function s.e6op(e, tp, eg, ep, ev, re, r, rp)
    if Duel.GetFlagEffect(tp, id + 3000000000) ~= 0 then return end
    Duel.RegisterFlagEffect(tp, id + 3000000000, RESET_PHASE + PHASE_END, 0, 1)

    local c = e:GetHandler()
    local sc = eg:GetFirst()
    if not c:IsRelateToEffect(e) then return end
    if sc:IsFacedown() then return end

    local g = Utility.SelectMatchingCard(HINTMSG_SELECT, tp, aux.NecroValleyFilter(s.e6filter), tp, LOCATION_DECK + LOCATION_GRAVE, 0, 1, 1, nil, e,
        tp, eg:GetFirst())
    if #g == 0 then return end

    aux.ToHandOrElse(g, tp,
        function(tc) return tc:IsCanBeSpecialSummoned(e, 0, tp, false, false) and Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 end,
        function(g) Duel.SpecialSummon(g, 0, tp, tp, false, false, POS_FACEUP_DEFENSE) end, 2)
end
