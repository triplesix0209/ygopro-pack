-- Number 100: Genesis Numeron Dragon
Duel.LoadScript("util.lua")
Duel.LoadScript("util_xyz.lua")
local s, id = GetID()

s.xyz_number = 100
s.listed_names = {57314798}
s.listed_series = {0x48, 0x95}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- xyz summon
    Xyz.AddProcedure(c, s.xyzfilter, nil, 5, s.xyzovfilter, aux.Stringid(id, 0),
                     nil, s.xyzop, false, s.xyzcheck)

    -- special summon limit
    local splimit = Effect.CreateEffect(c)
    splimit:SetType(EFFECT_TYPE_SINGLE)
    splimit:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    splimit:SetCode(EFFECT_SPSUMMON_CONDITION)
    c:RegisterEffect(splimit)

    -- summon cannot be negated
    local nospnegate = Effect.CreateEffect(c)
    nospnegate:SetType(EFFECT_TYPE_SINGLE)
    nospnegate:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    nospnegate:SetCode(EFFECT_CANNOT_DISABLE_SPSUMMON)
    c:RegisterEffect(nospnegate)

    -- activation and effects cannot be negated
    local inact = Effect.CreateEffect(c)
    inact:SetType(EFFECT_TYPE_FIELD)
    inact:SetCode(EFFECT_CANNOT_INACTIVATE)
    inact:SetRange(LOCATION_MZONE)
    inact:SetValue(function(e, ct)
        local te = Duel.GetChainInfo(ct, CHAININFO_TRIGGERING_EFFECT)
        return te:GetHandler() == e:GetHandler()
    end)
    c:RegisterEffect(inact)
    local inact2 = inact:Clone()
    inact2:SetCode(EFFECT_CANNOT_DISEFFECT)
    c:RegisterEffect(inact2)
    local nodis = Effect.CreateEffect(c)
    nodis:SetType(EFFECT_TYPE_SINGLE)
    nodis:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    nodis:SetCode(EFFECT_CANNOT_DISABLE)
    nodis:SetRange(LOCATION_MZONE)
    c:RegisterEffect(nodis)

    -- cannot be switch control
    local noswitch = Effect.CreateEffect(c)
    noswitch:SetType(EFFECT_TYPE_SINGLE)
    noswitch:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    noswitch:SetCode(EFFECT_CANNOT_CHANGE_CONTROL)
    noswitch:SetRange(LOCATION_MZONE)
    c:RegisterEffect(noswitch)

    -- cannot be flipped
    local noflip = Effect.CreateEffect(c)
    noflip:SetType(EFFECT_TYPE_SINGLE)
    noflip:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    noflip:SetCode(EFFECT_CANNOT_TURN_SET)
    noflip:SetRange(LOCATION_MZONE)
    c:RegisterEffect(noflip)

    -- cannot be tributed or be used as a material
    local norelease = Effect.CreateEffect(c)
    norelease:SetType(EFFECT_TYPE_FIELD)
    norelease:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    norelease:SetCode(EFFECT_CANNOT_RELEASE)
    norelease:SetRange(LOCATION_MZONE)
    norelease:SetTargetRange(0, 1)
    norelease:SetTarget(function(e, tc) return tc == e:GetHandler() end)
    c:RegisterEffect(norelease)
    local nofus = Effect.CreateEffect(c)
    nofus:SetType(EFFECT_TYPE_SINGLE)
    nofus:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    nofus:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
    nofus:SetRange(LOCATION_MZONE)
    nofus:SetValue(function(e, tc)
        if not tc then return false end
        return tc:GetControler() ~= e:GetHandlerPlayer()
    end)
    c:RegisterEffect(nofus)
    local nosync = nofus:Clone()
    nosync:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
    c:RegisterEffect(nosync)
    local noxyz = nofus:Clone()
    noxyz:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
    c:RegisterEffect(noxyz)
    local nolnk = nofus:Clone()
    nolnk:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
    c:RegisterEffect(nolnk)

    -- gain effect
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e1:SetCode(EVENT_ADJUST)
    e1:SetRange(LOCATION_MZONE)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- attach
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 1))
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetHintTiming(0, TIMINGS_CHECK_MONSTER)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)

    -- summon
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 2))
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)
end

