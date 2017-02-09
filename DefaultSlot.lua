----------------------------------------------------------------------------------------
-- Library Imports
----------------------------------------------------------------------------------------
local LAM2 = LibStub:GetLibrary("LibAddonMenu-2.0")

----------------------------------------------------------------------------------------
-- Namespace Table
----------------------------------------------------------------------------------------
DefaultSlot = {}

----------------------------------------------------------------------------------------
-- Local tables 
----------------------------------------------------------------------------------------
local appData = {
    Name = "DefaultSlot",
    DisplayName = "Default Slot",
    Version = "0.1.1",
    DataVersion = 1,
    Debug = true
}

local savedVars = {
    ReslotTimer = 30000,  -- default 30 second timer.
    DefaultSlotId = 13,
    SiegeSuppression = true
}

local tempVars = {
    siegeInUse = false
}

----------------------------------------------------------------------------------------
-- Function Declarations
----------------------------------------------------------------------------------------
local UpdateSlotInChat
local ResetSlot
local Dbg

----------------------------------------------------------------------------------------
-- Event handler for when the addon is loaded. This function triggers initialization
----------------------------------------------------------------------------------------
function DefaultSlot.OnAddOnLoaded(event, addonName)

    -- Looking for just my addon.
    if addonName == appData.Name then
        -- It is, so initialize it.
        savedVars = ZO_SavedVars:New("DefaultSlotData", appData.DataVersion, "Core", savedVars)
        DefaultSlot:Initialize()
    end

end

----------------------------------------------------------------------------------------
-- Event handler that is triggered when the quickslot gets changed.
----------------------------------------------------------------------------------------
function DefaultSlot.QuickSlotChanged(event, slotId)
    -- if it's not the default slot, prepare to possibly change it.
    if slotId ~= savedVars.DefaultSlotId then 
        UpdateSlotInChat(slotId)
        Dbg("In use: " .. tostring(tempVars.siegeInUse))
        Dbg("In Suppression: " .. tostring(savedVars.SiegeSuppression))
        zo_callLater(function() ResetSlot() end, savedVars.ReslotTimer )
    end 
end

----------------------------------------------------------------------------------------
-- Event handler that is triggered when the player sets up siege successfully.
----------------------------------------------------------------------------------------
function DefaultSlot.SiegeStarted(event)
    Dbg("Siege Started")
    tempVars.siegeInUse = true
end

----------------------------------------------------------------------------------------
-- Event handler that is triggered when the player takes down siege successfully.
----------------------------------------------------------------------------------------
function DefaultSlot.SiegeEnded(event)
    Dbg("Siege Ended")
    tempVars.siegeInUse = false
end

----------------------------------------------------------------------------------------
-- Event handler that is triggered when the siege weapon is busy (experimental).
--      It was a failed attempt to determine if a repair kit was being used.
----------------------------------------------------------------------------------------
function DefaultSlot.SiegeBusy(event, siegeName)
    Dbg(siegeName .. " is busy!")
end 

----------------------------------------------------------------------------------------
-- Initializes the addon and initializes the creation of the settings menu.
----------------------------------------------------------------------------------------
function DefaultSlot:Initialize()
    DefaultSlot.CreateSettingsWindow()
end

----------------------------------------------------------------------------------------
-- Function to determine if the slot should delay or reset immediately.
----------------------------------------------------------------------------------------
function ResetSlot()   
    if(tempVars.siegeInUse and savedVars.SiegeSuppression) then
        -- pause default slot until seige isn't potentially in use, but invoke reset 
        local suppressionMsg = appData.DisplayName .. "Siege suppression in effect, resetting timer."
        CHAT_SYSTEM:AddMessage(suppressionMsg)
        zo_callLater(function() ResetSlot() end, savedVars.ReslotTimer )
    else
        SetCurrentQuickslot(savedVars.DefaultSlotId)
        UpdateSlotInChat(savedVars.DefaultSlotId)
    end 
end

