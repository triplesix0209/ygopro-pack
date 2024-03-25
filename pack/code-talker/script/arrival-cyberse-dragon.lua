-- The Arrival Cyberse Dragon
Duel.LoadScript("util.lua")
local s, id = GetID()

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- link summon
    Link.AddProcedure(c, function(c, sc, sumtype, tp) return c:IsRace(RACE_CYBERSE, sc, sumtype, tp) and c:IsType(TYPE_LINK, sc, sumtype, tp) end, 3,
        99, function(g, sc, sumtype, tp) return g:CheckDifferentPropertyBinary(Card.GetAttribute, sc, sumtype, tp) end)

    -- special summon limit
    local splimit = Effect.CreateEffect(c)
    splimit:SetType(EFFECT_TYPE_SINGLE)
    splimit:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    splimit:SetCode(EFFECT_SPSUMMON_CONDITION)
    splimit:SetValue(aux.synlimit)
    c:RegisterEffect(splimit)

    -- summon cannot be negated
    local spsafe = Effect.CreateEffect(c)
    spsafe:SetType(EFFECT_TYPE_SINGLE)
    spsafe:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    spsafe:SetCode(EFFECT_CANNOT_DISABLE_SPSUMMON)
    spsafe:SetCondition(function(e) return e:GetHandler():GetSummonType() == SUMMON_TYPE_LINK end)
    c:RegisterEffect(spsafe)

    -- cannot be tributed, be used as a material
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

    -- co-linked protect
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e1:SetRange(LOCATION_MZONE)
    e1:SetTargetRange(LOCATION_ONFIELD, 0)
    e1:SetTarget(function(e, c) return c:GetMutualLinkedGroupCount() > 0 end)
    e1:SetValue(aux.indoval)
    c:RegisterEffect(e1)
    local e1b = e1:Clone()
    e1b:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
    e1b:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e1b:SetValue(aux.tgoval)
    c:RegisterEffect(e1b)

    -- special summon
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 0))
    e2:SetCategory(CATEGORY_DESTROY + CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1, {id, 1})
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)

    -- place link
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 1))
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1, {id, 2})
    e3:SetCost(s.e3cost)
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

function s.e3checkzone(p, zone) return Duel.GetLocationCount(p, LOCATION_SZONE, p, REASON_EFFECT, zone) > 0 end

function s.e3filter(c, zone)
    local p = c:GetOwner()
    return c:IsRace(RACE_CYBERSE) and c:IsLinkMonster() and c:CheckUniqueOnField(p, LOCATION_SZONE) and
               (c:IsLocation(LOCATION_MZONE) or not c:IsForbidden()) and s.e3checkzone(p, zone)
end

function s.e3cost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.CheckLPCost(tp, 2000) end
    Duel.PayLPCost(tp, 2000)
end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    local zone = c:GetLinkedZone() >> 8
    if chk == 0 then return Duel.IsExistingTarget(s.e3filter, tp, LOCATION_MZONE, 0, 1, c, zone) end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TARGET)
    Duel.SelectTarget(tp, s.e3filter, tp, LOCATION_MZONE, 0, 1, 1, c, zone)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Duel.GetFirstTarget()
    if not tc:IsRelateToEffect(e) or tc:IsImmuneToEffect(e) then return end

    local zone = c:GetLinkedZone() >> 8
    if tc:IsLocation(LOCATION_MZONE) and not s.e3checkzone(tc:GetOwner(), zone) then
        Duel.SendtoGrave(tc, REASON_RULE, nil, PLAYER_NONE)
    elseif Duel.MoveToField(tc, tp, tc:GetOwner(), LOCATION_SZONE, POS_FACEUP, true, zone) then
        -- treated as link spell
        local ec1 = Effect.CreateEffect(c)
        ec1:SetType(EFFECT_TYPE_SINGLE)
        ec1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
        ec1:SetCode(EFFECT_CHANGE_TYPE)
        ec1:SetValue(TYPE_SPELL + TYPE_LINK)
        ec1:SetReset(RESET_EVENT + (RESETS_STANDARD & ~RESET_TURN_SET))
        tc:RegisterEffect(ec1)
    end
