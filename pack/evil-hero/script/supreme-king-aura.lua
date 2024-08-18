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
end
