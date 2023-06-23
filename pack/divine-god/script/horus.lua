-- Black Flame Divine Dragon of Horus
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_series = {SET_HORUS}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- xyz summon
    Xyz.AddProcedure(c, s.xyzfilter, nil, 2, nil, nil, 99, nil, false, s.xyzcheck)

    -- special summon limit
    local splimit = Effect.CreateEffect(c)
    splimit:SetType(EFFECT_TYPE_SINGLE)
    splimit:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    splimit:SetCode(EFFECT_SPSUMMON_CONDITION)
    splimit:SetValue(function(e, se, sp, st)
        return not e:GetHandler():IsLocation(LOCATION_EXTRA) or ((st & SUMMON_TYPE_XYZ) == SUMMON_TYPE_XYZ and not se)
    end)
    c:RegisterEffect(splimit)

    -- summon cannot be negated
    local sumsafe = Effect.CreateEffect(c)
    sumsafe:SetType(EFFECT_TYPE_SINGLE)
    sumsafe:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    sumsafe:SetCode(EFFECT_CANNOT_DISABLE_SPSUMMON)
    sumsafe:SetCondition(function(e) return e:GetHandler():GetSummonType() == SUMMON_TYPE_XYZ end)
    c:RegisterEffect(sumsafe)

    -- cannot be tributed, nor be used as a material
    local norelease = Effect.CreateEffect(c)
    norelease:SetType(EFFECT_TYPE_FIELD)
    norelease:SetProperty(EFFECT_FLAG_PLAYER_TARGET + EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    norelease:SetCode(EFFECT_CANNOT_RELEASE)
    norelease:SetRange(LOCATION_MZONE)
    norelease:SetTargetRange(0, 1)
    norelease:SetTarget(function(e, tc) return tc == e:GetHandler() end)
    c:RegisterEffect(norelease)
    local nomaterial = Effect.CreateEffect(c)
    nomaterial:SetType(EFFECT_TYPE_SINGLE)
    nomaterial:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    nomaterial:SetCode(EFFECT_CANNOT_BE_MATERIAL)
    nomaterial:SetValue(function(e, tc) return tc and tc:GetControler() ~= e:GetHandlerPlayer() end)
    c:RegisterEffect(nomaterial)

    -- cannot be target, nor change control
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE + EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    e1:SetCode(EFFECT_CANNOT_CHANGE_POS_E)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCondition(function(e, tp, eg, ep, ev, re, r, rp) return e:GetHandler():GetOverlayCount() >= 2 end)
    c:RegisterEffect(e1)
    local e1b = e1:Clone()
    e1b:SetCode(EFFECT_CANNOT_CHANGE_CONTROL)
    c:RegisterEffect(e1b)

    -- cannot change position & immune spell
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE + EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCondition(function(e, tp, eg, ep, ev, re, r, rp) return e:GetHandler():GetOverlayCount() >= 2 end)
    e2:SetValue(aux.tgoval)
    c:RegisterEffect(e2)
    local e2b = e2:Clone()
    e2b:SetCode(EFFECT_IMMUNE_EFFECT)
    e2b:SetValue(function(e, te) return te:IsActiveType(TYPE_SPELL) and te:GetOwnerPlayer() ~= e:GetHandlerPlayer() end)
    c:RegisterEffect(e2b)

    -- negate effect
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
    e4:SetOperation(s.e4op)
    c:RegisterEffect(e4)
end

function s.xyzfilter(c, xyz, sumtype, tp) return c:IsLevelAbove(8) end

function s.xyzcheck(g, tp, xyz)
    return g:GetClassCount(Card.GetLevel) == 1 and g:GetClassCount(Card.GetAttribute) == #g and g:GetClassCount(Card.GetRace) == #g
end

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
        tc:RegisterFlagEffect(id, RESET_EVENT + 0x1fe4000, 0, 0)
        local code = tc:GetOriginalCode()
        if not g:IsExists(function(c, code) return c:IsCode(code) and c:GetFlagEffect(id) > 0 end, 1, tc, code) then
            local cid = c:CopyEffect(code, RESET_EVENT + 0x1fe4000)
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
            reset:SetReset(RESET_EVENT + 0x1fe4000)
            c:RegisterEffect(reset, true)
        end
    end
end