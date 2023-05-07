-- Supreme King Dragon Venowurm
Duel.LoadScript("util.lua")
local s, id = GetID()

function s.initial_effect(c)
    -- pendulum summon
    Pendulum.AddProcedure(c)

    -- fusion summon (pendulum zone)
    local pe1params = {aux.FilterBoolFunction(Card.IsRace, RACE_DRAGON)}
    local pe1 = Effect.CreateEffect(c)
    pe1:SetDescription(1170)
    pe1:SetCategory(CATEGORY_SPECIAL_SUMMON + CATEGORY_FUSION_SUMMON)
    pe1:SetType(EFFECT_TYPE_IGNITION)
    pe1:SetRange(LOCATION_PZONE)
    pe1:SetCountLimit(1)
    pe1:SetTarget(Fusion.SummonEffTG(table.unpack(pe1params)))
    pe1:SetOperation(Fusion.SummonEffOP(table.unpack(pe1params)))
    c:RegisterEffect(pe1)

    -- fusion limit
    local me1 = Effect.CreateEffect(c)
    me1:SetType(EFFECT_TYPE_SINGLE)
    me1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    me1:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
    me1:SetValue(function(e, c)
        if not c then return false end
        return not c:IsRace(RACE_DRAGON) and not c:IsType(TYPE_PENDULUM)
    end)
    c:RegisterEffect(me1)

    -- special summon
    local me2 = Effect.CreateEffect(c)
    me2:SetDescription(2)
    me2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    me2:SetType(EFFECT_TYPE_IGNITION)
    me2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    me2:SetRange(LOCATION_HAND + LOCATION_GRAVE + LOCATION_EXTRA)
    me2:SetCountLimit(1, id)
    me2:SetTarget(s.me2tg)
    me2:SetOperation(s.me2op)
    c:RegisterEffect(me2)

    -- fusion summon (monster zone)
    local me3params = {nil, Fusion.CheckWithHandler(Fusion.OnFieldMat),
                       function(e, tp, mg) return Duel.GetMatchingGroup(Card.IsAbleToGrave, tp, LOCATION_PZONE, 0, nil) end, nil, Fusion.ForcedHandler}
    local me3 = Effect.CreateEffect(c)
    me3:SetDescription(1170)
    me3:SetCategory(CATEGORY_SPECIAL_SUMMON + CATEGORY_FUSION_SUMMON)
    me3:SetType(EFFECT_TYPE_IGNITION)
    me3:SetRange(LOCATION_MZONE)
    me3:SetCountLimit(1)
    me3:SetTarget(Fusion.SummonEffTG(table.unpack(me3params)))
    me3:SetOperation(Fusion.SummonEffOP(table.unpack(me3params)))
    c:RegisterEffect(me3)
end

function s.pe1filter(c, e, tp) return c:IsCanBeSpecialSummoned(e, 0, tp, true, false) and c:IsRace(RACE_DRAGON) and c:IsType(TYPE_FUSION) end

function s.me2filter(c)
    if c:IsFacedown() or c:IsDisabled() or c:IsAttack(0) then return false end
    return (c:IsRace(RACE_DRAGON) and c:IsAttackAbove(2500)) or c:IsType(TYPE_PENDULUM)
end

function s.me2tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    local c = e:GetHandler()
    if chk == 0 then
        if (not c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCount(tp, LOCATION_MZONE) == 0) or
            (c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp, tp, nil, c) == 0) then return false end

        return Duel.IsExistingTarget(s.me2filter, tp, LOCATION_MZONE, 0, 1, nil) and c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
    end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TARGET)
    Duel.SelectTarget(tp, s.me2filter, tp, LOCATION_MZONE, 0, 1, 1, nil)

    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, c, 1, 0, 0)
end

function s.me2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Duel.GetFirstTarget()
    if tc:IsFacedown() or not tc:IsRelateToEffect(e) or tc:IsImmuneToEffect(e) or tc:IsAttack(0) or tc:IsDisabled() then return end

    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_SINGLE)
    ec1:SetCode(EFFECT_SET_ATTACK_FINAL)
    ec1:SetValue(0)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
    tc:RegisterEffect(ec1)
    local ec1b = ec1:Clone()
    ec1b:SetCode(EFFECT_DISABLE)
    tc:RegisterEffect(ec1b)
    local ec1c = ec1:Clone()
    ec1c:SetCode(EFFECT_DISABLE_EFFECT)
    tc:RegisterEffect(ec1c)

    if tc:IsImmuneToEffect(ec1) or tc:IsImmuneToEffect(ec1b) or tc:IsImmuneToEffect(ec1c) or not c:IsRelateToEffect(e) then return end
    Duel.AdjustInstantly(tc)

    if (not c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCount(tp, LOCATION_MZONE) == 0) or
        (c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp, tp, nil, c) == 0) then return false end

    if Duel.SpecialSummon(c, 0, tp, tp, false, false, POS_FACEUP_DEFENSE) > 0 then
        local ec2 = Effect.CreateEffect(c)
        ec2:SetType(EFFECT_TYPE_SINGLE)
        ec2:SetCode(EFFECT_CHANGE_ATTRIBUTE)
        ec2:SetValue(ATTRIBUTE_DARK)
        ec2:SetReset(RESET_EVENT + RESETS_STANDARD)
        tc:RegisterEffect(ec2)
    end
end
