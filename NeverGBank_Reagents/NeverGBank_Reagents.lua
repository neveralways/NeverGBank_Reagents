local Addon, ns = ...
local utils = ns.utils
local Frame = Addon.Frame

local stop = true

-- Functions
-- ------------------------------------------------------------------------------------------------------------------------------------------------
local function DepositReagents()
    -- Stop if Guild Bank frame is closed
    if stop then return end
    
    local guildBankTab = GetCurrentGuildBankTab()
    local name, icon, isViewable, canDeposit, numWithdrawals, remainingWithdrawals = GetGuildBankTabInfo(guildBankTab)

    -- Check deposit permissions
    if canDeposit or IsGuildLeader(UnitName("player")) then
        
        -- Navigate through the bags
        for i = 0, 4 do
            local numBagSlots = GetContainerNumSlots(i)
            for j = 1, numBagSlots do
                local itemID = GetContainerItemID(i, j)
                if itemID ~= nil then
                    -- Get item info
                    local itemName, itemLink, itemQuality, itemLevel, itemMinLevel, itemType, itemSubType,
                    itemStackCount, itemEquipLoc, itemTexture, sellPrice, classID, subclassID, bindType,
                    expacID, setID, isCraftingReagent = GetItemInfo(itemID)
                    
                    local isSoulBound = C_Item.IsBound(ItemLocation:CreateFromBagAndSlot(i, j))
                    -- Check if item is reagent
                    if isCraftingReagent and (not isSoulBound) then
                        -- Get the item
                        -- Check if there is free slot in the tab
                        local count = GetItemCount(itemID, false, false)
                        local guildBankItemSlot = utils.fitItemGuildBank(guildBankTab, itemLink, itemStackCount, count)
                        if guildBankItemSlot > 0 then
                        -- Store the item
                            
                            UseContainerItem(i, j)
                            C_Timer.After(0.1, DepositReagents)
                            return
                        end
                    end
                end   
            end
        end
    end
end
-- ------------------------------------------------------------------------------------------------------------------------------------------------

-- OnEvent
-- ------------------------------------------------------------------------------------------------------------------------------------------------
local function OnEvent(self, event, ...)
    if IsInGuild() then
        if ( event == "GUILDBANKFRAME_OPENED" ) then
            depositReagentsBtn:Show()
            stop = false
        elseif ( event == "GUILDBANKFRAME_CLOSED") then
            depositReagentsBtn:Hide()
            stop = true
        end
    end
end
-- ------------------------------------------------------------------------------------------------------------------------------------------------

-- ------------------------------------------------------------------------------------------------------------------------------------------------
local f = CreateFrame("Frame", nil, UIParent)

f:SetScript("OnEvent", OnEvent)
f:RegisterEvent("GUILDBANKFRAME_OPENED")
f:RegisterEvent("GUILDBANKFRAME_CLOSED")
-- ------------------------------------------------------------------------------------------------------------------------------------------------

-- Button frame
-- ------------------------------------------------------------------------------------------------------------------------------------------------
local depositReagentsBtn = CreateFrame("Button", "depositReagentsBtn", UIParent, "SecureHandlerClickTemplate")
depositReagentsBtn:SetHeight(70)
depositReagentsBtn:SetWidth(70)
depositReagentsBtn:SetText("Deposit Reagents")
depositReagentsBtn.tooltipText = "This is an options button"
depositReagentsBtn:SetNormalTexture("Interface/Icons/misc_arrowdown")
depositReagentsBtn:SetPushedTexture("Interface/Icons/misc_arrowdown")
depositReagentsBtn:SetHighlightTexture("Interface/Icons/misc_arrowdown")
depositReagentsBtn:SetPoint("TOP", UIParent, "TOP", 0, -50)
depositReagentsBtn:SetScript("OnClick", DepositReagents)
depositReagentsBtn:EnableMouse(true)
depositReagentsBtn:SetMovable(true)
depositReagentsBtn:RegisterForDrag("LeftButton")
depositReagentsBtn:SetScript("OnDragStart", depositReagentsBtn.StartMoving)
depositReagentsBtn:SetScript("OnDragStop", depositReagentsBtn.StopMovingOrSizing)
depositReagentsBtn:SetScript('OnEnter', function() depositReagentsTooltip:Show() end)
depositReagentsBtn:SetScript('OnLeave', function() depositReagentsTooltip:Hide() end)
depositReagentsBtn:Hide()
-- ------------------------------------------------------------------------------------------------------------------------------------------------

-- Tooltip frame
-- ------------------------------------------------------------------------------------------------------------------------------------------------
local depositReagentsTooltip = CreateFrame("Frame", "depositReagentsTooltip", depositReagentsBtn, "BasicFrameTemplateWithInset")
depositReagentsTooltip:SetSize(500, 70);
depositReagentsTooltip:SetAlpha(.90);
depositReagentsTooltip:SetPoint("CENTER", 200, -100);
depositReagentsTooltip:EnableMouse(true)
depositReagentsTooltip:SetMovable(true);
depositReagentsTooltip.text = depositReagentsTooltip:CreateFontString(nil,"ARTWORK") 
depositReagentsTooltip.text:SetFont("Fonts\\2002.ttf", 16, "OUTLINE")
depositReagentsTooltip.text:SetPoint("CENTER",0,-7)

depositReagentsTooltip.title = depositReagentsTooltip:CreateFontString("depositReagentsTooltip_Title", "OVERLAY", "GameFontNormal")
depositReagentsTooltip.title:SetPoint("TOP", 0, 0)
depositReagentsTooltip.title:SetFont("Fonts\\2002.ttf", 18, "OUTLINE")

local locale = GetLocale()
if locale == 'esES' or locale == 'esMX' then
    depositReagentsTooltip.title:SetText("Información")
    depositReagentsTooltip.text:SetText("Haz clic para depositar los componentes\n en el banco de hermandad")
else
    depositReagentsTooltip.title:SetText("Information")
    depositReagentsTooltip.text:SetText("Click to deposit components/reagents in the Guild Bank")
end

depositReagentsTooltip:Hide();
-- ------------------------------------------------------------------------------------------------------------------------------------------------