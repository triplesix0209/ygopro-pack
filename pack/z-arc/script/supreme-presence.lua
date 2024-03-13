-- Presence of the Supreme King
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {CARD_ZARC}
s.listed_series = {SET_SUPREME_KING_GATE, SET_SUPREME_KING_DRAGON}

function s.initial_effect(c)
    c:SetUniqueOnField(1, 0, id)

    -- activation and effect cannot be negated
    local nonegate = Effect.CreateEffect(c)
    nonegate:SetType(EFFECT_TYPE_FIELD)
    nonegate:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
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

    -- activate
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetProperty(EFFECT_FLAG_CANNOT_INACTIVATE + EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_CANNOT_NEGATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- untargetable & indes
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE + EFFECT_FLAG_CANNOT_DISABLE)
    e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e2:SetRange(LOCATION_SZONE)
    e2:SetCondition(function(e)
        return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode, CARD_ZARC), e:GetHandlerPlayer(), LOCATION_ONFIELD, 0, 1, nil)
    end)
    e2:SetValue(aux.tgoval)
    c:RegisterEffect(e2)
    local e2b = e2:Clone()
    e2b:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e2b:SetValue(1)
    c:RegisterEffect(e2b)

    -- send pendulum to extra
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 1))
    e3:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_F)
    e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e3:SetCode(EVENT_PHASE + PHASE_END)
    e3:SetRange(LOCATION_SZONE)
    e3:SetCountLimit(1)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)

    -- multi-attack
    local e4 = Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id, 2))
    e4:SetType(EFFECT_TYPE_IGNITION)
    e4:SetProperty(EFFECT_FLAG_CANNOT_INACTIVATE + EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_CANNOT_NEGATE)
    e4:SetRange(LOCATION_SZONE)
    e4:SetCountLimit(1, {id, 2})
    e4:SetCost(s.e4cost)
    e4:SetTarget(s.e4tg)
    e4:SetOperation(s.e4op)
    c:RegisterEffect(e4)

    -- material check
    local effmatcheck = Effect.CreateEffect(c)
    effmatcheck:SetType(EFFECT_TYPE_FIELD)
    effmatcheck:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_SET_AVAILABLE + EFFECT_FLAG_IGNORE_RANGE)
    effmatcheck:SetCode(EFFECT_MATERIAL_CHECK)
    effmatcheck:SetRange(LOCATION_SZONE)
    effmatcheck:SetValue(s.effmatcheck)
    c:RegisterEffect(effmatcheck)

    -- fusion: special summon
    local e5 = Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(id, 4))
    e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e5:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    e5:SetCode(EVENT_SPSUMMON_SUCCESS)
    e5:SetRange(LOCATION_SZONE)
    e5:SetLabel(TYPE_FUSION)
    e5:SetCondition(s.effcon)
    e5:SetTarget(s.e5tg)
    e5:SetOperation(s.e5op)
    c:RegisterEffect(e5)

    -- synchro: add fusion spell
    local e6 = e5:Clone()
    e6:SetDescription(aux.Stringid(id, 5))
    e6:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH)
    e6:SetLabel(TYPE_SYNCHRO)
    e6:SetTarget(s.e6tg)
    e6:SetOperation(s.e6op)
    c:RegisterEffect(e6)

    -- xyz: add to hand or special summon
    local e7 = e5:Clone()
    e7:SetDescription(aux.Stringid(id, 6))
    e7:SetCategory(CATEGORY_SPECIAL_SUMMON + CATEGORY_TOHAND + CATEGORY_SEARCH)
    e7:SetLabel(TYPE_XYZ)
    e7:SetTarget(s.e7tg)
    e7:SetOperation(s.e7op)
    c:RegisterEffect(e7)
end

function s.countFreePendulumZones(tp)
    local count = 0
    if Duel.CheckLocation(tp, LOCATION_PZONE, 0) then count = count + 1 end
    if Duel.CheckLocation(tp, LOCATION_PZONE, 1) then count = count + 1 end
    return count
end

function s.e1filter1(c)
    if not c:IsType(TYPE_PENDULUM) or c:IsForbidden() then return false end
    if c:IsLocation(LOCATION_EXTRA) and c:IsFacedown() then return false end
    return c:IsSetCard(SET_SUPREME_KING_GATE)
end

function s.e1filter2(c, lsc, rsc) return c:IsSetCard(SET_SUPREME_KING_DRAGON) and lsc < c:GetLevel() and c:GetLevel() < rsc and c:IsAbleToHand() end

