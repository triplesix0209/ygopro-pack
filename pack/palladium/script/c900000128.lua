-- Palladium Fusion Mastery
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_series = {SET_FUSION}

function s.initial_effect(c)
    c:AddSetcodesRule(id, true, 0x13a)

    -- activate
    local act = Effect.CreateEffect(c)
    act:SetType(EFFECT_TYPE_ACTIVATE)
    act:SetCode(EVENT_FREE_CHAIN)
    act:SetTarget(Utility.MultiEffectTarget(s))
    act:SetOperation(Utility.MultiEffectOperation(s))
    c:RegisterEffect(act)

    -- activate
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 1))
    e1:SetCategory(CATEGORY_TODECK + CATEGORY_SPECIAL_SUMMON)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    Utility.RegisterMultiEffect(s, 1, e1)

    -- prevent fusion negation
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 2))
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    Utility.RegisterMultiEffect(s, 2, e2)

    -- search fusion
    local e3 = Effect.CreateEffect(c)
    e3:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH + CATEGORY_TODECK)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_GRAVE)
    e3:SetCountLimit(1, id)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)
end

function s.e1filter1(c) return c:IsFaceup() and c:IsType(TYPE_FUSION) and c:IsAbleToExtra() end

function s.e1filter2(c, e, tp, fc, mg)
    return c:IsControler(tp) and (c:GetReason() & 0x40008) == 0x40008 and c:GetReasonCard() == fc and
               fc:CheckFusionMaterial(mg, c, PLAYER_NONE | FUSPROC_NOTFUSION) and c:IsCanBeSpecialSummoned(e, 0, tp, false, false) and
               c:IsLocation(LOCATION_HAND + LOCATION_DECK + LOCATION_GRAVE + LOCATION_REMOVED)
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingTarget(s.e1filter1, tp, LOCATION_MZONE, LOCATION_MZONE, 1, nil) end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TODECK)
    local g = Duel.SelectTarget(tp, s.e1filter1, tp, LOCATION_MZONE, LOCATION_MZONE, 1, 1, nil)

    Duel.SetOperationInfo(0, CATEGORY_TODECK, g, #g, 0, 0)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Duel.GetFirstTarget()
    if tc:IsFacedown() or not tc:IsRelateToEffect(e) then return end

    local mg = tc:GetMaterial()
    local sumtype = tc:GetSummonType()
    if Duel.SendtoDeck(tc, nil, 0, REASON_EFFECT) ~= 0 and (sumtype & SUMMON_TYPE_FUSION) == SUMMON_TYPE_FUSION and
        mg:FilterCount(aux.NecroValleyFilter(s.e1filter2), nil, e, tp, tc, mg) == #mg and #mg > 0 and #mg <=
        Duel.GetLocationCount(tp, LOCATION_MZONE) and (#mg == 1 or not Duel.IsPlayerAffectedByEffect(tp, CARD_BLUEEYES_SPIRIT)) and
        Duel.SelectEffectYesNo(tp, c, aux.Stringid(id, 0)) then
        Duel.BreakEffect()
        Duel.SpecialSummon(mg, 0, tp, tp, false, false, POS_FACEUP)
    end
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return true end

    Duel.SetChainLimit(function(e, rp, tp) return tp == rp end)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()

    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_FIELD)
    ec1:SetCode(EFFECT_CANNOT_INACTIVATE)
    ec1:SetValue(function(e, ct)
        local p = e:GetHandlerPlayer()
        local te, tp = Duel.GetChainInfo(ct, CHAININFO_TRIGGERING_EFFECT, CHAININFO_TRIGGERING_PLAYER)
        return p == tp and te:IsHasCategory(CATEGORY_FUSION_SUMMON)
    end)
    ec1:SetReset(RESET_PHASE + PHASE_END)
    Duel.RegisterEffect(ec1, tp)

    local ec2 = Effect.CreateEffect(c)
    ec2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    ec2:SetCode(EVENT_SPSUMMON_SUCCESS)
    ec2:SetCondition(function(e, tp, eg, ep, ev, re, r, rp)
        return eg:IsExists(function(c, tp) return c:IsSummonPlayer(tp) and c:IsSummonType(SUMMON_TYPE_FUSION) end, 1, nil, tp)
    end)
    ec2:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
        local c = e:GetHandler()
        if Duel.GetCurrentChain() == 0 then
            Duel.SetChainLimitTillChainEnd(function(e, rp, tp) return tp == rp end)
        elseif Duel.GetCurrentChain() == 1 then
            c:RegisterFlagEffect(id, RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END, 0, 1)
            local ec1 = Effect.CreateEffect(c)
            ec1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
            ec1:SetCode(EVENT_CHAINING)
            ec1:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
                e:GetHandler():ResetFlagEffect(id)
                e:Reset()
            end)
            Duel.RegisterEffect(ec1, tp)
            local ec1b = ec1:Clone()
            ec1b:SetCode(EVENT_BREAK_EFFECT)
            ec1b:SetReset(RESET_CHAIN)
            Duel.RegisterEffect(ec1b, tp)
        end
    end)
    ec2:SetReset(RESET_PHASE + PHASE_END)
    Duel.RegisterEffect(ec2, tp)

    local ec3 = Effect.CreateEffect(c)
    ec3:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    ec3:SetCode(EVENT_CHAIN_END)
    ec3:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
        local c = e:GetHandler()
        if c:GetFlagEffect(id) ~= 0 then Duel.SetChainLimitTillChainEnd(function(e, rp, tp) return tp == rp end) end
        c:ResetFlagEffect(id)
    end)
    ec3:SetReset(RESET_PHASE + PHASE_END)
    Duel.RegisterEffect(ec3, tp)
end

function s.e3filter(c) return not c:IsCode(id) and c:IsSetCard(SET_FUSION) and c:IsType(TYPE_SPELL) and c:IsAbleToHand() end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.e3filter, tp, LOCATION_DECK + LOCATION_GRAVE, 0, 1, c) and c:IsAbleToDeck()
    end

    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK + LOCATION_GRAVE)
    Duel.SetOperationInfo(0, CATEGORY_TODECK, c, 1, 0, 0)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc =
        Utility.SelectMatchingCard(HINTMSG_ATOHAND, tp, s.e3filter, tp, LOCATION_DECK + LOCATION_GRAVE, 0, 1, 1, c):GetFirst()
    if not tc or Duel.SendtoHand(tc, nil, REASON_EFFECT) == 0 then return end
    Duel.ConfirmCards(1 - tp, tc)
    if tc:IsPreviousLocation(LOCATION_DECK) then Duel.ShuffleDeck(tp) end

    if c:IsRelateToEffect(e) then
        Duel.BreakEffect()
        Duel.SendtoDeck(c, nil, SEQ_DECKBOTTOM, REASON_EFFECT)
    end
end
