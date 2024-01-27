-- Photonized Galaxy World
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_series = {SET_PHOTON, SET_GALAXY}

function s.initial_effect(c)
    -- activate
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1, {id, 1}, EFFECT_COUNT_CODE_OATH)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- place
    local e2reg = Effect.CreateEffect(c)
    e2reg:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e2reg:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e2reg:SetCode(EVENT_CHAINING)
    e2reg:SetRange(LOCATION_FZONE)
    e2reg:SetOperation(aux.chainreg)
    c:RegisterEffect(e2reg)
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EVENT_CHAIN_SOLVED)
    e2:SetRange(LOCATION_FZONE)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)

    -- gain effect
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e3:SetCode(EVENT_ADJUST)
    e3:SetRange(LOCATION_FZONE)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)

    -- cannot disable summon
    local e4 = Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_FIELD)
    e4:SetProperty(EFFECT_FLAG_IGNORE_RANGE + EFFECT_FLAG_SET_AVAILABLE)
    e4:SetCode(EFFECT_CANNOT_DISABLE_SPSUMMON)
    e4:SetRange(LOCATION_FZONE)
    e4:SetTarget(function(e, c) return c:IsSummonType(SUMMON_TYPE_LINK) and c:IsControler(e:GetHandlerPlayer()) end)
    c:RegisterEffect(e4)
end

function s.e1filter1(c) return c:IsSetCard(SET_PHOTON) and c:IsContinuousTrap() end

function s.e1filter2(c) return c:IsSetCard(SET_GALAXY) and c:IsContinuousSpell() and c:IsAbleToHand() end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.e1filter1, tp, LOCATION_HAND + LOCATION_DECK, 0, 1, nil) end
    Duel.SetPossibleOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_GRAVE + LOCATION_DECK)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) then return end

    local g1 = Utility.SelectMatchingCard(HINTMSG_SELECT, tp, s.e1filter1, tp, LOCATION_HAND + LOCATION_DECK, 0, 1, 1, nil)
    Duel.Overlay(c, g1)

    if #g1 > 0 and Duel.IsExistingMatchingCard(s.e1filter2, tp, LOCATION_GRAVE + LOCATION_DECK, 0, 1, nil) and
        Duel.SelectEffectYesNo(tp, c, aux.Stringid(id, 0)) then
        local g2 = Utility.SelectMatchingCard(HINTMSG_ATOHAND, tp, s.e1filter2, tp, LOCATION_GRAVE + LOCATION_DECK, 0, 1, 1, nil)
        if #g2 > 0 then
            Duel.SendtoHand(g2, nil, REASON_EFFECT)
            Duel.ConfirmCards(1 - tp, g2)
        end
    end
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local rc = re:GetHandler()
    if not (rp == tp and rc:IsSetCard({SET_PHOTON, SET_GALAXY}) and re:IsActiveType(TYPE_CONTINUOUS) and re:IsHasType(EFFECT_TYPE_ACTIVATE) and
        c:GetFlagEffect(1) > 0) then return end
    if not Duel.SelectEffectYesNo(tp, c, aux.Stringid(id, 0)) then return end

    Duel.Overlay(c, rc)
end

function s.e3filter(c)
    if c:GetFlagEffect(id) ~= 0 then return false end
    return c:IsType(TYPE_CONTINUOUS)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local g = c:GetOverlayGroup():Filter(s.e3filter, nil)
    if #g <= 0 then return end

    for tc in g:Iter() do
        tc:RegisterFlagEffect(id, RESET_EVENT + 0x1fe3000, 0, 0)
        local code = tc:GetOriginalCode()
        if not g:IsExists(function(c, code) return c:IsCode(code) and c:GetFlagEffect(id) > 0 end, 1, tc, code) then
            local cid = c:CopyEffect(code, RESET_EVENT + 0x1fe3000)
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
                if c:IsDisabled() or c:IsFacedown() or not g:IsContains(tc) or c:GetOverlayCount() < 5 then
                    c:ResetEffect(cid, RESET_COPY)
                    tc:ResetFlagEffect(id)
                end
            end)
            reset:SetReset(RESET_EVENT + 0x1fe3000)
            c:RegisterEffect(reset, true)
        end
    end
end
