-- Storm Coder
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_series = {SET_CODE_TALKER}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- link summon
    Link.AddProcedure(c, aux.FilterBoolFunctionEx(Card.IsRace, RACE_CYBERSE), 2, 2)

    -- search from deck
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetCountLimit(1, id)
    e1:SetCondition(s.e1con)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- extra material
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e2:SetCode(EFFECT_EXTRA_MATERIAL)
    e2:SetRange(LOCATION_HAND)
    e2:SetTargetRange(1, 0)
    e2:SetOperation(s.e2con)
    e2:SetValue(s.e2val)
    local e2b = Effect.CreateEffect(c)
    e2b:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_GRANT)
    e2b:SetRange(LOCATION_MZONE)
    e2b:SetTargetRange(LOCATION_HAND, 0)
    e2b:SetTarget(function(e, c) return c:IsRace(RACE_CYBERSE) and c:IsCanBeLinkMaterial() end)
    e2b:SetLabelObject(e2)
    c:RegisterEffect(e2b)
    aux.GlobalCheck(s, function() s.flagmap = {} end)
end

function s.e1filter(c) return c:ListsArchetype(SET_CODE_TALKER) and c:IsMonster() and c:IsAbleToHand() end

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

function s.e2con(c, e, tp, sg, mg, lc, og, chk)
    local ep = e:GetHandlerPlayer()
    local ct = sg:FilterCount(Card.HasFlagEffect, nil, id)
    return ct == 0 or
               ((sg + mg):Filter(function(c, tp) return c:IsLocation(LOCATION_MZONE) and c:IsControler(tp) end, nil, ep)
            :IsExists(Card.IsCode, 1, og, id) and ct < 2)
end

function s.e2val(chk, summon_type, e, ...)
    local c = e:GetHandler()
    if chk == 0 then
        local tp, sc = ...
        if summon_type ~= SUMMON_TYPE_LINK or not sc:IsSetCard(SET_CODE_TALKER) or Duel.GetFlagEffect(tp, id) > 0 then
            return Group.CreateGroup()
        else
            s.flagmap[c] = c:RegisterFlagEffect(id, 0, 0, 1)
            return Group.FromCards(c)
        end
    elseif chk == 1 then
        local sg, sc, tp = ...
        if summon_type & SUMMON_TYPE_LINK == SUMMON_TYPE_LINK and #sg > 0 and Duel.GetFlagEffect(tp, id) == 0 then
            Duel.Hint(HINT_CARD, tp, id)
            Duel.RegisterFlagEffect(tp, id, RESET_PHASE + PHASE_END, 0, 1)
        end
    elseif chk == 2 then
        if s.flagmap[c] then
            s.flagmap[c]:Reset()
            s.flagmap[c] = nil
        end
    end
end
