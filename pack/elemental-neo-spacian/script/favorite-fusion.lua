-- Favorite Fusion
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_series = {SET_HERO, SET_ELEMENTAL_HERO}

function s.initial_effect(c)
    -- activate
    local e1 = Fusion.CreateSummonEff({
        handler = c,
        fusfilter = aux.FilterBoolFunction(Card.ListsArchetypeAsMaterial, SET_ELEMENTAL_HERO),
        matfilter = Fusion.MatInHand,
        extrafil = s.e1extrafil,
        extratg = s.e1extratg,
        stage2 = s.e1stage2
    })
    e1:SetCountLimit(1, id, EFFECT_COUNT_CODE_OATH)
    c:RegisterEffect(e1)
end

function s.e1extrafil(e, tp, mg) return Duel.GetMatchingGroup(Fusion.IsMonsterFilter(Card.IsAbleToGrave), tp, LOCATION_DECK, 0, nil), s.fcheck end

function s.e1extratg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return true end
    Duel.SetOperationInfo(0, CATEGORY_TOGRAVE, nil, 0, tp, LOCATION_HAND + LOCATION_ONFIELD + LOCATION_DECK)
end

function s.e1stage2(e, tc, tp, mg, chk)
    local c = e:GetHandler()
    if chk == 0 then tc:RegisterFlagEffect(id, RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END, 0, 2) end
    if chk == 2 then
        if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
            local ec1 = Effect.CreateEffect(c)
            ec1:SetDescription(aux.Stringid(id, 0))
            ec1:SetType(EFFECT_TYPE_FIELD)
            ec1:SetProperty(EFFECT_FLAG_PLAYER_TARGET + EFFECT_FLAG_CLIENT_HINT)
            ec1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
            ec1:SetTargetRange(1, 0)
            ec1:SetTarget(function(e, c) return not c:IsSetCard(SET_HERO) end)
            ec1:SetReset(RESET_PHASE + PHASE_END)
            Duel.RegisterEffect(ec1, tp)
        end
    end
end
