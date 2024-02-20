-- Odd-Eyes Magician
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_series = {SET_ODD_EYES}

function s.initial_effect(c)
    Pendulum.AddProcedure(c)

    -- reduce damage
    local pe1 = Effect.CreateEffect(c)
    pe1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    pe1:SetCode(EVENT_PRE_BATTLE_DAMAGE)
    pe1:SetRange(LOCATION_PZONE)
    pe1:SetCondition(s.pe1con)
    pe1:SetOperation(s.pe1op)
    c:RegisterEffect(pe1)

    -- special summon odd-eyes
    local pe2 = Effect.CreateEffect(c)
    pe2:SetDescription(aux.Stringid(id, 1))
    pe2:SetCategory(CATEGORY_DESTROY + CATEGORY_SPECIAL_SUMMON)
    pe2:SetType(EFFECT_TYPE_IGNITION)
    pe2:SetRange(LOCATION_PZONE)
    pe2:SetCountLimit(1, {id, 1})
    pe2:SetCondition(s.pe2con)
    pe2:SetTarget(s.pe2tg)
    pe2:SetOperation(s.pe2op)
    c:RegisterEffect(pe2)

    -- extra pendulum summon
    local me1 = Effect.CreateEffect(c)
    me1:SetDescription(aux.Stringid(id, 2))
    me1:SetCategory(CATEGORY_DESTROY)
    me1:SetType(EFFECT_TYPE_IGNITION)
    me1:SetRange(LOCATION_MZONE)
    me1:SetCountLimit(1, {id, 2})
    me1:SetTarget(s.me1tg)
    me1:SetOperation(s.me1op)
    c:RegisterEffect(me1)

    -- damage
    local me2 = Effect.CreateEffect(c)
    me2:SetDescription(aux.Stringid(id, 5))
    me2:SetCategory(CATEGORY_DAMAGE)
    me2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    me2:SetCode(EVENT_BATTLE_DAMAGE)
    me2:SetRange(LOCATION_MZONE)
    me2:SetCountLimit(1, {id, 3})
    me2:SetCondition(s.me2con)
    me2:SetTarget(s.me2tg)
    me2:SetOperation(s.me2op)
    c:RegisterEffect(me2)
end

function s.pe1con(e, tp, eg, ep, ev, re, r, rp)
    local tc = Duel.GetAttacker()
    if tc:IsControler(1 - tp) then tc = Duel.GetAttackTarget() end
    return ep == tp and tc and tc:IsType(TYPE_PENDULUM) and Duel.GetFlagEffect(tp, id) == 0
end

function s.pe1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) and Duel.GetFlagEffect(tp, id) ~= 0 then return end

    if Duel.SelectEffectYesNo(tp, c, aux.Stringid(id, 0)) then
        Duel.RegisterFlagEffect(tp, id, RESET_PHASE + PHASE_END, 0, 1)
        Duel.ChangeBattleDamage(tp, 0)
    end
end

function s.pe2filter(c, e, tp)
    if c:IsLocation(LOCATION_EXTRA) and c:IsFacedown() then return false end
    return not c:IsCode(id) and c:IsSetCard(SET_ODD_EYES) and c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end

function s.pe2con(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    return Duel.IsExistingMatchingCard(nil, tp, LOCATION_PZONE, 0, 1, c)
end

function s.pe2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local loc = LOCATION_HAND + LOCATION_DECK + LOCATION_GRAVE + LOCATION_EXTRA
    if chk == 0 then return Duel.IsExistingMatchingCard(s.pe2filter, tp, loc, 0, 1, nil, e, tp) end

    local g = Duel.GetFieldGroup(tp, LOCATION_PZONE, 0)
    Duel.SetOperationInfo(0, CATEGORY_DESTROY, g, #g, 0, 0)
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, loc)
end

function s.pe2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) then return end
    local dg = Duel.GetFieldGroup(tp, LOCATION_PZONE, 0)
    if Duel.Destroy(dg, REASON_EFFECT) < #dg then return end

    local loc = 0
    if Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 then loc = loc + LOCATION_HAND + LOCATION_DECK + LOCATION_GRAVE end
    if Duel.GetLocationCountFromEx(tp, rp, nil) > 0 then loc = loc + LOCATION_EXTRA end
    if loc == 0 then return end

    local g = Utility.SelectMatchingCard(HINTMSG_SPSUMMON, tp, aux.NecroValleyFilter(s.pe2filter), tp, loc, 0, 1, 1, nil, e, tp)
    if #g > 0 then Duel.SpecialSummon(g, 0, tp, tp, false, false, POS_FACEUP) end
end

