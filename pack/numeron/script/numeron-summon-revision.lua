-- Numeron Summon Revision
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {CARD_NUMERON_NETWORK}

function s.initial_effect(c)
    -- activate
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_DISABLE_SUMMON + CATEGORY_DESTROY + CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_SPSUMMON)
    e1:SetCountLimit(1, id, EFFECT_COUNT_CODE_OATH)
    e1:SetCondition(s.e1con)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)
end

function s.e1filter(c, e, tp) return not c:IsPublic() and c:IsCanBeSpecialSummoned(e, 0, tp, false, false, POS_FACEUP, 1 - tp) end

function s.e1con(e, tp, eg, ep, ev, re, r, rp)
    local fc = Duel.GetFieldCard(tp, LOCATION_FZONE, 0)
    return fc and fc:IsFaceup() and fc:IsCode(CARD_NUMERON_NETWORK) and Duel.GetFieldGroupCount(tp, LOCATION_MZONE, 0) == 0 and ep == 1 - tp and
               Duel.GetCurrentChain(true) == 0 and #eg == 1 and eg:IsExists(Card.IsSummonLocation, 1, nil, LOCATION_EXTRA)
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.e1filter, tp, 0, LOCATION_DECK, 1, nil, e, tp) end
    Duel.SetOperationInfo(0, CATEGORY_DISABLE_SUMMON, eg, #eg, 0, 0)
    Duel.SetOperationInfo(0, CATEGORY_DESTROY, eg, #eg, 0, 0)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_CONFIRM)
    local tc = Duel.SelectMatchingCard(tp, s.e1filter, tp, 0, LOCATION_DECK, 1, 1, nil, e, tp):GetFirst()
    if not tc then return end

    Duel.ConfirmCards(1 - tp, tc)
    Duel.NegateSummon(eg)
    Duel.Destroy(eg, REASON_EFFECT)
    if Duel.GetLocationCount(1 - tp, LOCATION_MZONE) > 0 then
        Duel.BreakEffect()
        local ec1 = Effect.CreateEffect(c)
        ec1:SetType(EFFECT_TYPE_SINGLE)
        ec1:SetCode(EFFECT_DISABLE)
        ec1:SetReset(RESET_EVENT + RESETS_STANDARD - RESET_TOFIELD)
        tc:RegisterEffect(ec1)
        local ec1b = ec1:Clone()
        ec1b:SetCode(EFFECT_DISABLE_EFFECT)
        tc:RegisterEffect(ec1b)
        Duel.SpecialSummon(tc, 0, tp, 1 - tp, false, false, POS_FACEUP)
    end
end
