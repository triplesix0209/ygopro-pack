-- Messiah's Elysium
Duel.LoadScript("util.lua")
Duel.LoadScript("util_messiah.lua")
local s, id = GetID()

function s.initial_effect(c)
    -- activate
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1, id, EFFECT_COUNT_CODE_OATH)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- cannot be targeted & immune
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE + EFFECT_FLAG_CANNOT_DISABLE)
    e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e2:SetRange(LOCATION_FZONE)
    e2:SetTargetRange(LOCATION_ONFIELD, 0)
    e2:SetCondition(function(e)
        return Duel.IsExistingMatchingCard(function(c)
            return c:IsFaceup() and (c:GetType() & TYPE_LINK) ~= 0 and (c:GetType() & TYPE_PENDULUM) ~= 0
        end, e:GetHandlerPlayer(), LOCATION_ONFIELD, 0, 1, nil)
    end)
    e2:SetTarget(function(e, c)
        return c:IsFaceup() and (c == e:GetHandler() or ((c:GetType() & TYPE_LINK) ~= 0 and (c:GetType() & TYPE_PENDULUM) ~= 0))
    end)
    e2:SetValue(aux.tgoval)
    c:RegisterEffect(e2)
    local e2b = Effect.CreateEffect(c)
    e2b:SetType(EFFECT_TYPE_SINGLE)
    e2b:SetProperty(EFFECT_FLAG_SINGLE_RANGE + EFFECT_FLAG_CANNOT_DISABLE)
    e2b:SetCode(EFFECT_IMMUNE_EFFECT)
    e2b:SetRange(LOCATION_FZONE)
    e2b:SetCondition(function(e)
        return Duel.IsExistingMatchingCard(function(c)
            return c:IsFaceup() and (c:GetType() & TYPE_LINK) ~= 0 and (c:GetType() & TYPE_PENDULUM) ~= 0
        end, e:GetHandlerPlayer(), LOCATION_ONFIELD, 0, 1, nil)
    end)
    e2b:SetValue(function(e, te) return te:GetOwner() ~= e:GetOwner() end)
    c:RegisterEffect(e2b)

    -- place
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 2))
    e3:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetCode(EVENT_CHAIN_SOLVED)
    e3:SetRange(LOCATION_FZONE)
    e3:SetTarget(s.e3tg1)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)
    local e3b = e3:Clone()
    e3b:SetCode(EVENT_MOVE)
    e3b:SetTarget(s.e3tg2)
    c:RegisterEffect(e3b)

    -- gain effects
    local e4 = Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e4:SetCode(EVENT_ADJUST)
    e4:SetRange(LOCATION_FZONE)
    e4:SetOperation(s.e4op)
    c:RegisterEffect(e4)

    -- activate quick spell or trap in hand
    local e5 = Effect.CreateEffect(c)
    e5:SetType(EFFECT_TYPE_FIELD)
    e5:SetCode(EFFECT_QP_ACT_IN_NTPHAND)
    e5:SetRange(LOCATION_FZONE)
    e5:SetTargetRange(LOCATION_HAND, 0)
    e5:SetCondition(s.e5con)
    c:RegisterEffect(e5)
    local e5b = e5:Clone()
    e5b:SetCode(EFFECT_TRAP_ACT_IN_HAND)
    c:RegisterEffect(e5b)
end

function s.e1filter(c) return not c:IsCode(id) and c:IsFieldSpell() end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return true end
    Duel.SetPossibleOperationInfo(0, CATEGORY_DRAW, nil, 0, tp, 1)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local g = Duel.GetMatchingGroup(s.e1filter, tp, LOCATION_HAND + LOCATION_DECK + LOCATION_GRAVE, 0, nil)
    if #g == 0 or not Duel.SelectEffectYesNo(tp, c, aux.Stringid(id, 1)) then return end
    local tc = Utility.GroupSelect(HINTMSG_SELECT, g, tp):GetFirst()
    if tc then
        local loc = tc:GetLocation()
        Duel.Overlay(c, tc)
        if loc == LOCATION_HAND then
            Duel.BreakEffect()
            Duel.Draw(tp, 1, REASON_EFFECT)
        end
    end