end

function s.e2filter1(c, e, tp)
    return c:IsLinkMonster() and e:GetHandler():GetLinkedGroup():IsContains(c) and
               Duel.IsExistingMatchingCard(s.e2filter2, tp, LOCATION_EXTRA, 0, 1, nil, e, tp, c)
end

function s.e2filter2(c, e, tp, mc)
    return not c:IsCode({id, mc:GetCode()}) and c:IsRace(RACE_CYBERSE) and c:IsLinkMonster() and c:IsLinkBelow(mc:GetLink()) and
               c:IsCanBeSpecialSummoned(e, SUMMON_TYPE_LINK, tp, false, false)
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    local c = e:GetHandler()
    if chk == 0 then return Duel.IsExistingTarget(s.e2filter1, tp, LOCATION_MZONE, 0, 1, c, e, tp) end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_DESTROY)
    local g = Duel.SelectTarget(tp, s.e2filter1, tp, LOCATION_MZONE, 0, 1, 1, c, e, tp)
    Duel.SetOperationInfo(0, CATEGORY_DESTROY, g, #g, 0, 0)
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_EXTRA)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local tc = Duel.GetFirstTarget()
    if Duel.Destroy(tc, REASON_EFFECT) ~= 0 and Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 then
        local tc = Utility.SelectMatchingCard(HINTMSG_SPSUMMON, tp, s.e2filter2, tp, LOCATION_EXTRA, 0, 1, 1, nil, e, tp, tc):GetFirst()
        if tc then
            Duel.SpecialSummon(tc, SUMMON_TYPE_LINK, tp, tp, false, false, POS_FACEUP)
            tc:CompleteProcedure()
        end
    end
end

function s.e4filter(c) return c:IsRace(RACE_CYBERSE) and c:IsLinkSpell() end

function s.e4op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local og = c:GetMutualLinkedGroup():Filter(s.e4filter, nil)
    local g = og:Filter(function(c) return c:GetFlagEffect(id) == 0 end, nil)
    if #g <= 0 then return end

    for tc in g:Iter() do
        local code = tc:GetOriginalCode()
        if not og:IsExists(function(c, code) return c:IsCode(code) and c:GetFlagEffect(id) > 0 end, 1, tc, code) then
            tc:RegisterFlagEffect(id, RESET_EVENT + RESETS_STANDARD, 0, 0)
            local cid = c:CopyEffect(code, RESET_EVENT + RESETS_STANDARD)
            local reset1 = Effect.CreateEffect(c)
            reset1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
            reset1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
            reset1:SetCode(EVENT_ADJUST)
            reset1:SetRange(LOCATION_MZONE)
            reset1:SetLabel(cid)
            reset1:SetLabelObject(tc)
            reset1:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
                local cid = e:GetLabel()
                local c = e:GetHandler()
                local tc = e:GetLabelObject()
                local g = c:GetMutualLinkedGroup():Filter(function(c) return c:GetFlagEffect(id) > 0 end, nil)
                if c:IsDisabled() or c:IsFacedown() or not g:IsContains(tc) then
                    c:ResetEffect(cid, RESET_COPY)
                    tc:ResetFlagEffect(id)
                end
            end)
            reset1:SetReset(RESET_EVENT + RESETS_STANDARD)
            c:RegisterEffect(reset1, true)
            local reset2 = reset1:Clone()
            reset2:SetRange(LOCATION_ONFIELD)
            reset2:SetLabelObject(c)
            reset2:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
                local cid = e:GetLabel()
                local c = e:GetLabelObject()
                local tc = e:GetHandler()
                local g = c:GetMutualLinkedGroup():Filter(function(c) return c:GetFlagEffect(id) > 0 end, nil)
                if c:IsDisabled() or c:IsFacedown() or not g:IsContains(tc) then
                    c:ResetEffect(cid, RESET_COPY)
                    tc:ResetFlagEffect(id)
                end
            end)
            tc:RegisterEffect(reset2, true)
        end
    end
end
