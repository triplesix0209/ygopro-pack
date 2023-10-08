-- Elemental HERO Nimbus Neos
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {CARD_NEOS}
s.material_setcode = {SET_HERO, SET_ELEMENTAL_HERO, SET_NEOS, SET_NEO_SPACIAN}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- fusion summon
    Fusion.AddProcMix(c, true, true, CARD_NEOS, 17732278, 54959865)
    Fusion.AddContactProc(c, function(tp) return Duel.GetMatchingGroup(Card.IsAbleToDeckOrExtraAsCost, tp, LOCATION_ONFIELD, 0, nil) end,
        function(g, tp)
            Duel.ConfirmCards(1 - tp, g)
            Duel.SendtoDeck(g, nil, SEQ_DECKSHUFFLE, REASON_COST + REASON_MATERIAL)
        end, function(e) return not e:GetHandler():IsLocation(LOCATION_EXTRA) end)

    -- banish & recover
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_REMOVE + CATEGORY_RECOVER)
    e1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetCondition(s.e1con)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- draw
    aux.EnableNeosReturn(c, CATEGORY_DRAW, s.e2info, s.e2op)
end

function s.e1filter(c) return c:IsFaceup() and c:IsAbleToRemove() end

function s.e1con(e, tp, eg, ep, ev, re, r, rp) return e:GetHandler():IsPreviousLocation(LOCATION_EXTRA) end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local g = Duel.GetMatchingGroup(s.e1filter, tp, LOCATION_MZONE, LOCATION_MZONE, nil)
    if chk == 0 then return #g > 0 end

    Duel.SetTargetPlayer(tp)
    Duel.SetOperationInfo(0, CATEGORY_RECOVER, nil, 0, tp, 0)
    Duel.SetOperationInfo(0, CATEGORY_REMOVE, g, 1, 0, 0)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()

    local tc = Utility.SelectMatchingCard(HINTMSG_REMOVE, tp, s.e1filter, tp, LOCATION_MZONE, LOCATION_MZONE, 1, 1, nil):GetFirst()
    Duel.HintSelection(tc)

    if tc and Duel.Remove(tc, POS_FACEUP, REASON_COST + REASON_TEMPORARY) ~= 0 then
        local ec1 = Effect.CreateEffect(c)
        ec1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
        ec1:SetCode(EVENT_PHASE + PHASE_END)
        ec1:SetLabel(Duel.GetTurnCount())
        ec1:SetLabelObject(tc)
        ec1:SetCountLimit(1)
        ec1:SetCondition(function(e, tp, eg, ep, ev, re, r, rp) return e:GetLabel() ~= Duel.GetTurnCount() end)
        ec1:SetOperation(function(e, tp, eg, ep, ev, re, r, rp) Duel.ReturnToField(e:GetLabelObject()) end)
        ec1:SetReset(RESET_PHASE + PHASE_END, 2)
        Duel.RegisterEffect(ec1, tp)

        Duel.BreakEffect()
        local p = Duel.GetChainInfo(0, CHAININFO_TARGET_PLAYER)
        Duel.Recover(p, tc:GetBaseAttack(), REASON_EFFECT)
    end
end

function s.e2info(e, tp, eg, ep, ev, re, r, rp)
    local ct1 = 5 - Duel.GetFieldGroupCount(tp, LOCATION_HAND, 0)
    local ct2 = 5 - Duel.GetFieldGroupCount(tp, 0, LOCATION_HAND)
    Duel.SetOperationInfo(0, CATEGORY_DRAW, nil, 0, PLAYER_ALL, ct1 + ct2)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local turn_p = Duel.GetTurnPlayer()
    local ct1 = 5 - Duel.GetFieldGroupCount(turn_p, LOCATION_HAND, 0)
    local ct2 = 5 - Duel.GetFieldGroupCount(turn_p, 0, LOCATION_HAND)
    if ct1 <= 0 and ct2 <= 0 then return end
    if not (Duel.IsPlayerCanDraw(tp) or Duel.IsPlayerCanDraw(1 - tp)) then return end

    if ct1 > 0 then Duel.Draw(turn_p, ct1, REASON_EFFECT) end
    if ct2 > 0 then Duel.Draw(1 - turn_p, ct2, REASON_EFFECT) end
end