function s.xyzfilter(c, xyz, sumtype, tp)
    return c:IsType(TYPE_XYZ, xyz, sumtype, tp) and
               c:IsSetCard(0x48, xyz, sumtype, tp)
end

function s.xyzovfilter(c) return c:IsFaceup() and c:IsCode(57314798) end

function s.xyzcheck(g, tp, xyz)
    local mg =
        g:Filter(function(c) return not c:IsHasEffect(511001175) end, nil)
    return mg:GetClassCount(Card.GetRank) == 1
end

function s.xyzcostfilter(c)
    return c:IsSetCard(0x95) and c:IsType(TYPE_SPELL) and c:IsDiscardable()
end

function s.xyzop(e, tp, chk, mc)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.xyzcostfilter, tp, LOCATION_HAND,
                                           0, 1, nil)
    end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_DISCARD)
    local tc =
        Duel.GetMatchingGroup(s.xyzcostfilter, tp, LOCATION_HAND, 0, nil):SelectUnselect(
            Group.CreateGroup(), tp, false, Xyz.ProcCancellable)
    if tc then
        Duel.SendtoGrave(tc, REASON_DISCARD + REASON_COST)
        return true
    else
        return false
    end
end

function s.e1filter(c)
    return not c:IsCode(id) and c:IsType(TYPE_XYZ) and c:IsSetCard(0x48) and
               c:GetFlagEffect(id) == 0
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local g = c:GetOverlayGroup():Filter(s.e1filter, nil)
    if #g <= 0 then return end

    for tc in aux.Next(g) do
        tc:RegisterFlagEffect(id, RESET_EVENT + 0x1fe0000, 0, 0)

        local code = tc:GetOriginalCodeRule()
        if not g:IsExists(function(c, code)
            return c:IsCode(code) and c:GetFlagEffect(id) > 0
        end, 1, tc, code) then
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
                local g = c:GetOverlayGroup():Filter(function(c)
                    return c:GetFlagEffect(id) > 0
                end, nil)
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

function s.e2filter(c, tp)
    return c:IsFaceup() and not c:IsType(TYPE_TOKEN) and
               (c:IsControler(tp) or c:IsAbleToChangeControler())
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    local c = e:GetHandler()
    if chk == 0 then
        return c:IsType(TYPE_XYZ) and
                   Duel.IsExistingTarget(s.e2filter, tp,
                                         LOCATION_ONFIELD + LOCATION_REMOVED, 0,
                                         1, c, tp)
    end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TARGET)
    Duel.SelectTarget(tp, s.e2filter, tp, LOCATION_ONFIELD + LOCATION_REMOVED,
                      0, 1, 1, c, tp)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Duel.GetFirstTarget()
    if not c:IsRelateToEffect(e) or tc:IsFacedown() or
        not tc:IsRelateToEffect(e) or tc:IsImmuneToEffect(e) then return end

    UtilXyz.Overlay(c, tc, true)
end

function s.e3filter(c, e, tp)
    return c:IsSetCard(0x48) and c:IsType(TYPE_XYZ) and not c:IsCode(id) and
               c:IsCanBeSpecialSummoned(e, SUMMON_TYPE_XYZ, tp, true, true)
end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chk == 0 then
        return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and
                   Duel.IsExistingTarget(s.e3filter, tp, LOCATION_GRAVE, 0, 1,
                                         nil, e, tp)
    end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
    local g = Duel.SelectTarget(tp, s.e3filter, tp, LOCATION_GRAVE, 0, 1, 1,
                                nil, e, tp)
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, g, #g, 0, 0)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local tc = Duel.GetFirstTarget()
    if not tc:IsRelateToEffect(e) then return end

    Duel.SpecialSummon(tc, SUMMON_TYPE_XYZ, tp, tp, true, true, POS_FACEUP)
    tc:CompleteProcedure()
end
