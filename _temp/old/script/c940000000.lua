-- The Last Hope Remain
local s, id = GetID()
Duel.LoadScript("util.lua")
Duel.LoadScript("util_xyz.lua")

s.listed_names = {94770493}
s.listed_series = {0x54, 0x59, 0x82, 0x8f, 0x7e, 0x107e, 0x207e, 0x48, 0x16c}

function s.initial_effect(c)
    -- activate
    local act = Effect.CreateEffect(c)
    act:SetType(EFFECT_TYPE_ACTIVATE)
    act:SetProperty(EFFECT_FLAG_CANNOT_INACTIVATE + EFFECT_FLAG_CANNOT_DISABLE +
                        EFFECT_FLAG_CANNOT_NEGATE)
    act:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(act)

    -- double xyz material
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e1:SetCode(511001225)
    e1:SetRange(LOCATION_FZONE)
    e1:SetTargetRange(LOCATION_MZONE, 0)
    e1:SetTarget(function(e, tc)
        return tc:IsFaceup() and (tc:IsCode(69852487, 64591429, 940000006) or
                   Utility.IsSetCard(tc, 0x54, 0x59, 0x82, 0x8f))
    end)
    e1:SetValue(1)
    c:RegisterEffect(e1)

    -- act limit
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EVENT_CHAINING)
    e2:SetRange(LOCATION_FZONE)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)

    -- attach
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e3:SetCode(EVENT_SPSUMMON_SUCCESS)
    e3:SetRange(LOCATION_FZONE)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)

    -- search
    local e4 = Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id, 1))
    e4:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH)
    e4:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    e4:SetProperty(EFFECT_FLAG_CANNOT_INACTIVATE + EFFECT_FLAG_CANNOT_DISABLE +
                       EFFECT_FLAG_CANNOT_NEGATE)
    e4:SetCode(EVENT_PREDRAW)
    e4:SetRange(LOCATION_FZONE)
    e4:SetCountLimit(1)
    e4:SetCondition(s.e4con)
    e4:SetTarget(s.e4tg)
    e4:SetOperation(s.e4op)
    c:RegisterEffect(e4)

    -- shuffle
    local e5 = Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(id, 2))
    e5:SetCategory(CATEGORY_TODECK + CATEGORY_SEARCH + CATEGORY_TOHAND)
    e5:SetType(EFFECT_TYPE_IGNITION)
    e5:SetProperty(EFFECT_FLAG_CANNOT_INACTIVATE + EFFECT_FLAG_CANNOT_DISABLE +
                       EFFECT_FLAG_CANNOT_NEGATE)
    e5:SetRange(LOCATION_FZONE)
    e5:SetCountLimit(1, id)
    e5:SetTarget(s.e5tg)
    e5:SetOperation(s.e5op)
    c:RegisterEffect(e5)
end

function s.deck_edit(tp)
    Utility.DeckEditAddCardToDeck(tp, 52653092) -- Number S0: Utopic ZEXAL
    Utility.DeckEditAddCardToDeck(tp, 60992364) -- ZW - Leo Arms
    Utility.DeckEditAddCardToDeck(tp, 2896663) -- ZW - Dragonic Halberd
    Utility.DeckEditAddCardToDeck(tp, 31123642) -- ZS - Utopic Sage
end

function s.e2filter(c, tp)
    return c:IsControler(tp) and c:IsFaceup() and c:IsType(TYPE_XYZ)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
    local g = Duel.GetChainInfo(ev, CHAININFO_TARGET_CARDS)
    if ep == tp and g and g:IsExists(s.e2filter, 1, nil, tp) then
        Duel.SetChainLimit(function(e, rp, tp) return tp == rp end)
    end
end

function s.e3filter1(c, tp)
    return c:IsControler(tp) and c:IsFaceup() and c:IsType(TYPE_XYZ)
end

