SMODS.Atlas({
    key = "modicon",
    path = "icon.png",
    px = 34,
    py = 34,
})

local existing_suits = {}
for i = #SMODS.current_mod.config.suit_order, 1, -1 do
    if SMODS.Suits[SMODS.current_mod.config.suit_order[i]] then
        existing_suits[SMODS.current_mod.config.suit_order[i]] = true
    else
        table.remove(SMODS.current_mod.config.suit_order, i)
    end
end
for k, v in pairs(SMODS.Suits) do
    if not existing_suits[k] then
        table.insert(SMODS.current_mod.config.suit_order, k)
    end
end

for k, v in ipairs(SMODS.current_mod.config.suit_order) do
    SMODS.Suit.obj_buffer[#SMODS.current_mod.config.suit_order - k + 1] = v
    SMODS.Suits[v].suit_nominal = (#SMODS.current_mod.config.suit_order - k + 1) /
        (#SMODS.current_mod.config.suit_order * 10)
end

SMODS.current_mod.config_tab = function()
    local area = CardArea(nil, nil, 4 * G.CARD_W, G.CARD_H,
        { card_limit = #SMODS.Mods.SuitOrder.config.suit_order, highlight_limit = 0, type = "title" })
    area.suit_order_update = true
    for k, v in ipairs(SMODS.Mods.SuitOrder.config.suit_order) do
        local card = Card(nil, nil, G.CARD_W, G.CARD_H, G.P_CARDS[SMODS.Suits[v].card_key .. "_A"], G.P_CENTERS.c_base)
        area:emplace(card)
    end
    return {
        n = G.UIT.ROOT,
        config = { align = "cm", r = 0.1, colour = G.C.BLACK, emboss = 0.05 },
        nodes = { { n = G.UIT.O, config = { object = area } } }
    }
end

local hook = CardArea.align_cards
function CardArea:align_cards()
    if self.suit_order_update then
        for k, v in ipairs(self.cards) do
            SMODS.Mods.SuitOrder.config.suit_order[k] = v.base.suit
            for kk, vv in ipairs(SMODS.Mods.SuitOrder.config.suit_order) do
                SMODS.Suit.obj_buffer[#SMODS.Mods.SuitOrder.config.suit_order - kk + 1] = vv
                SMODS.Suits[vv].suit_nominal = (#SMODS.Mods.SuitOrder.config.suit_order - kk + 1) /
                    (#SMODS.Mods.SuitOrder.config.suit_order * 10)
            end
            for kk, vv in ipairs(G.playing_cards or {}) do
                vv.base.suit_nominal = SMODS.Suits[vv.base.suit].suit_nominal
            end
        end
    end
    return hook(self)
end
