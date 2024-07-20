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
    e2b:SetValue(function(e, te) return e:GetOwnerPlayer() ~= te:GetOwnerPlayer() end)
    c:RegisterEffect(e2b)

    -- cannot be negated
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetCode(EFFECT_CANNOT_DISABLE)
    e3:SetRange(LOCATION_FZONE)
    e3:SetTargetRange(LOCATION_ONFIELD, 0)
    e3:SetTarget(function(e, c) return (c:GetType() & TYPE_LINK) ~= 0 and (c:GetType() & TYPE_PENDULUM) ~= 0 end)
    c:RegisterEffect(e3)
    local e3b = Effect.CreateEffect(c)
    e3b:SetType(EFFECT_TYPE_FIELD)
    e3b:SetCode(EFFECT_CANNOT_DISEFFECT)
    e3b:SetRange(LOCATION_FZONE)
    e3b:SetValue(function(e, ct)
        local te, tp, loc = Duel.GetChainInfo(ct, CHAININFO_TRIGGERING_EFFECT, CHAININFO_TRIGGERING_PLAYER, CHAININFO_TRIGGERING_LOCATION)
        local tc = te:GetHandler()
        local p = e:GetHandler():GetControler()
        if p ~= tp or (loc & LOCATION_ONFIELD) == 0 then return false end
        return (tc:GetType() & TYPE_LINK) ~= 0 and (tc:GetType() & TYPE_PENDULUM) ~= 0
    end)
    c:RegisterEffect(e3b)

    -- place
    local e4reg = Effect.CreateEffect(c)
    e4reg:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e4reg:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e4reg:SetCode(EVENT_CHAINING)
    e4reg:SetRange(LOCATION_FZONE)
    e4reg:SetOperation(aux.chainreg)
    c:RegisterEffect(e4reg)
    local e4 = Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e4:SetCode(EVENT_CHAIN_SOLVED)
    e4:SetRange(LOCATION_FZONE)
    e4:SetOperation(s.e4op)
    c:RegisterEffect(e4)

    -- gain effects
    local e5 = Effect.CreateEffect(c)
    e5:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e5:SetCode(EVENT_ADJUST)
    e5:SetRange(LOCATION_FZONE)
    e5:SetOperation(s.e5op)
    c:RegisterEffect(e5)
end

function s.e1filter(c) return c:IsContinuousSpellTrap() end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local g = Duel.GetMatchingGroup(s.e1filter, tp, LOCATION_DECK, 0, nil)
    if #g == 0 or not Duel.SelectEffectYesNo(tp, c, aux.Stringid(id, 1)) then return end
    local tc = Utility.GroupSelect(HINTMSG_SELECT, g, tp):GetFirst()
    if tc then Duel.Overlay(c, tc) end
end

function s.e4op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local rc = re:GetHandler()
    if not (rp == tp and re:IsActiveType(TYPE_CONTINUOUS) and re:IsHasType(EFFECT_TYPE_ACTIVATE) and c:GetFlagEffect(1) > 0) then return end
    if not Duel.SelectEffectYesNo(tp, c, aux.Stringid(id, 1)) then return end
    Duel.Overlay(c, rc)
end

function s.e5filter(c) return c:IsContinuousSpellTrap() end

function s.e5op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local og = c:GetOverlayGroup():Filter(s.e5filter, nil)
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
