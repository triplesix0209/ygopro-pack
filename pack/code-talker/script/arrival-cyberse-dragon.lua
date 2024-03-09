-- The Arrival Cyberse Dragon
Duel.LoadScript("util.lua")
local s, id = GetID()

function s.initial_effect(c)
    c:EnableReviveLimit()
    c:SetUniqueOnField(1, 0, id)

    -- link summon
    Link.AddProcedure(c, aux.FilterBoolFunctionEx(Card.IsRace, RACE_CYBERSE), 2, 99,
        function(g, sc, sumtype, tp) return g:CheckDifferentPropertyBinary(Card.GetAttribute, sc, sumtype, tp) end)

    -- cannot link material
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    e1:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
    e1:SetValue(1)
    c:RegisterEffect(e1)

    -- co-linked protect
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e2:SetRange(LOCATION_MZONE)
    e2:SetTargetRange(LOCATION_ONFIELD, 0)
    e2:SetTarget(function(e, c) return c:GetMutualLinkedGroupCount() > 0 end)
    e2:SetValue(aux.indoval)
    c:RegisterEffect(e2)
    local e2b = e2:Clone()
    e2b:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e2b:SetCode(EFFECT_CANNOT_REMOVE)
    e2b:SetTargetRange(1, 1)
    e2b:SetTarget(function(e, c, rp, r, re)
        local tp = e:GetHandlerPlayer()
        return c:IsControler(tp) and c:IsLocation(LOCATION_ONFIELD) and rp == 1 - tp and r & REASON_EFFECT ~= 0 and c:GetMutualLinkedGroupCount() > 0
    end)
    c:RegisterEffect(e2b)

    -- place link
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 0))
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1, {id, 1})
    e3:SetCost(s.e3cost)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)

    -- special summon
    local e4 = Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id, 1))
    e4:SetCategory(CATEGORY_DESTROY + CATEGORY_SPECIAL_SUMMON)
    e4:SetType(EFFECT_TYPE_IGNITION)
    e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCountLimit(1, {id, 2})
    e4:SetTarget(s.e4tg)
    e4:SetOperation(s.e4op)
    c:RegisterEffect(e4)

    -- gain effect
    local e5 = Effect.CreateEffect(c)
    e5:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e5:SetCode(EVENT_ADJUST)
    e5:SetRange(LOCATION_MZONE)
    e5:SetOperation(s.e5op)
    c:RegisterEffect(e5)
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

        -- untargetable
        local ec2 = Effect.CreateEffect(c)
        ec2:SetDescription(3061)
        ec2:SetType(EFFECT_TYPE_SINGLE)
        ec2:SetProperty(EFFECT_FLAG_CLIENT_HINT)
        ec2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
        ec2:SetValue(aux.tgoval)
        ec2:SetReset(RESET_EVENT + RESETS_STANDARD)
        tc:RegisterEffect(ec2)
    end
end

function s.e4filter1(c, e, tp)
    return c:IsLinkMonster() and e:GetHandler():GetLinkedGroup():IsContains(c) and
               Duel.IsExistingMatchingCard(s.e4filter2, tp, LOCATION_EXTRA, 0, 1, nil, e, tp, c)
end

function s.e4filter2(c, e, tp, tc)
    return c:IsRace(RACE_CYBERSE) and c:IsLinkMonster() and c:IsLinkBelow(tc:GetLink()) and
               c:IsCanBeSpecialSummoned(e, SUMMON_TYPE_LINK, tp, false, false)
end

function s.e4tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    local c = e:GetHandler()
    if chk == 0 then return Duel.IsExistingTarget(s.e4filter1, tp, LOCATION_MZONE, 0, 1, c, e, tp) end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_DESTROY)
    local g = Duel.SelectTarget(tp, s.e4filter1, tp, LOCATION_MZONE, 0, 1, 1, c, e, tp)
    Duel.SetOperationInfo(0, CATEGORY_DESTROY, g, #g, 0, 0)
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_EXTRA)
end

function s.e4op(e, tp, eg, ep, ev, re, r, rp)
    local tc = Duel.GetFirstTarget()
    if Duel.Destroy(tc, REASON_EFFECT) ~= 0 and Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 then
        local tc = Utility.SelectMatchingCard(HINTMSG_SPSUMMON, tp, s.e4filter2, tp, LOCATION_EXTRA, 0, 1, 1, nil, e, tp, tc):GetFirst()
        if tc then
            Duel.SpecialSummon(tc, SUMMON_TYPE_LINK, tp, tp, false, false, POS_FACEUP)
            tc:CompleteProcedure()
        end
    end
end

function s.e5filter(c)
    if c:GetFlagEffect(id) ~= 0 then return false end
    return c:IsRace(RACE_CYBERSE) and c:IsLinkSpell()
end

function s.e5op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local g = c:GetMutualLinkedGroup():Filter(s.e5filter, nil)
    if #g <= 0 then return end

    for tc in g:Iter() do
        tc:RegisterFlagEffect(id, RESET_EVENT + 0x1fe5000, 0, 0)
        local code = tc:GetOriginalCode()
        if not g:IsExists(function(c, code) return c:IsCode(code) and c:GetFlagEffect(id) > 0 end, 1, tc, code) then
            local cid = c:CopyEffect(code, RESET_EVENT + 0x1fe5000)
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
                local g = c:GetMutualLinkedGroup():Filter(function(c) return c:GetFlagEffect(id) > 0 end, nil)
                if c:IsDisabled() or c:IsFacedown() or not g:IsContains(tc) then
                    c:ResetEffect(cid, RESET_COPY)
                    tc:ResetFlagEffect(id)
                end
            end)
            reset:SetReset(RESET_EVENT + 0x1fe5000)
            c:RegisterEffect(reset, true)
        end
    end
end
