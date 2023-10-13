-- The Palladium Dragoon
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {71703785, CARD_BLUEEYES_W_DRAGON}
s.material_setcode = {SET_PALLADIUM}

Duel.EnableUnofficialProc(PROC_CANNOT_BATTLE_INDES)

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- fusion summon
    Fusion.AddProcMix(c, true, true, 71703785, s.fusfilter)

    -- special summon limit
    local splimit = Effect.CreateEffect(c)
    splimit:SetType(EFFECT_TYPE_SINGLE)
    splimit:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    splimit:SetCode(EFFECT_SPSUMMON_CONDITION)
    splimit:SetValue(function(e, se, sp, st) return not e:GetHandler():IsLocation(LOCATION_EXTRA) or aux.fuslimit(e, se, sp, st) end)
    c:RegisterEffect(splimit)

    -- indes & untargetable
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e1:SetValue(1)
    c:RegisterEffect(e1)
    local e1b = e1:Clone()
    e1b:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e1b:SetValue(aux.tgoval)
    c:RegisterEffect(e1b)

    -- negate
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 0))
    e2:SetCategory(CATEGORY_NEGATE + CATEGORY_DESTROY)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP + EFFECT_FLAG_DAMAGE_CAL)
    e2:SetCode(EVENT_CHAINING)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1)
    e2:SetCondition(s.e2con)
    e2:SetCost(s.e2cost)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)

    -- disable
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
    e3:SetCode(EVENT_BATTLED)
    e3:SetRange(LOCATION_MZONE)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)

    -- register effect
    local eff = Effect.CreateEffect(c)
    eff:SetType(EFFECT_TYPE_CONTINUOUS + EFFECT_TYPE_SINGLE)
    eff:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    eff:SetCode(EVENT_SPSUMMON_SUCCESS)
    eff:SetCondition(s.effcon)
    eff:SetOperation(s.effop)
    c:RegisterEffect(eff)
    local effmat = Effect.CreateEffect(c)
    effmat:SetType(EFFECT_TYPE_SINGLE)
    effmat:SetCode(EFFECT_MATERIAL_CHECK)
    effmat:SetValue(s.effcheck)
    effmat:SetLabelObject(eff)
    c:RegisterEffect(effmat)
end

function s.fusfilter(c, fc, sumtype, tp) return c:IsLevelAbove(8) and c:IsRace(RACE_DRAGON, fc, sumtype, tp) end

function s.e2con(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if c:IsStatus(STATUS_BATTLE_DESTROYED) then return false end
    return re:GetHandler() ~= c and Duel.IsChainNegatable(ev)
end

function s.e2cost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable, tp, LOCATION_HAND, 0, 1, nil) end
    Duel.DiscardHand(tp, Card.IsDiscardable, 1, 1, REASON_COST + REASON_DISCARD)
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return true end

    Duel.SetOperationInfo(0, CATEGORY_NEGATE, eg, 1, 0, 0)
    if re:GetHandler():IsRelateToEffect(re) then Duel.SetOperationInfo(0, CATEGORY_DESTROY, eg, 1, 0, 0) end
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) and Duel.Destroy(eg, REASON_EFFECT) ~= 0 and c:IsRelateToEffect(e) and
        c:IsFaceup() then
        local ec1 = Effect.CreateEffect(c)
        ec1:SetType(EFFECT_TYPE_SINGLE)
        ec1:SetCode(EFFECT_UPDATE_ATTACK)
        ec1:SetValue(1000)
        ec1:SetReset(RESET_EVENT + RESETS_STANDARD_DISABLE)
        c:RegisterEffect(ec1)
    end
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local bc = Duel.GetAttackTarget()
    if bc == c then bc = Duel.GetAttacker() end
    if bc and bc:IsStatus(STATUS_BATTLE_DESTROYED) and bc:IsType(TYPE_EFFECT) and not c:IsStatus(STATUS_BATTLE_DESTROYED) then
        local ec1 = Effect.CreateEffect(c)
        ec1:SetType(EFFECT_TYPE_SINGLE)
        ec1:SetCode(EFFECT_DISABLE)
        ec1:SetReset(RESET_EVENT + RESETS_STANDARD_EXC_GRAVE)
        bc:RegisterEffect(ec1)
    end
end

function s.effcheck(e, c)
    local ct = c:GetMaterial():FilterCount(Card.IsCode, nil, CARD_BLUEEYES_W_DRAGON)
    e:GetLabelObject():SetLabel(ct)
end

function s.effcon(e, tp, eg, ep, ev, re, r, rp) return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION) and e:GetLabel() > 0 end

function s.effop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    c:RegisterFlagEffect(id, RESET_EVENT + (RESETS_STANDARD & ~RESET_TURN_SET), EFFECT_FLAG_CLIENT_HINT, 1, 0, aux.Stringid(id, 1))

    -- always Battle destroy
    local e4 = Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_FIELD)
    e4:SetCode(EFFECT_CANNOT_BATTLE_INDES)
    e4:SetRange(LOCATION_MZONE)
    e4:SetTargetRange(0, LOCATION_MZONE)
    e4:SetTarget(s.e4tg)
    e4:SetValue(s.e4val)
    c:RegisterEffect(e4)

    -- destroy
    local e5 = Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(id, 2))
    e5:SetCategory(CATEGORY_DESTROY)
    e5:SetType(EFFECT_TYPE_IGNITION)
    e5:SetRange(LOCATION_MZONE)
    e5:SetCountLimit(3)
    e5:SetTarget(s.e5tg)
    e5:SetOperation(s.e5op)
    c:RegisterEffect(e5)
end

function s.e4tg(e, c) return not c:IsStatus(STATUS_BATTLE_DESTROYED) end

function s.e4val(e, re) return re:GetOwnerPlayer() ~= e:GetHandlerPlayer() end

function s.e5tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chk == 0 then return Duel.IsExistingMatchingCard(aux.TRUE, tp, 0, LOCATION_ONFIELD, 1, nil) end
    Duel.SetOperationInfo(0, CATEGORY_DESTROY, 0, 1, 0, LOCATION_ONFIELD)
end

function s.e5op(e, tp, eg, ep, ev, re, r, rp)
    local g = Utility.SelectMatchingCard(HINTMSG_DESTROY, tp, aux.TRUE, tp, 0, LOCATION_ONFIELD, 1, 1, nil)
    if #g > 0 then
        Duel.HintSelection(g)
        Duel.Destroy(g, REASON_EFFECT)
    end
end
