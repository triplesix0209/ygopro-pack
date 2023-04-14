-- Blue-Eyes Chaos Infinity Dragon
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {CARD_BLUEEYES_W_DRAGON}
s.listed_series = {0xdd}
s.material_setcode = {0xdd}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- link summon
    Link.AddProcedure(c, nil, 3, 4,
        function(g, lc, sumtype, tp) return g:IsExists(Card.IsSetCard, 1, nil, 0xdd, lc, sumtype, tp) end)

    -- special summon limit
    local splimit = Effect.CreateEffect(c)
    splimit:SetType(EFFECT_TYPE_SINGLE)
    splimit:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    splimit:SetCode(EFFECT_SPSUMMON_CONDITION)
    splimit:SetValue(aux.lnklimit)
    c:RegisterEffect(splimit)

    -- special summon
    local sp = Effect.CreateEffect(c)
    sp:SetDescription(aux.Stringid(id, 0))
    sp:SetType(EFFECT_TYPE_FIELD)
    sp:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE + EFFECT_FLAG_IGNORE_IMMUNE)
    sp:SetRange(LOCATION_EXTRA)
    sp:SetCode(EFFECT_SPSUMMON_PROC)
    sp:SetCondition(s.spcon)
    sp:SetTarget(s.sptg)
    sp:SetOperation(s.spop)
    sp:SetValue(SUMMON_TYPE_LINK)
    c:RegisterEffect(sp)

    -- untargetable & indes
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e1:SetValue(aux.tgoval)
    c:RegisterEffect(e1)
    local e1b = e1:Clone()
    e1b:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e1b:SetValue(function(e, re, rp) return rp ~= e:GetHandlerPlayer() end)
    c:RegisterEffect(e1b)

    -- change position
    local e2reg = Effect.CreateEffect(c)
    e2reg:SetType(EFFECT_TYPE_SINGLE)
    e2reg:SetCode(EFFECT_MATERIAL_CHECK)
    e2reg:SetValue(s.e2regval)
    c:RegisterEffect(e2reg)
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(528)
    e2:SetCategory(CATEGORY_POSITION + CATEGORY_ATKCHANGE + CATEGORY_DEFCHANGE)
    e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_ATTACK_ANNOUNCE)
    e2:SetCondition(s.e2con)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)

    -- pierce
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetCode(EFFECT_PIERCE)
    e3:SetValue(DOUBLE_DAMAGE)
    c:RegisterEffect(e3)
end

function s.spfilter1(c)
    return c:IsType(TYPE_SPELL) and c:IsType(TYPE_RITUAL) and c:IsAbleToGraveAsCost() and (c:IsFacedown() or not c:IsOnField())
end

function s.spfilter2(c, sc, tp)
    return c:IsCanBeLinkMaterial(sc, tp) and Duel.GetLocationCountFromEx(tp, tp, c, sc) > 0 and
               c:IsSummonCode(sc, SUMMON_TYPE_LINK, tp, CARD_BLUEEYES_W_DRAGON)
end

function s.spcon(e, c)
    if c == nil then return true end
    local tp = c:GetControler()

    local g1 = Duel.GetMatchingGroup(s.spfilter1, tp, LOCATION_HAND + LOCATION_ONFIELD, 0, c)
    local g2 = Duel.GetMatchingGroup(s.spfilter2, tp, LOCATION_MZONE, 0, nil, c, tp)
    return #g1 > 0 and #g2 > 0 and aux.SelectUnselectGroup(g1, e, tp, 1, 1, nil, 0) and
               aux.SelectUnselectGroup(g2, e, tp, 1, 1, nil, 0, c, tp)
end

function s.sptg(e, tp, eg, ep, ev, re, r, rp, c)
    local c = e:GetHandler()
    local g1 = Duel.GetMatchingGroup(s.spfilter1, tp, LOCATION_HAND + LOCATION_ONFIELD, 0, c)
    g1 = aux.SelectUnselectGroup(g1, e, tp, 1, 1, nil, 1, tp, HINTMSG_TOGRAVE, nil, nil, true)
    local g2 = Duel.GetMatchingGroup(s.spfilter2, tp, LOCATION_MZONE, 0, nil, c, tp)
    g2 = aux.SelectUnselectGroup(g2, e, tp, 1, 1, nil, 1, tp, HINTMSG_RELEASE, nil, nil, true)
    if #g1 > 0 and #g2 > 0 then
        g1:KeepAlive()
        g2:KeepAlive()
        e:SetLabelObject({g1, g2})
        return true
    end

    return false
end

function s.spop(e, tp, eg, ep, ev, re, r, rp, c)
    local g1 = e:GetLabelObject()[1]
    local g2 = e:GetLabelObject()[2]
    if not g1 or not g2 then return end

    c:SetMaterial(g2)
    Duel.SendtoGrave(g1, REASON_COST)
    Duel.SendtoGrave(g2, REASON_MATERIAL + REASON_LINK)

    g1:DeleteGroup()
    g2:DeleteGroup()
end

function s.e2regval(e, c)
    local g = c:GetMaterial()
    if g:IsExists(Card.IsCode, 1, nil, CARD_BLUEEYES_W_DRAGON) then
        c:RegisterFlagEffect(id, RESET_EVENT | RESETS_STANDARD & ~(RESET_TOFIELD | RESET_LEAVE | RESET_TEMP_REMOVE),
            EFFECT_FLAG_CLIENT_HINT, 1, 0, aux.Stringid(id, 0))
    end
end

function s.e2con(e)
    local c = e:GetHandler()
    return c:IsSummonType(SUMMON_TYPE_LINK) and c:GetFlagEffect(id) ~= 0
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(Card.IsCanChangePosition, tp, 0, LOCATION_MZONE, 1, nil) end

    local g = Duel.GetMatchingGroup(Card.IsCanChangePosition, tp, 0, LOCATION_MZONE, nil)
    Duel.SetOperationInfo(0, CATEGORY_POSITION, g, #g, 0, 0)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tg = Duel.GetMatchingGroup(Card.IsCanChangePosition, tp, 0, LOCATION_MZONE, nil)
    if #tg == 0 or Duel.ChangePosition(tg, POS_FACEUP_DEFENSE, POS_FACEDOWN_DEFENSE, POS_FACEUP_ATTACK, POS_FACEUP_ATTACK) == 0 then
        return
    end

    local og = Duel.GetOperatedGroup():Filter(Card.IsFaceup, nil)
    for tc in aux.Next(og) do
        local ec1 = Effect.CreateEffect(c)
        ec1:SetType(EFFECT_TYPE_SINGLE)
        ec1:SetCode(EFFECT_SET_ATTACK_FINAL)
        ec1:SetValue(0)
        ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
        tc:RegisterEffect(ec1)
        local ec1b = ec1:Clone()
        ec1b:SetCode(EFFECT_SET_DEFENSE_FINAL)
        tc:RegisterEffect(ec1b)
    end
end
