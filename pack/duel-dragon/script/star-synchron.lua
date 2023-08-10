-- Star Synchron
Duel.LoadScript("util.lua")
local s, id = GetID()

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- synchro summon
    Synchro.AddProcedure(c, nil, 1, 1, Synchro.NonTuner(nil), 1, 1)

    -- gain effect
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
    e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
    e1:SetCode(EVENT_BE_MATERIAL)
    e1:SetCondition(s.e1con)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- synchro summon during the opponent's Main Phase
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(1172)
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_MZONE)
    e2:SetHintTiming(0, TIMINGS_CHECK_MONSTER + TIMING_MAIN_END)
    e2:SetCondition(s.e2con)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)

    -- special summon
    local e3 = Effect.CreateEffect(c)
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetCode(EVENT_SPSUMMON_SUCCESS)
    e3:SetRange(LOCATION_GRAVE)
    e3:SetCountLimit(1, id, EFFECT_COUNT_CODE_DUEL)
    e3:SetCondition(s.e3con)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)
end

function s.e1con(e, tp, eg, ep, ev, re, r, rp) return r == REASON_SYNCHRO end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local rc = c:GetReasonCard()

    local ec1 = Effect.CreateEffect(c)
    ec1:SetDescription(3110)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetProperty(EFFECT_FLAG_SINGLE_RANGE + EFFECT_FLAG_IGNORE_IMMUNE + EFFECT_FLAG_CLIENT_HINT)
    ec1:SetCode(EFFECT_IMMUNE_EFFECT)
    ec1:SetRange(LOCATION_MZONE)
    ec1:SetValue(function(e, te) return te:GetOwnerPlayer() ~= e:GetHandlerPlayer() and te:IsActivated() end)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD - RESET_TOFIELD + RESET_PHASE + PHASE_END)
    rc:RegisterEffect(ec1)
end

function s.e2con(e, tp, eg, ep, ev, re, r, rp) return Duel.IsTurnPlayer(1 - tp) and Duel.IsMainPhase() end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return c:GetFlagEffect(id) == 0 and Duel.IsExistingMatchingCard(Card.IsSynchroSummonable, tp, LOCATION_EXTRA, 0, 1, nil, c) end
    c:RegisterFlagEffect(id, RESET_CHAIN, 0, 1)

    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_EXTRA)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if c:IsControler(1 - tp) or not c:IsRelateToEffect(e) or c:IsFacedown() then return end

    local g = Duel.GetMatchingGroup(Card.IsSynchroSummonable, tp, LOCATION_EXTRA, 0, nil, c)
    if #g > 0 then
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
        local sc = g:Select(tp, 1, 1, nil):GetFirst()
        Duel.SynchroSummon(tp, sc, c)
    end
end

function s.e3filter1(c, tp) return c:IsLevel(8) and c:IsRace(RACE_DRAGON) and c:IsType((TYPE_SYNCHRO)) and c:IsSummonPlayer(tp) end

function s.e3filter2(c, tp, mc) return c:IsSummonType(SUMMON_TYPE_SYNCHRO) and c:IsSummonPlayer(tp) and c:GetMaterial():IsContains(mc) end

function s.e3con(e, tp, eg, ep, ev, re, r, rp) return
    eg:IsExists(s.e3filter1, 1, nil, tp) and not eg:IsExists(s.e3filter2, 1, nil, tp, e:GetHandler()) end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and c:IsCanBeSpecialSummoned(e, 0, tp, false, false) end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, c, 1, 0, 0)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) then return end

    Duel.SpecialSummon(c, 0, tp, tp, false, false, POS_FACEUP_DEFENSE)
end
