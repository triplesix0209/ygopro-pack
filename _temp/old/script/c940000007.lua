-- Rank-Up-Magic Barian's Pride
Duel.LoadScript("util.lua")
Duel.LoadScript("util_xyz.lua")
local s, id = GetID()

s.listed_series = {0x1048}

function s.initial_effect(c)
    -- rank-up
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1, id, EFFECT_COUNT_CODE_OATH)
    e1:SetCondition(s.e1con)
    e1:SetCost(s.e1cost)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- to hand
    local e2 = Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_TOHAND)
    e2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_PREDRAW)
    e2:SetRange(LOCATION_DECK + LOCATION_GRAVE)
    e2:SetCondition(s.e2con)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)
end

function s.deck_edit(tp)
    if not Duel.IsExistingMatchingCard(Card.IsCode, tp, LOCATION_ALL, 0, 1, nil,
                                       67926903) then return end

    Utility.DeckEditAddCardToDeck(tp, 48739166) -- Number 101
    Utility.DeckEditAddCardToDeck(tp, 12744567, 48739166) -- Number C101
    Utility.DeckEditAddCardToDeck(tp, 49678559) -- Number 102
    Utility.DeckEditAddCardToDeck(tp, 67173574, 49678559) -- Number C102
    Utility.DeckEditAddCardToDeck(tp, 94380860) -- Number 103
    Utility.DeckEditAddCardToDeck(tp, 20785975, 94380860) -- Number C103
    Utility.DeckEditAddCardToDeck(tp, 2061963) -- Number 104
    Utility.DeckEditAddCardToDeck(tp, 49456901, 2061963) -- Number C104
    Utility.DeckEditAddCardToDeck(tp, 59627393) -- Number 105
    Utility.DeckEditAddCardToDeck(tp, 85121942, 59627393) -- Number C105
    Utility.DeckEditAddCardToDeck(tp, 63746411) -- Number 106
    Utility.DeckEditAddCardToDeck(tp, 55888045, 63746411) -- Number C106
    Utility.DeckEditAddCardToDeck(tp, 88177324) -- Number 107
    Utility.DeckEditAddCardToDeck(tp, 68396121, 88177324) -- Number C107
end

