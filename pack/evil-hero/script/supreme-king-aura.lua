-- Supreme King's Aura
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {CARD_DARK_FUSION}
s.listed_series = {0xf8}

function s.initial_effect(c)
    aux.AddEquipProcedure(c, nil,
        function(c) return (c:GetOriginalLevel() == 12 and c:IsSetCard(0xf8)) or (c:IsType(TYPE_FUSION) and c.dark_calling) end)

    -- immune
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_EQUIP)
    e1:SetCode(EFFECT_IMMUNE_EFFECT)
    e1:SetValue(function(e, re)
        local c = e:GetHandler()
        local rc = re:GetOwner()
        return rc ~= c and rc ~= c:GetEquipTarget()
    end)
    c:RegisterEffect(e1)
end
