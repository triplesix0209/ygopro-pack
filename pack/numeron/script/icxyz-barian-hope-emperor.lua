-- iCxyz Barian Hope Emperor
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_series = {SET_NUMBER, SET_CXYZ, SET_NUMBER_C, SET_BARIANS, SET_SEVENTH}
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
    splimit:SetValue(aux.xyzlimit)
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

    -- gain effects
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetCondition(s.e1con)
    e1:SetOperation(s.e1op1)
    c:RegisterEffect(e1)
    local e1b = e1:Clone()
    e1b:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e1b:SetCode(EVENT_ADJUST)
    e1b:SetRange(LOCATION_MZONE)
    e1b:SetOperation(s.e1op2)
    c:RegisterEffect(e1b)
    local e1matcheck1 = Effect.CreateEffect(c)
    e1matcheck1:SetType(EFFECT_TYPE_SINGLE)
    e1matcheck1:SetCode(EFFECT_MATERIAL_CHECK)
    e1matcheck1:SetValue(s.e1matcheck)
    e1matcheck1:SetLabelObject(e1)
    c:RegisterEffect(e1matcheck1)
    local e1matcheck2 = e1matcheck1:Clone()
    e1matcheck2:SetLabelObject(e1b)
    c:RegisterEffect(e1matcheck2)

    -- cards cannot be negated
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_CANNOT_DISEFFECT)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCondition(s.effcon)
    e2:SetValue(function(e, ct)
        local c = e:GetHandler()
        local p = c:GetControler()
        local te, tp, loc = Duel.GetChainInfo(ct, CHAININFO_TRIGGERING_EFFECT, CHAININFO_TRIGGERING_PLAYER, CHAININFO_TRIGGERING_LOCATION)
        local tc = te:GetHandler()
        if p ~= tp or (loc & LOCATION_ONFIELD) == 0 then return false end
        return tc == c or s.e2filter(tc)
    end)
    c:RegisterEffect(e2)
    local e2b = e2:Clone()
    e2b:SetCode(EFFECT_CANNOT_DISABLE)
    e2b:SetTargetRange(LOCATION_ONFIELD, 0)
    e2b:SetTarget(function(e, tc) return tc == e:GetHandler() or s.e2filter(tc) end)
    c:RegisterEffect(e2b)

    -- detach replace
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e3:SetCode(EFFECT_OVERLAY_REMOVE_REPLACE)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCondition(function(e, tp, eg, ep, ev, re, r, rp)
        return s.effcon(e) and re:GetHandler() == e:GetHandler() and ep == e:GetOwnerPlayer() and Duel.CheckLPCost(ep, 800)
    end)
    e3:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
        Duel.PayLPCost(tp, 800)
        return ev
    end)
    c:RegisterEffect(e3)
end

function s.e1matcheck(e, c)
    local g = c:GetMaterial():Filter(Card.IsCode, nil, 67926903)
    e:GetLabelObject():SetLabel(1)
    e:GetLabelObject():SetLabelObject(g)
end

function s.e1filter(c) return c:IsType(TYPE_XYZ) and c:IsSetCard(SET_NUMBER_C) and c.xyz_number and c.xyz_number >= 101 and c.xyz_number <= 107 end

function s.e1con(e, tp, eg, ep, ev, re, r, rp) return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ) and e:GetLabel() == 1 end

function s.e1op1(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = e:GetLabelObject():GetFirst()
    if tc then c:CopyEffect(tc:GetOriginalCode(), RESET_EVENT | RESETS_STANDARD) end
end

function s.e1op2(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local og = c:GetOverlayGroup():Filter(s.e1filter, nil)
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

            local original_num_code = s.e1numcode(tc)
            if (original_num_code) then
                local ec1 = Effect.CreateEffect(c)
                ec1:SetType(EFFECT_TYPE_SINGLE)
                ec1:SetCode(EFFECT_ADD_CODE)
                ec1:SetValue(original_num_code)
                ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
                tc:RegisterEffect(ec1)
            end
        end
    end
end

function s.e1numcode(c)
    if c:IsCode({12744567, 900004003}) then return 48739166 end
    if c:IsCode(67173574) then return 49678559 end
    if c:IsCode(20785975) then return 94380860 end
    if c:IsCode(49456901) then return 2061963 end
    if c:IsCode(85121942) then return 59627393 end
    if c:IsCode(55888045) then return 63746411 end
    if c:IsCode(68396121) then return 88177324 end
end

function s.effcon(e) return e:GetHandler():GetOverlayGroup():IsExists(Card.IsCode, 1, nil, 67926903) end

function s.e2filter(c)
    local no = c.xyz_number
    return (c:IsSetCard({SET_NUMBER}) and no and no >= 101 and no <= 107 and c:IsMonster()) or
               (c:IsSetCard({SET_CXYZ, SET_NUMBER_C}) and c:IsMonster()) or (c:IsSetCard({SET_BARIANS, SET_SEVENTH}) and c:IsSpellTrap())
end
