-- Stormcode Talker
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_series = {SET_CODE_TALKER}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- link summon
    Link.AddProcedure(c, aux.FilterBoolFunctionEx(Card.IsRace, RACE_CYBERSE), 2)

    -- cannot be attacked
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCondition(function(e) return e:GetHandler():IsInExtraMZone() end)
    e1:SetValue(aux.imval1)
    c:RegisterEffect(e1)

    -- cannot disable summon
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_CANNOT_DISABLE_SPSUMMON)
    e2:SetRange(LOCATION_MZONE)
    e2:SetProperty(EFFECT_FLAG_IGNORE_RANGE + EFFECT_FLAG_SET_AVAILABLE)
    e2:SetTarget(function(e, c) return c:IsSummonType(SUMMON_TYPE_LINK) and c:IsControler(e:GetHandlerPlayer()) end)
    c:RegisterEffect(e2)

    -- shuffle monster into the Deck and then special summon
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 0))
    e3:SetCategory(CATEGORY_TODECK + CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetProperty(EFFECT_FLAG_NO_TURN_RESET)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1, id)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)
end

function s.e3filter1(c, e, tp)
    return e:GetHandler():GetLinkedGroup():IsContains(c) and c:IsRace(RACE_CYBERSE) and c:IsType(TYPE_LINK) and c:IsAbleToExtra() and
               Duel.IsExistingMatchingCard(s.e3filter2, tp, LOCATION_EXTRA, 0, 1, nil, e, tp, c)
end

function s.e3filter2(c, e, tp, mc)
    return c:IsSetCard(SET_CODE_TALKER) and c:IsLink(3) and not c:IsCode(id) and not c:IsCode(mc:GetCode()) and
               c:IsCanBeSpecialSummoned(e, SUMMON_TYPE_LINK, tp, false, false) and Duel.GetLocationCountFromEx(tp, tp, mc, c) > 0
end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return Duel.IsExistingMatchingCard(s.e3filter1, tp, LOCATION_MZONE, 0, 1, c, e, tp) end

    Duel.SetOperationInfo(0, CATEGORY_TODECK, nil, 1, tp, LOCATION_MZONE)
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_EXTRA)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Utility.SelectMatchingCard(HINTMSG_TODECK, tp, s.e3filter1, tp, LOCATION_MZONE, 0, 1, 1, c, e, tp):GetFirst()

    if tc then
        Duel.ConfirmCards(1 - tp, tc)
        if Duel.SendtoDeck(tc, tp, 2, REASON_EFFECT) ~= 0 and Duel.IsExistingMatchingCard(s.e3filter2, tp, LOCATION_EXTRA, 0, 1, nil, e, tp, tc) then
            local sc = Utility.SelectMatchingCard(HINTMSG_SPSUMMON, tp, s.e3filter2, tp, LOCATION_EXTRA, 0, 1, 1, nil, e, tp, tc):GetFirst()
            if sc then
                Duel.SpecialSummon(sc, SUMMON_TYPE_LINK, tp, tp, false, false, POS_FACEUP)
                sc:CompleteProcedure()
                local ec1 = Effect.CreateEffect(c)
                ec1:SetDescription(3206)
                ec1:SetType(EFFECT_TYPE_SINGLE)
                ec1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
                ec1:SetCode(EFFECT_CANNOT_ATTACK)
                ec1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
                sc:RegisterEffect(ec1)
            end
        end
    end
end
