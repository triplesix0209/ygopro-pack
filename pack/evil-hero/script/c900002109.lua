-- Evil HERO Revenge Smog
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_series = {0x6008, 0xf8}

function s.initial_effect(c)
    -- effect
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DELAY + EFFECT_FLAG_DAMAGE_STEP)
    e1:SetCode(EVENT_SUMMON_SUCCESS)
    e1:SetCountLimit(1, {id, 1})
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)
    local e1b = e1:Clone()
    e1b:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e1b)

    -- activate field
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 1))
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_MZONE + LOCATION_GRAVE)
    e2:SetCountLimit(1, {id, 2})
    e2:SetCost(aux.bfgcost)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)
end

function s.e1dmgfilter(c) return c:IsSetCard(0x6008) and c:IsMonster() end

function s.e1spfilter(c, e, tp)
    return c:IsSetCard(0x6008) and c:IsMonster() and (c:IsAbleToHand() or c:IsCanBeSpecialSummoned(e, 0, tp, false, false))
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    local ct = Duel.GetMatchingGroupCount(s.e1dmgfilter, tp, LOCATION_GRAVE, 0, nil)

    if chk == 0 then
        local sel = 0
        if ct > 0 then sel = sel + 1 end
        if Duel.IsExistingTarget(s.e1spfilter, tp, LOCATION_GRAVE, 0, 1, nil, e, tp) then sel = sel + 2 end

        e:SetLabel(sel)
        return sel ~= 0
    end

    local sel = e:GetLabel()
    if sel == 3 then
        Duel.Hint(HINT_SELECTMSG, tp, aux.Stringid(id, 0))
        sel = Duel.SelectOption(tp, aux.Stringid(id, 1), aux.Stringid(id, 2)) + 1
    elseif sel == 1 then
        Duel.SelectOption(tp, aux.Stringid(id, 1))
    else
        Duel.SelectOption(tp, aux.Stringid(id, 2))
    end
    e:SetLabel(sel)

    if sel == 1 then
        e:SetCategory(CATEGORY_DAMAGE)
        Duel.SetOperationInfo(0, CATEGORY_DAMAGE, nil, 0, 1 - tp, ct * 300)
    else
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SELECT)
        local tc = Duel.SelectTarget(tp, s.e1spfilter, tp, LOCATION_GRAVE, 0, 1, 1, nil, e, tp):GetFirst()

        e:SetCategory(CATEGORY_TOHAND + CATEGORY_SPECIAL_SUMMON)
        Duel.SetOperationInfo(0, CATEGORY_TOHAND, tc, 1, 0, 0)
        Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, tc, 1, 0, 0)
    end
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local sel = e:GetLabel()
    if sel == 1 then
        local ct = Duel.GetMatchingGroupCount(s.e1dmgfilter, tp, LOCATION_GRAVE, 0, nil)
        Duel.Damage(1 - tp, ct * 300, REASON_EFFECT)
    else
        local tc = Duel.GetFirstTarget()
        if not tc or not tc:IsRelateToEffect(e) then return end

        aux.ToHandOrElse(tc, tp, function(tc)
            return tc:IsCanBeSpecialSummoned(e, 0, tp, false, false, POS_FACEUP) and Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
        end, function(g) Duel.SpecialSummon(g, 0, tp, tp, false, false, POS_FACEUP) end, 2)
    end
end

function s.e2filter(c, tp)
    return c:IsSetCard(0xf8) and c:IsType(TYPE_FIELD) and c:GetActivateEffect() and
               c:GetActivateEffect():IsActivatable(tp, true, true)
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.e2filter, tp, LOCATION_HAND + LOCATION_DECK + LOCATION_GRAVE, 0, 1, nil, tp)
    end
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local tc = Utility.SelectMatchingCard(HINTMSG_TOFIELD, tp, aux.NecroValleyFilter(s.e2filter), tp,
        LOCATION_HAND + LOCATION_DECK + LOCATION_GRAVE, 0, 1, 1, nil, tp):GetFirst()
    Duel.ActivateFieldSpell(tc, e, tp, eg, ep, ev, re, r, rp)
end

