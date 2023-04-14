-- Mach Synchron
Duel.LoadScript("util.lua")
local s, id = GetID()

function s.initial_effect(c)
    -- hand synchro
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    e1:SetCode(EFFECT_HAND_SYNCHRO)
    e1:SetLabel(id)
    e1:SetValue(s.e1val)
    c:RegisterEffect(e1)

    -- recycle
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EVENT_BE_MATERIAL)
    e2:SetOperation(s.e2regop)
    c:RegisterEffect(e2)
end

function s.e1val(e, tc, sc)
    local c = e:GetHandler()
    if tc:IsLocation(LOCATION_HAND) then
        local ec1 = Effect.CreateEffect(c)
        ec1:SetType(EFFECT_TYPE_SINGLE)
        ec1:SetCode(EFFECT_HAND_SYNCHRO + EFFECT_SYNCHRO_CHECK)
        ec1:SetLabel(id)
        ec1:SetTarget(s.e1synctg)
        tc:RegisterEffect(ec1)
        return true
    else
        return false
    end
end

function s.e1syncheck1(c)
    if not c:IsHasEffect(EFFECT_HAND_SYNCHRO + EFFECT_SYNCHRO_CHECK) then return false end

    local te = {c:GetCardEffect(EFFECT_HAND_SYNCHRO + EFFECT_SYNCHRO_CHECK)}
    for i = 1, #te do
        local e = te[i]
        if e:GetLabel() ~= id then return false end
    end

    return true
end

function s.e1syncheck2(c)
    if not c:IsHasEffect(EFFECT_HAND_SYNCHRO) or c:IsHasEffect(EFFECT_HAND_SYNCHRO + EFFECT_SYNCHRO_CHECK) then return false end

    local te = {c:GetCardEffect(EFFECT_HAND_SYNCHRO)}
    for i = 1, #te do
        local e = te[i]
        if e:GetLabel() == id then return true end
    end

    return false
end

function s.e1synctg(e, c, sg, tg, ntg, tsg, ntsg)
    if c then
        local res = true
        if sg:IsExists(s.e1syncheck1, 1, c) or
            (not tg:IsExists(s.e1syncheck2, 1, c) and not ntg:IsExists(s.e1syncheck2, 1, c) and
                not sg:IsExists(s.e1syncheck2, 1, c)) then return false end

        local trg = tg:Filter(s.e1syncheck1, nil)
        local ntrg = ntg:Filter(s.e1syncheck1, nil)
        return res, trg, ntrg
    else
        return true
    end
end

function s.e2regop(e, tp, eg, ep, ev, re, r, rp)
    if r ~= REASON_SYNCHRO then return end

    local c = e:GetHandler()
    local ec1 = Effect.CreateEffect(c)
    ec1:SetCategory(CATEGORY_TOHAND + CATEGORY_SPECIAL_SUMMON)
    ec1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    ec1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    ec1:SetCode(EVENT_PHASE + PHASE_END)
    ec1:SetRange(LOCATION_GRAVE)
    ec1:SetCountLimit(1, id)
    ec1:SetTarget(s.e2tg)
    ec1:SetOperation(s.e2op)
    ec1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
    c:RegisterEffect(ec1)
end

function s.e2filter(c, e, tp, ft)
    return (c:GetReason() & REASON_SYNCHRO) == REASON_SYNCHRO and not c:IsCode(id) and
               (c:IsAbleToHand() or (c:IsCanBeSpecialSummoned(e, 0, tp, false, false) and ft > 0))
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    local ft = Duel.GetLocationCount(tp, LOCATION_MZONE)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.e2filter, tp, LOCATION_GRAVE, 0, 1, nil, e, tp, ft) end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
    local g = Duel.SelectTarget(tp, s.e2filter, tp, LOCATION_GRAVE, 0, 1, 1, nil, e, tp, ft)

    Duel.SetOperationInfo(0, CATEGORY_TOHAND, g, #g, 0, 0)
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, g, #g, 0, 0)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local tc = Duel.GetFirstTarget()
    if not tc or not tc:IsRelateToEffect(e) then return end

    local ft = Duel.GetLocationCount(tp, LOCATION_MZONE)
    aux.ToHandOrElse(tc, tp, function(c) return tc:IsCanBeSpecialSummoned(e, 0, tp, false, false) and ft > 0 end,
        function(c) Duel.SpecialSummon(tc, 0, tp, tp, false, false, POS_FACEUP) end, 2)
end
