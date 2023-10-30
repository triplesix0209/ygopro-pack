-- Divine Phoenix of Nephthys
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {id}
s.listed_series = {0x11f}

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- synchro summon
    Synchro.AddProcedure(c, aux.FilterBoolFunctionEx(Card.IsType, TYPE_RITUAL), 1, 1, nil, 1, 99,
        function(c, sc, sumtype, tp) return c:IsSummonType(SUMMON_TYPE_RITUAL) end)

    -- special summon limit
    local splimit = Effect.CreateEffect(c)
    splimit:SetType(EFFECT_TYPE_SINGLE)
    splimit:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    splimit:SetCode(EFFECT_SPSUMMON_CONDITION)
    splimit:SetValue(function(e, se, sp, st)
        return not e:GetHandler():IsLocation(LOCATION_EXTRA) or ((st & SUMMON_TYPE_SYNCHRO) == SUMMON_TYPE_SYNCHRO and not se)
    end)
    c:RegisterEffect(splimit)

    -- summon cannot be negated
    local sumsafe = Effect.CreateEffect(c)
    sumsafe:SetType(EFFECT_TYPE_SINGLE)
    sumsafe:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    sumsafe:SetCode(EFFECT_CANNOT_DISABLE_SPSUMMON)
    sumsafe:SetCondition(function(e) return e:GetHandler():GetSummonType() == SUMMON_TYPE_SYNCHRO end)
    c:RegisterEffect(sumsafe)

    -- cannot be tributed, nor be used as a material
    local norelease = Effect.CreateEffect(c)
    norelease:SetType(EFFECT_TYPE_FIELD)
    norelease:SetProperty(EFFECT_FLAG_PLAYER_TARGET + EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    norelease:SetCode(EFFECT_CANNOT_RELEASE)
    norelease:SetRange(LOCATION_MZONE)
    norelease:SetTargetRange(0, 1)
    norelease:SetTarget(function(e, tc) return tc == e:GetHandler() end)
    c:RegisterEffect(norelease)
    local nomaterial = Effect.CreateEffect(c)
    nomaterial:SetType(EFFECT_TYPE_SINGLE)
    nomaterial:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    nomaterial:SetCode(EFFECT_CANNOT_BE_MATERIAL)
    nomaterial:SetValue(function(e, tc) return tc and tc:GetControler() ~= e:GetHandlerPlayer() end)
    c:RegisterEffect(nomaterial)

    -- control cannot switch
    local noswitch = Effect.CreateEffect(c)
    noswitch:SetType(EFFECT_TYPE_SINGLE)
    noswitch:SetProperty(EFFECT_FLAG_SINGLE_RANGE + EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    noswitch:SetCode(EFFECT_CANNOT_CHANGE_CONTROL)
    noswitch:SetRange(LOCATION_MZONE)
    c:RegisterEffect(noswitch)

    -- battle position cannot be changed by effect
    local nopos = Effect.CreateEffect(c)
    nopos:SetType(EFFECT_TYPE_SINGLE)
    nopos:SetProperty(EFFECT_FLAG_SINGLE_RANGE + EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    nopos:SetCode(EFFECT_CANNOT_CHANGE_POS_E)
    nopos:SetRange(LOCATION_MZONE)
    c:RegisterEffect(nopos)

    -- atk up
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE + EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetRange(LOCATION_MZONE)
    e1:SetValue(function(e, c) return s.rebirth_count * 100 end)
    c:RegisterEffect(e1)
    aux.GlobalCheck(s, function()
        s.rebirth_count = 0
        local ge1 = Effect.CreateEffect(c)
        ge1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
        ge1:SetCode(EVENT_SPSUMMON_SUCCESS)
        ge1:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
            for tc in eg:Iter() do
                if tc:IsCode(id) and tc:GetSummonType() == SUMMON_TYPE_SPECIAL + 1 then s.rebirth_count = s.rebirth_count + 1 end
            end
        end)
        Duel.RegisterEffect(ge1, 0)
    end)

    -- change the effect
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 0))
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_CHAINING)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1)
    e2:SetCondition(s.e2con)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)

    -- rebirth
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
    e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e3:SetCode(EVENT_TO_GRAVE)
    e3:SetOperation(s.e3regop)
    c:RegisterEffect(e3)

    -- destroy
    local e4 = Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id, 1))
    e4:SetCategory(CATEGORY_DESTROY)
    e4:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e4:SetCode(EVENT_SPSUMMON_SUCCESS)
    e4:SetCountLimit(1, 0, EFFECT_COUNT_CODE_SINGLE)
    e4:SetCondition(s.e4con)
    e4:SetTarget(s.e4tg1)
    e4:SetOperation(s.e4op1)
    c:RegisterEffect(e4)
    local e4b = e4:Clone()
    e4b:SetDescription(aux.Stringid(id, 2))
    e4b:SetTarget(s.e4tg2)
    e4b:SetOperation(s.e4op2)
    c:RegisterEffect(e4b)
