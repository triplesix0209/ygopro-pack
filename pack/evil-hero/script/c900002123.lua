-- Dark Requiem
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {CARD_DARK_FUSION}
s.listed_series = {0xf8}

function s.initial_effect(c)
    -- fusion summon
    local e1 = Fusion.CreateSummonEff({
        handler = c,
        fusfilter = function(c) return c.dark_calling end,
        matfilter = Card.IsAbleToDeck,
        extrafil = function(e, tp)
            return Duel.GetMatchingGroup(Fusion.IsMonsterFilter(Card.IsFaceup, Card.IsAbleToDeck), tp,
                LOCATION_GRAVE + LOCATION_REMOVED, 0, nil)
        end,
        extraop = Fusion.ShuffleMaterial,
        extratg = function(e, tp, eg, ep, ev, re, r, rp, chk)
            if chk == 0 then return true end
            Duel.SetOperationInfo(0, CATEGORY_TODECK, nil, 0, tp, LOCATION_PUBLIC)
        end,
        chkf = FUSPROC_NOLIMIT
    })
    e1:SetCountLimit(1, id, EFFECT_COUNT_CODE_OATH)
    c:RegisterEffect(e1)

    -- act in hand
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_TRAP_ACT_IN_HAND)
    e2:SetCondition(s.e2con)
    c:RegisterEffect(e2)
end

function s.e2filter(c) return c:IsFaceup() and not c:IsSetCard(0xf8) end

function s.e2con(e) return not Duel.IsExistingMatchingCard(s.e2filter, e:GetHandlerPlayer(), LOCATION_ONFIELD, 0, 1, nil) end
