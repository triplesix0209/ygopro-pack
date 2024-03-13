-- Proxy Securiry Dragon
Duel.LoadScript("util.lua")
local s, id = GetID()
local CARD_FWD_DARKFLUID = 68934651
local COUNTER_FW = 0x14c

s.listed_names = {CARD_FWD_DARKFLUID}
s.listed_series = {SET_FIREWALL}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- link summon
    Link.AddProcedure(c, aux.FilterBoolFunctionEx(Card.IsType, TYPE_EFFECT), 2)

    -- extra material
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetCode(EFFECT_EXTRA_MATERIAL)
    e1:SetRange(LOCATION_HAND)
    e1:SetTargetRange(1, 0)
    e1:SetOperation(s.e1con)
    e1:SetValue(s.e1val)
    local e1b = Effect.CreateEffect(c)
    e1b:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_GRANT)
    e1b:SetRange(LOCATION_MZONE)
    e1b:SetTargetRange(LOCATION_HAND, 0)
    e1b:SetTarget(function(e, c) return c:IsRace(RACE_CYBERSE) and c:IsCanBeLinkMaterial() end)
    e1b:SetLabelObject(e1)
    c:RegisterEffect(e1b)
    aux.GlobalCheck(s, function() s.flagmap = {} end)

    -- draw
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 0))
    e2:SetCategory(CATEGORY_DRAW)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetProperty(EFFECT_FLAG_NO_TURN_RESET)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1, {id, 1})
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)

    -- place counter
    local e3 = Effect.CreateEffect(c)
    e3:SetCategory(CATEGORY_COUNTER)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e3:SetRange(LOCATION_GRAVE)
    e3:SetCountLimit(1, {id, 2})
    -- e3:SetCost(aux.bfgcost)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)
end

function s.e1con(c, e, tp, sg, mg, lc, og, chk)
    local ep = e:GetHandlerPlayer()
    local ct = sg:FilterCount(Card.HasFlagEffect, nil, id)
    return ct == 0 or
               ((sg + mg):Filter(function(c, tp) return c:IsLocation(LOCATION_MZONE) and c:IsControler(tp) end, nil, ep)
            :IsExists(Card.IsCode, 1, og, id) and ct < 2)
end

function s.e1val(chk, summon_type, e, ...)
    local c = e:GetHandler()
    if chk == 0 then
        local tp, sc = ...
        if summon_type ~= SUMMON_TYPE_LINK or not sc:IsSetCard(SET_FIREWALL) or Duel.GetFlagEffect(tp, id) > 0 then
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

function s.e2filter(c) return c:IsRace(RACE_CYBERSE) and c:IsMonster() end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    local ct = #(e:GetHandler():GetMutualLinkedGroup():Filter(s.e2filter, nil))
    if chk == 0 then return ct > 0 and Duel.IsPlayerCanDraw(tp, ct) end
    Duel.SetOperationInfo(0, CATEGORY_DRAW, nil, 0, tp, ct)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local ct = #(e:GetHandler():GetMutualLinkedGroup():Filter(s.e2filter, nil))
    Duel.Draw(tp, ct, REASON_EFFECT)
end

function s.e3filter1(c) return c:IsCode(CARD_FWD_DARKFLUID) and c:GetCounter(COUNTER_FW) == 0 end

function s.e3filter2(c)
    return c:IsFaceup() and c:IsAbleToDeck() and c:IsRace(RACE_CYBERSE) and c:IsType(TYPE_RITUAL + TYPE_FUSION + TYPE_SYNCHRO + TYPE_XYZ)
end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    local c = e:GetHandler()
    if chk == 0 then
        return Duel.IsExistingTarget(s.e3filter1, tp, LOCATION_ONFIELD, LOCATION_ONFIELD, 1, nil) and
                   Duel.IsExistingMatchingCard(s.e3filter2, tp, LOCATION_GRAVE + LOCATION_REMOVED, 0, 1, c)
    end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_COUNTER)
    local g = Duel.SelectTarget(tp, s.e3filter1, tp, LOCATION_ONFIELD, LOCATION_ONFIELD, 1, 1, nil)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local tc = Duel.GetFirstTarget()

    local g = Duel.GetMatchingGroup(s.e3filter2, tp, LOCATION_GRAVE + LOCATION_REMOVED, 0, 1, nil)
    local sg = aux.SelectUnselectGroup(g, e, tp, 1, 4, s.e3rescon, 1, tp, HINTMSG_TODECK)
    local ct = Duel.SendtoDeck(sg, nil, SEQ_DECKSHUFFLE, REASON_EFFECT)

    if ct == 0 or not tc:IsRelateToEffect(e) or tc:IsFacedown() then return end
    tc:AddCounter(COUNTER_FW, ct)
end

function s.e3rescon(sg, e, tp, mg)
    local ritual_ct = sg:FilterCount(Card.IsType, nil, TYPE_RITUAL)
    local fusion_ct = sg:FilterCount(Card.IsType, nil, TYPE_FUSION)
    local synchro_ct = sg:FilterCount(Card.IsType, nil, TYPE_SYNCHRO)
    local xyz_ct = sg:FilterCount(Card.IsType, nil, TYPE_XYZ)
    return ritual_ct <= 1 and fusion_ct <= 1 and synchro_ct <= 1 and xyz_ct <= 1
end
