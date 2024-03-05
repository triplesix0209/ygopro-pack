-- Storm Coder
Duel.LoadScript("util.lua")
local s, id = GetID()

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- link summon
    Link.AddProcedure(c, aux.FilterBoolFunctionEx(Card.IsRace, RACE_CYBERSE), 2, 2)

    -- extra material
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetCode(EFFECT_EXTRA_MATERIAL)
    e1:SetRange(LOCATION_HAND)
    e1:SetTargetRange(1, 0)
    e1:SetOperation(s.e1con)
    e1:SetValue(s.e1val)
    local e1b = Effect.CreateEffect(c)
    e1b:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_GRANT)
    e1b:SetRange(LOCATION_MZONE)
    e1b:SetTargetRange(LOCATION_HAND, 0)
    e1b:SetTarget(function(e, c) return c:IsRace(RACE_CYBERSE) and c:IsCanBeLinkMaterial() end)
    e1b:SetLabelObject(e1)
    c:RegisterEffect(e1b)
end

function s.e1filter(c, tp) return c:IsLocation(LOCATION_MZONE) and c:IsControler(tp) end

function s.e1con(c, e, tp, sg, mg, lc, og, chk)
    local ct = sg:FilterCount(Card.HasFlagEffect, nil, id)
    return ct == 0 or ((sg + mg):Filter(s.e1filter, nil, e:GetHandlerPlayer()):IsExists(Card.IsCode, 1, og, id) and ct < 2)
end

function s.e1val(chk, summon_type, e, ...)
    local c = e:GetHandler()
    if chk == 0 then
        local tp, sc = ...
        if summon_type ~= SUMMON_TYPE_LINK or not sc:IsRace(RACE_CYBERSE) or Duel.GetFlagEffect(tp, id) > 0 then
            return Group.CreateGroup()
        else
            s.flagmap[c] = c:RegisterFlagEffect(id, 0, 0, 1)
            return Group.FromCards(c)
        end
    elseif chk == 1 then
        local sg, sc, tp = ...
        if summon_type & SUMMON_TYPE_LINK == SUMMON_TYPE_LINK and #sg > 0 and Duel.GetFlagEffect(tp, id) == 0 then
            Duel.Hint(HINT_CARD, tp, id)
            Duel.RegisterFlagEffect(tp, id, RESET_PHASE | PHASE_END, 0, 1)
        end
    elseif chk == 2 then
        if s.flagmap[c] then
            s.flagmap[c]:Reset()
            s.flagmap[c] = nil
        end
    end
end
