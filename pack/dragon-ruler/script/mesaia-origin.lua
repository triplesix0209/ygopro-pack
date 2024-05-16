-- Mesaia, Origin of Dragons
Duel.LoadScript("util.lua")
local s, id = GetID()

function s.initial_effect(c)
    Pendulum.AddProcedure(c)

    -- pendulum summon limit
    local pe1 = Effect.CreateEffect(c)
    pe1:SetType(EFFECT_TYPE_FIELD)
    pe1:SetProperty(EFFECT_FLAG_PLAYER_TARGET + EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_CANNOT_NEGATE)
    pe1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    pe1:SetRange(LOCATION_PZONE)
    pe1:SetTargetRange(1, 0)
    pe1:SetTarget(function(e, c, tp, sumtp, sumpos) return not c:IsRace(RACE_DRAGON) and (sumtp & SUMMON_TYPE_PENDULUM) == SUMMON_TYPE_PENDULUM end)
    c:RegisterEffect(pe1)

    -- return from the pendulum zone
    local pe2 = Effect.CreateEffect(c)
    pe2:SetDescription(aux.Stringid(id, 0))
    pe2:SetCategory(CATEGORY_TOHAND)
    pe2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_F)
    pe2:SetCode(EVENT_SPSUMMON_SUCCESS)
    pe2:SetRange(LOCATION_PZONE)
    pe2:SetCondition(s.pe2con)
    pe2:SetTarget(s.pe2tg)
    pe2:SetOperation(s.pe2op)
    c:RegisterEffect(pe2)

    -- change attribute
    local me1 = Effect.CreateEffect(c)
    me1:SetDescription(aux.Stringid(id, 1))
    me1:SetType(EFFECT_TYPE_IGNITION)
    me1:SetRange(LOCATION_HAND)
    me1:SetCountLimit(1, {id, 1})
    me1:SetTarget(s.me1tg)
    me1:SetOperation(s.me1op)
    c:RegisterEffect(me1)

    -- shuffle
    local me2 = Effect.CreateEffect(c)
    me2:SetCategory(CATEGORY_TODECK)
    me2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_F)
    me2:SetCode(EVENT_PHASE + PHASE_END)
    me2:SetRange(LOCATION_REMOVED)
    me2:SetCountLimit(1, {id, 2})
    me2:SetCondition(s.me2con)
    me2:SetTarget(s.me2tg)
    me2:SetOperation(s.me2op)
    c:RegisterEffect(me2)
end

function s.pe2filter(c, tp) return c:IsSummonType(SUMMON_TYPE_PENDULUM) and c:IsSummonPlayer(tp) end

function s.pe2con(e, tp, eg, ep, ev, re, r, rp) return eg:IsExists(s.pe2filter, 1, nil, tp) end

function s.pe2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return true end
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, e:GetHandler(), 1, 0, 0)
end

function s.pe2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) then return end
    Duel.SendtoHand(c, nil, REASON_EFFECT)
end

function s.me1filter(c) return not c:IsAttribute(ATTRIBUTE_DIVINE) and c:IsRace(RACE_DRAGON) and not c:IsPublic() end

function s.me1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return not c:IsPublic() and Duel.IsExistingMatchingCard(s.me1filter, tp, LOCATION_HAND, 0, 1, c) end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_CONFIRM)
    local g = Duel.SelectMatchingCard(tp, s.me1filter, tp, LOCATION_HAND, 0, 1, 1, c)
    Duel.ConfirmCards(1 - tp, g)
    Duel.ShuffleHand(tp)
    Duel.SetTargetCard(g)
end

function s.me1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Duel.GetFirstTarget()
    if not tc or not tc:IsRelateToEffect(e) then return end

    local ec1 = Effect.CreateEffect(c)
    ec1:SetDescription(aux.Stringid(id, 2))
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
    ec1:SetCode(EFFECT_PUBLIC)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
    c:RegisterEffect(ec1)
    local ec2 = ec1:Clone()
    ec2:SetCode(EFFECT_CHANGE_ATTRIBUTE)
    ec2:SetValue(tc:GetAttribute())
    c:RegisterEffect(ec2)
end

function s.me2con(e, tp, eg, ep, ev, re, r, rp) return Duel.GetTurnCount() == e:GetHandler():GetTurnID() end

function s.me2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return c:IsAbleToDeck() end
    Duel.SetOperationInfo(0, CATEGORY_TODECK, c, 1, 0, 0)
end

function s.me2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) then return end
    Duel.SendtoDeck(c, tp, SEQ_DECKSHUFFLE, REASON_EFFECT)
end
