-- iCxyz Barian Hope Emperor
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_series = {SET_RANK_UP_MAGIC, SET_NUMBER_C, SET_BARIANS, SET_SEVENTH}
s.listed_names = {67926903}

function s.initial_effect(c)
    c:EnableReviveLimit()
    c:SetUniqueOnField(1, 0, id)

    -- xyz summon
    Xyz.AddProcedure(c, nil, 8, 4, nil, nil, 99)

    -- special summon limit
    local splimit = Effect.CreateEffect(c)
    splimit:SetType(EFFECT_TYPE_SINGLE)
    splimit:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    splimit:SetCode(EFFECT_SPSUMMON_CONDITION)
    splimit:SetValue(function(e, se, sp, st) return se:GetHandler():IsSetCard(0x95) and se:GetHandler():IsSpell() end)
    c:RegisterEffect(splimit)

    -- summon cannot be negated
    local sumsafe = Effect.CreateEffect(c)
    sumsafe:SetType(EFFECT_TYPE_SINGLE)
    sumsafe:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    sumsafe:SetCode(EFFECT_CANNOT_DISABLE_SPSUMMON)
    c:RegisterEffect(sumsafe)

    -- cannot be tributed, or be used as a material
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

    -- control cannot switch
    local noswitch = Effect.CreateEffect(c)
    noswitch:SetType(EFFECT_TYPE_SINGLE)
    noswitch:SetProperty(EFFECT_FLAG_SINGLE_RANGE + EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    noswitch:SetCode(EFFECT_CANNOT_CHANGE_CONTROL)
    noswitch:SetRange(LOCATION_MZONE)
    c:RegisterEffect(noswitch)

    -- battle position cannot be changed by effect
    local nopos = Effect.CreateEffect(c)
    nopos:SetType(EFFECT_TYPE_SINGLE)
    nopos:SetProperty(EFFECT_FLAG_SINGLE_RANGE + EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    nopos:SetCode(EFFECT_CANNOT_CHANGE_POS_E)
    nopos:SetRange(LOCATION_MZONE)
    c:RegisterEffect(nopos)

    -- atk/def value
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE + EFFECT_FLAG_CANNOT_DISABLE)
    e1:SetCode(EFFECT_SET_BASE_ATTACK)
    e1:SetRange(LOCATION_MZONE)
    e1:SetValue(function(e, c) return c:GetOverlayCount() * 1000 end)
    c:RegisterEffect(e1)
    local e1b = e1:Clone()
    e1b:SetCode(EFFECT_SET_BASE_DEFENSE)
    c:RegisterEffect(e1b)

    -- gain effect
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EVENT_ADJUST)
    e2:SetRange(LOCATION_MZONE)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)

    -- detach replace
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e3:SetCode(EFFECT_OVERLAY_REMOVE_REPLACE)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCondition(function(e, tp, eg, ep, ev, re, r, rp)
        local c = e:GetHandler()
        return c:GetOverlayGroup():IsExists(Card.IsCode, 1, nil, 67926903) and c == re:GetHandler() and ep == e:GetOwnerPlayer() and
                   Duel.CheckLPCost(ep, 800)
    end)
    e3:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
        Duel.PayLPCost(tp, 800)
        return ev
    end)
    c:RegisterEffect(e3)

    -- cards cannot be negated
    local e4 = Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_FIELD)
    e4:SetCode(EFFECT_CANNOT_DISEFFECT)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCondition(function(e) return e:GetHandler():GetOverlayGroup():IsExists(Card.IsCode, 1, nil, 67926903) end)
    e4:SetValue(function(e, ct)
        local c = e:GetHandler()
        local p = c:GetControler()
        local te, tp, loc = Duel.GetChainInfo(ct, CHAININFO_TRIGGERING_EFFECT, CHAININFO_TRIGGERING_PLAYER, CHAININFO_TRIGGERING_LOCATION)
        if p ~= tp or (loc & LOCATION_ONFIELD) == 0 then return false end
        return te:GetHandler() == c or (te:IsActiveType(TYPE_SPELL + TYPE_TRAP) and te:GetHandler():IsSetCard({SET_BARIANS, SET_SEVENTH}))
    end)
    c:RegisterEffect(e4)
    local e4b = e4:Clone()
    e4b:SetCode(EFFECT_CANNOT_DISABLE)
    e4b:SetTargetRange(LOCATION_ONFIELD, 0)
    e4b:SetTarget(function(e, tc) return tc == e:GetHandler() or (tc:IsSetCard({SET_BARIANS, SET_SEVENTH}) and tc:IsSpellTrap()) end)
    c:RegisterEffect(e4b)
end

s.rum_limit = function(c, e) return c:IsCode(67926903) end
s.rum_xyzsummon = function(c)
    local esum = Effect.CreateEffect(c)
    esum:SetType(EFFECT_TYPE_FIELD)
    esum:SetDescription(1073)
    esum:SetCode(EFFECT_SPSUMMON_PROC)
    esum:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    esum:SetRange(c:GetLocation())
    esum:SetCondition(Xyz.Condition(nil, 9, 4, 4, false))
    esum:SetTarget(Xyz.Target(nil, 9, 4, 4, false))
    esum:SetOperation(Xyz.Operation(nil, 9, 4, 4, false))
    esum:SetValue(SUMMON_TYPE_XYZ)
    esum:SetReset(RESET_CHAIN)
    c:RegisterEffect(esum)
    return esum
end

function s.e2filter(c) return c:IsType(TYPE_XYZ) and c:IsSetCard(SET_NUMBER_C) and c.xyz_number and c.xyz_number >= 101 and c.xyz_number <= 107 end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local og = c:GetOverlayGroup():Filter(s.e2filter, nil)
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