end

function s.e3tg1(e, tp, eg, ep, ev, re, r, rp, chk)
    local tc = re:GetHandler()
    if chk == 0 then return tc:IsContinuousSpellTrap() and tc:IsControler(tp) and tc:IsLocation(LOCATION_SZONE) and tc:GetFlagEffect(id) == 0 end
    tc:RegisterFlagEffect(id, RESET_CHAIN, 0, 1)
    Duel.SetTargetCard(tc)
end

function s.e3tg2(e, tp, eg, ep, ev, re, r, rp, chk)
    local tc = eg:GetFirst()
    if chk == 0 then
        return
            tc and tc:IsFaceup() and tc:IsContinuousSpellTrap() and tc:IsControler(tp) and tc:IsLocation(LOCATION_SZONE) and tc:GetFlagEffect(id) == 0
    end
    tc:RegisterFlagEffect(id, RESET_CHAIN, 0, 1)
    Duel.SetTargetCard(tc)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Duel.GetFirstTarget()
    if not tc or not c:IsRelateToEffect(e) or not tc:IsRelateToEffect(e) then return end
    Duel.Overlay(c, tc)
end

function s.e4filter(c) return c:IsFieldSpell() or c:IsContinuousSpellTrap() end

function s.e4op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local og = c:GetOverlayGroup():Filter(s.e4filter, nil)
    local g = og:Filter(function(c) return c:GetFlagEffect(id) == 0 end, nil)
    if #g <= 0 then return end

    for tc in g:Iter() do
        local code = tc:GetOriginalCode()
        if not og:IsExists(function(c, code) return c:IsCode(code) and c:GetFlagEffect(id) > 0 end, 1, tc, code) then
            tc:RegisterFlagEffect(id, RESET_EVENT + RESETS_STANDARD, 0, 0)
            local cid = c:CopyEffect(code, RESET_EVENT + RESETS_STANDARD)
            local reset = Effect.CreateEffect(c)
            reset:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
            reset:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
            reset:SetCode(EVENT_ADJUST)
            reset:SetRange(LOCATION_MZONE)
            reset:SetLabel(cid)
            reset:SetLabelObject(tc)
            reset:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
                local cid = e:GetLabel()
                local c = e:GetHandler()
                local tc = e:GetLabelObject()
                local g = c:GetOverlayGroup():Filter(function(c) return c:GetFlagEffect(id) > 0 end, nil)
                if c:IsDisabled() or c:IsFacedown() or not g:IsContains(tc) then
                    c:ResetEffect(cid, RESET_COPY)
                    tc:ResetFlagEffect(id)
                end
            end)
            reset:SetReset(RESET_EVENT + RESETS_STANDARD)
            c:RegisterEffect(reset, true)
        end
    end
end

function s.e5tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chk == 0 then
        return Duel.IsExistingTarget(Card.IsFaceup, tp, LOCATION_MZONE, 0, 1, nil) and
                   Duel.GetLocationCount(tp, LOCATION_MZONE, tp, LOCATION_REASON_CONTROL) > 0
    end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TARGET)
    Duel.SelectTarget(tp, Card.IsFaceup, tp, LOCATION_MZONE, 0, 1, 1, nil)
end

function s.e5op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Duel.GetFirstTarget()
    if not c:IsRelateToEffect(e) or not tc:IsRelateToEffect(e) or tc:IsImmuneToEffect(e) or tc:IsControler(1 - tp) or
        Duel.GetLocationCount(tp, LOCATION_MZONE, tp, LOCATION_REASON_CONTROL) == 0 then return end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOZONE)
    local s = Duel.SelectDisableField(tp, 1, LOCATION_MZONE, 0, 0)
    local nseq = math.log(s, 2)
    Duel.MoveSequence(tc, nseq)
end

function s.e5con(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local g = c:GetOverlayGroup()
    return g:IsExists(Card.IsFieldSpell, 1, nil) and g:IsExists(Card.IsContinuousSpell, 1, nil) and g:IsExists(Card.IsContinuousTrap, 1, nil)
end
