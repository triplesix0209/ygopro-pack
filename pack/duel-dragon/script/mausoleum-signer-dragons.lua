-- Mausoleum of the Signer Dragons
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {CARD_CRIMSON_DRAGON}

function s.initial_effect(c)
    -- activate
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_TODECK)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- cannot disable summon
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetProperty(EFFECT_FLAG_IGNORE_RANGE + EFFECT_FLAG_SET_AVAILABLE)
    e2:SetCode(EFFECT_CANNOT_DISABLE_SPSUMMON)
    e2:SetRange(LOCATION_FZONE)
    e2:SetTarget(function(e, c) return c:IsRace(RACE_DRAGON) and c:IsType(TYPE_SYNCHRO) and c:IsControler(e:GetHandlerPlayer()) end)
    c:RegisterEffect(e2)

    -- cannot to extra
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetCode(EFFECT_CANNOT_TO_DECK)
    e3:SetRange(LOCATION_FZONE)
    e3:SetTargetRange(LOCATION_ONFIELD, LOCATION_ONFIELD)
    e3:SetTarget(function(e, c)
        local tp = e:GetHandlerPlayer()
        local mt = c:GetMetatable()
        local ct = 0
        if mt.synchro_tuner_required then ct = ct + mt.synchro_tuner_required end
        if mt.synchro_nt_required then ct = ct + mt.synchro_nt_required end
        return c:IsFaceup() and c:IsControler(tp) and c:IsRace(RACE_DRAGON) and c:IsType(TYPE_SYNCHRO) and ct > 0
    end)
    e3:SetValue(1)
    c:RegisterEffect(e3)

    -- draw
    local e4 = Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id, 1))
    e4:SetCategory(CATEGORY_DRAW)
    e4:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    e4:SetProperty(EFFECT_FLAG_DELAY + EFFECT_FLAG_PLAYER_TARGET)
    e4:SetCode(EVENT_SPSUMMON_SUCCESS)
    e4:SetRange(LOCATION_FZONE)
    e4:SetCondition(s.e4con)
    e4:SetTarget(s.e4tg)
    e4:SetOperation(s.e4op)
    c:RegisterEffect(e4)

    -- special summon
    local e5 = Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(id, 2))
    e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e5:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    e5:SetProperty(EFFECT_FLAG_DELAY)
    e5:SetCode(EVENT_LEAVE_FIELD)
    e5:SetRange(LOCATION_FZONE)
    e5:SetCountLimit(1, id)
    e5:SetTarget(s.e5tg)
    e5:SetOperation(s.e5op)
    c:RegisterEffect(e5)

    -- special summon the crimson dragon
    local e6 = Effect.CreateEffect(c)
    e6:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e6:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e6:SetProperty(EFFECT_FLAG_DELAY)
    e6:SetCode(EVENT_DESTROYED)
    e6:SetCondition(s.e6con)
    e6:SetTarget(s.e6tg)
    e6:SetOperation(s.e6op)
    c:RegisterEffect(e6)
end

function s.e1filter(c) return c:IsSpellTrap() and c:ListsCode(CARD_CRIMSON_DRAGON) and not c:IsCode(id) and c:IsAbleToHand() end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) then return end

    local g = Duel.GetMatchingGroup(s.e1filter, tp, LOCATION_DECK, 0, nil)
    if #g == 0 or not Duel.SelectEffectYesNo(tp, c, aux.Stringid(id, 0)) then return end

    local tc = Utility.GroupSelect(HINTMSG_ATOHAND, g, tp, 1, 1, nil):GetFirst()
    Duel.SendtoHand(tc, nil, REASON_EFFECT)
    Duel.ConfirmCards(1 - tp, tc)
end

function s.e4filter(c, tp) return c:IsFaceup() and c:IsSummonPlayer(tp) and c:IsSummonType(SUMMON_TYPE_SYNCHRO) and c:IsRace(RACE_DRAGON) end

function s.e4con(e, tp, eg, ep, ev, re, r, rp) return eg:IsExists(s.e4filter, 1, e:GetHandler(), tp) end

function s.e4tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsPlayerCanDraw(tp, 1) end

    Duel.SetTargetPlayer(tp)
    Duel.SetTargetParam(1)
    Duel.SetOperationInfo(0, CATEGORY_DRAW, nil, 0, tp, 1)
end

function s.e4op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) then return end

    local p, d = Duel.GetChainInfo(0, CHAININFO_TARGET_PLAYER, CHAININFO_TARGET_PARAM)
    Duel.Draw(p, d, REASON_EFFECT)
end

function s.e5filter(c, e, tp, r, rp)
    return c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousControler(tp) and (c:IsRace(RACE_DRAGON) and c:IsType(TYPE_SYNCHRO)) and rp == tp and
               ((r & REASON_EFFECT) == REASON_EFFECT or (r & REASON_COST) == REASON_COST) and c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end

function s.e5tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return eg:IsExists(s.e5filter, 1, nil, e, tp, r, rp) end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_GRAVE + LOCATION_REMOVED)
end

function s.e5op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) then return end

    local g = eg:Filter(s.e5filter, nil, e, tp, r, rp)
    local tc = Utility.GroupSelect(HINTMSG_SPSUMMON, g, tp, 1, 1, nil):GetFirst()
    Duel.SpecialSummon(tc, 0, tp, tp, false, false, POS_FACEUP)
end

function s.e6filter(c, e, tp)
    return c:IsCode(CARD_CRIMSON_DRAGON) and Duel.GetLocationCountFromEx(tp, tp, nil, c) > 0 and c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end

function s.e6con(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    return rp == 1 - tp and c:IsReason(REASON_EFFECT) and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_ONFIELD)
end

function s.e6tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.e6filter, tp, LOCATION_EXTRA, 0, 1, nil, e, tp) end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_EXTRA)
end

function s.e6op(e, tp, eg, ep, ev, re, r, rp)
    local g = Utility.SelectMatchingCard(HINTMSG_SPSUMMON, tp, s.e6filter, tp, LOCATION_EXTRA, 0, 1, 1, nil, e, tp)
    if #g > 0 then Duel.SpecialSummon(g, 0, tp, tp, false, false, POS_FACEUP) end
end
