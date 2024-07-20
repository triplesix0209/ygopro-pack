-- Messiah, Supreme Deity of Dragons
Duel.LoadScript("util.lua")
Duel.LoadScript("util_messiah.lua")
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
    sp:SetRange(LOCATION_EXTRA + LOCATION_PZONE)
    sp:SetCountLimit(1, id, EFFECT_COUNT_CODE_OATH)
    sp:SetCondition(s.spcon)
    sp:SetTarget(s.sptg)
    sp:SetOperation(s.spop)
    c:RegisterEffect(sp)

    -- summon cannot be negated
    local sumsafe = Effect.CreateEffect(c)
    sumsafe:SetType(EFFECT_TYPE_SINGLE)
    sumsafe:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    sumsafe:SetCode(EFFECT_CANNOT_DISABLE_SPSUMMON)
    c:RegisterEffect(sumsafe)

    -- cannot be material
    local nomaterial = Effect.CreateEffect(c)
    nomaterial:SetType(EFFECT_TYPE_SINGLE)
    nomaterial:SetProperty(EFFECT_FLAG_SINGLE_RANGE + EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    nomaterial:SetCode(EFFECT_UNRELEASABLE_SUM)
    nomaterial:SetRange(LOCATION_MZONE)
    nomaterial:SetValue(aux.TRUE)
    c:RegisterEffect(nomaterial)
    local nomaterial2 = nomaterial:Clone()
    nomaterial2:SetCode(EFFECT_UNRELEASABLE_NONSUM)
    c:RegisterEffect(nomaterial2)
    local nomaterial3 = nomaterial:Clone()
    nomaterial3:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
    c:RegisterEffect(nomaterial3)
    local nomaterial4 = nomaterial:Clone()
    nomaterial4:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
    c:RegisterEffect(nomaterial4)
    local nomaterial5 = nomaterial:Clone()
    nomaterial5:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
    c:RegisterEffect(nomaterial5)
    local nomaterial6 = nomaterial:Clone()
    nomaterial6:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
    c:RegisterEffect(nomaterial6)

    -- control cannot switch
    local noswitch = Effect.CreateEffect(c)
    noswitch:SetType(EFFECT_TYPE_SINGLE)
    noswitch:SetProperty(EFFECT_FLAG_SINGLE_RANGE + EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    noswitch:SetCode(EFFECT_CANNOT_CHANGE_CONTROL)
    noswitch:SetRange(LOCATION_MZONE)
    c:RegisterEffect(noswitch)

    -- untargetable & immune (p-zone)
    local pe1 = Effect.CreateEffect(c)
    pe1:SetType(EFFECT_TYPE_SINGLE)
    pe1:SetProperty(EFFECT_FLAG_SINGLE_RANGE + EFFECT_CANNOT_DISABLE)
    pe1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    pe1:SetRange(LOCATION_PZONE)
    pe1:SetValue(1)
    c:RegisterEffect(pe1)
    local pe1b = pe1:Clone()
    pe1b:SetCode(EFFECT_IMMUNE_EFFECT)
    pe1b:SetValue(function(e, te) return te:GetOwner() ~= e:GetOwner() end)
    c:RegisterEffect(pe1b)

    -- pendulum scale
    local pe2 = Effect.CreateEffect(c)
    pe2:SetType(EFFECT_TYPE_FIELD)
    pe2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    pe2:SetCode(EFFECT_CHANGE_LSCALE)
    pe2:SetRange(LOCATION_PZONE)
    pe2:SetTargetRange(LOCATION_PZONE, 0)
    pe2:SetTarget(function(e, c) return c ~= e:GetHandler() end)
    pe2:SetValue(0)
    c:RegisterEffect(pe2)
    local pe2b = pe2:Clone()
    pe2b:SetCode(EFFECT_CHANGE_RSCALE)
    c:RegisterEffect(pe2b)

    -- time skip
    local pe3 = Effect.CreateEffect(c)
    pe3:SetDescription(aux.Stringid(id, 0))
    pe3:SetCategory(CATEGORY_TOEXTRA)
    pe3:SetType(EFFECT_TYPE_QUICK_O)
    pe3:SetCode(EVENT_FREE_CHAIN)
    pe3:SetRange(LOCATION_PZONE)
    pe3:SetCountLimit(1, {id, 1})
    pe3:SetCondition(aux.exccon)
    pe3:SetTarget(s.pe3tg)
    pe3:SetOperation(s.pe3op)
    c:RegisterEffect(pe3)

    -- immune (m-zone)
    local me1 = Effect.CreateEffect(c)
    me1:SetType(EFFECT_TYPE_SINGLE)
    me1:SetProperty(EFFECT_FLAG_SINGLE_RANGE + EFFECT_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    me1:SetCode(EFFECT_IMMUNE_EFFECT)
    me1:SetRange(LOCATION_MZONE)
    me1:SetValue(function(e, te) return te:GetOwner() ~= e:GetOwner() end)
    c:RegisterEffect(me1)

    -- atk value & gain effect
    local me2 = Effect.CreateEffect(c)
    me2:SetType(EFFECT_TYPE_SINGLE)
    me2:SetProperty(EFFECT_FLAG_SINGLE_RANGE + EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    me2:SetCode(EFFECT_SET_BASE_ATTACK)
    me2:SetRange(LOCATION_MZONE)
    me2:SetValue(function(e, c) return c:GetOverlayCount() * 1000 end)
    c:RegisterEffect(me2)
    local me2b = Effect.CreateEffect(c)
    me2b:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    me2b:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    me2b:SetCode(EVENT_ADJUST)
    me2b:SetRange(LOCATION_MZONE)
    me2b:SetOperation(s.me2op)
    c:RegisterEffect(me2b)

    -- place in pendulum zone
    local me3 = Effect.CreateEffect(c)
    me3:SetDescription(aux.Stringid(id, 1))
    me3:SetCategory(CATEGORY_DESTROY + CATEGORY_TOEXTRA)
    me3:SetType(EFFECT_TYPE_QUICK_O)
    me3:SetProperty(EFFECT_FLAG_CANNOT_INACTIVATE + EFFECT_FLAG_CANNOT_NEGATE + EFFECT_FLAG_CANNOT_DISABLE)
    me3:SetCode(EVENT_FREE_CHAIN)
    me3:SetRange(LOCATION_MZONE + LOCATION_EXTRA)
    me3:SetCountLimit(1, {id, 2})
    me3:SetTarget(s.me3tg)
    me3:SetOperation(s.me3op)
    c:RegisterEffect(me3)
end

function s.spfilter(c) return c:IsLinkMonster() and c:IsType(TYPE_PENDULUM) and c:IsReleasable() end

function s.spcon(e, c)
    if c == nil then return true end
    if c:IsLocation(LOCATION_PZONE) and not aux.exccon(e) then return false end

    local tp = c:GetControler()
    local rg = Duel.GetReleaseGroup(tp):Filter(s.spfilter, nil, tp)
    return (c:IsFacedown() or c:IsLocation(LOCATION_PZONE)) and aux.SelectUnselectGroup(rg, e, tp, 3, 3, aux.ChkfMMZ(1), 0)
end

function s.sptg(e, tp, eg, ep, ev, re, r, rp, c)
    local rg = Duel.GetReleaseGroup(tp):Filter(s.spfilter, nil, tp)
    local mg = aux.SelectUnselectGroup(rg, e, tp, 3, 3, aux.ChkfMMZ(1), 1, tp, HINTMSG_RELEASE, nil, nil, true)
    if #mg == 3 then
        mg:KeepAlive()
        e:SetLabelObject(mg)
        return true
    end
    return false
end

function s.spop(e, tp, eg, ep, ev, re, r, rp, c)
    local g = e:GetLabelObject()
    if not g then return end
    Duel.Release(g, REASON_COST)
    g:DeleteGroup()
end

function s.pe3tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return c:IsAbleToExtra() end
    Duel.SetOperationInfo(0, CATEGORY_TOEXTRA, c, 1, 0, 0)
end

function s.pe3op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) or Duel.SendtoDeck(c, nil, SEQ_DECKSHUFFLE, REASON_EFFECT) == 0 then return end

    if (Duel.GetTurnPlayer() == tp) then
        local ec1 = Effect.CreateEffect(c)
        ec1:SetType(EFFECT_TYPE_FIELD)
        ec1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
        ec1:SetCode(EFFECT_CANNOT_BP)
        ec1:SetTargetRange(1, 1)
        ec1:SetReset(RESET_PHASE + PHASE_END + RESET_OPPO_TURN)
        Duel.RegisterEffect(ec1, tp)

        Duel.SkipPhase(tp, PHASE_DRAW, RESET_PHASE + PHASE_END, 2)
        Duel.SkipPhase(tp, PHASE_STANDBY, RESET_PHASE + PHASE_END, 1)
        Duel.SkipPhase(tp, PHASE_MAIN1, RESET_PHASE + PHASE_END, 1)
        Duel.SkipPhase(tp, PHASE_BATTLE, RESET_PHASE + PHASE_END, 1)
        Duel.SkipPhase(tp, PHASE_MAIN2, RESET_PHASE + PHASE_END, 1)
        Duel.SkipPhase(tp, PHASE_END, RESET_PHASE + PHASE_END, 1)
        Duel.SkipPhase(1 - tp, PHASE_DRAW, RESET_PHASE + PHASE_END, 1)
        Duel.SkipPhase(1 - tp, PHASE_STANDBY, RESET_PHASE + PHASE_END, 1)
        Duel.SkipPhase(1 - tp, PHASE_MAIN1, RESET_PHASE + PHASE_END, 1)
        Duel.SkipPhase(1 - tp, PHASE_BATTLE, RESET_PHASE + PHASE_END, 1)
        Duel.SkipPhase(1 - tp, PHASE_MAIN2, RESET_PHASE + PHASE_END, 1)
        Duel.SkipPhase(1 - tp, PHASE_END, RESET_PHASE + PHASE_END, 1)
    else
        local ec1 = Effect.CreateEffect(c)
        ec1:SetType(EFFECT_TYPE_FIELD)
        ec1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
        ec1:SetCode(EFFECT_CANNOT_BP)
        ec1:SetTargetRange(1, 0)
        ec1:SetReset(RESET_PHASE + PHASE_END)
        Duel.RegisterEffect(ec1, 1 - tp)

        Duel.SkipPhase(1 - tp, PHASE_DRAW, RESET_PHASE + PHASE_END, 1)
        Duel.SkipPhase(1 - tp, PHASE_STANDBY, RESET_PHASE + PHASE_END, 1)
        Duel.SkipPhase(1 - tp, PHASE_MAIN1, RESET_PHASE + PHASE_END, 1)
        Duel.SkipPhase(1 - tp, PHASE_BATTLE, RESET_PHASE + PHASE_END, 1)
        Duel.SkipPhase(1 - tp, PHASE_MAIN2, RESET_PHASE + PHASE_END, 1)
        Duel.SkipPhase(1 - tp, PHASE_END, RESET_PHASE + PHASE_END, 1)
        Duel.SkipPhase(tp, PHASE_DRAW, RESET_PHASE + PHASE_END, 1)
    end
end

function s.me2filter(c) return c:IsMonster() end

function s.me2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local og = c:GetOverlayGroup():Filter(s.me2filter, nil)
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

function s.me3filter1(c) return c:GetOriginalType() & TYPE_LINK ~= 0 and c:GetOriginalType() & TYPE_PENDULUM ~= 0 end

function s.me3filter2(c) return c:IsType(TYPE_PENDULUM) and not c:IsForbidden() end

function s.me3tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return c:IsFaceup() and Duel.IsExistingMatchingCard(s.me3filter1, tp, LOCATION_PZONE, 0, 2, nil) end

    local g1 = Duel.GetFieldGroup(tp, LOCATION_PZONE, 0)
    local g2 = Duel.GetMatchingGroup(s.me3filter2, tp, LOCATION_GRAVE, 0, c)
    g2:Merge(c:GetOverlayGroup():Filter(s.me3filter2, nil))

    Duel.SetOperationInfo(0, CATEGORY_DESTROY, g1, #g1, 0, 0)
    Duel.SetOperationInfo(0, CATEGORY_TOEXTRA, g2, #g2, 0, 0)
end

function s.me3op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local dg = Duel.GetFieldGroup(tp, LOCATION_PZONE, 0)
    if #dg < 2 or Duel.Destroy(dg, REASON_EFFECT) ~= 2 then return end

    local g = Duel.GetMatchingGroup(s.me3filter2, tp, LOCATION_GRAVE, 0, c)
    if c:IsRelateToEffect(e) then g:Merge(c:GetOverlayGroup():Filter(s.me3filter2, nil)) end
    if #g > 0 then Duel.SendtoExtraP(g, nil, REASON_EFFECT) end

    if c:IsRelateToEffect(e) and c:IsFaceup() and Duel.MoveToField(c, tp, tp, LOCATION_PZONE, POS_FACEUP, true) and
        Duel.IsExistingMatchingCard(s.me3filter2, tp, LOCATION_DECK, 0, 1, nil) and Duel.SelectEffectYesNo(tp, c, aux.Stringid(id, 2)) then
        Duel.BreakEffect()
        local tc = Utility.SelectMatchingCard(HINTMSG_TOFIELD, tp, s.me3filter2, tp, LOCATION_DECK, 0, 1, 1, nil):GetFirst()
        if tc then Duel.MoveToField(tc, tp, tp, LOCATION_PZONE, POS_FACEUP, true) end
    end
end
