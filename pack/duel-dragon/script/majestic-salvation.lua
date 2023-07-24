-- Majestic Salvation
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_series = {SET_MAJESTIC}

function s.initial_effect(c)
    c:SetUniqueOnField(1, 0, id)

    -- activate
    aux.AddEquipProcedure(c, nil, aux.FilterBoolFunction(s.eqfilter))

    -- cannot be tributed, nor be used as a material
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetCode(EFFECT_CANNOT_RELEASE)
    e1:SetRange(LOCATION_SZONE)
    e1:SetTargetRange(0, 1)
    e1:SetTarget(function(e, tc) return tc == e:GetHandler():GetEquipTarget() end)
    c:RegisterEffect(e1)
    local e1b = Effect.CreateEffect(c)
    e1b:SetType(EFFECT_TYPE_EQUIP)
    e1b:SetCode(EFFECT_CANNOT_BE_MATERIAL)
    e1b:SetValue(function(e, tc) return tc and tc:GetControler() ~= e:GetHandlerPlayer() end)
    c:RegisterEffect(e1b)

    -- prevent negation
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_CANNOT_INACTIVATE)
    e2:SetRange(LOCATION_SZONE)
    e2:SetTargetRange(1, 0)
    e2:SetValue(function(e, ct)
        local te = Duel.GetChainInfo(ct, CHAININFO_TRIGGERING_EFFECT)
        return te:GetHandler() == e:GetHandler():GetEquipTarget()
    end)
    c:RegisterEffect(e2)
    local e2b = e2:Clone()
    e2b:SetCode(EFFECT_CANNOT_DISEFFECT)
    c:RegisterEffect(e2b)

    -- untargetable
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_EQUIP)
    e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
    e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e3:SetValue(aux.tgoval)
    c:RegisterEffect(e3)

    -- no return
    local e4 = Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_EQUIP)
    e4:SetCode(EFFECT_CANNOT_TO_DECK)
    c:RegisterEffect(e4)
end

function s.eqfilter(c) return c:IsSetCard(SET_MAJESTIC) and c:IsRace(RACE_DRAGON) and c:IsType(TYPE_SYNCHRO) end
