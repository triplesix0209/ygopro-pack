-- Millennium Hieroglyph
Duel.LoadScript("util.lua")

local s, id = GetID()

s.owner = -1
s.destiny_draw = 0

function s.initial_effect(c)
    local startup = Effect.CreateEffect(c)
    startup:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    startup:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    startup:SetCode(EVENT_STARTUP)
    startup:SetRange(LOCATION_ALL)
    startup:SetOperation(s.startup)
    c:RegisterEffect(startup)
end

function s.startup(e, tp, eg, ep, ev, re, r, rp)
    s.owner = e:GetOwnerPlayer()
    local c = e:GetHandler()

    -- remove from duel
    Duel.DisableShuffleCheck(true)
    Duel.SendtoDeck(c, tp, -2, REASON_RULE)
    if c:IsPreviousLocation(LOCATION_HAND) and Duel.GetFieldGroupCount(tp, LOCATION_DECK, 0) > 0 then
        Duel.Draw(p, 1, REASON_RULE)
    end
    e:Reset()

    -- deck edit & global effect
    local g = Duel.GetMatchingGroup(function(c) return c.deck_edit or c.global_effect end, tp, LOCATION_ALL, 0, nil)
    local deck_edit = Group.CreateGroup()
    local global_effect = Group.CreateGroup()
    for tc in aux.Next(g) do
        if tc.deck_edit and not deck_edit:IsExists(function(c) return c:GetOriginalCode() == tc:GetOriginalCode() end, 1, nil) then
            tc.deck_edit(tp)
            deck_edit:AddCard(tc)
        end

        Duel.ShuffleDeck(tp)
    end
    for tc in aux.Next(g) do
        if tc.global_effect and
            not global_effect:IsExists(function(c) return c:GetOriginalCode() == tc:GetOriginalCode() end, 1, nil) then
            tc.global_effect(tc, tp)
            global_effect:AddCard(tc)
        end
    end

    -- mulligan
    local mulligan = Effect.CreateEffect(c)
    mulligan:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    mulligan:SetCode(EVENT_ADJUST)
    mulligan:SetCountLimit(1, id, EFFECT_COUNT_CODE_DUEL)
    mulligan:SetCondition(function() return Duel.GetTurnCount() == 1 end)
    mulligan:SetOperation(function(e, tp)
        if Duel.GetFieldGroupCount(tp, LOCATION_HAND, 0) > 0 and Duel.GetFieldGroupCount(tp, LOCATION_DECK, 0) > 0 and
            Duel.SelectYesNo(tp, aux.Stringid(id, 0)) then
            local max = Duel.GetFieldGroupCount(tp, LOCATION_HAND, 0)
            local g = Utility.SelectMatchingCard(HINTMSG_TODECK, tp, aux.TRUE, tp, LOCATION_HAND, 0, 1, max, nil)
            local ct = Duel.SendtoDeck(g, nil, SEQ_DECKBOTTOM, REASON_RULE)
            Duel.Draw(tp, ct, REASON_RULE)
            Duel.ShuffleDeck(tp)
        end

        s.destiny_draw = 1
    end)
    Duel.RegisterEffect(mulligan, tp)

    -- place field
    local field = Effect.CreateEffect(c)
    field:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    field:SetCode(EVENT_ADJUST)
    field:SetCountLimit(1)
    field:SetCondition(function(e, tp) return Duel.IsTurnPlayer(tp) and Duel.GetCurrentPhase() == PHASE_DRAW end)
    field:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
        local g = Duel.GetMatchingGroup(function(c)
            return c:IsType(TYPE_FIELD) and Utility.CheckActivateEffectCanApply(c, e, tp, false, true, false)
        end, tp, LOCATION_HAND + LOCATION_DECK + LOCATION_GRAVE + LOCATION_REMOVED, 0, nil)
        if Duel.IsExistingMatchingCard(Card.IsFaceup, tp, LOCATION_FZONE, 0, 1, nil) or #g == 0 or
            not Duel.SelectYesNo(tp, aux.Stringid(id, 1)) then return end

        local sc = Utility.GroupSelect(HINTMSG_TOFIELD, g, tp):GetFirst()
        Duel.ActivateFieldSpell(sc, e, tp, eg, ep, ev, re, r, rp)
        Utility.ApplyActivateEffect(sc, e, tp, false, true, false)

        if sc:IsPreviousLocation(LOCATION_HAND) and Duel.GetTurnCount() <= 2 and Duel.GetFieldGroupCount(tp, LOCATION_DECK, 0) > 0 then
            Duel.Draw(tp, 1, REASON_RULE)
        end
    end)
    Duel.RegisterEffect(field, tp)

    -- destiny draw (draw phase)
    local ddraw = Effect.CreateEffect(c)
    ddraw:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    ddraw:SetCode(EVENT_PREDRAW)
    ddraw:SetCountLimit(1)
    ddraw:SetCondition(function(e, tp)
        return s.destiny_draw == 1 and Duel.IsTurnPlayer(tp) and Duel.GetFieldGroupCount(tp, LOCATION_DECK, 0) > 1 and
                   Duel.GetTurnCount() > 1
    end)
    ddraw:SetOperation(function(e, tp, eg, ep, ev, re, r, rp) s.DestinySequenceDeck(tp, Duel.GetDrawCount(tp), 2) end)
    Duel.RegisterEffect(ddraw, tp)
end

function s.DestinySequenceDeck(tp, count, string_id)
    if count == 0 or not Duel.SelectYesNo(tp, aux.Stringid(id, string_id)) then return end

    local g = Utility.SelectMatchingCard(HINTMSG_SELECT, tp, aux.TRUE, tp, LOCATION_DECK, 0, count, count, nil)
    for tc in aux.Next(g) do Duel.MoveSequence(tc, 0) end
end

local base_draw = Duel.Draw
Duel.Draw = function(...)
    local tb = {...}
    local tp = tb[1]
    local count = tb[2]
    if s.destiny_draw == 1 and tp == s.owner then s.DestinySequenceDeck(tp, count, 2) end
    return base_draw(...)
end

local base_confirmDecktop = Duel.ConfirmDecktop
Duel.ConfirmDecktop = function(...)
    local tb = {...}
    local tp = tb[1]
    local count = tb[2]

    if tp == s.owner then s.DestinySequenceDeck(tp, count, 3) end
    return base_confirmDecktop(...)
end
