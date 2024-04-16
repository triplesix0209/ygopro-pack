-- Asgard the Aesir Realm
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_series = {0x4b, 0x42}

function s.initial_effect(c)
    -- activate
    local act = Effect.CreateEffect(c)
    act:SetType(EFFECT_TYPE_ACTIVATE)
    act:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(act)

    -- cannot be target
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e1:SetRange(LOCATION_FZONE)
    e1:SetCondition(function(e)
        return Duel.IsExistingMatchingCard(
                   aux.FilterFaceupFunction(Card.IsSetCard, 0x4b),
                   e:GetHandlerPlayer(), LOCATION_MZONE, 0, 1, nil)
    end)
    e1:SetValue(aux.tgoval)
    c:RegisterEffect(e1)

    -- cannot banish & cannot be target
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_CANNOT_REMOVE)
    e2:SetRange(LOCATION_FZONE)
    e2:SetTargetRange(LOCATION_GRAVE, 0)
    e2:SetTarget(function(e, c) return c:IsSetCard(0x4b) end)
    c:RegisterEffect(e2)
    local e2b = e2:Clone()
    e2b:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
    e2b:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e2b:SetValue(aux.tgoval)
    c:RegisterEffect(e2b)

    -- search
    local e3 = Effect.CreateEffect(c)
    e3:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH)
    e3:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_PREDRAW)
    e3:SetRange(LOCATION_FZONE)
    e3:SetCondition(s.e3con)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)

    -- change effect
    local e4 = Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id, 0))
    e4:SetType(EFFECT_TYPE_QUICK_O)
    e4:SetCode(EVENT_CHAINING)
    e4:SetRange(LOCATION_FZONE)
    e4:SetCountLimit(1, id)
    e4:SetCondition(s.e4con)
    e4:SetCost(s.e4cost)
    e4:SetTarget(s.e4tg)
    e4:SetOperation(s.e4op)
    c:RegisterEffect(e4)
end

function s.e3filter(c)
    return c:IsSetCard(0x42) and c:IsType(TYPE_TUNER) and c:IsAbleToHand()
end

function s.e3con(e, tp, eg, ep, ev, re, r, rp)
    return Duel.GetTurnPlayer() == tp and
               Duel.GetFieldGroupCount(tp, LOCATION_DECK, 0) > 0 and
               Duel.GetDrawCount(tp) > 0 and
               not Duel.IsExistingMatchingCard(
                   aux.FilterFaceupFunction(Card.IsSetCard, 0x4b), tp,
                   LOCATION_MZONE, 0, 1, nil)

end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.e3filter, tp, LOCATION_DECK, 0, 1,
                                           nil)
    end

    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK)
    Duel.SetChainLimit(function(e, ep, tp) return tp == ep end)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) then return end

    local dt = Duel.GetDrawCount(tp)
    if dt == 0 then return end
    _replace_count = 1
    _replace_max = dt
    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_FIELD)
    ec1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    ec1:SetCode(EFFECT_DRAW_COUNT)
    ec1:SetTargetRange(1, 0)
    ec1:SetValue(0)
    ec1:SetReset(RESET_PHASE + PHASE_DRAW)
    Duel.RegisterEffect(ec1, tp)
    if _replace_count > _replace_max then return end

    local g =
        Duel.GetMatchingGroup(s.e3filter, tp, LOCATION_DECK, 0, nil):RandomSelect(
            tp, 1)
    if #g > 0 then
        Duel.SendtoHand(g, nil, REASON_EFFECT)
        Duel.ConfirmCards(1 - tp, g)
    end
end

function s.e4filter1(c) return c:IsSetCard(0x42) and c:IsAbleToGraveAsCost() end

function s.e4filter2(c) return c:IsFaceup() and not c:IsType(TYPE_FIELD) end

function s.e4con(e, tp, eg, ep, ev, re, r, rp)
    return rp == 1 - tp and
               Duel.IsExistingMatchingCard(
                   aux.FilterFaceupFunction(Card.IsSetCard, 0x4b), tp,
                   LOCATION_MZONE, 0, 1, nil)
end

function s.e4cost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.e4filter1, tp,
                                           LOCATION_HAND + LOCATION_DECK, 0, 1,
                                           nil)
    end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOGRAVE)
    local g = Duel.SelectMatchingCard(tp, s.e4filter1, tp,
                                      LOCATION_HAND + LOCATION_DECK, 0, 1, 1,
                                      nil)
    Duel.SendtoGrave(g, REASON_COST)
end

function s.e4tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.e4filter2, tp, LOCATION_ONFIELD, 0,
                                           1, nil)
    end
end

function s.e4op(e, tp, eg, ep, ev, re, r, rp)
    local g = Group.CreateGroup()
    Duel.ChangeTargetCard(ev, g)
    Duel.ChangeChainOperation(ev, s.e4desop)
end

function s.e4desop(e, tp, eg, ep, ev, re, r, rp)
    Duel.Hint(HINT_SELECTMSG, 1 - tp, HINTMSG_DESTROY)
    local g = Duel.SelectMatchingCard(1 - tp, s.e4filter2, 1 - tp,
                                      LOCATION_ONFIELD, 0, 1, 1, nil)
    if #g > 0 then Duel.Destroy(g, REASON_EFFECT) end
end
