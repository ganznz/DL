local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local PlrDataManager = require(ServerScriptService.PlayerData.Manager)
local AccessibleBuildingManager = require(ServerScriptService.Functionality.Buildings.AccessibleBuildingManager)

local Remotes = ReplicatedStorage.Remotes

type Response = {
    Text: string,
    Next: string?
}

type Dialogue = {
    Text: string,
    Responses: { [number]: Response }?,
    Next: string?,
}

local Dialogue = {}

-- studio store NPC dialogue
local studioStoreNpcDialogue: { Name: string, [string]: Dialogue } = {
    Name = "Studio Bro",
    ["1"] = {
        Text = "Welcome to the Studio store!",
        Next = "2"
    },
    ["2"] = {
        Text = "How can I help you?",
        Responses = {
            ["1"] = { Text = "View Studios" },
            ["2"] = { Text = "Bye" },
        },
    }
}
Dialogue.StudioStoreNPC = studioStoreNpcDialogue

-- laptop store NPC dialogue
local laptopStoreNpcDialogue: { Name: string, [number]: Dialogue } = {
    Name = "Laptop Bro",
    ["1"] = {
        Text = "Hi. Please come back when you're level 2!"
    },
    ["2"] = {
        Text = "Hello, want to purchase a laptop?",
        Responses = {
            ["1"] = { Text = "Yeah" },
            ["2"] = { Text = "No thanks" },
        }
    }
}

-- gets specific dialogue to send to the plr. Allows sending only selected dialogue based on plr progression.
local function getDialogueRange(allDialogue, startIndex: number, endIndex: number)
    startIndex = startIndex or 1
    endIndex = endIndex or 1

    local dialogueToSendPlr = {}
    for i = startIndex, endIndex, 1 do
        dialogueToSendPlr[tostring(i)] = allDialogue[tostring(i)]
    end

    return dialogueToSendPlr
end

local function getDialogue(plr: Player, dialogueToGet: string)
    local profile = PlrDataManager.Profiles[plr]
    if not profile then return end

    local allNpcDialogue = Dialogue[dialogueToGet]
    if not allNpcDialogue then return end

    local firstDialogueKey
    local dialogueToSend

    -- plr is requesting studio store NPC dialogue
    if dialogueToGet == "StudioStoreNPC" then
        -- check if plr is inside studio store
        local plrInBuilding = AccessibleBuildingManager.PlrsInBuildings[plr.UserId]
        if not plrInBuilding then return end
        if not plrInBuilding.InBuilding == "StudioStore" then return end

        firstDialogueKey = "1"
        dialogueToSend = allNpcDialogue
    end

    if dialogueToGet == "LaptopStoreNPC" then
        -- if plr is only level 1
        if profile.Data.Character == 1 then
            dialogueToSend = getDialogueRange(allNpcDialogue, 1, 1)
        else
            dialogueToSend = allNpcDialogue
        end
        firstDialogueKey = "1"
    end

    Remotes.NPC.Dialogue.GetDialogue:FireClient(plr, {
        Speaker = allNpcDialogue.Name,
        DialogueName = dialogueToGet,
        FirstDialogueKey = firstDialogueKey,
        Dialogue = dialogueToSend
    })
end

-- function handles response functionality, if there is any for that response  
local function handleResponse(plr: Player, dialogueName: string, dialogueIndex: string, replyIndex: string)
    local profile = PlrDataManager.Profiles[plr]
    if not profile then return end

    local functionalityEnded = nil

    -- if response initiates any functionality (e.g. camera panning to area to show) then do that here
    if dialogueName == "StudioStoreNPC" then
        if dialogueIndex == "2" then
            if replyIndex == "1" then
                Remotes.Studio.General.ViewStudioStore:FireClient(plr, profile.Data)
                -- functionalityEnded = Remotes.NPC.Dialogue.InitiateReplyFunctionality:InvokeClient(plr)
            elseif replyIndex == "2" then
            end
        end
    end

    return functionalityEnded
end

Remotes.NPC.Dialogue.GetDialogue.OnServerEvent:Connect(getDialogue)

Remotes.NPC.Dialogue.DialogueReply.OnServerEvent:Connect(function(plr: Player, dialogueName: string, dialogueIndex: string, replyIndex: string)
    local allNpcDialogue = Dialogue[dialogueName]
    if not allNpcDialogue then return end
    if not allNpcDialogue[dialogueIndex] then return end
    if not allNpcDialogue[dialogueIndex]["Responses"] then return end

    local replyInfo = allNpcDialogue[dialogueIndex]["Responses"][replyIndex]
    if not replyInfo then return end

    local responseFunctionalityHandled = handleResponse(plr, dialogueName, dialogueIndex, replyIndex)

    local dialogueState = if replyInfo["Next"] then "ContinueDialogue" else "EndDialogue"

    Remotes.NPC.Dialogue.DialogueReply:FireClient(plr, dialogueState, { NextDialogueKey = replyInfo["Next"] })
end)