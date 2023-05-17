-- Supreme King Gate Despair
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {13331639}

function s.initial_effect(c)
    Pendulum.AddProcedure(c)

    -- act limit
    local pe1 = Effect.CreateEffect(c)
    pe1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    pe1:SetCode(EVENT_SPSUMMON_SUCCESS)
    pe1:SetRange(LOCATION_PZONE)
    pe1:SetOperation(s.pe1op)
    c:RegisterEffect(pe1)

    -- take no damage
    local pe2 = Effect.CreateEffect(c)
    pe2:SetType(EFFECT_TYPE_FIELD)
    pe2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    pe2:SetCode(EFFECT_CHANGE_DAMAGE)
    pe2:SetRange(LOCATION_PZONE)
    pe2:SetTargetRange(1, 0)
    pe2:SetLabel(0)
    pe2:SetCondition(s.pe2con)
    pe2:SetValue(s.pe2val)
    c:RegisterEffect(pe2)
    local pe2raise = Effect.CreateEffect(c)
    pe2raise:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    pe2raise:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
    pe2raise:SetCode(EVENT_ADJUST)
    pe2raise:SetRange(LOCATION_PZONE)
    pe2raise:SetLabelObject(pe2)
    pe2raise:SetOperation(s.pe2op)
    c:RegisterEffect(pe2raise)
end

function s.pe1filter(c, tp) return c:IsControler(tp) and c:IsSummonType(SUMMON_TYPE_PENDULUM) end

function s.pe1op(e, tp, eg, ep, ev, re, r, rp) if eg:IsExists(s.pe1filter, 1, nil, tp) then Duel.SetChainLimitTillChainEnd(s.pe1chainlimit) end end

function s.pe1chainlimit(e, rp, tp) return tp == rp or (e:IsActiveType(TYPE_SPELL + TYPE_TRAP) and not e:IsHasType(EFFECT_TYPE_ACTIVATE)) end

function s.pe2con(e) return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode, 13331639), e:GetHandlerPlayer(), LOCATION_ONFIELD, 0, 1, nil) end

function s.pe2val(e, re, val, r, rp, rc)
    local tp = e:GetHandlerPlayer()
    if val ~= 0 then
        e:SetLabel(val)
        return 0
    else
        return val
    end
end

function s.pe2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local val = e:GetLabelObject():GetLabel()
    if val ~= 0 then
        Duel.RaiseEvent(c, id, e, REASON_EFFECT, tp, tp, val)
        e:GetLabelObject():SetLabel(0)
    end
end
