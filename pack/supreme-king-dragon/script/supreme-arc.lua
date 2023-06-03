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

    -- untargetable
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e1:SetRange(LOCATION_FZONE)
    e1:SetValue(aux.tgoval)
    c:RegisterEffect(e1)
    local e1b = e1:Clone()
    e1b:SetType(EFFECT_TYPE_FIELD)
    e1b:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
    e1b:SetTargetRange(LOCATION_PZONE, 0)
    c:RegisterEffect(e1b)

    -- search
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 0))
    e2:SetCategory(CATEGORY_DESTROY + CATEGORY_TOHAND + CATEGORY_SEARCH)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_FZONE)
    e2:SetCountLimit(1, id)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)

    -- pendulum summon
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(1163)
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetRange(LOCATION_FZONE)
    e3:SetCountLimit(1)
    e3:SetCondition(s.e3con)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)
    aux.GlobalCheck(s, function()
        local e3reg = Effect.CreateEffect(c)
        e3reg:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
        e3reg:SetCode(EVENT_SPSUMMON_SUCCESS)
        e3reg:SetOperation(s.e3regop)
        Duel.RegisterEffect(e3reg, 0)
    end)
end

function s.e2filter(c)
    if not c:IsAbleToHand() then return false end
    return c:IsSetCard(SET_ODD_EYES) or c:ListsCode(CARD_ZARC)
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    local loc = LOCATION_DECK
    if Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode, CARD_ZARC), tp, LOCATION_ONFIELD, 0, 1, nil) then loc = loc + LOCATION_GRAVE end

    if chk == 0 then
        return Duel.IsExistingMatchingCard(Card.IsFaceup, tp, LOCATION_ONFIELD, 0, 1, e:GetHandler()) and
                   Duel.IsExistingMatchingCard(s.e2filter, tp, loc, 0, 1, nil)
    end

    Duel.SetOperationInfo(0, CATEGORY_DESTROY, nil, 1, 0, LOCATION_ONFIELD)
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, loc)
    Duel.SetChainLimit(aux.FALSE)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) then return end

    local g = Utility.SelectMatchingCard(HINTMSG_DESTROY, tp, Card.IsFaceup, tp, LOCATION_ONFIELD, 0, 1, 1, c)
    Duel.HintSelection(g)

    if Duel.Destroy(g, REASON_EFFECT) ~= 0 then
        local loc = LOCATION_DECK
        if Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode, CARD_ZARC), tp, LOCATION_ONFIELD, 0, 1, nil) then
            loc = loc + LOCATION_GRAVE
        end
        local sg = Utility.SelectMatchingCard(HINTMSG_ATOHAND, tp, aux.NecroValleyFilter(s.e2filter), tp, loc, 0, 1, 1, g)
        if #sg > 0 then
            Duel.SendtoHand(sg, nil, REASON_EFFECT)
            Duel.ConfirmCards(1 - tp, sg)
        end
    end
end

function s.e3regop(e, tp, eg, ep, ev, re, r, rp)
    for tc in eg:Iter() do
        local sumtp = tc:GetSummonPlayer()
        if tc:IsSummonLocation(LOCATION_EXTRA) and tc:IsType(TYPE_PENDULUM) and tc:IsPreviousPosition(POS_FACEDOWN) and tc:IsFaceup() and
            tc:GetOwner() == sumtp then Duel.RegisterFlagEffect(sumtp, id, RESET_PHASE + PHASE_END, 0, 1) end
    end
end

function s.e3con(e, tp, eg, ep, ev, re, r, rp) return Duel.GetFlagEffect(tp, id) ~= 0 end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsPlayerCanPendulumSummon(tp) end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_HAND + LOCATION_EXTRA)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp) Duel.PendulumSummon(tp) end
