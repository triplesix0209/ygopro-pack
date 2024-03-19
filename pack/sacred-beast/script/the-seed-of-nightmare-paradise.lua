-- The Seed of Nightmare Paradise
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {6007213, 32491822, 69890967}
s.listed_series = {SET_YUBEL}

function s.initial_effect(c)
    -- activate
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1, {id, 1}, EFFECT_COUNT_CODE_OATH)
    e1:SetTarget(s.e1tg)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- untargetable & indes
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e2:SetRange(LOCATION_FZONE)
    e2:SetValue(aux.tgoval)
    c:RegisterEffect(e2)
    local e2b = e2:Clone()
    e2b:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e2b:SetValue(function(e, re, rp) return rp ~= e:GetHandlerPlayer() end)
    c:RegisterEffect(e2b)

    -- gain effect
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e3:SetCode(EVENT_ADJUST)
    e3:SetRange(LOCATION_FZONE)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)

    -- attach
    local e4 = Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id, 0))
    e4:SetCategory(CATEGORY_LEAVE_GRAVE)
    e4:SetType(EFFECT_TYPE_IGNITION)
    e4:SetRange(LOCATION_FZONE)
    e4:SetCountLimit(1)
    e4:SetCost(s.e4con)
    e4:SetTarget(s.e4tg)
    e4:SetOperation(s.e4op)
    c:RegisterEffect(e4)
end

function s.e1filter(c)
    return not c:IsCode(id) and c:IsFieldSpell() and (c:ListsArchetype(SET_YUBEL) or c:ListsCode(6007213, 32491822, 69890967)) and
               c:CheckActivateEffect(true, true, false) ~= nil
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.e1filter, tp, LOCATION_HAND + LOCATION_DECK, 0, 1, nil) end
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) then return end

    local tc = Utility.SelectMatchingCard(HINTMSG_SELECT, tp, s.e1filter, tp, LOCATION_HAND + LOCATION_DECK, 0, 1, 1, c):GetFirst()
    Duel.Overlay(c, tc)

    local te = tc:CheckActivateEffect(true, true, false)
    if not te then return end
    local op = te:GetOperation()
    if op then op(e, tp, eg, ep, ev, re, r, rp) end
end

function s.e3filter(c) return c:IsFieldSpell() or c:IsType(TYPE_CONTINUOUS) end

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

function s.e4filter(c, og)
    return (c:IsFieldSpell() or c:IsType(TYPE_CONTINUOUS)) and (c:ListsArchetype(SET_YUBEL) or c:ListsCode(6007213, 32491822, 69890967)) and
               not og:IsExists(Card.IsCode, 1, nil, c:GetCode())
end

function s.e4con(e, tp, eg, ep, ev, re, r, rp)
    return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsLevelAbove, 10), tp, LOCATION_MZONE, 0, 1, nil)
end

function s.e4tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    local og = c:GetOverlayGroup()
    if chk == 0 then return Duel.IsExistingMatchingCard(s.e4filter, tp, LOCATION_HAND + LOCATION_DECK, 0, 1, c, og) end
end

function s.e4op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local og = c:GetOverlayGroup()
    if not c:IsRelateToEffect(e) then return end

    local tg = Utility.SelectMatchingCard(HINTMSG_SELECT, tp, s.e4filter, tp, LOCATION_HAND + LOCATION_DECK, 0, 1, 1, c, og)
    Duel.Overlay(c, tg)
end