end

function s.e2filter(c) return c:IsSetCard(0x11f) end

function s.e2con(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    return not c:IsStatus(STATUS_BATTLE_DESTROYED) and rp ~= tp
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.e2filter, tp, LOCATION_HAND + LOCATION_DECK + LOCATION_MZONE, 0, 1, nil) end
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if c:IsFacedown() or not c:IsRelateToEffect(e) then return end

    Duel.ChangeTargetCard(ev, Group.CreateGroup())
    Duel.ChangeChainOperation(ev, s.e2repop)
end

function s.e2repop(e, tp, eg, ep, ev, re, r, rp)
    local g = Utility.SelectMatchingCard(HINTMSG_DESTROY, 1 - tp, s.e2filter, 1 - tp, LOCATION_HAND + LOCATION_DECK + LOCATION_MZONE, 0, 1, 1, nil)
    if #g > 0 then Duel.Destroy(g, REASON_EFFECT + REASON_RULE) end
end

function s.e3regop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if c:IsReason(REASON_DESTROY) and c:IsReason(REASON_BATTLE + REASON_EFFECT) then
        local e3 = Effect.CreateEffect(c)
        e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
        e3:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
        e3:SetCode(EVENT_PHASE + PHASE_STANDBY)
        e3:SetRange(LOCATION_GRAVE)
        e3:SetCountLimit(1)
        e3:SetCondition(aux.exccon)
        e3:SetTarget(s.e3tg)
        e3:SetOperation(s.e3op)
        e3:SetReset(RESET_EVENT + RESETS_STANDARD)
        c:RegisterEffect(e3)
    end
end

function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and c:IsCanBeSpecialSummoned(e, 0, tp, false, false) end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, c, 1, 0, LOCATION_GRAVE)
    Duel.SetChainLimit(aux.FALSE)
end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if c:IsRelateToEffect(e) then Duel.SpecialSummon(c, 1, tp, tp, false, false, POS_FACEUP) end
end

function s.e4con(e, tp, eg, ep, ev, re, r, rp) return e:GetHandler():GetSummonType() == SUMMON_TYPE_SPECIAL + 1 end

function s.e4tg1(e, tp, eg, ep, ev, re, r, rp, chk)
    local g = Duel.GetMatchingGroup(aux.TRUE, tp, 0, LOCATION_MZONE, nil)
    if chk == 0 then return #g > 0 end
    Duel.SetOperationInfo(0, CATEGORY_DESTROY, g, #g, 0, 0)
end

function s.e4op1(e, tp, eg, ep, ev, re, r, rp)
    local g = Duel.GetMatchingGroup(aux.TRUE, tp, 0, LOCATION_MZONE, nil)
    Duel.Destroy(g, REASON_EFFECT)
end

function s.e4tg2(e, tp, eg, ep, ev, re, r, rp, chk)
    local g = Duel.GetMatchingGroup(Card.IsSpellTrap, tp, 0, LOCATION_ONFIELD, nil)
    if chk == 0 then return #g > 0 end
    Duel.SetOperationInfo(0, CATEGORY_DESTROY, g, #g, 0, 0)
end

function s.e4op2(e, tp, eg, ep, ev, re, r, rp)
    local g = Duel.GetMatchingGroup(Card.IsSpellTrap, tp, 0, LOCATION_ONFIELD, nil)
    Duel.Destroy(g, REASON_EFFECT)
end
