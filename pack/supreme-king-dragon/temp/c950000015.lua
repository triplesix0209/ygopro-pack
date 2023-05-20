-- Dark Rebellion Magician
Duel.LoadScript("util.lua")
Duel.LoadScript("util_pendulum.lua")
Duel.LoadScript("c419.lua")
local s, id = GetID()

s.listed_series = {0x13b}
s.pendulum_level = 4

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- xyz summon
    Xyz.AddProcedure(c, aux.FilterBoolFunctionEx(Card.IsType, TYPE_PENDULUM), 4,
                     2)

    -- pendulum
    Pendulum.AddProcedure(c, false)
    UtilPendulum.PlaceToPZoneWhenDestroyed(c)

    -- rank-up
    local pe1 = Effect.CreateEffect(c)
    pe1:SetDescription(aux.Stringid(id, 0))
    pe1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    pe1:SetType(EFFECT_TYPE_IGNITION)
    pe1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    pe1:SetRange(LOCATION_PZONE)
    pe1:SetCountLimit(1)
    pe1:SetTarget(s.pe1tg)
    pe1:SetOperation(s.pe1op)
    c:RegisterEffect(pe1)

    -- detach cost replacement
    local me1 = Effect.CreateEffect(c)
    me1:SetType(EFFECT_TYPE_CONTINUOUS + EFFECT_TYPE_FIELD)
    me1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_CANNOT_NEGATE)
    me1:SetCode(EFFECT_OVERLAY_REMOVE_REPLACE)
    me1:SetRange(LOCATION_MZONE)
    me1:SetCondition(s.me1con)
    me1:SetOperation(s.me1op)
    c:RegisterEffect(me1)

    -- damage
    local me2 = Effect.CreateEffect(c)
    me2:SetDescription(aux.Stringid(id, 1))
    me2:SetCategory(CATEGORY_DAMAGE)
    me2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    me2:SetProperty(EFFECT_FLAG_DELAY + EFFECT_FLAG_DAMAGE_STEP +
                        EFFECT_FLAG_PLAYER_TARGET)
    me2:SetCode(511001265)
    me2:SetRange(LOCATION_MZONE)
    me2:SetCountLimit(1, id)
    me2:SetCondition(s.me2con)
    me2:SetTarget(s.me2tg)
    me2:SetOperation(s.me2op)
    c:RegisterEffect(me2)
end

function s.pe1filter1(c, e, tp)
    local pg = aux.GetMustBeMaterialGroup(tp, Group.FromCards(c), tp, nil, nil,
                                          REASON_XYZ)
    return #pg <= 1 and c:IsFaceup() and c:IsRace(RACE_DRAGON) and
               (c:GetRank() > 0 or c:IsStatus(STATUS_NO_LEVEL)) and
               Duel.IsExistingMatchingCard(s.pe1filter2, tp, LOCATION_EXTRA, 0,
                                           1, nil, e, tp, c, pg)
end

function s.pe1filter2(c, e, tp, mc, pg)
    local rk = mc:GetRank()
    if c.rum_limit and not c.rum_limit(mc, e) or
        Duel.GetLocationCountFromEx(tp, tp, mc, c) <= 0 then return false end
    return
        c:IsType(TYPE_XYZ) and mc:IsType(TYPE_XYZ, c, SUMMON_TYPE_XYZ, tp) and
            mc:IsRace(RACE_DRAGON, c, SUMMON_TYPE_XYZ, tp) and c:IsRank(rk + 1) and
            mc:IsCanBeXyzMaterial(c, tp) and (#pg <= 0 or pg:IsContains(mc)) and
            c:IsCanBeSpecialSummoned(e, SUMMON_TYPE_XYZ, tp, false, false)
end

function s.pe1tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chk == 0 then
        return Duel.IsExistingTarget(s.pe1filter1, tp, LOCATION_MZONE, 0, 1,
                                     nil, e, tp)
    end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TARGET)
    Duel.SelectTarget(tp, s.pe1filter1, tp, LOCATION_MZONE, 0, 1, 1, nil, e, tp)

    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_EXTRA)
end

function s.pe1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Duel.GetFirstTarget()
    if not tc or tc:IsFacedown() or not c:IsRelateToEffect(e) or
        not tc:IsRelateToEffect(e) or tc:IsControler(1 - tp) or
        tc:IsImmuneToEffect(e) then return end

    local pg = aux.GetMustBeMaterialGroup(tp, Group.FromCards(tc), tp, nil, nil,
                                          REASON_XYZ)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
    local sc = Duel.SelectMatchingCard(tp, s.pe1filter2, tp, LOCATION_EXTRA, 0,
                                       1, 1, nil, e, tp, tc, pg):GetFirst()
    if not sc then return end

    sc:SetMaterial(Group.FromCards(tc))
    Duel.Overlay(sc, Group.FromCards(tc, c), true)
    Duel.SpecialSummon(sc, SUMMON_TYPE_XYZ, tp, tp, false, false, POS_FACEUP)
    sc:CompleteProcedure()
end

function s.me1con(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local rc = re:GetHandler()
    return (r & REASON_COST) ~= 0 and ep == e:GetOwnerPlayer() and
               re:IsActivated(0x7e0) and
               c:CheckRemoveOverlayCard(tp, 1, REASON_EFFECT) and
               c:GetOverlayCount() + rc:GetOverlayCount() >= ev and
               re:IsActiveType(TYPE_XYZ) and rc:IsAttribute(ATTRIBUTE_DARK)
end

function s.me1op(e, tp, eg, ep, ev, re, r, rp)
    return e:GetHandler():RemoveOverlayCard(tp, 1, ev, REASON_EFFECT)
end

function s.me2filter1(c, tp)
    local preatk = 0
    if c:GetFlagEffect(284) > 0 then preatk = c:GetFlagEffectLabel(284) end
    return
        c:IsControler(tp) and c:GetAttack() ~= preatk and c:IsSetCard(0x13b) and
            c:IsRace(RACE_DRAGON)
end

function s.me2filter2(c, g)
    local preatk = 0
    if c:GetFlagEffect(284) > 0 then preatk = c:GetFlagEffectLabel(284) end

    local dif = 0
    if c:GetAttack() > preatk then
        dif = c:GetAttack() - preatk
    else
        dif = preatk - c:GetAttack()
    end
    return g:IsExists(s.me2filter3, 1, c, dif)
end

function s.me2filter3(c, dif)
    local preatk = 0
    if c:GetFlagEffect(284) > 0 then preatk = c:GetFlagEffectLabel(284) end

    local dif2 = 0
    if c:GetAttack() > preatk then
        dif2 = c:GetAttack() - preatk
    else
        dif2 = preatk - c:GetAttack()
    end

    return dif ~= dif2
end

function s.me2con(e, tp, eg, ep, ev, re, r, rp)
    return eg:IsExists(s.me2filter1, 1, nil, tp)
end

function s.me2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return true end

    local g = eg:Filter(s.me2filter1, nil, tp)
    local sc = g:GetFirst()
    local sg = g:Filter(s.me2filter2, nil, g)
    if #sg > 0 then sc = sg:Select(tp, 1, 1, nil):GetFirst() end

    local dmg = 0
    local preatk = 0
    if sc:GetFlagEffect(284) > 0 then preatk = sc:GetFlagEffectLabel(284) end
    if sc:GetAttack() > preatk then
        dmg = sc:GetAttack() - preatk
    else
        dmg = preatk - sc:GetAttack()
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
