-- Palladium Reborn
Duel.LoadScript("util.lua")
local s, id = GetID()

function s.initial_effect(c)
    c:AddSetcodesRule(id, true, 0x13a)

    -- activate
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCondition(s.e1con)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)
end

function s.e1sumcheck(c, e, tp) return not c:IsCanBeSpecialSummoned(e, 0, tp, false, false, POS_FACEUP) and c:IsSummonableCard() end

function s.e1filter(c, e, tp) return c:IsCanBeSpecialSummoned(e, 0, tp, s.e1sumcheck(c, e, tp), false, POS_FACEUP) end

function s.e1con(e, tp, eg, ep, ev, re, r, rp) return (Duel.IsTurnPlayer(tp) and Duel.IsMainPhase()) or Duel.IsTurnPlayer(1 - tp) end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingTarget(s.e1filter, tp, LOCATION_GRAVE, LOCATION_GRAVE, 1, nil, e, tp) and
                   Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
    end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TARGET)
    local g = Duel.SelectTarget(tp, s.e1filter, tp, LOCATION_GRAVE, LOCATION_GRAVE, 1, 1, nil, e, tp)
    Duel.SetOperationInfo(0, CATEGORY_LEAVE_GRAVE, g, #g, 0, 0)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Duel.GetFirstTarget()
    if not tc or not tc:IsRelateToEffect(e) or Duel.GetLocationCount(tp, LOCATION_MZONE) == 0 then return end

    local check = s.e1sumcheck(tc, e, tp)
    if Duel.SpecialSummon(tc, 0, tp, tp, check, false, POS_FACEUP) ~= 0 and check then
        tc:RegisterFlagEffect(id, RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END, 0, 1)
        local ec1 = Effect.CreateEffect(c)
        ec1:SetDescription(574)
        ec1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
        ec1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
        ec1:SetCode(EVENT_PHASE + PHASE_END)
        ec1:SetCountLimit(1)
        ec1:SetLabelObject(tc)
        ec1:SetCondition(function(e) return e:GetLabelObject():GetFlagEffect(id) ~= 0 end)
        ec1:SetOperation(function(e) Duel.SendtoGrave(e:GetLabelObject(), REASON_EFFECT) end)
        ec1:SetReset(RESET_PHASE + PHASE_END)
        Duel.RegisterEffect(ec1, tp)
    end
end
