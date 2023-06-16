-- Black Flame Dragon of Horus
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_series = {SET_HORUS}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- xyz summon
    Xyz.AddProcedure(c, nil, 8, 3, nil, nil, 99, nil, false, s.xyzcheck)

    -- xyz summon cannot be negated
    local sumsafe = Effect.CreateEffect(c)
    sumsafe:SetType(EFFECT_TYPE_SINGLE)
    sumsafe:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    sumsafe:SetCode(EFFECT_CANNOT_DISABLE_SPSUMMON)
    sumsafe:SetCondition(function(e) return e:GetHandler():GetSummonType() == SUMMON_TYPE_XYZ end)
    c:RegisterEffect(sumsafe)

    -- cannot be tributed, be used as a material, nor change control
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET + EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    e1:SetCode(EFFECT_CANNOT_RELEASE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetTargetRange(0, 1)
    e1:SetCondition(function(e, tp, eg, ep, ev, re, r, rp) return e:GetHandler():GetOverlayCount() >= 1 end)
    e1:SetTarget(function(e, tc) return tc == e:GetHandler() end)
    c:RegisterEffect(e1)
    local e1b = Effect.CreateEffect(c)
    e1b:SetType(EFFECT_TYPE_SINGLE)
    e1b:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    e1b:SetCode(EFFECT_CANNOT_BE_MATERIAL)
    e1b:SetCondition(function(e, tp, eg, ep, ev, re, r, rp) return e:GetHandler():GetOverlayCount() >= 1 end)
    e1b:SetValue(function(e, tc) return tc and tc:GetControler() ~= e:GetHandlerPlayer() end)
    c:RegisterEffect(e1b)
    local e1c = Effect.CreateEffect(c)
    e1c:SetType(EFFECT_TYPE_SINGLE)
    e1c:SetProperty(EFFECT_FLAG_SINGLE_RANGE + EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    e1c:SetCode(EFFECT_CANNOT_CHANGE_CONTROL)
    e1c:SetRange(LOCATION_MZONE)
    e1c:SetCondition(function(e, tp, eg, ep, ev, re, r, rp) return e:GetHandler():GetOverlayCount() >= 1 end)
    c:RegisterEffect(e1c)

    -- cannot change position & immune spell
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE + EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    e2:SetCode(EFFECT_CANNOT_CHANGE_POS_E)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCondition(function(e, tp, eg, ep, ev, re, r, rp) return e:GetHandler():GetOverlayCount() >= 2 end)
    c:RegisterEffect(e2)
    local e2b = e2:Clone()
    e2b:SetCode(EFFECT_IMMUNE_EFFECT)
    e2b:SetValue(function(e, te) return te:IsActiveType(TYPE_SPELL) and te:GetOwnerPlayer() ~= e:GetHandlerPlayer() end)
    c:RegisterEffect(e2b)

    -- negate
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(1117)
    e3:SetCategory(CATEGORY_NEGATE + CATEGORY_DESTROY)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP + EFFECT_FLAG_DAMAGE_CAL)
    e3:SetCode(EVENT_CHAINING)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCondition(s.e3con)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)

    -- gain effect
    local e4 = Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e4:SetCode(EVENT_ADJUST)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCondition(function(e, tp, eg, ep, ev, re, r, rp) return e:GetHandler():GetOverlayCount() >= 4 end)
    e4:SetOperation(s.e4op)
    c:RegisterEffect(e4)

    -- activation and effect cannot be negated & protect continuous spell/trap
    local e5 = Effect.CreateEffect(c)
    e5:SetType(EFFECT_TYPE_FIELD)
    e5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    e5:SetCode(EFFECT_CANNOT_INACTIVATE)
    e5:SetRange(LOCATION_MZONE)
    e5:SetTargetRange(1, 0)
    e5:SetCondition(function(e, tp, eg, ep, ev, re, r, rp) return e:GetHandler():GetOverlayCount() >= 5 end)
    e5:SetValue(function(e, ct)
        local te = Duel.GetChainInfo(ct, CHAININFO_TRIGGERING_EFFECT)
        return te:GetHandler() == e:GetHandler()
    end)
    c:RegisterEffect(e5)
    local e5b = e5:Clone()
    e5b:SetCode(EFFECT_CANNOT_DISEFFECT)
    c:RegisterEffect(e5b)
    local e5c = Effect.CreateEffect(c)
    e5c:SetType(EFFECT_TYPE_FIELD)
    e5c:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    e5c:SetCode(EFFECT_IMMUNE_EFFECT)
    e5c:SetRange(LOCATION_MZONE)
    e5c:SetTargetRange(LOCATION_ONFIELD, 0)
    e5c:SetCondition(function(e, tp, eg, ep, ev, re, r, rp) return e:GetHandler():GetOverlayCount() >= 5 end)
    e5c:SetTarget(function(e, c) return c:IsFaceup() and c:IsType(TYPE_CONTINUOUS) end)
    e5c:SetValue(function(e, te) return e:GetOwnerPlayer() ~= te:GetOwnerPlayer() end)
    c:RegisterEffect(e5c)
end

function s.xyzcheck(g, tp, xyz) return g:GetClassCount(Card.GetRace) == #g end

function s.e3con(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    return not c:IsStatus(STATUS_BATTLE_DESTROYED) and c:GetOverlayCount() >= 3 and re:IsActiveType(TYPE_SPELL) and Duel.IsChainDisablable(ev)
end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local rc = re:GetHandler()
    if chk == 0 then return true end

    Duel.SetOperationInfo(0, CATEGORY_DISABLE, eg, 1, 0, 0)
    if rc:IsDestructable() and rc:IsRelateToEffect(re) then Duel.SetOperationInfo(0, CATEGORY_DESTROY, eg, 1, 0, 0) end
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local rc = re:GetHandler()
    if c:IsFacedown() or not c:IsRelateToEffect(e) then return end
    if Duel.NegateEffect(ev) and rc:IsRelateToEffect(re) then Duel.Destroy(eg, REASON_EFFECT) end
end

function s.e4filter(c)
    if c:GetFlagEffect(id) ~= 0 then return false end
    return c:IsSetCard(SET_HORUS) and c:IsMonster()
end

function s.e4op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local g = c:GetOverlayGroup():Filter(s.e4filter, nil)
    if #g <= 0 then return end

    for tc in g:Iter() do
        tc:RegisterFlagEffect(id, RESET_EVENT + 0x1fe0000, 0, 0)
        local code = tc:GetOriginalCode()
        if not g:IsExists(function(c, code) return c:IsCode(code) and c:GetFlagEffect(id) > 0 end, 1, tc, code) then
            local cid = c:CopyEffect(code, RESET_EVENT + 0x1fe0000)
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
            reset:SetReset(RESET_EVENT + 0x1fe0000)
            c:RegisterEffect(reset, true)
        end
    end
end
