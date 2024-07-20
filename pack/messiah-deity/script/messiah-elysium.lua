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
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- cannot be targeted & immune
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE + EFFECT_FLAG_CANNOT_DISABLE)
    e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e2:SetRange(LOCATION_FZONE)
    e2:SetCondition(function(e)
        return Duel.IsExistingMatchingCard(function(c)
            return c:IsFaceup() and (c:GetType() & TYPE_LINK) ~= 0 and (c:GetType() & TYPE_PENDULUM) ~= 0
        end, e:GetHandlerPlayer(), LOCATION_ONFIELD, 0, 1, nil)
    end)
    e2:SetValue(aux.tgoval)
    c:RegisterEffect(e2)
    local e2b = e2:Clone()
    e2b:SetCode(EFFECT_IMMUNE_EFFECT)
    e2b:SetValue(function(e, te) return te:GetOwner() ~= e:GetOwner() end)
    c:RegisterEffect(e2b)

    -- place
    local e3reg = Effect.CreateEffect(c)
    e3reg:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e3reg:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e3reg:SetCode(EVENT_CHAINING)
    e3reg:SetRange(LOCATION_FZONE)
    e3reg:SetOperation(aux.chainreg)
    c:RegisterEffect(e3reg)
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e3:SetCode(EVENT_CHAIN_SOLVED)
    e3:SetRange(LOCATION_FZONE)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)

    -- gain effects
    local e4 = Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e4:SetCode(EVENT_ADJUST)
    e4:SetRange(LOCATION_FZONE)
    e4:SetOperation(s.e4op)
    c:RegisterEffect(e4)

    -- move to another zone
    local e5 = Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(id, 2))
    e5:SetType(EFFECT_TYPE_IGNITION)
    e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e5:SetRange(LOCATION_FZONE)
    e5:SetCountLimit(3)
    e5:SetTarget(s.e5tg)
    e5:SetOperation(s.e5op)
    c:RegisterEffect(e5)
end

function s.e1filter(c) return not c:IsCode(id) and c:IsFieldSpell() end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local g = Duel.GetMatchingGroup(s.e1filter, tp, LOCATION_HAND + LOCATION_DECK + LOCATION_GRAVE, 0, nil)
    if #g == 0 or not Duel.SelectEffectYesNo(tp, c, aux.Stringid(id, 1)) then return end
    local tc = Utility.GroupSelect(HINTMSG_SELECT, g, tp):GetFirst()
    if tc then Duel.Overlay(c, tc) end
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local rc = re:GetHandler()
    if not (rp == tp and re:IsActiveType(TYPE_CONTINUOUS) and re:IsHasType(EFFECT_TYPE_ACTIVATE) and c:GetFlagEffect(1) > 0) then return end
    if not Duel.SelectEffectYesNo(tp, c, aux.Stringid(id, 1)) then return end
    Duel.Overlay(c, rc)
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
    local tc = Duel.GetFirstTarget()
    if not tc:IsRelateToEffect(e) or tc:IsImmuneToEffect(e) or tc:IsControler(1 - tp) or
        Duel.GetLocationCount(tp, LOCATION_MZONE, tp, LOCATION_REASON_CONTROL) == 0 then return end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOZONE)
    local s = Duel.SelectDisableField(tp, 1, LOCATION_MZONE, 0, 0)
    local nseq = math.log(s, 2)
    Duel.MoveSequence(tc, nseq)
end
