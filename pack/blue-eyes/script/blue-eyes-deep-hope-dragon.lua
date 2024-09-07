-- Blue-Eyes Deep Hope Dragon
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_series = {SET_BLUE_EYES}
s.listed_names = {CARD_BLUEEYES_W_DRAGON, 23995346}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- xyz summon
    Xyz.AddProcedure(c, function(c, sc, st, tp) return c:IsRace(RACE_DRAGON, sc, st, tp) and c:IsType(TYPE_NORMAL, sc, st, tp) end, 8, 2)

    -- special summon
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
    e1:SetRange(LOCATION_EXTRA + LOCATION_GRAVE)
    e1:SetCode(EVENT_DESTROYED)
    e1:SetCountLimit(1, {id, 1})
    e1:SetCondition(s.e1con)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- atk value
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE + EFFECT_FLAG_CANNOT_DISABLE)
    e2:SetCode(EFFECT_SET_BASE_ATTACK)
    e2:SetRange(LOCATION_MZONE)
    e2:SetValue(function(e, c)
        local og = c:GetOverlayGroup()
        local _, atk = og:GetMaxGroup(Card.GetAttack)
        return atk
    end)
    c:RegisterEffect(e2)

    -- special summon
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 2))
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1, {id, 2})
    e3:SetCost(s.e3cost)
    e3:SetTarget(s.e3tg)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3, false, REGISTER_FLAG_DETACH_XMAT)

    -- material
    local e4 = Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id, 3))
    e4:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    e4:SetCode(EVENT_PHASE + PHASE_END)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCountLimit(1, {id, 3})
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

function s.e1filter(c, tp)
    return c:IsPreviousSetCard(SET_BLUE_EYES) and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE) and
               (c:IsReason(REASON_BATTLE) or (c:IsReason(REASON_EFFECT) and c:GetReasonPlayer() ~= tp)) and not c:IsCode(id)
end

function s.e1con(e, tp, eg, ep, ev, re, r, rp)
    return eg:IsExists(s.e1filter, 1, nil, tp) and (e:GetHandler():IsLocation(LOCATION_EXTRA) or aux.exccon(e))
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
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

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
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

    if Duel.SpecialSummon(c, st, tp, tp, false, false, POS_FACEUP) ~= 0 then
        local g = Duel.GetMatchingGroup(Card.IsRace, tp, LOCATION_GRAVE, 0, c, RACE_DRAGON)
        if #g > 0 and Duel.SelectEffectYesNo(tp, c, aux.Stringid(id, 0)) then
            g = Utility.GroupSelect(g, tp, 1, 1, HINTMSG_XMATERIAL)
            Duel.Overlay(c, g)
        end
    end
    c:CompleteProcedure()
end

function s.e3filter(c, e, tp)
    return not c:IsCode(id) and c:IsCanBeSpecialSummoned(e, 0, tp, true, false) and
               (c:IsCode({CARD_BLUEEYES_W_DRAGON, 23995346}) or c:ListsCode(CARD_BLUEEYES_W_DRAGON) or c:ListsCode(23995346))
end

function s.e3cost(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return c:CheckRemoveOverlayCard(tp, 3, REASON_COST) end
    c:RemoveOverlayCard(tp, 3, 3, REASON_COST)
end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local loc = LOCATION_HAND + LOCATION_DECK + LOCATION_GRAVE + LOCATION_REMOVED
    if chk == 0 then return Duel.IsExistingMatchingCard(s.e3filter, tp, loc, 0, 1, nil, e, tp) and Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, loc)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    if Duel.GetLocationCount(tp, LOCATION_MZONE) <= 0 then return end
    local loc = LOCATION_HAND + LOCATION_DECK + LOCATION_GRAVE + LOCATION_REMOVED

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
    local g = Duel.SelectMatchingCard(tp, s.e3filter, tp, loc, 0, 1, 1, nil, e, tp)
    if #g > 0 then Duel.SpecialSummon(g, 0, tp, tp, true, false, POS_FACEUP) end
end

function s.e4filter(c) return c:IsSetCard(SET_BLUE_EYES) end

function s.e4tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return c:IsType(TYPE_XYZ) and Duel.IsExistingMatchingCard(s.e4filter, tp, LOCATION_MZONE, 0, 1, c) end
end

function s.e4op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) then return end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_XMATERIAL)
    local g = Utility.SelectMatchingCard(HINTMSG_XMATERIAL, tp, s.e4filter, tp, LOCATION_MZONE, 0, 1, 1, c)
    if #g > 0 then Duel.Overlay(c, g) end
end

function s.e5filter(c) return c:IsMonster() end

function s.e5op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local og = c:GetOverlayGroup():Filter(s.e5filter, nil)
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
