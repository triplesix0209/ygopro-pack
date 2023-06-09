-- Supreme Arc
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {CARD_ZARC}
s.listed_series = {SET_ODD_EYES, SET_FUSION}

function s.initial_effect(c)
    -- activate
    local act = Effect.CreateEffect(c)
    act:SetType(EFFECT_TYPE_ACTIVATE)
    act:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(act)

    -- inactivatable to fusion summon
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CANNOT_INACTIVATE)
    e1:SetRange(LOCATION_FZONE)
    e1:SetValue(function(e, ct)
        local p = e:GetHandlerPlayer()
        local te, tp = Duel.GetChainInfo(ct, CHAININFO_TRIGGERING_EFFECT, CHAININFO_TRIGGERING_PLAYER)
        return p == tp and te:IsHasCategory(CATEGORY_FUSION_SUMMON)
    end)
    c:RegisterEffect(e1)

    -- cannot disable summon
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_CANNOT_DISABLE_SPSUMMON)
    e2:SetRange(LOCATION_FZONE)
    e2:SetProperty(EFFECT_FLAG_IGNORE_RANGE + EFFECT_FLAG_SET_AVAILABLE)
    e2:SetTarget(function(e, tc)
        local p = e:GetHandlerPlayer()
        return tc:GetOwner() == p and tc:IsRace(RACE_DRAGON)
    end)
    c:RegisterEffect(e2)

    -- untargetable
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e3:SetRange(LOCATION_FZONE)
    e3:SetValue(aux.tgoval)
    c:RegisterEffect(e3)
    local e3b = e3:Clone()
    e3b:SetType(EFFECT_TYPE_FIELD)
    e3b:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
    e3b:SetTargetRange(LOCATION_PZONE, 0)
    c:RegisterEffect(e3b)

    -- search
    local e4 = Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id, 0))
    e4:SetCategory(CATEGORY_DESTROY + CATEGORY_TOHAND + CATEGORY_SEARCH)
    e4:SetType(EFFECT_TYPE_IGNITION)
    e4:SetRange(LOCATION_FZONE)
    e4:SetCountLimit(1, id)
    e4:SetTarget(s.e4tg)
    e4:SetOperation(s.e4op)
    c:RegisterEffect(e4)

    -- pendulum summon
    local e5 = Effect.CreateEffect(c)
    e5:SetDescription(1163)
    e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e5:SetType(EFFECT_TYPE_QUICK_O)
    e5:SetCode(EVENT_FREE_CHAIN)
    e5:SetRange(LOCATION_FZONE)
    e5:SetCountLimit(1)
    e5:SetCondition(s.e5con)
    e5:SetTarget(s.e5tg)
    e5:SetOperation(s.e5op)
    c:RegisterEffect(e5)
    aux.GlobalCheck(s, function()
        local e5reg = Effect.CreateEffect(c)
        e5reg:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
        e5reg:SetCode(EVENT_SPSUMMON_SUCCESS)
        e5reg:SetOperation(s.e5regop)
        Duel.RegisterEffect(e5reg, 0)
    end)
end

function s.e4filter(c)
    if not c:IsAbleToHand() then return false end
    return c:IsSetCard(SET_ODD_EYES) or c:ListsCode(CARD_ZARC)
end

function s.e4tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    local loc = LOCATION_DECK
    if Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode, CARD_ZARC), tp, LOCATION_ONFIELD, 0, 1, nil) then loc = loc + LOCATION_GRAVE end

    if chk == 0 then
        return Duel.IsExistingMatchingCard(Card.IsFaceup, tp, LOCATION_ONFIELD, 0, 1, e:GetHandler()) and
                   Duel.IsExistingMatchingCard(s.e4filter, tp, loc, 0, 1, nil)
    end

    Duel.SetOperationInfo(0, CATEGORY_DESTROY, nil, 1, 0, LOCATION_ONFIELD)
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, loc)
    Duel.SetChainLimit(aux.FALSE)
end

function s.e4op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) then return end

    local g = Utility.SelectMatchingCard(HINTMSG_DESTROY, tp, Card.IsFaceup, tp, LOCATION_ONFIELD, 0, 1, 1, c)
    Duel.HintSelection(g)

    if Duel.Destroy(g, REASON_EFFECT) ~= 0 then
        local loc = LOCATION_DECK
        if Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode, CARD_ZARC), tp, LOCATION_ONFIELD, 0, 1, nil) then
            loc = loc + LOCATION_GRAVE
        end
        local sg = Utility.SelectMatchingCard(HINTMSG_ATOHAND, tp, aux.NecroValleyFilter(s.e4filter), tp, loc, 0, 1, 1, g)
        if #sg > 0 then
            Duel.SendtoHand(sg, nil, REASON_EFFECT)
            Duel.ConfirmCards(1 - tp, sg)
        end
    end
end

function s.e5regop(e, tp, eg, ep, ev, re, r, rp)
    for tc in eg:Iter() do
        local sumtp = tc:GetSummonPlayer()
        if tc:IsSummonLocation(LOCATION_EXTRA) and tc:IsType(TYPE_PENDULUM) and tc:IsPreviousPosition(POS_FACEDOWN) and tc:IsFaceup() and
            tc:GetOwner() == sumtp then Duel.RegisterFlagEffect(sumtp, id, RESET_PHASE + PHASE_END, 0, 1) end
    end
end

function s.e5con(e, tp, eg, ep, ev, re, r, rp) return Duel.GetFlagEffect(tp, id) ~= 0 end

function s.e5tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsPlayerCanPendulumSummon(tp) end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_HAND + LOCATION_EXTRA)
end

function s.e5op(e, tp, eg, ep, ev, re, r, rp) Duel.PendulumSummon(tp) end
