-- Number C101: Full Armored Silent Honor DARK
Duel.LoadScript("util.lua")
local s, id = GetID()

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- Xyz Summon Procedure
    Xyz.AddProcedure(c, aux.FilterBoolFunctionEx(Card.IsAttribute, ATTRIBUTE_WATER), 6, 4, s.xyzfilter, aux.Stringid(id, 0), 3, s.xyzop)
end

function s.xyzfilter(c, tp, sc)
    return c:IsFaceup() and c:IsRank(5, 6) and c:IsAttribute(ATTRIBUTE_WATER, sc, SUMMON_TYPE_XYZ, tp) and c:IsType(TYPE_XYZ, sc, SUMMON_TYPE_XYZ, tp)
end

function s.xyzop(e, tp, chk)
    if chk == 0 then return not Duel.HasFlagEffect(tp, id) end
    Duel.RegisterFlagEffect(tp, id, RESET_PHASE | PHASE_END, 0, 1)
    return true
end
