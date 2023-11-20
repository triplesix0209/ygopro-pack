-- Red-Eyes Blaster Dragon
Duel.LoadScript("util.lua")
Duel.EnableUnofficialProc(PROC_STATS_CHANGED)
local s, id = GetID()

s.listed_names = {CARD_REDEYES_B_DRAGON}
s.material_setcode = {SET_RED_EYES}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- fusion summon
    Fusion.AddProcMix(c, false, false, CARD_REDEYES_B_DRAGON, aux.FilterBoolFunctionEx(Card.IsType, TYPE_GEMINI))

    -- destroy battling
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_DESTROY)
    e1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_BATTLE_START)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- atk up
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 1))
    e2:SetCategory(CATEGORY_ATKCHANGE)
    e2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_F)
    e2:SetProperty(EFFECT_FLAG_DELAY + EFFECT_FLAG_DAMAGE_STEP)
    e2:SetCode(EVENT_DESTROYED)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCondition(s.e2con)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)

    -- special summon
    local e3 = Effect.CreateEffect(c)
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetCode(EVENT_DESTROYED)
    e3:SetCountLimit(1, id)
    e3:SetCondition(s.e3con)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    local tc = c:GetBattleTarget()
    if chk == 0 then return tc and tc:IsControler(1 - tp) end
    Duel.SetOperationInfo(0, CATEGORY_DESTROY, tc, 1, 0, 0)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local tc = e:GetHandler():GetBattleTarget()
    if tc and tc:IsRelateToBattle() then Duel.Destroy(tc, REASON_EFFECT) end
end

function s.e2filter(c, tp, rc, re) return c:IsReason(REASON_BATTLE + REASON_EFFECT) and (c:GetReasonCard() == rc or (re and re:GetOwner() == rc)) end

function s.e2con(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    return eg:IsExists(s.e2filter, 1, nil, tp, c, re)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if c:IsFacedown() or not c:IsRelateToEffect(e) then return end

    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetCode(EFFECT_UPDATE_ATTACK)
    ec1:SetValue(500)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
    c:RegisterEffect(ec1)

    if c:IsAttackAbove(4000) then
        Duel.BreakEffect()
        Duel.Destroy(c, REASON_EFFECT)
    end
end

function s.e3filter(c, e, tp) return c:IsCode(CARD_REDEYES_B_DRAGON) and c:IsCanBeSpecialSummoned(e, 0, tp, false, false) end

function s.e3con(e, tp, eg, ep, ev, re, r, rp) return (r & REASON_EFFECT + REASON_BATTLE) ~= 0 end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and
                   Duel.IsExistingMatchingCard(s.e3filter, tp, LOCATION_HAND + LOCATION_DECK + LOCATION_GRAVE, 0, 1, nil, e, tp)
    end

    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_GRAVE)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    if Duel.GetLocationCount(tp, LOCATION_MZONE) <= 0 then return end

    local g = Utility.SelectMatchingCard(HINTMSG_SPSUMMON, tp, aux.NecroValleyFilter(s.e3filter), tp, LOCATION_HAND + LOCATION_DECK + LOCATION_GRAVE,
        0, 1, 1, nil, e, tp)
    if #g > 0 then Duel.SpecialSummon(g, 0, tp, tp, false, false, POS_FACEUP) end
end
