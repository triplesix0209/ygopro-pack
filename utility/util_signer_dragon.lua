-- init
if not aux.SignerDragonProcedure then aux.SignerDragonProcedure = {} end
if not SignerDragon then SignerDragon = aux.SignerDragonProcedure end

-- constant
SignerDragon.CARD_MAJESTIC_DRAGON = 21159309
SignerDragon.CARD_RED_DRAGON_ARCHFIEND = 70902743
SignerDragon.CARD_ANCIENT_FAIRY_DRAGON = 25862681
SignerDragon.CARD_LIFE_STREAM_DRAGON = 25165047
SignerDragon.CARD_SHOOTING_STAR_DRAGON = 24696097
SignerDragon.COUNTER_SIGNER = 0x9001

-- function
function SignerDragon.AddMajesticProcedure(c, s, card_code)
    s.material = {SignerDragon.CARD_MAJESTIC_DRAGON, card_code}
    s.listed_names = {SignerDragon.CARD_MAJESTIC_DRAGON, card_code}
    s.synchro_nt_required = 1

    -- synchro summon
    Synchro.AddMajesticProcedure(c, aux.FilterBoolFunction(Card.IsCode, SignerDragon.CARD_MAJESTIC_DRAGON), true,
        aux.FilterBoolFunction(Card.IsCode, card_code), true, Synchro.NonTuner(nil), false)

    -- double tuner check
    local doubleTuner = Effect.CreateEffect(c)
    doubleTuner:SetType(EFFECT_TYPE_SINGLE)
    doubleTuner:SetCode(EFFECT_MATERIAL_CHECK)
    doubleTuner:SetValue(function(e, c)
        local g = c:GetMaterial()
        if g:IsExists(Card.IsType, 2, nil, TYPE_TUNER) then
            local ec1 = Effect.CreateEffect(c)
            ec1:SetType(EFFECT_TYPE_SINGLE)
            ec1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
            ec1:SetCode(21142671)
            ec1:SetReset(RESET_EVENT + RESETS_STANDARD - RESET_TOFIELD + RESET_PHASE + PHASE_END)
            c:RegisterEffect(ec1)
        end
    end)
    c:RegisterEffect(doubleTuner)
end

function SignerDragon.AddMajesticReturn(c, card_code)
    local ret = Effect.CreateEffect(c)
    ret:SetDescription(666001)
    ret:SetCategory(CATEGORY_TODECK + CATEGORY_SPECIAL_SUMMON)
    ret:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_F)
    ret:SetProperty(EFFECT_FLAG_CARD_TARGET)
    ret:SetCode(EVENT_PHASE + PHASE_END)
    ret:SetRange(LOCATION_MZONE)
    ret:SetCountLimit(1)
    ret:SetTarget(function(e, tp, eg, ep, ev, re, r, rp, chk)
        if chk == 0 then return true end

        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
        local g = Duel.SelectTarget(tp, majesticReturnFilter, tp, LOCATION_GRAVE, 0, 1, 1, nil, e, tp, card_code)

        Duel.SetOperationInfo(0, CATEGORY_TODECK, e:GetHandler(), 1, 0, 0)
        Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, g, 1, 0, 0)
    end)
    ret:SetOperation(function(e, tp, eg, ep, ev, re, r, rp)
        local tc = Duel.GetFirstTarget()
        local c = e:GetHandler()
        if c:IsRelateToEffect(e) and c:IsAbleToExtra() and Duel.SendtoDeck(c, nil, 0, REASON_EFFECT) ~= 0 and
            c:IsLocation(LOCATION_EXTRA) and tc and tc:IsRelateToEffect(e) then
            Duel.SpecialSummon(tc, 0, tp, tp, false, false, POS_FACEUP)
        end
    end)
    c:RegisterEffect(ret)
end

function majesticReturnFilter(c, e, tp, card_code) return c:IsCode(card_code) and c:IsCanBeSpecialSummoned(e, 0, tp, false, false) end
