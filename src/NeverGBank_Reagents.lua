local Addon, ns = ...
local utils = ns.utils
local Frame = Addon.Frame

local stop = true

-- Functions
-- ------------------------------------------------------------------------------------------------------------------------------------------------
local function DepositReagents()
    -- Stop if Guild Bank frame is closed
    if stop then return end
    
    local numBags = 4
    local guildBankTab = GetCurrentGuildBankTab()
    local name, icon, isViewable, canDeposit, numWithdrawals, remainingWithdrawals = GetGuildBankTabInfo(guildBankTab)

    -- Check deposit permissions
    if canDeposit or IsGuildLeader(UnitName("player")) then
        
        if cbComponentsContainer:GetChecked() == true then
            numBags = 5
        end

        -- Navigate through the bags
        for i = 0, numBags do
            local numBagSlots = C_Container.GetContainerNumSlots(i)
            for j = 1, numBagSlots do
                local itemID = C_Container.GetContainerItemID(i, j)
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
                            C_Container.UseContainerItem(i, j)
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
local function OnEvent(self, event, arg1)

    
    if event == "ADDON_LOADED" and arg1 == "NeverGBank_Reagents" then
        -- Load variable
        
        if UseComponentsContainer == nil then
            -- Never established
            UseComponentsContainer = false
        end

        cbComponentsContainer:SetChecked(UseComponentsContainer)
        
    elseif event == "PLAYER_LOGOUT" then
        UseComponentsContainer = cbComponentsContainer:GetChecked()
    end

    if IsInGuild() then
        if ( event == "PLAYER_INTERACTION_MANAGER_FRAME_SHOW" ) then
            local type = arg1
            if type == 10 then
                depositReagentsBtn:Show()
                stop = false
            end
        elseif ( event == "PLAYER_INTERACTION_MANAGER_FRAME_HIDE") then
            local type = arg1
            if type == 10 then
                depositReagentsBtn:Hide()
                stop = true
            end
        end
    end
end
-- ------------------------------------------------------------------------------------------------------------------------------------------------

-- ------------------------------------------------------------------------------------------------------------------------------------------------
local f = CreateFrame("Frame")

f:SetScript("OnEvent", OnEvent)
f:RegisterEvent("PLAYER_INTERACTION_MANAGER_FRAME_SHOW")
f:RegisterEvent("PLAYER_INTERACTION_MANAGER_FRAME_HIDE")
f:RegisterEvent("ADDON_LOADED")
f:RegisterEvent("PLAYER_LOGOUT")
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


-- Create panel in game options panel
-- ------------------------------------------------------------------------------------------------------------------------------------------------

local optionsPanel = CreateFrame("Frame")
optionsPanel.name = "NeverGBank Reagents " .. C_AddOns.GetAddOnMetadata("NeverGBank_Reagents", "Version")

if SettingsPanel then
    local category, layout = Settings.RegisterCanvasLayoutCategory(optionsPanel, "NeverGBank Reagents " .. C_AddOns.GetAddOnMetadata("NeverGBank_Reagents", "Version"))
    Settings.RegisterAddOnCategory(category)
end

local title = optionsPanel:CreateFontString("ARTWORK", nil, "GameFontNormalLarge")
title:SetPoint("TOP")
title:SetText(optionsPanel.name)

cbComponentsContainer = CreateFrame("CheckButton", "cbComponentsContainer", optionsPanel, "ChatConfigCheckButtonTemplate");
cbComponentsContainer:SetPoint("TOPLEFT", 50, -65);
cbComponentsContainerText:SetText("Use Components Container")
