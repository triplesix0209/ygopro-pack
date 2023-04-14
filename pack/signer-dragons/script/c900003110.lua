-- Cosmic Star Dragon
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {CARD_STARDUST_DRAGON}
s.synchro_tuner_required = 1
s.synchro_nt_required = 1

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- synhcro summon
    Synchro.AddProcedure(c, aux.FilterBoolFunctionEx(Card.IsType, TYPE_SYNCHRO), 1, 1,
        Synchro.NonTunerEx(Card.IsType, TYPE_SYNCHRO), 1, 1)

    -- accel synchro
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(1172)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP + EFFECT_FLAG_UNCOPYABLE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetRange(LOCATION_EXTRA)
    e1:SetHintTiming(0, TIMING_MAIN_END)
    e1:SetCountLimit(1)
    e1:SetCondition(s.e1con)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- multi attack
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 0))
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1)
    e2:SetCondition(s.e2con)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)

    -- negate effect
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 1))
    e3:SetCategory(CATEGORY_DISABLE + CATEGORY_DESTROY)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_CHAINING)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1)
    e3:SetCondition(s.e3con)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)

    -- banish
    local e4 = Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id, 2))
    e4:SetCategory(CATEGORY_REMOVE)
    e4:SetType(EFFECT_TYPE_QUICK_O)
    e4:SetCode(EVENT_CHAINING)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCountLimit(1, 0, EFFECT_COUNT_CODE_SINGLE)
    e4:SetCondition(s.e4con1)
    e4:SetTarget(s.e4tg)
    e4:SetOperation(s.e4op)
    c:RegisterEffect(e4)
    local e4b = e4:Clone()
    e4b:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    e4b:SetCode(EVENT_ATTACK_ANNOUNCE)
    e4b:SetCondition(s.e4con2)
    c:RegisterEffect(e4b)
    local e4ret = Effect.CreateEffect(c)
    e4ret:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e4ret:SetCode(EVENT_PHASE + PHASE_END)
    e4ret:SetRange(LOCATION_REMOVED)
    e4ret:SetCountLimit(1)
    e4ret:SetCondition(s.e4retcon)
    e4ret:SetOperation(s.e4retop)
    c:RegisterEffect(e4ret)
end

function s.e1filter(c, sc) return c:IsFaceup() and c:IsCode(CARD_STARDUST_DRAGON) and sc:IsSynchroSummonable(c) end

function s.e1con(e, tp, eg, ep, ev, re, r, rp)
    return Duel.GetCurrentPhase() == PHASE_MAIN1 or Duel.GetCurrentPhase() == PHASE_MAIN2
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return Duel.IsExistingMatchingCard(s.e1filter, tp, LOCATION_MZONE, 0, 1, nil, c) end

    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, c, 1, tp, LOCATION_EXTRA)
    Duel.SetChainLimit(function(e, rp, tp) return tp == rp end)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) then return end

    local g = Utility.SelectMatchingCard(HINTMSG_SMATERIAL, tp, s.e1filter, tp, LOCATION_MZONE, 0, 1, 1, nil, c)
    local mc = Utility.GroupSelect(HINTMSG_SMATERIAL, g, tp):GetFirst()
    if not mc then return end

    Duel.SynchroSummon(tp, c, mc)
end

function s.e2con(e, tp, eg, ep, ev, re, r, rp) return
    Duel.IsAbleToEnterBP() and Duel.GetFieldGroupCount(tp, LOCATION_DECK, 0) >= 5 end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    Duel.ConfirmDecktop(tp, 5)
    local ct = Duel.GetDecktopGroup(tp, 5):FilterCount(Card.IsType, nil, TYPE_TUNER)
    Duel.ShuffleDeck(tp)

    if ct > 0 then
        local ec1 = Effect.CreateEffect(c)
        ec1:SetType(EFFECT_TYPE_SINGLE)
        ec1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
        ec1:SetCode(EFFECT_EXTRA_ATTACK)
        ec1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
        ec1:SetValue(ct)
        c:RegisterEffect(ec1)
    end
end

function s.e3con(e, tp, eg, ep, ev, re, r, rp)
    if e == re or e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) or not Duel.IsChainNegatable(ev) then return false end

    if re:IsHasCategory(CATEGORY_NEGATE) and
        Duel.GetChainInfo(ev - 1, CHAININFO_TRIGGERING_EFFECT):IsHasType(EFFECT_TYPE_ACTIVATE) then return false end

    if re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then
        local tg = Duel.GetChainInfo(ev, CHAININFO_TARGET_CARDS)
        if tg and tg:IsExists(Card.IsOnField, 1, nil) then return true end
    end

    local ex, tg, tc = Duel.GetOperationInfo(ev, CATEGORY_DESTROY)
    return ex and tg ~= nil and tc + tg:FilterCount(Card.IsOnField, nil) - #tg > 0
end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    local rc = re:GetHandler()
    if chk == 0 then return true end

    Duel.SetOperationInfo(0, CATEGORY_DISABLE, eg, #eg, 0, 0)
    if rc:IsRelateToEffect(re) and rc:IsDestructable() then Duel.SetOperationInfo(0, CATEGORY_DESTROY, eg, #eg, 0, 0) end
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    if Duel.NegateEffect(ev) and re:GetHandler():IsRelateToEffect(re) then Duel.Destroy(eg, REASON_EFFECT) end
end

function s.e4con1(e, tp, eg, ep, ev, re, r, rp)
    return Duel.GetTurnPlayer() ~= tp and rp == 1 - tp and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
end

function s.e4con2(e, tp, eg, ep, ev, re, r, rp) return Duel.GetTurnPlayer() ~= tp and Duel.GetAttacker():GetControler() ~= tp end

function s.e4tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return c:IsAbleToRemove() end

    Duel.SetOperationInfo(0, CATEGORY_REMOVE, c, 1, 0, 0)
end

function s.e4op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) or Duel.Remove(c, POS_FACEUP, REASON_EFFECT) == 0 then return end

    c:RegisterFlagEffect(id, RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END, 0, 0)
    if Duel.GetAttacker() and Duel.GetAttacker():GetControler() ~= tp and Duel.SelectEffectYesNo(tp, c, aux.Stringid(id, 3)) then
        Duel.NegateAttack()
    else
        local ec1 = Effect.CreateEffect(c)
        ec1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
        ec1:SetCode(EVENT_ATTACK_ANNOUNCE)
        ec1:SetRange(LOCATION_REMOVED)
        ec1:SetLabel(0)
        ec1:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
            if e:GetLabel() ~= 0 or not Duel.SelectEffectYesNo(tp, c, aux.Stringid(id, 3)) then return end

            Utility.HintCard(e:GetHandler())
            Duel.NegateAttack()
            e:SetLabel(1)
        end)
        ec1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
        c:RegisterEffect(ec1)
    end
end

function s.e4retcon(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    return c:GetFlagEffect(id) > 0 and Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and
               c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end

function s.e4retop(e, tp, eg, ep, ev, re, r, rp) Duel.SpecialSummon(e:GetHandler(), 0, tp, tp, false, false, POS_FACEUP) end
