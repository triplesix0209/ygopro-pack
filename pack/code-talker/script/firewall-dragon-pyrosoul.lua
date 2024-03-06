-- Firewall Dragon Pyrosoul
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_series = {0x118}

function s.initial_effect(c)
    c:EnableReviveLimit()
    c:SetUniqueOnField(1, 0, id)

    -- link summon
    Link.AddProcedure(c, aux.FilterBoolFunctionEx(Card.IsRace, RACE_CYBERSE), 2, 99,
        function(g, sc, sumtype, tp) return g:CheckDifferentPropertyBinary(Card.GetAttribute, sc, sumtype, tp) end)

    -- protect
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e1:SetRange(LOCATION_MZONE)
    e1:SetTargetRange(LOCATION_ONFIELD, 0)
    e1:SetTarget(function(e, c) return c == e:GetHandler() or e:GetHandler():GetLinkedGroup():IsContains(c) end)
    e1:SetValue(aux.indoval)
    c:RegisterEffect(e1)
    local e1b = e1:Clone()
    e1b:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1b:SetCode(EFFECT_CANNOT_REMOVE)
    e1b:SetTargetRange(1, 1)
    e1b:SetTarget(function(e, c, rp, r, re)
        local tp = e:GetHandlerPlayer()
        return c:IsControler(tp) and c:IsLocation(LOCATION_ONFIELD) and rp == 1 - tp and r & REASON_EFFECT ~= 0 and
                   (c == e:GetHandler() or e:GetHandler():GetLinkedGroup():IsContains(c))
    end)
    c:RegisterEffect(e1b)

    -- atk up
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_UPDATE_ATTACK)
    e2:SetRange(LOCATION_MZONE)
    e2:SetTargetRange(LOCATION_MZONE, 0)
    e2:SetCondition(function(e) return e:GetHandler():GetMutualLinkedGroupCount() > 0 end)
    e2:SetTarget(function(e, c)
        local g = e:GetHandler():GetMutualLinkedGroup()
        return c == e:GetHandler() or g:IsContains(c)
    end)
    e2:SetValue(function(e, c) return c:GetMutualLinkedGroupCount() * 500 end)
    c:RegisterEffect(e2)

    -- place
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 0))
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetProperty(EFFECT_FLAG_CARD_TARGET + EFFECT_FLAG_NO_TURN_RESET)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1, id)
    e3:SetCost(s.e3cost)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)
end

function s.e3checkzone(p, zone) return Duel.GetLocationCount(p, LOCATION_SZONE, p, REASON_EFFECT, zone) > 0 end

function s.e3filter(c, zone)
    local p = c:GetOwner()
    return c:IsLinkMonster() and c:CheckUniqueOnField(p, LOCATION_SZONE) and (c:IsLocation(LOCATION_MZONE) or not c:IsForbidden()) and
               s.e3checkzone(p, zone)
end

function s.e3cost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.CheckLPCost(tp, 2000) end
    Duel.PayLPCost(tp, 2000)
end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    local zone = c:GetLinkedZone() >> 8
    if chk == 0 then return Duel.IsExistingTarget(s.e3filter, tp, LOCATION_MZONE, 0, 1, c, zone) end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TARGET)
    Duel.SelectTarget(tp, s.e3filter, tp, LOCATION_MZONE, 0, 1, 1, c, zone)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Duel.GetFirstTarget()
    if not tc:IsRelateToEffect(e) or tc:IsImmuneToEffect(e) then return end

    local zone = c:GetLinkedZone() >> 8
    if tc:IsLocation(LOCATION_MZONE) and not s.e3checkzone(tc:GetOwner(), zone) then
        Duel.SendtoGrave(tc, REASON_RULE, nil, PLAYER_NONE)
    elseif Duel.MoveToField(tc, tp, tc:GetOwner(), LOCATION_SZONE, POS_FACEUP, true, zone) then
        local ec1 = Effect.CreateEffect(c)
        ec1:SetType(EFFECT_TYPE_SINGLE)
        ec1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
        ec1:SetCode(EFFECT_CHANGE_TYPE)
        ec1:SetValue(TYPE_SPELL + TYPE_LINK)
        ec1:SetReset(RESET_EVENT + (RESETS_STANDARD & ~RESET_TURN_SET))
        tc:RegisterEffect(ec1)

        if c:GetMutualLinkedGroup():IsContains(tc) then
            local code = tc:GetOriginalCode()
            c:CopyEffect(code, RESET_EVENT + RESETS_STANDARD, 1)
        end
    end
end