function s.e1filter1(c, e, tp)
    local m = c:GetMetatable(true)
    if not m then return false end
    local no = m.xyz_number
    local pg = aux.GetMustBeMaterialGroup(tp, Group.FromCards(c), tp, nil, nil,
                                          REASON_XYZ)
    if not (#pg <= 0 or (#pg == 1 and pg:IsContains(c))) or not no or no < 101 or
        no > 107 or not c:IsType(TYPE_XYZ) or c:IsSetCard(0x1048) or
        not Duel.IsExistingMatchingCard(s.e1filter2, tp, LOCATION_EXTRA, 0, 1,
                                        nil, e, tp, c) then return false end

    if c:IsLocation(LOCATION_MZONE) then return c:IsFaceup() end
    if not c:IsCanBeSpecialSummoned(e, SUMMON_TYPE_XYZ, tp, true, true) then
        return false
    end
    return (c:IsLocation(LOCATION_GRAVE) and
               Duel.GetLocationCount(tp, LOCATION_MZONE) > 0) or
               (c:IsLocation(LOCATION_EXTRA) and aux.CheckSummonGate(tp, 2) and
                   Duel.GetLocationCountFromEx(tp, tp, nil, c) > 0)
end

function s.e1filter2(c, e, tp, mc)
    if c.rum_limit and not c.rum_limit(mc, e) then return false end
    local m = mc:GetMetatable(true)
    return mc:IsCanBeXyzMaterial(c, tp) and
               Duel.GetLocationCountFromEx(tp, tp, mc, c) > 0 and
               c:IsCanBeSpecialSummoned(e, SUMMON_TYPE_XYZ, tp, false, false) and
               m.xyz_number and c.xyz_number == m.xyz_number and
               c:IsSetCard(0x1048)
end

function s.e1con(e, tp, eg, ep, ev, re, r, rp)
    return Duel.GetCurrentPhase() & PHASE_MAIN1 + PHASE_MAIN2 > 0
end

function s.e1cost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return Duel.GetActivityCount(tp, ACTIVITY_SPSUMMON) == 0 end

    local ec1 = Effect.CreateEffect(c)
    ec1:SetDescription(aux.Stringid(id, 0))
    ec1:SetType(EFFECT_TYPE_FIELD)
    ec1:SetProperty(EFFECT_FLAG_PLAYER_TARGET + EFFECT_FLAG_CLIENT_HINT +
                        EFFECT_FLAG_OATH)
    ec1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    ec1:SetTargetRange(1, 0)
    ec1:SetTarget(function(e, c) return not c:IsType(TYPE_XYZ) end)
    ec1:SetReset(RESET_PHASE + PHASE_END)
    Duel.RegisterEffect(ec1, tp)
    aux.addTempLizardCheck(c, tp, function(e, c)
        return not c:IsOriginalType(TYPE_XYZ)
    end)
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    local loc = LOCATION_MZONE + LOCATION_GRAVE + LOCATION_EXTRA
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.e1filter1, tp, loc, 0, 1, nil, e,
                                           tp)
    end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SELECT)
    local tc = Duel.SelectMatchingCard(tp, s.e1filter1, tp, loc, 0, 1, 1, nil,
                                       e, tp):GetFirst()
    if not tc:IsLocation(LOCATION_MZONE) then
        Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, tc, 1, tp, nil)
    end

    Duel.SetTargetCard(tc)
    if tc:IsLocation(LOCATION_ONFIELD) then
        Duel.HintSelection(Group.FromCards(tc))
    end

    if tc:IsLocation(LOCATION_EXTRA) then
        Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 2, tp,
                              LOCATION_EXTRA)
    else
        Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp,
                              LOCATION_EXTRA)
    end
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local tc = Duel.GetFirstTarget()
    if not tc or not tc:IsRelateToEffect(e) then return end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
    local sc = Duel.SelectMatchingCard(tp, s.e1filter2, tp, LOCATION_EXTRA, 0,
                                       1, 1, tc, e, tp, tc):GetFirst()
    if not sc then return end

    if tc:IsLocation(LOCATION_GRAVE + LOCATION_EXTRA) then
        if not Duel.IsPlayerCanSpecialSummonCount(tp, 2) then return end
        if tc:IsLocation(LOCATION_GRAVE) and
            (Duel.GetLocationCount(tp, LOCATION_MZONE) <= 0 or
                tc:IsHasEffect(EFFECT_NECRO_VALLEY)) then return end
        if tc:IsLocation(LOCATION_EXTRA) and
            Duel.GetLocationCountFromEx(tp, tp, nil, tc) <= 0 then return end
        Duel.SpecialSummon(tc, SUMMON_TYPE_XYZ, tp, tp, true, true, POS_FACEUP)
        tc:CompleteProcedure()
        Duel.BreakEffect()
    else
        local pg = aux.GetMustBeMaterialGroup(tp, Group.FromCards(tc), tp, nil,
                                              nil, REASON_XYZ)
        if tc:IsFacedown() or tc:IsControler(1 - tp) or tc:IsImmuneToEffect(e) or
            #pg > 1 or (#pg == 1 and not pg:IsContains(tc)) then return end
    end

    sc:SetMaterial(Group.FromCards(tc))
    UtilXyz.Overlay(sc, tc, true)
    Duel.SpecialSummon(sc, SUMMON_TYPE_XYZ, tp, tp, false, false, POS_FACEUP)
    sc:CompleteProcedure()
end

function s.e2con(e, tp, eg, ep, ev, re, r, rp)
    return tp == Duel.GetTurnPlayer() and
               Duel.GetFieldGroupCount(tp, LOCATION_DECK, 0) > 0 and
               Duel.GetDrawCount(tp) > 0 and
               Duel.GetFieldGroupCount(tp, LOCATION_MZONE, 0) == 0
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return c:IsAbleToHand() end

    local dt = Duel.GetDrawCount(tp)
    if dt ~= 0 then
        _replace_count = 0
        _replace_max = dt
        local ec1 = Effect.CreateEffect(c)
        ec1:SetType(EFFECT_TYPE_FIELD)
        ec1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
        ec1:SetCode(EFFECT_DRAW_COUNT)
        ec1:SetTargetRange(1, 0)
        ec1:SetValue(0)
        ec1:SetReset(RESET_PHASE + PHASE_DRAW)
        Duel.RegisterEffect(ec1, tp)
    end

    Duel.SetOperationInfo(0, CATEGORY_TOHAND, c, 1, 0, 0)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    _replace_count = _replace_count + 1
    if _replace_count <= _replace_max and c:IsRelateToEffect(e) then
        Duel.SendtoHand(c, nil, REASON_EFFECT)
        Duel.ConfirmCards(1 - tp, c)
    end
end
