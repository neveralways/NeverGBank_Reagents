local Addon, ns = ...
local utils = {}
ns.utils = utils

local GUILD_BANK_TAB_SLOTS = 98

-- Get first slot available in the specified Guild Bank tab
-- @return -1 if not found, > 0 if found
function utils.fitItemGuildBank(tab, searchItemLink, itemStackCount, bagsCount)
    local itemSlot = -1

    local i = 1
    while (i <= GUILD_BANK_TAB_SLOTS and itemSlot == -1) do
        local itemLink = GetGuildBankItemLink(tab, i)
        local texture, amount = GetGuildBankItemInfo(tab, i)

        if ((itemLink == searchItemLink) and ((amount + bagsCount) < itemStackCount)) or (amount == 0) then
            -- Found free slot
            itemSlot = i
        end

        i = i + 1
    end

    return itemSlot
end

