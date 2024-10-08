-- Supreme King's Dark Castle
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {CARD_DARK_FUSION}
s.listed_series = {SET_FUSION, SET_EVIL_HERO}

function s.initial_effect(c)
    -- activate
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1, id, EFFECT_COUNT_CODE_OATH)
    e1:SetOperation(s.e1op)
    c:RegisterEffect(e1)

    -- dark fusion ignore
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e2:SetCode(72043279)
    e2:SetRange(LOCATION_FZONE)
    e2:SetTargetRange(1, 0)
    c:RegisterEffect(e2)

    -- prevent fusion negation
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetCode(EFFECT_CANNOT_INACTIVATE)
    e3:SetRange(LOCATION_FZONE)
    e3:SetValue(s.e3val)
    c:RegisterEffect(e3)
    local e3b = Effect.CreateEffect(c)
    e3b:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e3b:SetCode(EVENT_SPSUMMON_SUCCESS)
    e3b:SetRange(LOCATION_FZONE)
    e3b:SetCondition(s.e3con)
    e3b:SetOperation(s.e3op1)
    c:RegisterEffect(e3b)
    local e3c = Effect.CreateEffect(c)
    e3c:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e3c:SetCode(EVENT_CHAIN_END)
    e3c:SetRange(LOCATION_FZONE)
    e3c:SetOperation(s.e3op2)
    c:RegisterEffect(e3c)

    -- atk up
    local e4 = Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id, 1))
    e4:SetCategory(CATEGORY_ATKCHANGE)
    e4:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    e4:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
    e4:SetRange(LOCATION_FZONE)
    e4:SetCountLimit(1)
    e4:SetCondition(s.e4con)
    e4:SetCost(s.e4cost)
    e4:SetOperation(s.e4op)
    c:RegisterEffect(e4)
end

function s.e1filter(c) return c:IsSetCard(SET_FUSION) and c:IsSpell() and c:IsAbleToHand() end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) then return end

    local g = Duel.GetMatchingGroup(s.e1filter, tp, LOCATION_DECK, 0, nil)
    if #g > 0 and Duel.SelectEffectYesNo(tp, c, aux.Stringid(id, 0)) then
        local sg = Utility.GroupSelect(HINT_SELECTMSG, g, tp, 1, 1, nil)
        Duel.SendtoHand(sg, nil, REASON_EFFECT)
        Duel.ConfirmCards(1 - tp, sg)
    end
end

function s.e3val(e, ct)
    local p = e:GetHandlerPlayer()
    local te, tp = Duel.GetChainInfo(ct, CHAININFO_TRIGGERING_EFFECT, CHAININFO_TRIGGERING_PLAYER)
    return p == tp and te:IsHasCategory(CATEGORY_FUSION_SUMMON)
end

function s.e3con(e, tp, eg, ep, ev, re, r, rp)
    return eg:IsExists(function(tc, tp) return tc:IsSummonPlayer(tp) and tc:IsSummonType(SUMMON_TYPE_FUSION) end, 1, nil, tp)
end

function s.e3op1(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if Duel.GetCurrentChain() == 0 then
        Duel.SetChainLimitTillChainEnd(s.e3chainlimit)
    elseif Duel.GetCurrentChain() == 1 then
        c:RegisterFlagEffect(id, RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END, 0, 1)
        local ec1 = Effect.CreateEffect(c)
        ec1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
        ec1:SetCode(EVENT_CHAINING)
        ec1:SetOperation(s.e3resetop)
        Duel.RegisterEffect(ec1, tp)
        local e1b = ec1:Clone()
        e1b:SetCode(EVENT_BREAK_EFFECT)
        e1b:SetReset(RESET_CHAIN)
        Duel.RegisterEffect(e1b, tp)
    end
end

function s.e3op2(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if c:GetFlagEffect(id) ~= 0 then Duel.SetChainLimitTillChainEnd(s.e3chainlimit) end

    c:ResetFlagEffect(id)
end

function s.e3resetop(e, tp, eg, ep, ev, re, r, rp)
    e:GetHandler():ResetFlagEffect(id)
    e:Reset()
end

function s.e3chainlimit(e, rp, tp) return tp == rp end

function s.e4filter(c) return c:IsMonster() and c:IsSetCard(SET_EVIL_HERO) and c:HasLevel() and c:IsAbleToGraveAsCost() end

function s.e4con(e, tp, eg, ep, ev, re, r, rp)
    local tc = Duel.GetAttacker()
    local bc = Duel.GetAttackTarget()
    if not bc then return false end
    if bc:IsControler(1 - tp) then bc = tc end

    e:SetLabelObject(bc)
    return bc:IsFaceup() and bc:IsRace(RACE_FIEND)
end

function s.e4cost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.e4filter, tp, LOCATION_DECK + LOCATION_EXTRA, 0, 1, nil) end
    local tc = Utility.SelectMatchingCard(HINTMSG_TOGRAVE, tp, s.e4filter, tp, LOCATION_DECK + LOCATION_EXTRA, 0, 1, 1, nil):GetFirst()
    Duel.SendtoGrave(tc, REASON_COST)
    e:SetLabel(tc:GetLevel())
end

function s.e4op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) then return end
    local tc = e:GetLabelObject()
    if tc:IsRelateToBattle() and tc:IsFaceup() and tc:IsControler(tp) then
        local ec1 = Effect.CreateEffect(c)
        ec1:SetType(EFFECT_TYPE_SINGLE)
        ec1:SetCode(EFFECT_UPDATE_ATTACK)
        ec1:SetValue(e:GetLabel() * 200)
        ec1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
        tc:RegisterEffect(ec1)
    end
end
