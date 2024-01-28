-- Photon Stream of Eternity
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {31801517}
s.listed_series = {0x107b}

function s.initial_effect(c)
    -- activate
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_REMOVE)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetHintTiming(0, TIMINGS_CHECK_MONSTER_E)
    e1:SetCondition(s.e1con)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)
end

function s.e1filter1(c) return c:IsFaceup() and c:IsSetCard(0x107b) end

function s.e1filter2(c) return c:IsFaceup() and (c:IsCode(31801517) or (c:IsType(TYPE_XYZ) and c:ListsCode(31801517))) end

function s.e1filter3(c) return c:IsSpellTrap() and c:IsAbleToRemove() end

function s.disfilter(c) return (c:IsFaceup() or c:IsType(TYPE_TRAPMONSTER)) and not (c:IsType(TYPE_NORMAL) and c:GetOriginalType() & TYPE_NORMAL > 0) end

function s.e1con(e, tp, eg, ep, ev, re, r, rp)
    return Duel.IsExistingMatchingCard(s.e1filter1, tp, LOCATION_MZONE, 0, 1, nil) and
               (Duel.GetTurnPlayer() == tp or Duel.IsExistingMatchingCard(s.e1filter2, tp, LOCATION_ONFIELD, 0, 1, nil))
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.e1filter3, tp, 0, LOCATION_ONFIELD, 1, nil) end

    local g = Duel.GetMatchingGroup(s.e1filter3, tp, 0, LOCATION_ONFIELD, nil)
    Duel.SetOperationInfo(0, CATEGORY_REMOVE, g, #g, 0, 0)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local g = Duel.GetMatchingGroup(s.e1filter3, tp, 0, LOCATION_ONFIELD, nil)
    if #g > 0 then Duel.Remove(g, POS_FACEUP, REASON_EFFECT) end

    local g = Duel.GetMatchingGroup(Card.IsFaceup, tp, 0, LOCATION_MZONE, nil)
    if Duel.IsExistingMatchingCard(s.e1filter2, tp, LOCATION_ONFIELD, 0, 1, nil) and #g > 0 then
        Duel.BreakEffect()
        local ng = g:Filter(s.disfilter, nil)
        for nc in ng:Iter() do
            local ec1 = Effect.CreateEffect(c)
            ec1:SetType(EFFECT_TYPE_SINGLE)
            ec1:SetCode(EFFECT_DISABLE)
            ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
            nc:RegisterEffect(ec1)
            local ec2 = ec1:Clone()
            ec2:SetCode(EFFECT_DISABLE_EFFECT)
            nc:RegisterEffect(ec2)
            if nc:IsType(TYPE_TRAPMONSTER) then
                local ec3 = ec1:Clone()
                ec3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
                nc:RegisterEffect(ec3)
            end
        end
    end
end
