-- Odd-Eyes Arc Pendulumgraph Dragon
Duel.LoadScript("util.lua")
local s, id = GetID()

function s.initial_effect(c)
    Pendulum.AddProcedure(c)

    -- reduce damage
    local pe1 = Effect.CreateEffect(c)
    pe1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    pe1:SetCode(EVENT_PRE_BATTLE_DAMAGE)
    pe1:SetRange(LOCATION_PZONE)
    pe1:SetCondition(s.pe1con)
    pe1:SetOperation(s.pe1op)
    c:RegisterEffect(pe1)

    -- search
    local pe2 = Effect.CreateEffect(c)
    pe2:SetDescription(aux.Stringid(id, 1))
    pe2:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH)
    pe2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    pe2:SetProperty(EFFECT_FLAG_DAMAGE_STEP + EFFECT_FLAG_DELAY)
    pe2:SetCode(EVENT_DESTROYED)
    pe2:SetRange(LOCATION_PZONE)
    pe2:SetCountLimit(1, id)
    pe2:SetCondition(s.pe2con)
    pe2:SetTarget(s.pe2tg)
    pe2:SetOperation(s.pe2op)
    c:RegisterEffect(pe2)

    -- second attack
    local me1 = Effect.CreateEffect(c)
    me1:SetDescription(aux.Stringid(id, 2))
    me1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    me1:SetCode(EVENT_BATTLE_DESTROYING)
    me1:SetCondition(s.me1con)
    me1:SetTarget(s.me1tg)
    me1:SetOperation(s.me1op)
    c:RegisterEffect(me1)

    -- place into pendulum zone
    local me2 = Effect.CreateEffect(c)
    me2:SetDescription(2203)
    me2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    me2:SetCode(EVENT_DESTROYED)
    me2:SetProperty(EFFECT_FLAG_DELAY)
    me2:SetCondition(function(e, tp, eg, ep, ev, re, r, rp) return e:GetHandler():IsPreviousLocation(LOCATION_MZONE) and e:GetHandler():IsFaceup() end)
    me2:SetTarget(function(e, tp, eg, ep, ev, re, r, rp, chk) if chk == 0 then return Duel.CheckPendulumZones(tp) end end)
    me2:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
        if not e:GetHandler():IsRelateToEffect(e) or not Duel.CheckPendulumZones(tp) then return end
        Duel.MoveToField(e:GetHandler(), tp, tp, LOCATION_PZONE, POS_FACEUP, true)
    end)
    c:RegisterEffect(me2)
end

function s.pe1con(e, tp, eg, ep, ev, re, r, rp) return ep == tp and Duel.GetFlagEffect(tp, id) == 0 end

function s.pe1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if Duel.GetFlagEffect(tp, id) ~= 0 then return end
    if Duel.SelectEffectYesNo(tp, c, aux.Stringid(id, 0)) then
        Utility.HintCard(c)
        Duel.RegisterFlagEffect(tp, id, RESET_PHASE + PHASE_END, 0, 1)
        Duel.ChangeBattleDamage(tp, 0)
    end
end

function s.pe2filter(c) return c:IsType(TYPE_PENDULUM) and c:IsAttackBelow(1500) and c:IsAbleToHand() end

function s.pe2con(e, tp, eg, ep, ev, re, r, rp)
    return eg:IsExists(function(c, tp)
        return c:IsReason(REASON_BATTLE + REASON_EFFECT) and c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousControler(tp)
    end, 1, nil, tp)
end

function s.pe2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.pe2filter, tp, LOCATION_DECK, 0, 1, nil) end
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK + LOCATION_GRAVE)
end

function s.pe2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) then return end

    local g = Utility.SelectMatchingCard(HINTMSG_ATOHAND, tp, s.pe2filter, tp, LOCATION_DECK, 0, 1, 1, nil)
    if #g > 0 then
        Duel.SendtoHand(g, nil, REASON_EFFECT)
        Duel.ConfirmCards(1 - tp, g)
    end
end

function s.me1con(e, tp, eg, ep, ev, re, r, rp) return aux.bdocon(e, tp, eg, ep, ev, re, r, rp) and Duel.GetAttacker() == e:GetHandler() end

function s.me1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return c:IsRelateToBattle() and not c:IsHasEffect(EFFECT_EXTRA_ATTACK) end
end

function s.me1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not (c:IsRelateToBattle() and c:IsRelateToEffect(e) and c:IsFaceup()) then return end

    local ec1 = Effect.CreateEffect(c)
    ec1:SetDescription(3201)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_CLIENT_HINT)
    ec1:SetCode(EFFECT_EXTRA_ATTACK)
    ec1:SetValue(1)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_BATTLE)
    c:RegisterEffect(ec1)
end