function s.e1check(sg, e, tp) return sg:GetClassCount(Card.GetCode) == 2 end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    local g = Duel.GetMatchingGroup(s.e1filter1, tp, LOCATION_HAND + LOCATION_DECK + LOCATION_EXTRA, 0, nil)
    if chk == 0 then
        return s.countFreePendulumZones(tp) >= 2 and (Duel.GetLocationCount(tp, LOCATION_SZONE) >= 2 or c:IsLocation(LOCATION_SZONE)) and
                   aux.SelectUnselectGroup(g, e, tp, 2, 2, s.e1check, 0)
    end

    Duel.SetPossibleOperationInfo(0, CATEGORY_TOHAND, nil, 1, 0, LOCATION_DECK)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) or s.countFreePendulumZones(tp) < 2 then return end
    local pg = Duel.GetMatchingGroup(s.e1filter1, tp, LOCATION_HAND + LOCATION_DECK + LOCATION_EXTRA, 0, nil)
    pg = aux.SelectUnselectGroup(pg, e, tp, 2, 2, s.e1check, 1, tp, HINTMSG_ATOHAND)
    if #pg < 2 then return end
    for tc in pg:Iter() do Duel.MoveToField(tc, tp, tp, LOCATION_PZONE, POS_FACEUP, true) end

    if Duel.GetFieldCard(tp, LOCATION_PZONE, 0) and Duel.GetFieldCard(tp, LOCATION_PZONE, 1) then
        local lsc = Duel.GetFieldCard(tp, LOCATION_PZONE, 0):GetLeftScale()
        local rsc = Duel.GetFieldCard(tp, LOCATION_PZONE, 1):GetRightScale()
        if lsc > rsc then lsc, rsc = rsc, lsc end
        if Duel.IsExistingMatchingCard(s.e1filter2, tp, LOCATION_DECK, 0, 1, nil, lsc, rsc) and Duel.SelectEffectYesNo(tp, c, aux.Stringid(id, 0)) then
            local sg = Utility.SelectMatchingCard(HINTMSG_ATOHAND, tp, s.e1filter2, tp, LOCATION_DECK + LOCATION_EXTRA, 0, 1, 1, nil, lsc, rsc)
            Duel.SendtoHand(sg, nil, REASON_EFFECT)
            Duel.ConfirmCards(1 - tp, sg)
        end
    end
end

function s.e3filter(c) return c:IsType(TYPE_PENDULUM) and not c:IsForbidden() end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local g = Duel.GetMatchingGroup(s.e3filter, tp, LOCATION_GRAVE, 0, nil)
    if chk == 0 then return #g > 0 end

    Duel.SetOperationInfo(0, CATEGORY_LEAVE_GRAVE, g, #g, 0, 0)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) then return end

    local g = Duel.GetMatchingGroup(s.e3filter, tp, LOCATION_GRAVE, 0, nil)
    if #g > 0 then Duel.SendtoExtraP(g, nil, REASON_EFFECT) end
end

function s.e4filter(c) return c:IsFaceup() and c:IsCode(CARD_ZARC) end

function s.e4cost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return c:IsAbleToGraveAsCost() end
    Duel.SendtoGrave(c, REASON_COST)
end

function s.e4tg(e, tp, eg, ep, ev, re, r, rp, chk) if chk == 0 then return Duel.IsExistingMatchingCard(s.e4filter, tp, LOCATION_MZONE, 0, 1, nil) end end

function s.e4op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Utility.SelectMatchingCard(HINTMSG_SELECT, tp, s.e4filter, tp, LOCATION_MZONE, 0, 1, 1, nil):GetFirst()
    if not tc then return end
    Duel.HintSelection(tc)

    -- multi-attack
    local ec1 = Effect.CreateEffect(c)
    ec1:SetDescription(aux.Stringid(id, 3))
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
    ec1:SetCode(EFFECT_ATTACK_ALL)
    ec1:SetValue(1)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
    tc:RegisterEffect(ec1)

    -- act limit
    local ec2 = Effect.CreateEffect(c)
    ec2:SetType(EFFECT_TYPE_FIELD)
    ec2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    ec2:SetCode(EFFECT_CANNOT_ACTIVATE)
    ec2:SetRange(LOCATION_MZONE)
    ec2:SetTargetRange(0, 1)
    ec2:SetValue(function(e, re, tp) return re:IsHasType(EFFECT_TYPE_ACTIVATE) end)
    ec2:SetCondition(function(e) return Duel.GetAttacker() == e:GetHandler() end)
    ec2:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
    c:RegisterEffect(ec2)
end

function s.effmatcheck(e, c)
    local g = c:GetMaterial()
    if c:IsType(TYPE_FUSION + TYPE_SYNCHRO + TYPE_XYZ) and g:IsExists(Card.IsType, 1, nil, TYPE_PENDULUM) then
        c:RegisterFlagEffect(id, RESET_EVENT + 0x4fe0000 + RESET_PHASE + PHASE_END, 0, 1)
    end
end

function s.efffilter(c, e, tp) return c:GetFlagEffect(id) ~= 0 and c:IsFaceup() and c:IsType(e:GetLabel()) and c:IsSummonPlayer(tp) end

function s.effcon(e, tp, eg, ep, ev, re, r, rp) return #eg == 1 and s.efffilter(eg:GetFirst(), e, tp) end

function s.e5filter(c, e, tp, sc)
    return c:HasLevel() and c:GetOriginalLevel() == sc:GetOriginalLevel() and c:IsCanBeSpecialSummoned(e, 0, tp, false, false, POS_FACEUP_DEFENSE)
end

function s.e5tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local loc = LOCATION_HAND + LOCATION_DECK + LOCATION_GRAVE
    if chk == 0 then
        return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and Duel.IsExistingMatchingCard(s.e5filter, tp, loc, 0, 1, nil, e, tp, eg:GetFirst()) and
                   Duel.GetFlagEffect(tp, id + 1000000000) == 0
    end

    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, loc)
