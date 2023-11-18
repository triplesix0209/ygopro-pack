-- Meteor Flare Fusion
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names={CARD_REDEYES_B_DRAGON}
s.material_setcode = {SET_RED_EYES}

function s.initial_effect(c)
    -- Activate
    local e1 = Fusion.CreateSummonEff({
        handler = c,
        fusfilter = aux.FilterBoolFunction(Card.ListsArchetypeAsMaterial, SET_RED_EYES),
        matfilter = Card.IsAbleToDeck,
        extrafil = function(e, tp, mg)
            return Duel.GetMatchingGroup(aux.NecroValleyFilter(Fusion.IsMonsterFilter(Card.IsAbleToDeck)), tp, LOCATION_GRAVE, 0, nil)
        end,
        extratg = function(e, tp, eg, ep, ev, re, r, rp, chk)
            if chk == 0 then return true end
            Duel.SetOperationInfo(0, CATEGORY_TODECK, nil, 0, tp, LOCATION_HAND + LOCATION_MZONE + LOCATION_GRAVE)
        end,
        extraop = Fusion.ShuffleMaterial,
        stage2 = s.e1stage2
    })
    e1:SetCountLimit(1, id, EFFECT_COUNT_CODE_OATH)
    c:RegisterEffect(e1)
end

function s.e1stage2(e, tc, tp, mg, chk)
    local c = e:GetHandler()
    if chk == 1 then
        local ec1 = Effect.CreateEffect(c)
        ec1:SetType(EFFECT_TYPE_SINGLE)
        ec1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
        ec1:SetCode(EFFECT_CHANGE_CODE)
        ec1:SetValue(CARD_REDEYES_B_DRAGON)
        ec1:SetReset(RESET_EVENT + RESETS_STANDARD)
        tc:RegisterEffect(ec1)
    end
end
