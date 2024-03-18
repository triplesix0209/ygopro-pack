-- Stormcode Talker
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_series = {SET_CODE_TALKER}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- link summon
    Link.AddProcedure(c, aux.FilterBoolFunctionEx(Card.IsRace, RACE_CYBERSE), 2)

    -- search from deck
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetCountLimit(1, {id, 1})
    e1:SetCondition(s.e1con)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- cannot be attacked
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e2:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCondition(function(e) return e:GetHandler():IsInExtraMZone() end)
    e2:SetValue(aux.imval1)
    c:RegisterEffect(e2)

    -- shuffle monster into the Deck and then special summon
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 0))
    e3:SetCategory(CATEGORY_TODECK + CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetProperty(EFFECT_FLAG_NO_TURN_RESET)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1, {id, 2})
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)
end

function s.e1filter(c) return c:ListsArchetype(SET_CODE_TALKER) and c:IsAbleToHand() end

function s.e1con(e) return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK) end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.e1filter, tp, LOCATION_DECK, 0, 1, nil) end
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local g = Utility.SelectMatchingCard(HINTMSG_ATOHAND, tp, s.e1filter, tp, LOCATION_DECK, 0, 1, 1, nil)
    if #g > 0 then
        Duel.SendtoHand(g, nil, REASON_EFFECT)
        Duel.ConfirmCards(1 - tp, g)
    end
end

function s.e3filter1(c, e, tp)
    return e:GetHandler():GetLinkedGroup():IsContains(c) and c:IsLinkMonster() and c:IsAbleToExtra() and
               Duel.IsExistingMatchingCard(s.e3filter2, tp, LOCATION_EXTRA, 0, 1, nil, e, tp, c)
end

function s.e3filter2(c, e, tp, mc)
    return c:IsSetCard(SET_CODE_TALKER) and c:IsLink(3) and not c:IsCode(id) and not c:IsCode(mc:GetCode()) and
               c:IsCanBeSpecialSummoned(e, SUMMON_TYPE_LINK, tp, false, false) and Duel.GetLocationCountFromEx(tp, tp, mc, c) > 0
end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return Duel.IsExistingMatchingCard(s.e3filter1, tp, LOCATION_MZONE, 0, 1, c, e, tp) end

    Duel.SetOperationInfo(0, CATEGORY_TODECK, nil, 1, tp, LOCATION_MZONE)
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_EXTRA)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Utility.SelectMatchingCard(HINTMSG_TODECK, tp, s.e3filter1, tp, LOCATION_MZONE, 0, 1, 1, c, e, tp):GetFirst()

    if tc then
        Duel.ConfirmCards(1 - tp, tc)
        if Duel.SendtoDeck(tc, tp, 2, REASON_EFFECT) ~= 0 and Duel.IsExistingMatchingCard(s.e3filter2, tp, LOCATION_EXTRA, 0, 1, nil, e, tp, tc) then
            local sc = Utility.SelectMatchingCard(HINTMSG_SPSUMMON, tp, s.e3filter2, tp, LOCATION_EXTRA, 0, 1, 1, nil, e, tp, tc):GetFirst()
            if sc then
                Duel.SpecialSummon(sc, SUMMON_TYPE_LINK, tp, tp, false, false, POS_FACEUP)
                sc:CompleteProcedure()
            end
        end
    end
end
