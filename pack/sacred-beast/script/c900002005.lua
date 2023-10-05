-- Successor of Phantasmal Lord
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {6007213, 32491822, 69890967}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- fusion summon
    Fusion.AddProcMix(c, true, true, {6007213, 32491822, 69890967}, aux.FilterBoolFunctionEx(Card.IsType, TYPE_EFFECT))
    Fusion.AddContactProc(c, s.fusfilter, s.fusop, s.splimit)

    -- indes
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
    e1:SetValue(1)
    c:RegisterEffect(e1)

    -- apply effects
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)
    local e2reg = Effect.CreateEffect(c)
    e2reg:SetType(EFFECT_TYPE_SINGLE)
    e2reg:SetCode(EFFECT_MATERIAL_CHECK)
    e2reg:SetValue(s.e2val)
    e2reg:SetLabelObject(e2)
    c:RegisterEffect(e2reg)
end

function s.splimit(e, se, sp, st) return not e:GetHandler():IsLocation(LOCATION_EXTRA) end

function s.fusfilter(tp) return Duel.GetMatchingGroup(Card.IsAbleToDeckOrExtraAsCost, tp, LOCATION_ONFIELD, 0, nil) end

function s.fusop(g, tp)
    Duel.ConfirmCards(1 - tp, g)
    Duel.Remove(g, POS_FACEUP, REASON_COST + REASON_MATERIAL)
end

function s.e2val(e, c)
    local g = c:GetMaterial()
    local flag = 0
    if g:IsExists(Card.IsCode, 1, nil, 6007213) then flag = flag + 1 end
    if g:IsExists(Card.IsCode, 1, nil, 32491822) then flag = flag + 2 end
    if g:IsExists(Card.IsCode, 1, nil, 69890967) then flag = flag + 4 end
    e:GetLabelObject():SetLabel(flag)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local flag = e:GetLabel()

    -- uria
    if (flag & 1) > 0 then
        local ec1 = Effect.CreateEffect(c)
        ec1:SetType(EFFECT_TYPE_SINGLE)
        ec1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
        ec1:SetCode(EFFECT_IMMUNE_EFFECT)
        ec1:SetRange(LOCATION_MZONE)
        ec1:SetValue(function(e, te) return te:IsActiveType(TYPE_TRAP) and te:GetOwnerPlayer() ~= e:GetHandlerPlayer() end)
        ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
        c:RegisterEffect(ec1)
        local ec1b = ec1:Clone()
        ec1b:SetCode(EFFECT_UPDATE_ATTACK)
        ec1b:SetCondition(function(e) return Duel.GetTurnPlayer() == e:GetHandlerPlayer() end)
        ec1b:SetValue(function(e, c)
            local ct = Duel.GetMatchingGroupCount(function(c) return c:GetType() == TYPE_TRAP + TYPE_CONTINUOUS end,
                c:GetControler(), LOCATION_GRAVE, 0, nil)
            return ct * 1000
        end)
        c:RegisterEffect(ec1b)
        c:RegisterFlagEffect(id, RESET_EVENT + RESETS_STANDARD, EFFECT_FLAG_CLIENT_HINT, 1, 0, aux.Stringid(id, 0))
    end

    -- hamon
    if (flag & 2) > 0 then
        local ec2 = Effect.CreateEffect(c)
        ec2:SetType(EFFECT_TYPE_SINGLE)
        ec2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
        ec2:SetCode(EFFECT_IMMUNE_EFFECT)
        ec2:SetRange(LOCATION_MZONE)
        ec2:SetValue(function(e, te) return te:IsActiveType(TYPE_SPELL) and te:GetOwnerPlayer() ~= e:GetHandlerPlayer() end)
        ec2:SetReset(RESET_EVENT + RESETS_STANDARD)
        c:RegisterEffect(ec2)
        local ec2b = ec2:Clone()
        ec2b:SetCode(EFFECT_UPDATE_ATTACK)
        ec2b:SetCondition(function(e) return Duel.GetTurnPlayer() == e:GetHandlerPlayer() end)
        ec2b:SetValue(4000)
        c:RegisterEffect(ec2b)
        c:RegisterFlagEffect(id, RESET_EVENT + RESETS_STANDARD, EFFECT_FLAG_CLIENT_HINT, 1, 0, aux.Stringid(id, 1))
    end

    -- raviel
    if (flag & 4) > 0 then
        local ec3 = Effect.CreateEffect(c)
        ec3:SetType(EFFECT_TYPE_SINGLE)
        ec3:SetCode(EFFECT_PIERCE)
        ec3:SetReset(RESET_EVENT + RESETS_STANDARD)
        c:RegisterEffect(ec3)
        local ec3b = ec3:Clone()
        ec3b:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
        ec3b:SetCode(EFFECT_UPDATE_ATTACK)
        ec3b:SetRange(LOCATION_MZONE)
        ec3b:SetCondition(function(e) return Duel.GetTurnPlayer() == e:GetHandlerPlayer() end)
        ec3b:SetValue(4000)
        c:RegisterEffect(ec3b)
        c:RegisterFlagEffect(id, RESET_EVENT + RESETS_STANDARD, EFFECT_FLAG_CLIENT_HINT, 1, 0, aux.Stringid(id, 2))
    end
end
