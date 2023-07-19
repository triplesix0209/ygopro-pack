-- Let's Rev It Up!
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_series = {SET_SYNCHRON}
s.counter_list = {COUNTER_SIGNAL}

function s.initial_effect(c)
    c:SetUniqueOnField(1, 0, id)
    c:EnableCounterPermit(COUNTER_SIGNAL)

    -- activate
    local act = Effect.CreateEffect(c)
    act:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH + CATEGORY_DECKDES)
    act:SetType(EFFECT_TYPE_ACTIVATE)
    act:SetCode(EVENT_FREE_CHAIN)
    act:SetCountLimit(1, id, EFFECT_COUNT_CODE_OATH)
    act:SetTarget(s.acttg)
    act:SetOperation(s.actop)
    c:RegisterEffect(act)
end

function s.actfilter1(c) return c:IsSetCard(SET_SYNCHRON) and c:IsType(TYPE_TUNER) and c:IsAbleToHand() end

function s.actfilter2(c, tc) return c:IsRace(RACE_WARRIOR + RACE_MACHINE) and c:HasLevel() and c:GetLevel() < tc:GetLevel() end

function s.acttg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return Duel.IsExistingMatchingCard(s.actfilter1, tp, LOCATION_DECK, 0, 1, nil) end

    Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK)
    Duel.SetPossibleOperationInfo(0, CATEGORY_TOGRAVE, nil, 1, tp, LOCATION_DECK)
end

function s.actop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()

    local tc = Utility.SelectMatchingCard(HINTMSG_ATOHAND, tp, s.actfilter1, tp, LOCATION_DECK, 0, 1, 1, nil):GetFirst()
    if tc then
        Duel.SendtoHand(tc, nil, REASON_EFFECT)
        Duel.ConfirmCards(1 - tp, tc)
        Duel.ShuffleDeck(tp)

        if tc:IsLocation(LOCATION_HAND) and Duel.GetMatchingGroupCount(s.actfilter2, tp, LOCATION_DECK, 0, nil, tc) > 0 and
            Duel.SelectEffectYesNo(tp, c, 504) then
            Duel.BreakEffect()
            local sg = Utility.SelectMatchingCard(HINTMSG_TOGRAVE, tp, s.e2filter2, tp, LOCATION_DECK, 0, 1, 1, nil, tc)
            Duel.SendtoGrave(sg, REASON_EFFECT)
        end
    end

    local ec0 = Effect.CreateEffect(c)
    ec0:SetDescription(aux.Stringid(id, 0))
    ec0:SetProperty(EFFECT_FLAG_PLAYER_TARGET + EFFECT_FLAG_CLIENT_HINT)
    ec0:SetCode(id)
    ec0:SetTargetRange(1, 0)
    ec0:SetReset(RESET_PHASE + PHASE_END)
    Duel.RegisterEffect(ec0, tp)

    -- cannot disable summon
    local ec1 = Effect.CreateEffect(c)
    ec1:SetType(EFFECT_TYPE_FIELD)
    ec1:SetProperty(EFFECT_FLAG_IGNORE_RANGE + EFFECT_FLAG_SET_AVAILABLE)
    ec1:SetCode(EFFECT_CANNOT_DISABLE_SUMMON)
    ec1:SetTarget(s.e1tg)
    ec1:SetReset(RESET_PHASE + PHASE_END)
    Duel.RegisterEffect(ec1, tp)
    local ec1b = ec1:Clone()
    ec1b:SetCode(EFFECT_CANNOT_DISABLE_SPSUMMON)
    Duel.RegisterEffect(ec1b, tp)
    local ec1c = ec1:Clone()
    ec1c:SetCode(EFFECT_CANNOT_DISABLE_FLIP_SUMMON)
    Duel.RegisterEffect(ec1c, tp)

    -- chain limit
    local ec2 = Effect.CreateEffect(c)
    ec2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    ec2:SetCode(EVENT_CHAINING)
    ec2:SetOperation(s.e2op)
    Duel.RegisterEffect(ec2, tp)

    -- draw
    local ec3 = Effect.CreateEffect(c)
    ec3:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    ec3:SetProperty(EFFECT_FLAG_DELAY + EFFECT_FLAG_PLAYER_TARGET)
    ec3:SetCode(EVENT_SPSUMMON_SUCCESS)
    ec3:SetCondition(s.e3con)
    ec3:SetOperation(s.e3op)
    Duel.RegisterEffect(ec3, tp)
end

function s.e1tg(e, c) return c:GetOwner() == e:GetOwnerPlayer() and c:IsSetCard(SET_SYNCHRON) end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
    local rc = re:GetHandler()
    if re:IsActiveType(TYPE_MONSTER) and rc:IsOriginalSetCard(SET_SYNCHRON) then Duel.SetChainLimit(s.e2chainlimit) end
end

function s.e2chainlimit(e, rp, tp) return tp == rp end

function s.e3filter(c, tp) return c:IsFaceup() and c:IsSummonPlayer(tp) and c:IsSummonType(SUMMON_TYPE_SYNCHRO) and c:IsType(TYPE_SYNCHRO) end

function s.e3con(e, tp, eg, ep, ev, re, r, rp) return eg:IsExists(s.e3filter, 1, e:GetHandler(), tp) and Duel.IsPlayerCanDraw(tp, 1) end

function s.e3op(e, tp, eg, ep, ev, re, r, rp)
    if not Duel.SelectYesNo(tp, aux.Stringid(id, 1)) then return end
    Duel.Draw(tp, 1, REASON_EFFECT)
end
