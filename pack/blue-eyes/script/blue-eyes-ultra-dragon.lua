-- Blue-Eyes Ultra Dragon
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {CARD_BLUEEYES_W_DRAGON}
s.material_setcode = {SET_BLUE_EYES}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- fusion summon
    Fusion.AddProcMixN(c, false, false, CARD_BLUEEYES_W_DRAGON, 3)

    -- untargetable & indes
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e1:SetRange(LOCATION_MZONE)
    e1:SetValue(aux.tgoval)
    c:RegisterEffect(e1)
    local e1b = e1:Clone()
    e1b:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e1b:SetValue(function(e, re, rp) return rp ~= e:GetHandlerPlayer() end)
    c:RegisterEffect(e1b)

    -- destroy
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 1))
    e2:SetCategory(CATEGORY_DESTROY)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1)
    e2:SetCost(s.e2cost)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)
    local e2reg = Effect.CreateEffect(c)
    e2reg:SetType(EFFECT_TYPE_SINGLE)
    e2reg:SetCode(EFFECT_MATERIAL_CHECK)
    e2reg:SetValue(s.e2matcheck)
    c:RegisterEffect(e2reg)

    -- multi attack
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 2))
    e3:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_DAMAGE_STEP_END)
    e3:SetCountLimit(1, id)
    e3:SetCondition(s.e3con)
    e3:SetCost(s.e3cost)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)
    aux.GlobalCheck(s, function()
        local e3check = Effect.CreateEffect(c)
        e3check:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
        e3check:SetCode(EVENT_ATTACK_ANNOUNCE)
        e3check:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
            local tc = eg:GetFirst()
            if tc:GetFlagEffect(id) > 0 then return end
            s[ep] = s[ep] + 1
            tc:RegisterFlagEffect(id, RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END, 0, 1)
        end)
        Duel.RegisterEffect(e3check, 0)
        s[0] = 0
        s[1] = 0
        aux.AddValuesReset(function()
            s[0] = 0
            s[1] = 0
        end)
    end)
end

function s.e2matcheck(e, c)
    if c:GetMaterial():IsExists(Card.IsType, 1, nil, TYPE_NORMAL) then
        c:RegisterFlagEffect(id, RESET_EVENT | RESETS_STANDARD & ~(RESET_TOFIELD | RESET_TEMP_REMOVE | RESET_LEAVE), EFFECT_FLAG_CLIENT_HINT, 1, 0,
            aux.Stringid(id, 0))
    end
end

function s.e2cost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return c:GetAttackAnnouncedCount() == 0 end

    local ec1 = Effect.CreateEffect(c)
    ec1:SetDescription(3206)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_OATH + EFFECT_FLAG_CLIENT_HINT)
    ec1:SetCode(EFFECT_CANNOT_ATTACK)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
    c:RegisterEffect(ec1)
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    local c = e:GetHandler()
    if chk == 0 then return Duel.IsExistingTarget(aux.TRUE, tp, LOCATION_ONFIELD, LOCATION_ONFIELD, 1, c) end

    local max = 1
    if c:GetFlagEffect(id) ~= 0 then max = 3 end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_DESTROY)
    local g = Duel.SelectTarget(tp, aux.TRUE, tp, LOCATION_ONFIELD, LOCATION_ONFIELD, 1, max, c)
    Duel.SetOperationInfo(0, CATEGORY_DESTROY, g, #g, 0, 0)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local g = Duel.GetTargetCards(e):Filter(Card.IsRelateToEffect, nil, e)
    if #g > 0 then Duel.Destroy(g, REASON_EFFECT) end
end

function s.e3filter(c) return c:IsRace(RACE_DRAGON) and c:IsType(TYPE_FUSION) and c:IsAbleToGraveAsCost() end

function s.e3con(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    return c:IsSummonType(SUMMON_TYPE_FUSION) and Duel.GetAttacker() == c
end

function s.e3cost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return s[tp] <= 1 and Duel.IsExistingMatchingCard(s.e3filter, tp, LOCATION_EXTRA, 0, 1, nil) end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOGRAVE)
    local g = Utility.SelectMatchingCard(HINTMSG_TOGRAVE, tp, s.e3filter, tp, LOCATION_EXTRA, 0, 1, 1, nil)
    Duel.SendtoGrave(g, REASON_COST)

    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_FIELD)
    ec1:SetProperty(EFFECT_FLAG_OATH)
    ec1:SetCode(EFFECT_CANNOT_ATTACK)
    ec1:SetTargetRange(LOCATION_MZONE, 0)
    ec1:SetTarget(function(e, c) return e:GetLabel() ~= c:GetFieldID() end)
    ec1:SetLabel(c:GetFieldID())
    ec1:SetReset(RESET_PHASE + PHASE_END)
    Duel.RegisterEffect(ec1, tp)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) then return end

    local ec1 = Effect.CreateEffect(c)
    ec1:SetDescription(aux.Stringid(id, 3))
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_CLIENT_HINT)
    ec1:SetCode(EFFECT_EXTRA_ATTACK)
    ec1:SetValue(2)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
    c:RegisterEffect(ec1)
end
