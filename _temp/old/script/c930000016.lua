-- Alsvid of the Nordic Beasts
local s, id = GetID()
Duel.LoadScript("util.lua")
Duel.LoadScript("util_nordic.lua")

s.listed_names = {UtilNordic.BEAST_TOKEN}
s.listed_series = {0x4b, 0x42}

function s.initial_effect(c)
    -- special summon
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e1:SetCode(EFFECT_SPSUMMON_PROC)
    e1:SetRange(LOCATION_HAND)
    e1:SetCondition(s.e1con)
    c:RegisterEffect(e1)

    -- act limit
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EVENT_CHAINING)
    e2:SetRange(LOCATION_MZONE)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)

    -- summon token
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 0))
    e3:SetCategory(CATEGORY_RELEASE + CATEGORY_SPECIAL_SUMMON + CATEGORY_TOKEN)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1, id)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)
end

function s.e1con(e, c)
    if c == nil then return true end
    return Duel.GetFieldGroupCount(c:GetControler(), LOCATION_MZONE, 0, nil) ==
               0 and Duel.GetLocationCount(c:GetControler(), LOCATION_MZONE) > 0
end

function s.e2filter(c, tp)
    return c:IsControler(tp) and c:IsFaceup() and c:IsSetCard(0x42)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
    local g = Duel.GetChainInfo(ev, CHAININFO_TARGET_CARDS)
    if ep == tp and g and g:IsExists(s.e2filter, 1, nil, tp) then
        Duel.SetChainLimit(function(e, rp, tp) return tp == rp end)
    end
end

function s.e3filter(c)
    return c:IsFaceup() and c:IsSetCard(0x42) and c:IsReleasableByEffect()
end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    local c = e:GetHandler()
    if chk == 0 then
        return not Duel.IsPlayerAffectedByEffect(tp, CARD_BLUEEYES_SPIRIT) and
                   Duel.IsExistingTarget(s.e3filter, tp, LOCATION_MZONE, 0, 1, c) and
                   Duel.GetLocationCount(tp, LOCATION_MZONE) >= 1 and
                   Duel.IsPlayerCanSpecialSummonMonster(tp,
                                                        UtilNordic.BEAST_TOKEN,
                                                        0x6042, TYPES_TOKEN, 0,
                                                        0, 3, RACE_BEAST,
                                                        ATTRIBUTE_EARTH)
    end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_RELEASE)
    local g = Duel.SelectTarget(tp, s.e3filter, tp, LOCATION_MZONE, 0, 1, 1, c)

    Duel.SetOperationInfo(0, CATEGORY_RELEASE, g, #g, 0, 0)
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 2, tp, 0)
    Duel.SetOperationInfo(0, CATEGORY_TOKEN, nil, 2, 0, 0)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Duel.GetFirstTarget()

    if not Duel.IsPlayerAffectedByEffect(tp, CARD_BLUEEYES_SPIRIT) and
        tc:IsRelateToEffect(e) and Duel.Release(tc, REASON_EFFECT) > 0 and
        Duel.GetLocationCount(tp, LOCATION_MZONE) >= 2 and
        Duel.IsPlayerCanSpecialSummonMonster(tp, UtilNordic.BEAST_TOKEN, 0x6042,
                                             TYPES_TOKEN, 0, 0, 3, RACE_BEAST,
                                             ATTRIBUTE_EARTH) then
        for i = 1, 2 do
            local token = Duel.CreateToken(tp, UtilNordic.BEAST_TOKEN)
            Duel.SpecialSummonStep(token, 0, tp, tp, false, false, POS_FACEUP)
        end
        Duel.SpecialSummonComplete()
    end

    local ec1 = Effect.CreateEffect(c)
    ec1:SetDescription(aux.Stringid(id, 1))
    ec1:SetType(EFFECT_TYPE_FIELD)
    ec1:SetProperty(EFFECT_FLAG_PLAYER_TARGET + EFFECT_FLAG_CLIENT_HINT)
    ec1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    ec1:SetTargetRange(1, 0)
    ec1:SetTarget(function(e, c)
        return c:IsLocation(LOCATION_EXTRA) and not c:IsSetCard(0x4b)
    end)
    ec1:SetReset(RESET_PHASE + PHASE_END)
    Duel.RegisterEffect(ec1, tp)
end
