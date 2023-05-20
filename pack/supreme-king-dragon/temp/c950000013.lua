-- Starving Venom Magician
Duel.LoadScript("util.lua")
Duel.LoadScript("util_pendulum.lua")
local s, id = GetID()

s.listed_series = {0x1050, 0x50}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- fusion summon procedure
    Fusion.AddProcMixN(c, true, true,
                       aux.FilterBoolFunctionEx(Card.IsType, TYPE_PENDULUM), 2)

    -- pendulum
    Pendulum.AddProcedure(c, false)
    UtilPendulum.PlaceToPZoneWhenDestroyed(c)

    -- fusion summon
    local pe1params = {
        nil,
        Fusion.CheckWithHandler(function(c)
            return c:IsRace(RACE_DRAGON) and c:IsType(TYPE_FUSION) and
                       c:IsOnField() and c:IsAbleToGrave()
        end),
        function(e) return Group.FromCards(e:GetHandler()) end,
        nil,
        Fusion.ForcedHandler,
        extratg = function(e, tp, eg, ep, ev, re, r, rp, chk)
            Duel.SetChainLimit(function(e, ep, tp) return tp == ep end)
        end
    }
    local pe1 = Effect.CreateEffect(c)
    pe1:SetDescription(1170)
    pe1:SetCategory(CATEGORY_SPECIAL_SUMMON + CATEGORY_FUSION_SUMMON)
    pe1:SetType(EFFECT_TYPE_IGNITION)
    pe1:SetRange(LOCATION_PZONE)
    pe1:SetCountLimit(1)
    pe1:SetTarget(Fusion.SummonEffTG(table.unpack(pe1params)))
    pe1:SetOperation(Fusion.SummonEffOP(table.unpack(pe1params)))
    c:RegisterEffect(pe1)

    -- fusion substitute
    local me1 = Effect.CreateEffect(c)
    me1:SetType(EFFECT_TYPE_SINGLE)
    me1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_CANNOT_NEGATE)
    me1:SetCode(EFFECT_FUSION_SUBSTITUTE)
    me1:SetCondition(function(e)
        local c = e:GetHandler()
        if c:IsLocation(LOCATION_REMOVED + LOCATION_EXTRA) and c:IsFacedown() then
            return false
        end
        return c:IsLocation(
                   LOCATION_ONFIELD + LOCATION_GRAVE + LOCATION_REMOVED +
                       LOCATION_EXTRA)
    end)
    c:RegisterEffect(me1)

    -- damage
    local me2 = Effect.CreateEffect(c)
    me2:SetDescription(aux.Stringid(id, 0))
    me2:SetCategory(CATEGORY_DAMAGE)
    me2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    me2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    me2:SetCode(EVENT_PHASE + PHASE_END)
    me2:SetRange(LOCATION_MZONE)
    me2:SetCountLimit(1, id)
    me2:SetTarget(s.me2tg)
    me2:SetOperation(s.me2op)
    c:RegisterEffect(me2)
end

function s.me2filter(c, tid)
    if c:GetReasonEffect() == nil and c:GetReasonCard() == nil then
        return false
    end
    if not c:IsReason(REASON_DESTROY) or c:GetTurnID() ~= tid or
        not c:IsType(TYPE_MONSTER) then return end

    local rc1 = c:GetReasonCard()
    local rc2 = c:GetReasonEffect() and c:GetReasonEffect():GetHandler() or nil
    return
        (rc1 and rc1:IsRace(RACE_DRAGON) and rc1:IsOriginalSetCard(0x1050)) or
            (rc2 and rc2:IsRace(RACE_DRAGON) and rc2:IsOriginalSetCard(0x1050))
end

function s.me2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local g = Duel.GetMatchingGroup(s.me2filter, tp, LOCATION_ALL, LOCATION_ALL,
                                    nil, Duel.GetTurnCount())
    if chk == 0 then return #g > 0 end

    local dmg = 0
    for tc in aux.Next(g) do
        if tc:GetBaseAttack() > 0 then dmg = dmg + tc:GetBaseAttack() end
    end

    Duel.SetTargetPlayer(1 - tp)
    Duel.SetTargetParam(dmg)
    Duel.SetOperationInfo(0, CATEGORY_DAMAGE, nil, 0, 1 - tp, dmg)
end

function s.me2op(e, tp, eg, ep, ev, re, r, rp)
    local p, d = Duel.GetChainInfo(0, CHAININFO_TARGET_PLAYER,
                                   CHAININFO_TARGET_PARAM)
    Duel.Damage(p, d, REASON_EFFECT)
end
