-- Alp of the Nordic Alfar
local s, id = GetID()
Duel.LoadScript("util.lua")
Duel.LoadScript("util_nordic.lua")

s.listed_series = {0x4b, 0x42}

function s.initial_effect(c)
    -- synchro substitute
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    e1:SetCode(61777313)
    c:RegisterEffect(e1)

    -- material limit
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    e2:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
    e2:SetValue(function(e, c)
        if not c then return false end
        return not c:IsSetCard(0x4b)
    end)
    c:RegisterEffect(e2)

    -- lv change
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 0))
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1)
    e3:SetCost(s.e3cost)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)
end

function s.e3filter1(c)
    return c:IsSetCard(0x42) and c:IsType(TYPE_MONSTER) and
               c:IsAbleToGraveAsCost()
end

function s.e3filter2(c) return c:IsFaceup() and c:HasLevel() end

function s.e3cost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.e3filter1, tp, LOCATION_DECK, 0, 1,
                                           nil)
    end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOGRAVE)
    local g = Duel.SelectMatchingCard(tp, s.e3filter1, tp, LOCATION_DECK, 0, 1,
                                      1, nil)
    Duel.SendtoGrave(g, REASON_COST)
end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chk == 0 then
        return Duel.IsExistingTarget(s.e3filter2, tp, LOCATION_MZONE, 0, 1, nil)
    end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_FACEUP)
    local tc = Duel.SelectTarget(tp, s.e3filter2, tp, LOCATION_MZONE, 0, 1, 1,
                                 nil):GetFirst()

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_LVRANK)
    local lv = Duel.AnnounceLevel(tp, 1, 8, tc:GetLevel())
    Duel.SetTargetParam(lv)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Duel.GetFirstTarget()
    local lv = Duel.GetChainInfo(0, CHAININFO_TARGET_PARAM)
    if not tc or tc:IsFacedown() or not tc:IsRelateToEffect(e) then return end

    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetCode(EFFECT_CHANGE_LEVEL)
    ec1:SetValue(lv)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
    tc:RegisterEffect(ec1)
end
