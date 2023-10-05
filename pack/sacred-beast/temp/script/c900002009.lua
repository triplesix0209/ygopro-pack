-- Seed of Desolation
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {78371393}

function s.initial_effect(c)
    -- destroy (hand)
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_DESTROY + CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1, {id, 1})
    e1:SetCost(s.e1cost)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- destroy (grave)
    local e2 = Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_DESTROY + CATEGORY_DRAW)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetCountLimit(1, {id, 2})
    e2:SetCost(aux.bfgcost)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)
end

function s.e1filter1(c) return c:IsFaceup() end

function s.e1filter2(c, e, tp) return c:IsCode(78371393) and c:IsCanBeSpecialSummoned(e, 0, tp, false, false) end

function s.e1cost(e, tp, eg, ep, ev, re, r, rp, chk) if chk == 0 then return not e:GetHandler():IsPublic() end end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    local c = e:GetHandler()
    if chk == 0 then
        return
            Duel.IsExistingTarget(s.e1filter1, tp, LOCATION_MZONE, 0, 1, nil) and Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and
                (c:IsCanBeSpecialSummoned(e, 0, tp, false, false) or
                    Duel.IsExistingMatchingCard(s.e1filter2, tp, LOCATION_HAND + LOCATION_DECK, 0, 1, nil))
    end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_DESTROY)
    local g = Duel.SelectTarget(tp, s.e1filter1, tp, LOCATION_MZONE, 0, 1, 1, nil)

    Duel.SetOperationInfo(0, CATEGORY_DESTROY, g, #g, 0, 0)
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, 0, LOCATION_HAND + LOCATION_DECK)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Duel.GetFirstTarget()
    if not tc:IsRelateToEffect(e) or Duel.Destroy(tc, REASON_EFFECT) == 0 then return end

    local opt = {}
    local sel = {}
    if c:IsRelateToEffect(e) and c:IsCanBeSpecialSummoned(e, 0, tp, false, false) then
        table.insert(opt, aux.Stringid(id, 0))
        table.insert(sel, 1)
    end
    if Duel.IsExistingMatchingCard(s.e1filter2, tp, LOCATION_HAND + LOCATION_DECK, 0, 1, nil, e, tp) then
        table.insert(opt, aux.Stringid(id, 1))
        table.insert(sel, 2)
    end
    local op = sel[Duel.SelectOption(tp, table.unpack(opt)) + 1]

    if op == 1 then
        Duel.SpecialSummon(c, 0, tp, tp, false, false, POS_FACEUP)
    elseif op == 2 then
        local g = Utility.SelectMatchingCard(HINTMSG_SPSUMMON, tp, s.e1filter2, tp, LOCATION_HAND + LOCATION_DECK, 0, 1, 1, nil,
            e, tp)
        Duel.SpecialSummon(g, 0, tp, tp, false, false, POS_FACEUP)
    end
end

function s.e2filter(c) return c:IsFaceup() and c:IsRace(RACE_FIEND) end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chk == 0 then return Duel.IsExistingTarget(s.e2filter, tp, LOCATION_MZONE, 0, 1, nil) end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_FACEUP)
    local g = Duel.SelectTarget(tp, s.e2filter, tp, LOCATION_MZONE, 0, 1, 1, nil)

    Duel.SetOperationInfo(0, CATEGORY_DESTROY, g, #g, 0, 0)
    Duel.SetPossibleOperationInfo(0, CATEGORY_DRAW, nil, 0, tp, 1)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Duel.GetFirstTarget()
    if tc:IsRelateToEffect(e) and Duel.Destroy(tc, REASON_EFFECT) > 0 and Duel.IsPlayerCanDraw(tp, 1) and
        Duel.SelectEffectYesNo(tp, c, aux.Stringid(id, 2)) then Duel.Draw(tp, 1, REASON_EFFECT) end
end
