-- Blue-Eyes Deep Hope Dragon
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_series = {SET_BLUE_EYES}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- xyz summon
    Xyz.AddProcedure(c, s.xyzfilter, 8, 2)

    -- atk up
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_CANNOT_NEGATE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- special summon
    local e2 = Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
    e2:SetRange(LOCATION_EXTRA + LOCATION_GRAVE)
    e2:SetCode(EVENT_DESTROYED)
    e2:SetCountLimit(1, id)
    e2:SetCondition(s.e2con)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)

    -- material
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 0))
    e3:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_PHASE + PHASE_END)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1)
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

function s.xyzfilter(c, sc, st, tp) return c:IsAttribute(ATTRIBUTE_LIGHT, sc, st, tp) and c:IsRace(RACE_DRAGON, sc, st, tp) and c:IsFaceup() end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()

    local g = Utility.SelectMatchingCard(HINTMSG_XMATERIAL, tp, Card.IsRace, tp, LOCATION_GRAVE + LOCATION_REMOVED, 0, 1, 1, nil, RACE_DRAGON)
    if #g > 0 then Duel.Overlay(c, g) end

    local og = c:GetOverlayGroup()
    if #og > 0 then
        local _, atk = og:GetMaxGroup(Card.GetAttack)
        local ec1 = Effect.CreateEffect(c)
        ec1:SetType(EFFECT_TYPE_SINGLE)
        ec1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
        ec1:SetCode(EFFECT_SET_BASE_ATTACK)
        ec1:SetValue(atk)
        ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
        c:RegisterEffect(ec1)
    end
end

function s.e2filter(c, tp)
    return c:IsPreviousSetCard(SET_BLUE_EYES) and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE) and
               (c:IsReason(REASON_BATTLE) or (c:IsReason(REASON_EFFECT) and c:GetReasonPlayer() ~= tp)) and not c:IsCode(id)
end

function s.e2con(e, tp, eg, ep, ev, re, r, rp)
    return eg:IsExists(s.e2filter, 1, nil, tp) and (e:GetHandler():IsLocation(LOCATION_EXTRA) or aux.exccon(e))
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then
        if c:IsLocation(LOCATION_EXTRA) then
            return Duel.GetLocationCountFromEx(tp, tp, nil, c) > 0 and c:IsCanBeSpecialSummoned(e, SUMMON_TYPE_XYZ, tp, false, false)
        else
            return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
        end
    end

    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, c, 1, 0, 0)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) then return end

    local st
    if c:IsLocation(LOCATION_EXTRA) then
        if Duel.GetLocationCountFromEx(tp, tp, nil, c) == 0 then return end
        st = SUMMON_TYPE_XYZ
    else
        if Duel.GetLocationCount(tp, LOCATION_MZONE) == 0 then return end
        st = 0
    end

    Duel.SpecialSummon(c, st, tp, tp, false, false, POS_FACEUP)
    c:CompleteProcedure()
end

function s.e3filter(c) return c:IsSetCard(SET_BLUE_EYES) end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return c:IsType(TYPE_XYZ) and Duel.IsExistingMatchingCard(s.e3filter, tp, LOCATION_MZONE, 0, 1, c) end
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) then return end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_XMATERIAL)
    local g = Utility.SelectMatchingCard(HINTMSG_XMATERIAL, tp, s.e3filter, tp, LOCATION_MZONE, 0, 1, 1, c)
    if #g > 0 then Duel.Overlay(c, g) end
end

function s.e4filter(c) return c:IsMonster() end

function s.e4op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local og = c:GetOverlayGroup():Filter(s.e4filter, nil)
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
