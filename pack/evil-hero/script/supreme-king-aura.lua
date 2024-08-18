-- Supreme King's Aura
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {CARD_DARK_FUSION}
s.listed_series = {0xf8}

function s.initial_effect(c)
    c:SetUniqueOnField(1, 0, id)
    aux.AddEquipProcedure(c, nil,
        function(c) return (c:GetOriginalLevel() == 12 and c:IsSetCard(0xf8)) or (c:IsType(TYPE_FUSION) and c.dark_calling) end)

    -- double ATK & immune
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_EQUIP)
    e1:SetCode(EFFECT_SET_BASE_ATTACK)
    e1:SetValue(function(e, c)
        local val = c:GetBaseAttack()
        return val >= 0 and val * 2 or 0
    end)
    c:RegisterEffect(e1)
    local e1b = e1:Clone()
    e1b:SetCode(EFFECT_IMMUNE_EFFECT)
    e1b:SetValue(function(e, re)
        local c = e:GetHandler()
        local rc = re:GetOwner()
        return rc ~= c and rc ~= c:GetEquipTarget()
    end)
    c:RegisterEffect(e1b)

    -- attach
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 0))
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_SZONE)
    e2:SetCountLimit(1)
    e2:SetCondition(s.effcon)
    e2:SetCost(s.e2cost)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)

    -- gain effect
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e3:SetCode(EVENT_ADJUST)
    e3:SetRange(LOCATION_SZONE)
    e3:SetCondition(s.effcon)
    e3:SetOperation(s.e3op)
    c:RegisterEffect(e3)
end

function s.effcon(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local ec = c:GetEquipTarget()
    return ec and ec:IsSetCard(0xf8)
end

function s.e2filter(c, tp) return c:IsFaceup() and (c:IsControler(tp) or c:IsControlerCanBeChanged()) end

function s.e2cost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable, tp, LOCATION_HAND, 0, 1, nil) end
    Duel.DiscardHand(tp, Card.IsDiscardable, 1, 1, REASON_COST + REASON_DISCARD, nil)
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    local ec = c:GetEquipTarget()
    if chk == 0 then return Duel.IsExistingMatchingCard(s.e2filter, tp, LOCATION_MZONE, LOCATION_MZONE, 1, ec, tp) end
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local ec = c:GetEquipTarget()
    if not c:IsRelateToEffect(e) then return end
    local g = Utility.SelectMatchingCard(HINTMSG_SELECT, tp, s.e2filter, tp, LOCATION_MZONE, LOCATION_MZONE, 1, 1, ec, tp)
    Duel.HintSelection(g)
    Duel.Overlay(c, g)
end

function s.e3filter(c) return c:IsMonster() end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local ec = c:GetEquipTarget()
    local og = c:GetOverlayGroup():Filter(s.e3filter, nil)
    local g = og:Filter(function(c) return c:GetFlagEffect(id) == 0 end, nil)
    if #g <= 0 then return end

    for tc in g:Iter() do
        local code = tc:GetOriginalCode()
        if not og:IsExists(function(c, code) return c:IsCode(code) and c:GetFlagEffect(id) > 0 end, 1, tc, code) then
            tc:RegisterFlagEffect(id, RESET_EVENT + RESETS_STANDARD, 0, 0)
            local cid = ec:CopyEffect(code, RESET_EVENT + RESETS_STANDARD)
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
                local ec = c:GetEquipTarget()
                local tc = e:GetLabelObject()
                local g = c:GetOverlayGroup():Filter(function(c) return c:GetFlagEffect(id) > 0 end, nil)
                if c:IsDisabled() or ec == nil or not g:IsContains(tc) then
                    ec:ResetEffect(cid, RESET_COPY)
                    tc:ResetFlagEffect(id)
                end
            end)
            reset:SetReset(RESET_EVENT + RESETS_STANDARD)
            c:RegisterEffect(reset, true)
        end
    end
end
