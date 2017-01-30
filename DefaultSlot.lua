-------
-- Library Imports
-------
local LAM2 = LibStub:GetLibrary("LibAddonMenu-2.0")

DefaultSlot = {}

local appData = {
    Name = "DefaultSlot",
    DisplayName = "Default Slot",
    Version = "0.1",
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

local UpdateSlotInChat
local ResetSlot
local Dbg

-- Detect if the addon is loaded.
function DefaultSlot.OnAddOnLoaded(event, addonName)

    -- Looking for just my addon.
    if addonName == appData.Name then
        -- It is, so initialize it.
        savedVars = ZO_SavedVars:New("DefaultSlotData", appData.DataVersion, "Core", savedVars)
        DefaultSlot:Initialize()
    end

end

-- Triggers when the quickslot gets changed.
function DefaultSlot.QuickSlotChanged(event, slotId)
    -- if it's not the default slot, prepare to possibly change it.
    if slotId ~= savedVars.DefaultSlotId then 
        UpdateSlotInChat(slotId)
        Dbg("In use: " .. tostring(tempVars.siegeInUse))
        Dbg("In Suppression: " .. tostring(savedVars.SiegeSuppression))
        zo_callLater(function() ResetSlot() end, savedVars.ReslotTimer )
    end 
end

function DefaultSlot.SiegeStarted(event)
    Dbg("Siege Started")
    tempVars.siegeInUse = true
end

function DefaultSlot.SiegeEnded(event)
    Dbg("Siege Ended")
    tempVars.siegeInUse = false
end

function DefaultSlot.SiegeBusy(event, siegeName)
    Dbg(siegeName .. " is busy!")
end 

-- Initialize the addon 
function DefaultSlot:Initialize()
    DefaultSlot.CreateSettingsWindow()
    --local colorizedName = GetColorizedText(DefaultSlot.name, COLORS.PURPLE)
    --local initMsg = zo_strformat("<<1>> has been Initialized.", colorizedName)
    --zo_callLater(function() d(initMsg) end, 3000)
end

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

function UpdateSlotInChat(slotId)
    local item = GetItemLinkName(GetSlotItemLink(slotId))
    item = GetSlotItemLink(slotId)
    local content = zo_strformat("Quickslot Changed to [<<1>>]", item)
    CHAT_SYSTEM:AddMessage(content)
end 

function Dbg(msg)
    if appData.Debug then
        local dbg = zo_strformat("*** <<1>>", msg)
        CHAT_SYSTEM:AddMessage(dbg)
    end 
end 

--------
-- Settings Menu UI
--------

function DefaultSlot.CreateSettingsWindow()


    local panelData = {
        type = "panel",
        name = appData.DisplayName,
        displayName = appData.DisplayName,
        author = "condorhauck",
        version = appData.Version,
        registerForRefresh = true,
        registerForDefaults = true,
    }

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


    local cntrlOptionsPanel = LAM2:RegisterAddonPanel(appData.Name, panelData)
    LAM2:RegisterOptionControls(appData.Name, optionsData)
    OpenSettingsPanel = function()
        LAM:OpenToPanel(panel)
    end
end


-- Register the event handler for onload.
EVENT_MANAGER:RegisterForEvent(appData.Name, EVENT_ADD_ON_LOADED, DefaultSlot.OnAddOnLoaded)
EVENT_MANAGER:RegisterForEvent(appData.Name, EVENT_ACTIVE_QUICKSLOT_CHANGED, DefaultSlot.QuickSlotChanged)
EVENT_MANAGER:RegisterForEvent(appData.Name, EVENT_BEGIN_SIEGE_CONTROL, DefaultSlot.SiegeStarted)
EVENT_MANAGER:RegisterForEvent(appData.Name, EVENT_END_SIEGE_CONTROL, DefaultSlot.SiegeEnded)
EVENT_MANAGER:RegisterForEvent(appData.Name, EVENT_SIEGE_BUSY, DefaultSlot.SiegeBusy)
