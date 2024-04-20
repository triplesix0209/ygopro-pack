-- Numeron Code Dragon
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {57314798}
s.listed_series = {SET_NUMBER}

function s.initial_effect(c)
    c:EnableReviveLimit()
    c:SetUniqueOnField(1, 0, id)

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

    -- battle position cannot be changed by effect
    local nopos = Effect.CreateEffect(c)
    nopos:SetType(EFFECT_TYPE_SINGLE)
    nopos:SetProperty(EFFECT_FLAG_SINGLE_RANGE + EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    nopos:SetCode(EFFECT_CANNOT_CHANGE_POS_E)
    nopos:SetRange(LOCATION_MZONE)
    c:RegisterEffect(nopos)

    -- indes battle
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
    e1:SetValue(function(e, tc) return not tc:IsType(SET_NUMBER) end)
    c:RegisterEffect(e1)

    -- attach
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 0))
    e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET + EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_CUSTOM + id)
    e2:SetRange(LOCATION_MZONE)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)
    local g = Group.CreateGroup()
    g:KeepAlive()
    e2:SetLabelObject(g)
    local e2reg = Effect.CreateEffect(c)
    e2reg:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e2reg:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e2reg:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2reg:SetRange(LOCATION_MZONE)
    e2reg:SetLabelObject(e2)
    e2reg:SetOperation(s.e2regop)
    c:RegisterEffect(e2reg)

    -- gain effect
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    e3:SetCode(EVENT_ADJUST)
    e3:SetRange(LOCATION_MZONE)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)
end

function s.spfilter(c) return c:IsFaceup() and c:IsSetCard(SET_NUMBER) and c:IsType(TYPE_XYZ) end

function s.spcon(e, c)
    if c == nil then return true end
    local tp = c:GetControler()
    local g = Duel.GetMatchingGroup(s.spfilter, tp, LOCATION_MZONE, 0, nil)
    return g:IsExists(Card.IsOriginalCode, 1, nil, 57314798)
end

function s.spop(e, tp, eg, ep, ev, re, r, rp, c)
    local g = Duel.GetMatchingGroup(s.spfilter, tp, LOCATION_MZONE, 0, nil)
    Duel.Overlay(c, g)
end

function s.e2filter(c, e, tp)
    return c:IsFaceup() and c:IsControler(tp) and c:IsSetCard(SET_NUMBER) and c.xyz_number and c.xyz_number >= 1 and c.xyz_number <= 100
end

function s.e2regop(e, tp, eg, ep, ev, re, r, rp)
    local tg = eg:Filter(s.e2filter, nil, e, tp)
    if #tg == 0 then return end
    for tc in tg:Iter() do tc:RegisterFlagEffect(id, RESET_CHAIN, 0, 1) end
    
    local g = e:GetLabelObject():GetLabelObject()
    if Duel.GetCurrentChain() == 0 then g:Clear() end
    g:Merge(tg)
    g:Remove(function(c) return c:GetFlagEffect(id) == 0 end, nil)
    e:GetLabelObject():SetLabelObject(g)
    Duel.RaiseSingleEvent(e:GetHandler(), EVENT_CUSTOM + id, e, 0, tp, tp, 0)
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    local g = e:GetLabelObject():Filter(s.e2filter, nil, e, tp)
    if chk == 0 then return #g > 0 and Duel.GetFlagEffect(tp, id) == 0 end
    Duel.RegisterFlagEffect(tp, id, RESET_CHAIN, 0, 1)
    Duel.SetTargetCard(g)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
    local g = Duel.GetChainInfo(0, CHAININFO_TARGET_CARDS)
    g = g:Filter(function(c, e) return c:IsRelateToEffect(e) and not c:IsImmuneToEffect(e) end, nil, e)
    if #g > 0 then Duel.Overlay(c, g) end
end

function s.e3filter(c)
    return not c:IsCode(id) and c:IsType(TYPE_XYZ) and c:IsSetCard(SET_NUMBER) and c.xyz_number and c.xyz_number >= 1 and c.xyz_number <= 100
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local og = c:GetOverlayGroup():Filter(s.e3filter, nil)
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
