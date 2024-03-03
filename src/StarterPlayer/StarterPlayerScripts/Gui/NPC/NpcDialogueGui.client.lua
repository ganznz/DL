local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local GeneralUtils = require(ReplicatedStorage.Utils.GeneralUtils)
local CameraControls = require(ReplicatedStorage.Utils.Camera.CameraControls)
local PlayerUtils = require(ReplicatedStorage.Utils.Player.Player)
local GuiServices = require(ReplicatedStorage.Utils.Gui.GuiServices)
local GuiTemplates = require(ReplicatedStorage.Utils.Gui.GuiTemplates)

local Remotes = ReplicatedStorage.Remotes

local localPlr = Players.LocalPlayer
local camera = Workspace:FindFirstChild("Camera")
local PlayerGui = localPlr.PlayerGui

-- GUI VARIABLES --
local AllGuiScreenGui = PlayerGui:WaitForChild("AllGui")
local DialogueContainer: Frame = AllGuiScreenGui.Misc:WaitForChild("DialogueContainer")
-- dialogue box
local DialogueBox: Frame = DialogueContainer.DialogueBox
local DialogueBoxText: TextLabel = DialogueBox.Dialogue
local ClickToContinueText: TextLabel = DialogueBox.ClickToContinue
-- -- NPC name display
local NpcNameContainer: Frame = DialogueBox.NameContainer
local NpcNameText: TextLabel = NpcNameContainer.TextLabel
local NpcNameTextStroke: UIStroke = NpcNameText.UIStroke
-- replies container
local RepliesContainer: Frame = DialogueContainer.RepliesContainer
local ReplyTemplate: TextButton = RepliesContainer.Template

-- STATE VARIABLES --
local dialoguePrimaryColour: Color3 = nil
local dialogueSecondaryColour: Color3 = nil
-- -- dialogue state variables
local viewingDialogue: boolean = false -- if true, then player is currently going through NPC dialogue
local dialogueName: string = nil
local dialoguesToPlay = nil -- variable holds all of the dialogue to be showed
local currentViewedDialogueInfo = nil
local skippedDialogue: boolean = false

local dialogueContainerVisiblePos: UDim2 = DialogueContainer.Position
local dialogueContainerHiddenPos: UDim2 = UDim2.fromScale(0.5, 1.35)

-- hide dialogue container by default
DialogueContainer.Position = dialogueContainerHiddenPos
DialogueContainer.Visible = false

local function determineDialogueColours(dialogueName: string)
    if dialogueName == "StudioStoreNPC" then
        dialoguePrimaryColour = Color3.fromRGB(103, 189, 255)
        dialogueSecondaryColour = Color3.fromRGB(84, 155, 209)
    end
end

local function styleDialogueColours()

end

local function clearRepliesContainer()
    local instancesToIgnore = { "UIListLayout", "Template" }

    for _i, instance in RepliesContainer:GetChildren() do
        if table.find(instancesToIgnore, instance.Name) then continue end

        instance:Destroy()
    end
end

local function endDialogue()
    viewingDialogue = false
    CameraControls.SetDefault(localPlr, camera, true)
    PlayerUtils.ShowPlayer(localPlr, true)
    GuiServices.ShowHUD()

    -- hide dialogue GUI
    local hideTween = TweenService:Create(DialogueContainer, TweenInfo.new(0.5), { Position = dialogueContainerHiddenPos })
    hideTween:Play()
end

local function displayResponses(dialogueIndex: string)
    clearRepliesContainer()

    for responseIndex, responseInfo in dialoguesToPlay[dialogueIndex]["Responses"] do
        local responseTemplate = ReplyTemplate:Clone()
        responseTemplate.Name = responseIndex
        responseTemplate:FindFirstChild("Dialogue").Text = responseInfo.Text
        responseTemplate.Parent = RepliesContainer
        responseTemplate.Visible = true

        responseTemplate.Activated:Connect(function()
            -- some replies when selected may prompt functionality (e.g. camera panning to area to show)
            -- if this is the case, this remote halts progressing through dialogue until such functionality has completed
            Remotes.NPC.Dialogue.DialogueReply:FireServer(dialogueName, dialogueIndex, responseIndex)
        end)
    end
end

local function showDialogue(dialogueIndex: string)
    skippedDialogue = false
    ClickToContinueText.Visible = false

    currentViewedDialogueInfo = dialoguesToPlay[dialogueIndex]

    -- play typewriter effect
    DialogueBoxText.Text = currentViewedDialogueInfo.Text
    local index = 0
    for first, last in utf8.graphemes(DialogueBoxText.Text) do
        if skippedDialogue then break end
        index += 1
        DialogueBoxText.MaxVisibleGraphemes = index
        task.wait()
    end

    skippedDialogue = true
    DialogueBoxText.MaxVisibleGraphemes = -1 -- set this to -1 in case plr skips dialogue typewriter effect

    -- display skip text if applicable
    if not currentViewedDialogueInfo["Responses"] then
        ClickToContinueText.Visible = true
    end

    -- all text has displayed
    -- display replies if any
    if currentViewedDialogueInfo["Responses"] then displayResponses(dialogueIndex) end

end

local function setupDialogueView(dialogueInfo: {})
    -- set defaults
    viewingDialogue = true
    NpcNameText.Text = dialogueInfo.Speaker
    DialogueBoxText.Text = ""
    ClickToContinueText.Visible = false
    dialogueName = dialogueInfo.DialogueName
    skippedDialogue = false
    dialoguesToPlay = dialogueInfo.Dialogue
    clearRepliesContainer()
    determineDialogueColours(dialogueInfo.DialogueName)
    styleDialogueColours()

    GuiServices.HideGuiStandard()
    GuiServices.HideHUD()

    local showDialogueContainerTween = TweenService:Create(DialogueContainer, TweenInfo.new(0.5), { Position = dialogueContainerVisiblePos })
    DialogueContainer.Visible = true
    showDialogueContainerTween:Play()

    task.wait(1)

    showDialogue(dialogueInfo.FirstDialogueKey)
end

local inputTypesThatAllowSkip = { Enum.UserInputType.MouseButton1, Enum.UserInputType.Touch }
UserInputService.InputBegan:Connect(function(input: InputObject, processed: boolean)
    if processed then return end
    if not table.find(inputTypesThatAllowSkip, input.UserInputType) then return end
    if not viewingDialogue then return end
    if not currentViewedDialogueInfo then return end

    -- if skippedDialogue is true, then plr has reached end of current dialogue and can proceed
    if skippedDialogue then
        -- can only proceed if the current viewed dialogue hasn't got responses
        if currentViewedDialogueInfo["Responses"] then return end
        if currentViewedDialogueInfo["Next"] then
            showDialogue(currentViewedDialogueInfo.Next)
        else
            endDialogue()
        end
    
    -- if skippedDialogue is false, then the typewriter effect is being played but will be skipped
    else
        skippedDialogue = true
    end

end)

Remotes.NPC.Dialogue.GetDialogue.OnClientEvent:Connect(setupDialogueView)

Remotes.NPC.Dialogue.DialogueReply.OnClientEvent:Connect(function(dialogueState, responseInfo: { NextDialogueKey: string })
    if dialogueState == "ContinueDialogue" then
        showDialogue(responseInfo.NextDialogueKey)

    elseif dialogueState == "EndDialogue" then
        endDialogue()
    end
end)
