-- The Genesis Messiah
Duel.LoadScript("util.lua")
Duel.LoadScript("util_messiah.lua")
local s, id = GetID()

function s.initial_effect(c)
    Messiah.RegisterMessiahBabyEffect(s, c, id, LOCATION_HAND + LOCATION_DECK, function(c) return c:IsLevelBelow(4) end)

    -- link summon
    Link.AddProcedure(c, function(c, sc, sumtype, tp) return not c:IsType(TYPE_LINK, sc, sumtype, tp) end, 2, 2)

    -- destroy itself
    local me1 = Effect.CreateEffect(c)
    me1:SetDescription(aux.Stringid(id, 3))
    me1:SetCategory(CATEGORY_DESTROY)
    me1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_F)
    me1:SetRange(LOCATION_MZONE)
    me1:SetCode(EVENT_PHASE + PHASE_END)
    me1:SetCountLimit(1)
    me1:SetTarget(function(e, tp, eg, ep, ev, re, r, rp, chk)
        if chk == 0 then return true end
        Duel.SetOperationInfo(0, CATEGORY_DESTROY, e:GetHandler(), 1, 0, 0)
    end)
    me1:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
        local c = e:GetHandler()
        if c:IsRelateToEffect(e) and c:IsFaceup() then Duel.Destroy(c, REASON_EFFECT) end
    end)
    c:RegisterEffect(me1)
end
