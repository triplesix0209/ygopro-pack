-- Red Synchron
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {10723472, CARD_RED_DRAGON_ARCHFIEND}
s.listed_series = {SET_RED_DRAGON_ARCHFIEND}

function s.initial_effect(c)
    -- hand synchro
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    e1:SetCode(EFFECT_HAND_SYNCHRO)
    e1:SetLabel(id)
    e1:SetValue(s.e1val)
    c:RegisterEffect(e1)

    -- gain effect
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
    e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
    e2:SetCode(EVENT_BE_MATERIAL)
    e2:SetCondition(s.e2con)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)

    -- search
    local e3 = Effect.CreateEffect(c)
    e3:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH)
    e3:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetCode(EVENT_BE_MATERIAL)
    e3:SetCountLimit(1, id)
    e3:SetCondition(s.e3con)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)
end

function s.e1val(e, tc, sc)
    local c = e:GetHandler()
    if tc:IsLocation(LOCATION_HAND) then
        local ec1 = Effect.CreateEffect(c)
        ec1:SetType(EFFECT_TYPE_SINGLE)
        ec1:SetCode(EFFECT_HAND_SYNCHRO + EFFECT_SYNCHRO_CHECK)
        ec1:SetLabel(id)
        ec1:SetTarget(s.e1chktg)
        tc:RegisterEffect(ec1)
        tc:RegisterFlagEffect(id, RESET_EVENT + RESETS_STANDARD, 0, 1)
        return true
    else
        return false
    end
end

function s.e1chktg(e, c, sg, tg, ntg, tsg, ntsg)
    if c then
        local res = true
        if sg:IsExists(s.e1chk, 1, c) or (not tg:IsExists(s.e1chk2, 1, c) and not ntg:IsExists(s.e1chk2, 1, c) and not sg:IsExists(s.e1chk2, 1, c)) then
            return false
        end
        local trg = tg:Filter(s.e1chk, nil)
        local ntrg = ntg:Filter(s.e1chk, nil)
        return res, trg, ntrg
    else
        return true
    end
end

function s.e1chk(c)
    if not c:IsHasEffect(EFFECT_HAND_SYNCHRO + EFFECT_SYNCHRO_CHECK) then return false end
    local te = {c:GetCardEffect(EFFECT_HAND_SYNCHRO + EFFECT_SYNCHRO_CHECK)}
    for i = 1, #te do
        local e = te[i]
        if e:GetLabel() ~= id then return false end
    end
    return true
end

function s.e1chk2(c)
    if not c:IsHasEffect(EFFECT_HAND_SYNCHRO) or c:IsHasEffect(EFFECT_HAND_SYNCHRO + EFFECT_SYNCHRO_CHECK) then return false end
    local te = {c:GetCardEffect(EFFECT_HAND_SYNCHRO)}
    for i = 1, #te do
        local e = te[i]
        if e:GetLabel() == id then return true end
    end
    return false
end

function s.e2con(e, tp, eg, ep, ev, re, r, rp) return r == REASON_SYNCHRO end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local rc = c:GetReasonCard()

    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_FIELD)
    ec1:SetCode(EFFECT_CANNOT_INACTIVATE)
    ec1:SetRange(LOCATION_MZONE)
    ec1:SetTargetRange(1, 0)
    ec1:SetValue(function(e, ct)
        local te = Duel.GetChainInfo(ct, CHAININFO_TRIGGERING_EFFECT)
        return te:GetHandler() == e:GetHandler()
    end)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD - RESET_TOFIELD + RESET_PHASE + PHASE_END)
    rc:RegisterEffect(ec1)
    local ec2 = ec1:Clone()
    ec2:SetCode(EFFECT_CANNOT_DISEFFECT)
    rc:RegisterEffect(ec2)

    rc:RegisterFlagEffect(id, RESET_EVENT + RESETS_STANDARD - RESET_TOFIELD + RESET_PHASE + PHASE_END, EFFECT_FLAG_CLIENT_HINT, 1, 0,
        aux.Stringid(id, 0))
end

function s.e3filter(c)
    if not c:IsAbleToHand() then return false end
    return c:IsCode(10723472) or (c:IsSpellTrap() and (c:ListsCode(CARD_RED_DRAGON_ARCHFIEND) or c:ListsArchetype(SET_RED_DRAGON_ARCHFIEND)))
end

function s.e3con(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local rc = c:GetReasonCard()
    return c:IsLocation(LOCATION_GRAVE) and (r & REASON_SYNCHRO) == REASON_SYNCHRO and rc:IsRace(RACE_DRAGON) and rc:IsLevel(7, 8)
end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.e3filter, tp, LOCATION_DECK + LOCATION_GRAVE, 0, 1, nil) end
    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK + LOCATION_GRAVE)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local g = Utility.SelectMatchingCard(HINTMSG_ATOHAND, tp, aux.NecroValleyFilter(s.e3filter), tp, LOCATION_DECK + LOCATION_GRAVE, 0, 1, 1, nil)
    if #g > 0 then
        Duel.SendtoHand(g, nil, REASON_EFFECT)
        Duel.ConfirmCards(1 - tp, g)
    end
end
