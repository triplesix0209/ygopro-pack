-- Supreme King Gate Sin
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {13331639}

function s.initial_effect(c)
    Pendulum.AddProcedure(c)

    -- take no damage
    local pe1 = Effect.CreateEffect(c)
    pe1:SetType(EFFECT_TYPE_FIELD)
    pe1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    pe1:SetCode(EFFECT_CHANGE_DAMAGE)
    pe1:SetRange(LOCATION_PZONE)
    pe1:SetTargetRange(1, 0)
    pe1:SetLabel(0)
    pe1:SetCondition(s.pe1con)
    pe1:SetValue(s.pe1val)
    c:RegisterEffect(pe1)
    local pe1raise = Effect.CreateEffect(c)
    pe1raise:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    pe1raise:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
    pe1raise:SetCode(EVENT_ADJUST)
    pe1raise:SetRange(LOCATION_PZONE)
    pe1raise:SetLabelObject(pe1)
    pe1raise:SetOperation(s.pe1op)
    c:RegisterEffect(pe1raise)
end

function s.pe1filter(c) return c:IsFaceup() and c:IsCode(13331639) end

function s.pe1con(e) return Duel.IsExistingMatchingCard(s.pe1filter, e:GetHandlerPlayer(), LOCATION_ONFIELD, 0, 1, nil) end

function s.pe1val(e, re, val, r, rp, rc)
    local tp = e:GetHandlerPlayer()
    if val ~= 0 then
        e:SetLabel(val)
        return 0
    else
        return val
    end
end

function s.pe1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local val = e:GetLabelObject():GetLabel()
    if val ~= 0 then
        Duel.RaiseEvent(c, id, e, REASON_EFFECT, tp, tp, val)
        e:GetLabelObject():SetLabel(0)
    end
end