end

function s.e5op(e, tp, eg, ep, ev, re, r, rp)
    if Duel.GetFlagEffect(tp, id + 1000000000) ~= 0 then return end
    Duel.RegisterFlagEffect(tp, id + 1000000000, RESET_PHASE + PHASE_END, 0, 1)

    local c = e:GetHandler()
    local sc = eg:GetFirst()
    if not c:IsRelateToEffect(e) then return end
    if sc:IsFacedown() or Duel.GetLocationCount(tp, LOCATION_MZONE) <= 0 then return end

    local loc = LOCATION_HAND + LOCATION_DECK + LOCATION_GRAVE
    local tc = Duel.SelectMatchingCard(tp, s.e5filter, tp, loc, 0, 1, 1, nil, e, tp, sc):GetFirst()
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

function s.e6filter(c) return c:IsSetCard(SET_FUSION) and c:IsSpell() and c:IsAbleToHand() end

function s.e6tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.e6filter, tp, LOCATION_DECK + LOCATION_GRAVE, 0, 1, nil) and Duel.GetFlagEffect(tp, id + 2000000000) == 0
    end

    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK + LOCATION_GRAVE)
end

function s.e6op(e, tp, eg, ep, ev, re, r, rp)
    if Duel.GetFlagEffect(tp, id + 2000000000) ~= 0 then return end
    Duel.RegisterFlagEffect(tp, id + 2000000000, RESET_PHASE + PHASE_END, 0, 1)

    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) then return end

    local g = Utility.SelectMatchingCard(HINTMSG_ATOHAND, tp, s.e6filter, tp, LOCATION_DECK + LOCATION_GRAVE, 0, 1, 1, nil)
    if #g > 0 then
        Duel.SendtoHand(g, nil, REASON_EFFECT)
        Duel.ConfirmCards(1 - tp, g)
    end
end

function s.e7filter(c, e, tp, sc)
    local ft = Duel.GetLocationCount(tp, LOCATION_MZONE)
    return c:IsLevelBelow(sc:GetRank()) and c:IsType(TYPE_TUNER) and
               (c:IsAbleToHand() or (ft > 0 and c:IsCanBeSpecialSummoned(e, 0, tp, false, false)))
end

function s.e7tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.e7filter, tp, LOCATION_DECK + LOCATION_GRAVE, 0, 1, nil, e, tp, eg:GetFirst()) and
                   Duel.GetFlagEffect(tp, id + 3000000000) == 0
    end

    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK + LOCATION_GRAVE)
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_DECK + LOCATION_GRAVE)
end

function s.e7op(e, tp, eg, ep, ev, re, r, rp)
    if Duel.GetFlagEffect(tp, id + 3000000000) ~= 0 then return end
    Duel.RegisterFlagEffect(tp, id + 3000000000, RESET_PHASE + PHASE_END, 0, 1)

    local c = e:GetHandler()
    local sc = eg:GetFirst()
    if not c:IsRelateToEffect(e) then return end
    if sc:IsFacedown() then return end

    local g = Utility.SelectMatchingCard(HINTMSG_SELECT, tp, s.e7filter, tp, LOCATION_DECK + LOCATION_GRAVE, 0, 1, 1, nil, e, tp, eg:GetFirst())
    if #g == 0 then return end

    aux.ToHandOrElse(g, tp,
        function(tc) return tc:IsCanBeSpecialSummoned(e, 0, tp, false, false) and Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 end,
        function(g) Duel.SpecialSummon(g, 0, tp, tp, false, false, POS_FACEUP_DEFENSE) end, 2)
end