function s.e3filter2(c) return c:IsType(TYPE_XYZ) and c:IsSetCard(0x48) end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local g = eg:Filter(s.e3filter1, nil, tp)
    if #g == 0 or not Duel.IsExistingMatchingCard(s.e3filter2, tp,
                                                  LOCATION_GRAVE +
                                                      LOCATION_EXTRA, 0, 1, nil) or
        not Duel.SelectYesNo(tp, aux.Stringid(id, 0)) then return end

    local tc = Utility.GroupSelect(g, tp, 1, nil, HINTMSG_FACEUP):GetFirst()
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_XMATERIAL)
    local mg = Duel.SelectMatchingCard(tp, aux.NecroValleyFilter(s.e3filter2),
                                       tp, LOCATION_GRAVE + LOCATION_EXTRA, 0,
                                       1, 1, tc)
    if #mg > 0 then UtilXyz.Overlay(tc, mg) end
end

function s.e4filter(c)
    return c:IsAbleToHand() and c:IsType(TYPE_SPELL) and
               Utility.IsSetCard(c, 0x95, 0x15d)
end

function s.e4con(e, tp, eg, ep, ev, re, r, rp)
    return Duel.GetTurnPlayer() == tp and
               Duel.GetFieldGroupCount(tp, LOCATION_DECK, 0) > 0 and
               Duel.GetDrawCount(tp) > 0
end

function s.e4tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.e4filter, tp, LOCATION_DECK, 0, 1,
                                           nil)
    end

    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, 0, LOCATION_DECK)
end

function s.e4op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) then return end

    local dt = Duel.GetDrawCount(tp)
    if dt == 0 then return false end
    _replace_count = 1
    _replace_max = dt
    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_FIELD)
    ec1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    ec1:SetCode(EFFECT_DRAW_COUNT)
    ec1:SetTargetRange(1, 0)
    ec1:SetValue(0)
    ec1:SetReset(RESET_PHASE + PHASE_DRAW)
    Duel.RegisterEffect(ec1, tp)
    if _replace_count > _replace_max or not c:IsRelateToEffect(e) then return end

    local g = Duel.GetMatchingGroup(s.e4filter, tp, LOCATION_DECK, 0, nil)
    g = Utility.GroupSelect(g, tp, 1, nil, HINTMSG_ATOHAND)
    if #g > 0 then
        Duel.SendtoHand(g, nil, REASON_EFFECT)
        Duel.ConfirmCards(1 - tp, g)
    end
end

function s.e5filter1(c)
    if c:IsLocation(LOCATION_REMOVED) and c:IsFacedown() then return false end
    if not c:IsAbleToDeck() then return false end
    return c:IsCode(94770493) or
               Utility.IsSetCard(c, 0x7e, 0x107e, 0x207e, 0x48, 0x16c)
end

function s.e5filter2(c)
    return c:IsAbleToHand() and c:IsType(TYPE_MONSTER) and
               (c:IsCode(69852487, 64591429, 940000006) or
                   Utility.IsSetCard(c, 0x54, 0x59, 0x82, 0x8f))
end

function s.e5tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local loc = LOCATION_REMOVED + LOCATION_HAND + LOCATION_GRAVE
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.e5filter1, tp, loc, 0, 1, nil)
    end

    Duel.SetOperationInfo(0, CATEGORY_TODECK, nil, 1, tp, loc)
end

function s.e5op(e, tp, eg, ep, ev, re, r, rp)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TODECK)
    local g = Duel.SelectMatchingCard(tp, s.e5filter1, tp, LOCATION_REMOVED +
                                          LOCATION_HAND + LOCATION_GRAVE, 0, 1,
                                      1, nil)
    if Duel.SendtoDeck(g, nil, SEQ_DECKSHUFFLE, REASON_EFFECT) == 0 then
        return
    end

    if (Duel.IsExistingMatchingCard(s.e5filter2, tp,
                                    LOCATION_DECK + LOCATION_GRAVE, 0, 1, nil) and
        Duel.SelectYesNo(tp, 573)) then
        Duel.BreakEffect()
        Duel.Hint(HINT_SELECTMSG, tp, 573)
        local sg = Duel.SelectMatchingCard(tp,
                                           aux.NecroValleyFilter(s.e5filter2),
                                           tp, LOCATION_DECK + LOCATION_GRAVE,
                                           0, 1, 1, nil)
        if #sg > 0 then
            Duel.SendtoHand(sg, tp, REASON_EFFECT)
            Duel.ConfirmCards(1 - tp, sg)
        end
    end
end
