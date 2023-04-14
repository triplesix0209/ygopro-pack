-- Vicious Fusion
Duel.LoadScript("util.lua")
local s, id = GetID()

s.listed_names = {CARD_DARK_FUSION}
s.listed_series = {0xf8, 0x6008}

function s.initial_effect(c)
    -- fusion summon
    local e1 = Fusion.CreateSummonEff {
        handler = c,
        fusfilter = function(c) return c.dark_calling end,
        matfilter = Fusion.InHandMat(Card.IsAbleToRemove),
        extrafil = function(e, tp)
            local g = Duel.GetMatchingGroup(Fusion.IsMonsterFilter(Card.IsAbleToRemove), tp, LOCATION_MZONE + LOCATION_GRAVE, 0,
                nil)

            if Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard, 0xf8), tp, LOCATION_ONFIELD, 0, 1, nil) then
                g:Merge(Duel.GetMatchingGroup(Fusion.IsMonsterFilter(Card.IsAbleToRemove), tp, LOCATION_EXTRA, 0, nil))
                local check = function(tp, sg, fc) return sg:FilterCount(Card.IsLocation, nil, LOCATION_EXTRA) <= 1 end
                return g, check
            end
            return g
        end,
        extraop = Fusion.BanishMaterial,
        extratg = function(e, tp, eg, ep, ev, re, r, rp, chk)
            if chk == 0 then return true end
            local loc = LOCATION_HAND + LOCATION_MZONE + LOCATION_GRAVE
            if Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard, 0xf8), tp, LOCATION_ONFIELD, 0, 1, nil) then
                loc = loc + LOCATION_EXTRA
            end

            Duel.SetOperationInfo(0, CATEGORY_REMOVE, nil, 1, tp, loc)
        end,
        chkf = FUSPROC_NOLIMIT
    }
    c:RegisterEffect(e1)
end
