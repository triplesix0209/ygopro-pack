-- Contact Space
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {CARD_NEOS}
s.listed_series = {SET_NEOS}

function s.initial_effect(c)
    -- activate
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- special summon "Neos"
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 1))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY + EFFECT_FLAG_DAMAGE_STEP)
    e2:SetCode(EVENT_LEAVE_FIELD)
    e2:SetRange(LOCATION_FZONE)
    e2:SetCountLimit(1, id)
    e2:SetCondition(s.e2con)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)

    -- "Neos" fusions can choose to not return
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetCode(42015635)
    e3:SetRange(LOCATION_FZONE)
    e3:SetTargetRange(LOCATION_MZONE, LOCATION_MZONE)
    c:RegisterEffect(e3)

    -- spell/trap immune
    local e4 = Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_FIELD)
    e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE + EFFECT_FLAG_CANNOT_DISABLE)
    e4:SetCode(EFFECT_IMMUNE_EFFECT)
    e4:SetRange(LOCATION_FZONE)
    e4:SetTargetRange(LOCATION_SZONE, 0)
    e4:SetTarget(function(e, tc) tc:IsFaceup() end)
    e4:SetValue(function(e, te)
        local c = e:GetOwner()
        local tc = te:GetOwner()
        return tc ~= c and tc:IsSetCard(SET_NEOS)
    end)
    c:RegisterEffect(e4)
end

function s.e1filter(c) return c:IsAbleToHand() and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsSetCard(SET_NEOS) end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) or Duel.GetFlagEffect(tp, id) > 0 then return end

    local g = Duel.GetMatchingGroup(s.e1filter, tp, LOCATION_DECK, 0, nil)
    if #g > 0 and Duel.SelectEffectYesNo(tp, c, aux.Stringid(id, 0)) then
        local sg = Utility.GroupSelect(HINTMSG_ATOHAND, g, tp, 1, 1, nil)
        Duel.SendtoHand(sg, nil, REASON_EFFECT)
        Duel.ConfirmCards(1 - tp, sg)

        Duel.RegisterFlagEffect(tp, id, RESET_PHASE + PHASE_END, 0, 1)
    end
end

function s.e2filter1(c, tp)
    return c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsType(TYPE_FUSION) and c:ListsCodeAsMaterial(CARD_NEOS) and
               c:IsReason(REASON_EFFECT + REASON_BATTLE)
end

function s.e2filter2(c, e, tp, ft)
    if c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp, tp, c) == 0 then
        return false
    elseif not c:IsLocation(LOCATION_EXTRA) and ft == 0 then
        return false
    end

    return c:IsCode(CARD_NEOS) and c:IsCanBeSpecialSummoned(e, 0, tp, true, false)
end

function s.e2con(e, tp, eg, ep, ev, re, r, rp) return eg:IsExists(s.e2filter1, 1, nil, tp) end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local loc = LOCATION_HAND + LOCATION_DECK + LOCATION_EXTRA + LOCATION_GRAVE
    local ft = Duel.GetLocationCount(tp, LOCATION_MZONE)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.e2filter2, tp, loc, 0, 1, nil, e, tp, ft) end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, loc)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) then return end

    local loc = LOCATION_HAND + LOCATION_DECK + LOCATION_EXTRA + LOCATION_GRAVE
    local ft = Duel.GetLocationCount(tp, LOCATION_MZONE)
    local tc = Utility.SelectMatchingCard(HINTMSG_SPSUMMON, tp, aux.NecroValleyFilter(s.e2filter2), tp, loc, 0, 1, 1, nil, e, tp, ft):GetFirst()
    if tc then
        Duel.SpecialSummon(tc, 0, tp, tp, true, false, POS_FACEUP)
        tc:CompleteProcedure()
    end
end
