-- Photon World
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {CARD_GALAXYEYES_P_DRAGON}
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
end

function s.e1filter(c) return c:IsSetCard(SET_PHOTON) and c:IsType(TYPE_CONTINUOUS) end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.e1filter, tp, LOCATION_HAND + LOCATION_DECK, 0, 1, nil) end
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) then return end

    local tc = Utility.SelectMatchingCard(HINTMSG_SELECT, tp, s.e1filter, tp, LOCATION_HAND + LOCATION_DECK, 0, 1, 1, c):GetFirst()
    Duel.Overlay(c, tc)
end

function s.e2filter(c) return c:IsFaceup() and c:IsSetCard(SET_GALAXY) and c:IsRace(RACE_DRAGON) end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not (rp == tp and re:IsActiveType(TYPE_CONTINUOUS) and re:IsHasType(EFFECT_TYPE_ACTIVATE) and e:GetHandler():GetFlagEffect(1) > 0 and
        Duel.IsExistingMatchingCard(s.e2filter, tp, LOCATION_MZONE, 0, 1, nil)) then return end
    if not Duel.SelectEffectYesNo(tp, c, aux.Stringid(id, 0)) then return end

    Duel.Overlay(c, re:GetHandler())
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