----------------------------------------------------------------------------------------
-- Function to push a message to chat indicating the item that was slotted.  This gets 
--    called by a slot change that was invoked by the user or a slot change invoked by
--    the Default Slot addon.
----------------------------------------------------------------------------------------
function UpdateSlotInChat(slotId)
    local item = GetItemLinkName(GetSlotItemLink(slotId))
    item = GetSlotItemLink(slotId)
    local content = zo_strformat("Quickslot Changed to <<1>>", item)
    CHAT_SYSTEM:AddMessage(content)
end 

----------------------------------------------------------------------------------------
-- Function to push a message to chat for debugging purposes.  Only works when debugging
--    mode is enabled.  Debug messages are prefixed with ***
----------------------------------------------------------------------------------------
function Dbg(msg)
    if appData.Debug then
        local dbg = zo_strformat("*** <<1>> ***", msg)
        CHAT_SYSTEM:AddMessage(dbg)
    end 
end 

----------------------------------------------------------------------------------------
-- Settings Menu UI : This function invokes the LibAddonMenu-2.0 library to create the
--    addon settings menu for Default Slot.
----------------------------------------------------------------------------------------
function DefaultSlot.CreateSettingsWindow()

    -- A table to hold the data for setting up the settings window.
    local panelData = {
        type = "panel",
        name = appData.DisplayName,
        displayName = appData.DisplayName,
        author = "condorhauck",
        version = appData.Version,
        registerForRefresh = true,
        registerForDefaults = true,
    }

    -- A table contiaining the controls displayed on the settings menu.
    local optionsData = {
        [1] = {
            type = "header",
            name = "Default Slot Settings"
        },
        [2] = {
            type = "description",
            name = "Change the way the default slot add on works."
        },
        [3] = {
            type = "slider",
            name = "Default Slot",
            tooltip = "The quick slot that gets selected after the timer elapses.",
            min = 1,
            max = 8,
            default = 5,
            getFunc = function() return (savedVars.DefaultSlotId - 8) end,
	        setFunc = function(newValue) 
                savedVars.DefaultSlotId = newValue + 8
            end
        },
        [4] = {
            type = "slider",
            name = "Reslot Timer",
            tooltip = "The amount of time (in seconds) to wait before switching back to the default slot.",
            min = 5,
            max = 300,
            default = 15,
            getFunc = function() return (savedVars.ReslotTimer / 1000) end,
	        setFunc = function(newValue) 
                savedVars.ReslotTimer = newValue * 1000
            end
        },
        [5] = {
            type = "checkbox",
            name = "Siege Suppression",
            default = true,
            tooltip = "If the timer ticks while siege is in progress, or keep repair is in progress, the timer restarts instead of switching slots.",
            getFunc = function() return (savedVars.SiegeSuprression) end,
            setFunc = function(newValue)
                savedVars.SiegeSuprression = newValue
            end 
        },
        [6] = {
            type = "description",
            name = "A key to describe the slot numbers for the slider"
        },
        [7] = {
            type = "texture",
            image = "DefaultSlot/slots.dds",
            imageWidth = "150",
            imageHeight = "150"
        }
    }

    -- Invocation of the sections defined above in creating the panel displayed in the settings -> addons menu.
    local cntrlOptionsPanel = LAM2:RegisterAddonPanel(appData.Name, panelData)
    LAM2:RegisterOptionControls(appData.Name, optionsData)
    OpenSettingsPanel = function()
        LAM:OpenToPanel(panel)
    end
end



----------------------------------------------------------------------------------------
-- Event Registrations for the various API events being watched by the addon.
----------------------------------------------------------------------------------------
EVENT_MANAGER:RegisterForEvent(appData.Name, EVENT_ADD_ON_LOADED, DefaultSlot.OnAddOnLoaded)
EVENT_MANAGER:RegisterForEvent(appData.Name, EVENT_ACTIVE_QUICKSLOT_CHANGED, DefaultSlot.QuickSlotChanged)
EVENT_MANAGER:RegisterForEvent(appData.Name, EVENT_BEGIN_SIEGE_CONTROL, DefaultSlot.SiegeStarted)
EVENT_MANAGER:RegisterForEvent(appData.Name, EVENT_END_SIEGE_CONTROL, DefaultSlot.SiegeEnded)
EVENT_MANAGER:RegisterForEvent(appData.Name, EVENT_SIEGE_BUSY, DefaultSlot.SiegeBusy)