function s.me1tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return Duel.GetFlagEffect(tp, 58308221 + 100) == 0 end

    Duel.SetOperationInfo(0, CATEGORY_DESTROY, c, 1, 0, 0)
end

function s.me1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) or Duel.Destroy(c, REASON_EFFECT) == 0 then return end
    Duel.RegisterFlagEffect(tp, 58308221 + 100, RESET_PHASE + PHASE_END + RESET_SELF_TURN, 0, 1)
    aux.RegisterClientHint(c, 0, tp, 1, 0, aux.Stringid(id, 3))

    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_CONTINUOUS + EFFECT_TYPE_FIELD)
    ec1:SetCode(EVENT_ADJUST)
    ec1:SetOperation(s.me1checkop)
    ec1:SetReset(RESET_PHASE + PHASE_END)
    Duel.RegisterEffect(ec1, tp)
    s.me1checkop(e, tp)
end

function s.me1checkop(e, tp)
    local c = e:GetHandler()
    local lpz = Duel.GetFieldCard(tp, LOCATION_PZONE, 0)
    if lpz ~= nil and lpz:GetFlagEffect(id) <= 0 then
        local ec1 = Effect.CreateEffect(c)
        ec1:SetDescription(aux.Stringid(id, 4))
        ec1:SetType(EFFECT_TYPE_FIELD)
        ec1:SetProperty(EFFECT_FLAG_UNCOPYABLE + EFFECT_FLAG_CANNOT_DISABLE)
        ec1:SetCode(EFFECT_SPSUMMON_PROC_G)
        ec1:SetRange(LOCATION_PZONE)
        ec1:SetCondition(s.me1pencon1)
        ec1:SetOperation(s.me1penop1)
        ec1:SetValue(SUMMON_TYPE_PENDULUM)
        ec1:SetReset(RESET_PHASE + PHASE_END)
        lpz:RegisterEffect(ec1)
        lpz:RegisterFlagEffect(id, RESET_PHASE + PHASE_END, 0, 1)
    end

    local olpz = Duel.GetFieldCard(1 - tp, LOCATION_PZONE, 0)
    local orpz = Duel.GetFieldCard(1 - tp, LOCATION_PZONE, 1)
    if olpz ~= nil and orpz ~= nil and olpz:GetFlagEffect(id) <= 0 and olpz:GetFlagEffectLabel(31531170) == orpz:GetFieldID() and
        orpz:GetFlagEffectLabel(31531170) == olpz:GetFieldID() then
        local ec2 = Effect.CreateEffect(c)
        ec2:SetDescription(aux.Stringid(id, 4))
        ec2:SetType(EFFECT_TYPE_FIELD)
        ec2:SetCode(EFFECT_SPSUMMON_PROC_G)
        ec2:SetProperty(EFFECT_FLAG_UNCOPYABLE + EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_BOTH_SIDE)
        ec2:SetRange(LOCATION_PZONE)
        ec2:SetCondition(s.me1pencon2)
        ec2:SetOperation(s.me1penop2)
        ec2:SetValue(SUMMON_TYPE_PENDULUM)
        ec2:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
        olpz:RegisterEffect(ec2)
        olpz:RegisterFlagEffect(id, RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END, 0, 1)
    end
end

function s.me1pencon1(e, c, og)
    if c == nil then return true end
    local tp = c:GetControler()
    local rpz = Duel.GetFieldCard(tp, LOCATION_PZONE, 1)
    if rpz == nil or c == rpz or Duel.GetFlagEffect(tp, 29432356) > 0 then return false end

    local lscale = c:GetLeftScale()
    local rscale = rpz:GetRightScale()
    if lscale > rscale then lscale, rscale = rscale, lscale end

    local ft = Duel.GetLocationCountFromEx(tp)
    if ft <= 0 then return false end

    if og ~= nil then
        return og:Filter(Card.IsLocation, nil, LOCATION_EXTRA):IsExists(Pendulum.Filter, 1, nil, e, tp, lscale, rscale)
    else
        return Duel.IsExistingMatchingCard(Pendulum.Filter, tp, LOCATION_EXTRA, 0, 1, nil, e, tp, lscale, rscale)
    end
end

