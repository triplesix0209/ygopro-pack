-- Palladium Diadhank
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_series = {0x13a}

function s.initial_effect(c)
    -- activate
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1, id, EFFECT_COUNT_CODE_OATH)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)
    local e1leave = Effect.CreateEffect(c)
    e1leave:SetType(EFFECT_TYPE_CONTINUOUS + EFFECT_TYPE_SINGLE)
    e1leave:SetCode(EVENT_LEAVE_FIELD)
    e1leave:SetOperation(s.e1leaveop)
    c:RegisterEffect(e1leave)
end

function s.e1filter(c, e, tp) return (c:IsSetCard(0x13a) or c:IsType(TYPE_NORMAL)) and c:IsCanBeSpecialSummoned(e, 0, tp, false, false) end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    local c = e:GetHandler()
    local loc = LOCATION_HAND + LOCATION_DECK + LOCATION_GRAVE
    if chk == 0 then return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and Duel.IsExistingMatchingCard(s.e1filter, tp, loc, 0, 1, nil, e, tp) end

    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, 0, loc)
    Duel.SetOperationInfo(0, CATEGORY_EQUIP, c, 1, 0, loc)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()

    local tc =
        Utility.SelectMatchingCard(HINTMSG_SPSUMMON, tp, s.e1filter, tp, LOCATION_HAND + LOCATION_DECK + LOCATION_GRAVE, 0, 1, 1, nil, e, tp):GetFirst()
    if tc and c:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc, 0, tp, tp, false, false, POS_FACEUP) then
        Duel.Equip(tp, c, tc, true)
        local eqlimit = Effect.CreateEffect(tc)
        eqlimit:SetType(EFFECT_TYPE_SINGLE)
        eqlimit:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
        eqlimit:SetCode(EFFECT_EQUIP_LIMIT)
        eqlimit:SetValue(function(e, c) return e:GetOwner() == c end)
        eqlimit:SetReset(RESET_EVENT + RESETS_STANDARD)
        c:RegisterEffect(eqlimit)
    end
    Duel.SpecialSummonComplete()
end

function s.e1leaveop(e, tp, eg, ep, ev, re, r, rp)
    local tc = e:GetHandler():GetFirstCardTarget()
    if not tc or not tc:IsLocation(LOCATION_MZONE) or not tc:IsAbleToHand() then return end

    Utility.HintCard(e)
    Duel.SendtoHand(tc, nil, REASON_EFFECT)
end
