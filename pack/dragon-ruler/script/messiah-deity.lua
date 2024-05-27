-- Messiah, Supreme Deity of Dragons
Duel.LoadScript("util.lua")
Duel.LoadScript("util_dragon_ruler.lua")
local s, id = GetID()

function s.initial_effect(c)
    c:EnableReviveLimit()
    c:SetUniqueOnField(1, 0, id)
    Pendulum.AddProcedure(c, false)

    -- special summon limit
    local splimit = Effect.CreateEffect(c)
    splimit:SetType(EFFECT_TYPE_SINGLE)
    splimit:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    splimit:SetCode(EFFECT_SPSUMMON_CONDITION)
    c:RegisterEffect(splimit)

    -- special summon procedure
    local sp = Effect.CreateEffect(c)
    sp:SetType(EFFECT_TYPE_FIELD)
    sp:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    sp:SetCode(EFFECT_SPSUMMON_PROC)
    sp:SetRange(LOCATION_EXTRA)
    sp:SetCondition(s.spcon)
    sp:SetOperation(s.spop)
    c:RegisterEffect(sp)

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

    -- special summon success
    local sp_success = Effect.CreateEffect(c)
    sp_success:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
    sp_success:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    sp_success:SetCode(EVENT_SPSUMMON_SUCCESS)
    sp_success:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
        local c = e:GetHandler()
        Duel.SetChainLimitTillChainEnd(s.spchainlimit(c))
        if Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and Duel.SelectEffectYesNo(tp, c, aux.Stringid(id, 0)) then
            Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOZONE)
            local s = Duel.SelectDisableField(tp, 1, LOCATION_MZONE, 0, 0)
            local seq = math.log(s, 2)
            Duel.MoveSequence(c, seq)
        end
    end)
    c:RegisterEffect(sp_success)

    -- atk value & gain effect
    local me1 = Effect.CreateEffect(c)
    me1:SetType(EFFECT_TYPE_SINGLE)
    me1:SetProperty(EFFECT_FLAG_SINGLE_RANGE + EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    me1:SetCode(EFFECT_SET_BASE_ATTACK)
    me1:SetRange(LOCATION_MZONE)
    me1:SetValue(function(e, c) return c:GetOverlayGroup():FilterCount(s.me1filter, nil) * 1000 end)
    c:RegisterEffect(me1)
    local me1b = Effect.CreateEffect(c)
    me1b:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    me1b:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    me1b:SetCode(EVENT_ADJUST)
    me1b:SetRange(LOCATION_MZONE)
    me1b:SetOperation(s.me1op)
    c:RegisterEffect(me1b)
end

function s.spfilter(c) return c:IsFaceup() and c:IsLinkMonster() and c:IsType(TYPE_PENDULUM) end

function s.spcon(e, c)
    if c == nil then return true end
    local tp = c:GetControler()
    local g = Duel.GetMatchingGroup(s.spfilter, tp, LOCATION_MZONE, 0, nil)
    return c:IsFacedown() and g:IsExists(Card.IsOriginalRace, 3, nil, RACE_DRAGON)
end

function s.spop(e, tp, eg, ep, ev, re, r, rp, c)
    local g = Duel.GetMatchingGroup(s.spfilter, tp, LOCATION_MZONE, 0, nil)
    Duel.Overlay(c, g)
end

function s.spchainlimit(c) return function(e, rp, tp) return e:GetHandler() == c end end

function s.me1filter(c) return c:IsRace(RACE_DRAGON) and c:IsType(TYPE_PENDULUM) and c:IsLinkMonster() end

function s.me1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local og = c:GetOverlayGroup():Filter(s.me1filter, nil)
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