function s.me1penop1(e, tp, eg, ep, ev, re, r, rp, c, sg, og)
    local rpz = Duel.GetFieldCard(tp, LOCATION_PZONE, 1)

    local lscale = c:GetLeftScale()
    local rscale = rpz:GetRightScale()
    if lscale > rscale then lscale, rscale = rscale, lscale end

    local ft = Duel.GetLocationCountFromEx(tp)
    if Duel.IsPlayerAffectedByEffect(tp, CARD_BLUEEYES_SPIRIT) then ft = 1 end
    ft = math.min(ft, aux.CheckSummonGate(tp) or ft)

    if og then
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
        local g = og:Filter(Card.IsLocation, nil, LOCATION_EXTRA):FilterSelect(tp, Pendulum.Filter, 0, ft, nil, e, tp, lscale, rscale)
        if g then sg:Merge(g) end
    else
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
        local g = Duel.SelectMatchingCard(tp, Pendulum.Filter, tp, LOCATION_EXTRA, 0, 0, ft, nil, e, tp, lscale, rscale)
        if g then sg:Merge(g) end
    end

    if #sg > 0 then
        Utility.HintCard(id)
        Duel.RegisterFlagEffect(tp, 29432356, RESET_PHASE + PHASE_END + RESET_SELF_TURN, 0, 1)
        Duel.HintSelection(c, true)
        Duel.HintSelection(rpz, true)
    end
end

function s.me1pencon2(e, c, og)
    if c == nil then return true end
    local tp = e:GetOwnerPlayer()
    local rpz = Duel.GetFieldCard(1 - tp, LOCATION_PZONE, 1)
    if rpz == nil or rpz:GetFieldID() ~= c:GetFlagEffectLabel(31531170) or Duel.GetFlagEffect(tp, 29432356) > 0 then return false end

    local lscale = c:GetLeftScale()
    local rscale = rpz:GetRightScale()
    if lscale > rscale then lscale, rscale = rscale, lscale end
    local ft = Duel.GetLocationCountFromEx(tp)
    if ft <= 0 then return false end

    if og then
        return og:Filter(Card.IsLocation, nil, LOCATION_EXTRA):IsExists(Pendulum.Filter, 1, nil, e, tp, lscale, rscale)
    else
        return Duel.IsExistingMatchingCard(Pendulum.Filter, tp, LOCATION_EXTRA, 0, 1, nil, e, tp, lscale, rscale)
    end
end

function s.me1penop2(e, tp, eg, ep, ev, re, r, rp, c, sg, og)
    local tp = e:GetOwnerPlayer()
    local rpz = Duel.GetFieldCard(1 - tp, LOCATION_PZONE, 1)

    local lscale = c:GetLeftScale()
    local rscale = rpz:GetRightScale()
    if lscale > rscale then lscale, rscale = rscale, lscale end

    local ft = Duel.GetLocationCountFromEx(tp)
    if Duel.IsPlayerAffectedByEffect(tp, CARD_BLUEEYES_SPIRIT) then ft = 1 end
    ft = math.min(ft, aux.CheckSummonGate(tp) or ft)

    if og then
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
        local g = og:FilterSelect(tp, Pendulum.Filter, 0, ft, nil, e, tp, lscale, rscale)
        if g then sg:Merge(g) end
    else
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
        local g = Duel.SelectMatchingCard(tp, Pendulum.Filter, tp, LOCATION_EXTRA, 0, 0, ft, nil, e, tp, lscale, rscale)
        if g then sg:Merge(g) end
    end

    if #sg > 0 then
        Duel.Hint(HINT_CARD, 0, 31531170)
        Duel.Hint(HINT_CARD, 0, id)
        Duel.RegisterFlagEffect(tp, 29432356, RESET_PHASE + PHASE_END + RESET_SELF_TURN, 0, 1)
        Duel.HintSelection(c, true)
        Duel.HintSelection(rpz, true)
    end
end

function s.me2con(e, tp, eg, ep, ev, re, r, rp)
    local ac = Duel.GetAttacker()
    return ep ~= tp and ac:IsControler(tp) and ac:IsSetCard(SET_ODD_EYES) and ac:IsRace(RACE_DRAGON)
end

function s.me2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local g = Duel.GetMatchingGroup(Card.IsFaceup, tp, LOCATION_PZONE, 0, nil)
    if chk == 0 then return #g > 0 end

    local dmg = 0
    for tc in g:Iter() do if tc:GetAttack() > 0 then dmg = dmg + tc:GetAttack() end end

    Duel.SetTargetPlayer(1 - tp)
    Duel.SetTargetParam(dmg)
    Duel.SetOperationInfo(0, CATEGORY_DAMAGE, nil, 0, 1 - tp, dmg)
end

function s.me2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if c:IsFacedown() or not c:IsRelateToEffect(e) then return end

    local p, d = Duel.GetChainInfo(0, CHAININFO_TARGET_PLAYER, CHAININFO_TARGET_PARAM)
    Duel.Damage(p, d, REASON_EFFECT)
end
