-- init
if not aux.DuelDragonProcedure then aux.DuelDragonProcedure = {} end
if not DuelDragon then DuelDragon = aux.DuelDragonProcedure end

-- constant
DuelDragon.COUNTER_COSMIC = 0x9001

-- function
function DuelDragon.AddMajesticProcedure(c, s, dragon_code)
    s.material = {21159309, dragon_code}
    s.listed_names = {21159309, dragon_code}
    s.synchro_nt_required = 1

    Synchro.AddMajesticProcedure(c, aux.FilterBoolFunction(Card.IsCode, 21159309), true, aux.FilterBoolFunction(Card.IsCode, dragon_code), true,
        Synchro.NonTuner(nil), false)

    -- multiple tuners
    local efftuner = Effect.CreateEffect(c)
    efftuner:SetType(EFFECT_TYPE_SINGLE)
    efftuner:SetCode(EFFECT_MATERIAL_CHECK)
    efftuner:SetValue(function(e, c)
        local g = c:GetMaterial()
        if g:IsExists(Card.IsType, 2, nil, TYPE_TUNER) then
            local ec1 = Effect.CreateEffect(c)
            ec1:SetType(EFFECT_TYPE_SINGLE)
            ec1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
            ec1:SetCode(EFFECT_MULTIPLE_TUNERS)
            ec1:SetReset(RESET_EVENT | RESETS_STANDARD & ~(RESET_TOFIELD) | RESET_PHASE | PHASE_END)
            c:RegisterEffect(ec1)
        end
    end)
    c:RegisterEffect(efftuner)
end

function DuelDragon.AddMajesticReturn(c, dragon_code, description)
    local eff = Effect.CreateEffect(c)
    eff:SetDescription(description)
    eff:SetCategory(CATEGORY_TODECK + CATEGORY_SPECIAL_SUMMON)
    eff:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_F)
    eff:SetProperty(EFFECT_FLAG_CARD_TARGET)
    eff:SetCode(EVENT_PHASE + PHASE_END)
    eff:SetRange(LOCATION_MZONE)
    eff:SetCountLimit(1)
    eff:SetTarget(MajesticReturnTarget(dragon_code))
    eff:SetOperation(MajesticReturnOperation)
    c:RegisterEffect(eff)
end

function MajesticReturnTarget(dragon_code)
    return function(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
        if chk == 0 then return true end

        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
        local g = Duel.SelectTarget(tp, function(c, e, tp) return c:IsCode(dragon_code) and c:IsCanBeSpecialSummoned(e, 0, tp, false, false) end, tp,
            LOCATION_GRAVE, 0, 1, 1, nil, e, tp)

        Duel.SetOperationInfo(0, CATEGORY_TODECK, e:GetHandler(), 1, 0, 0)
        Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, g, 1, 0, 0)
    end
end

function MajesticReturnOperation(e, tp, eg, ep, ev, re, r, rp)
    local tc = Duel.GetFirstTarget()
    local c = e:GetHandler()
    if c:IsRelateToEffect(e) and c:IsAbleToExtra() and Duel.SendtoDeck(c, nil, 0, REASON_EFFECT) ~= 0 and c:IsLocation(LOCATION_EXTRA) and tc and
        tc:IsRelateToEffect(e) then Duel.SpecialSummon(tc, 0, tp, tp, false, false, POS_FACEUP) end
end
