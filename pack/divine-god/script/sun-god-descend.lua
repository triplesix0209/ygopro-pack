-- Sun God Descend
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {CARD_RA}

function s.initial_effect(c)
    local EFFECT_FLAG_CANNOT_NEGATE_ACTIV_EFF = EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_CANNOT_NEGATE +
                                                    EFFECT_FLAG_CANNOT_INACTIVATE

    -- special summon
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetProperty(EFFECT_FLAG_CANNOT_NEGATE_ACTIV_EFF)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetHintTiming(0, TIMING_MAIN_END)
    e1:SetCountLimit(1, {id, 1})
    e1:SetCondition(s.e1con)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- recycle
    local e2 = Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_TODECK + CATEGORY_DRAW)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetProperty(EFFECT_FLAG_CANNOT_NEGATE_ACTIV_EFF + EFFECT_FLAG_CARD_TARGET)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1, {id, 2})
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)
end

function s.e1filter1(c, e, tp)
    local ft = Duel.GetLocationCount(tp, LOCATION_MZONE)
    local check1 = Duel.CheckReleaseGroup(tp, s.e1filter2, 3, nil, ft, tp)
    local check2 = ft > 0 and Duel.CheckReleaseGroup(tp, Card.IsControler, 3, false, 3, false, nil, tp, 0xff, true, nil, 1 - tp)
    return c:IsCode(CARD_RA) and c:IsCanBeSpecialSummoned(e, 0, tp, true, false) and (check1 or check2)
end

function s.e1filter2(c, ft, tp) return ft > 0 or (c:IsControler(tp) and c:GetSequence() < 5) end

function s.e1con(e, tp, eg, ep, ev, re, r, rp) return Duel.IsMainPhase() end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.GetMatchingGroupCount(s.e1filter1, tp, LOCATION_HAND + LOCATION_DECK, 0, nil, e, tp) > 0 end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_HAND + LOCATION_DECK)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local ft = Duel.GetLocationCount(tp, LOCATION_MZONE)
    local check1 = Duel.CheckReleaseGroup(tp, s.e1filter2, 3, nil, ft, tp)
    local check2 = ft > 0 and Duel.CheckReleaseGroup(tp, Card.IsControler, 3, false, 3, false, nil, tp, 0xff, true, nil, 1 - tp)
    if not check1 and not check2 then return end

    local tc = Utility.SelectMatchingCard(HINTMSG_SPSUMMON, tp, s.e1filter1, tp, LOCATION_HAND + LOCATION_DECK, 0, 1, 1, nil, e,
        tp):GetFirst()
    local op = Duel.SelectEffect(tp, {check1, aux.Stringid(id, 0)}, {check2, aux.Stringid(id, 1)})
    local g = Group.CreateGroup()
    if op == 1 then
        g = Duel.SelectReleaseGroup(tp, s.e1filter2, 3, 3, nil, ft, tp)
    else
        g = Duel.SelectReleaseGroup(tp, Card.IsControler, 3, 3, false, false, false, nil, tp, 0xff, true, nil, 1 - tp)
    end

    local atk = 0
    local def = 0
    for mc in aux.Next(g) do
        atk = atk + mc:GetAttack()
        def = def + mc:GetDefense()
    end

    if tc and Duel.Release(g, REASON_EFFECT) == 3 and Duel.SpecialSummonStep(tc, 0, tp, tp, true, false, POS_FACEUP) then
        local ec1 = Effect.CreateEffect(c)
        ec1:SetType(EFFECT_TYPE_SINGLE)
        ec1:SetCode(EFFECT_SET_BASE_ATTACK)
        ec1:SetValue(atk)
        ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
        tc:RegisterEffect(ec1)
        local ec1b = ec1:Clone()
        ec1b:SetCode(EFFECT_SET_BASE_DEFENSE)
        ec1b:SetValue(def)
        tc:RegisterEffect(ec1b)

        if op == 2 then
            local ec2 = Effect.CreateEffect(c)
            ec2:SetDescription(3206)
            ec2:SetType(EFFECT_TYPE_SINGLE)
            ec2:SetProperty(EFFECT_FLAG_CLIENT_HINT)
            ec2:SetCode(EFFECT_CANNOT_ATTACK)
            ec2:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
            tc:RegisterEffect(ec2)
        end
    end
    Duel.SpecialSummonComplete()
end

function s.e2filter(c)
    return c:IsFaceup() and (c:IsCode(CARD_RA) or c:ListsCode(CARD_RA)) and not c:IsCode(id) and c:IsAbleToDeck()
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    local c = e:GetHandler()
    if chk == 0 then
        return Duel.IsExistingTarget(s.e2filter, tp, LOCATION_GRAVE + LOCATION_REMOVED, 0, 1, nil) and c:IsFaceup() and
                   c:IsAbleToDeck() and Duel.IsPlayerCanDraw(tp, 1)
    end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TODECK)
    local g = Duel.SelectTarget(tp, s.e2filter, tp, LOCATION_GRAVE + LOCATION_REMOVED, 0, 1, 1, nil)
    g:AddCard(c)

    Duel.SetOperationInfo(0, CATEGORY_TODECK, g, #g, 0, 0)
    Duel.SetOperationInfo(0, CATEGORY_DRAW, nil, 0, tp, 1)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Duel.GetFirstTarget()
    if not c:IsRelateToEffect(e) or not tc:IsRelateToEffect(e) then return end

    local g = Group.FromCards(c, tc)
    if Duel.SendtoDeck(g, nil, SEQ_DECKSHUFFLE, REASON_EFFECT) == #g then
        Duel.BreakEffect()
        Duel.Draw(tp, 1, REASON_EFFECT)
    end
end
