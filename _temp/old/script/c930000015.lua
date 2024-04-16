-- Eir of the Nordic Champions
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

    -- synchro limit
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    e2:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
    e2:SetValue(function(e, c)
        if not c then return false end
        return not c:IsSetCard(0x4b)
    end)
    c:RegisterEffect(e2)

    -- level change
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

function s.e3filter(c)
    return c:IsSetCard(0x42) and c:IsType(TYPE_MONSTER) and c:HasLevel() and
               c:IsAbleToGraveAsCost()
end

function s.e3cost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.e3filter, tp, LOCATION_DECK, 0, 1,
                                           nil)
    end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOGRAVE)
    local g = Duel.SelectMatchingCard(tp, s.e3filter, tp, LOCATION_DECK, 0, 1,
                                      1, nil)
    Duel.SendtoGrave(g, REASON_COST)
    e:SetLabelObject(g:GetFirst())
end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return c:HasLevel() end

    local lv = c:GetLevel()
    local opt
    if e:GetLabelObject():GetLevel() < lv then
        opt = Duel.SelectOption(tp, aux.Stringid(id, 1), aux.Stringid(id, 2))
    else
        opt = Duel.SelectOption(tp, aux.Stringid(id, 1))
    end
    e:SetLabel(opt)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local lv = e:GetLabelObject():GetLevel()
    if not c:IsRelateToEffect(e) or c:IsFacedown() then return end

    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetCode(EFFECT_UPDATE_LEVEL)
    if e:GetLabel() == 0 then
        ec1:SetValue(lv)
    else
        ec1:SetValue(-lv)
    end
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD_DISABLE)
    c:RegisterEffect(ec1)
end
