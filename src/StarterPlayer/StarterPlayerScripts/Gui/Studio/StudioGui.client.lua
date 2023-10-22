local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GuiServices = require(ReplicatedStorage.Utils.Gui:WaitForChild("GuiServices"))
local GlobalVariables = require(ReplicatedStorage.GlobalVariables)
local StudioConfig = require(ReplicatedStorage.Configs:WaitForChild("Studio"))

local Remotes = ReplicatedStorage.Remotes

local localPlr = Players.LocalPlayer
local PlayerGui = localPlr.PlayerGui

local LeftSideContainer = PlayerGui:WaitForChild("Left"):WaitForChild("LeftBtnContainer")
local StudioTeleportBtn = LeftSideContainer.StudioTpBtn
local StudioBuildModeBtn = LeftSideContainer.StudioBuildModeBtn

local RightSideContainer = PlayerGui:WaitForChild("Right"):WaitForChild("RightBtnContainer")
local PlrStudiosBtn = RightSideContainer.PlrStudiosBtn

local StudioListContainer = PlayerGui:WaitForChild("Studios"):WaitForChild("StudioListContainer")
local StudioListExitBtn = StudioListContainer.ExitBtn
local StudioListScrollingFrame = StudioListContainer.ScrollingFrame
local StudioListScrollingFrameTemplate = StudioListScrollingFrame:WaitForChild("Template")
local StudioWhitelistBtn = StudioListContainer.StudioSettings.WhitelistBtn
local StudioKickAllBtn = StudioListContainer.StudioSettings.KickBtn

local WHITELIST_BTN_TEXT_TEMPLATE = "Studio: SETTING"
local KICK_PLRS_COOLDOWN = 15 -- seconds
local visibleGuiPos = StudioListContainer.Position
local visibleGuiSize = StudioListContainer.Size

local char = localPlr.Character or localPlr.CharacterAdded:Wait()
local humanoid = char:WaitForChild("Humanoid")

-- stores Activated connections for when visit buttons get clicked
-- { [userId] = connection }
local visitBtnConnections = {}

GuiServices.DefaultMainGuiStyling(StudioListContainer, GlobalVariables.Gui.MainGuiInvisiblePosOffset)

local function getPlrNameFromUserId(userId: number)
    local username = nil
    local success, errorMsg = pcall(function()
        username = Players:GetNameFromUserIdAsync(userId)
    end)
    return username
end

local function getPlrIconImage(userId: number, thumbType: Enum.ThumbnailType, thumbSize: Enum.ThumbnailSize)
    local iconImg = nil
    local success, errorMsg = pcall(function()
        iconImg = Players:GetUserThumbnailAsync(userId, thumbType, thumbSize)
    end)
    return iconImg
end

local function getPlrStudioName(studioIndex: number)
    local studioConfig = StudioConfig.GetConfig(studioIndex)
    return studioConfig.Name
end

local function setStudioVisitBtn(visitBtn, plrStudioStatus)
    if plrStudioStatus == "open" then
        visitBtn.BackgroundColor3 = Color3.fromRGB(70, 184, 255)
        visitBtn.Text = "Visit Studio"

    elseif plrStudioStatus == "closed" then
        visitBtn.BackgroundColor3 = GlobalVariables.Gui.InvalidRedColour
        visitBtn.Text = "Studio closed"
    
    elseif plrStudioStatus == "friends" then
        visitBtn.BackgroundColor3 = GlobalVariables.Gui.InvalidGreyColour
        visitBtn.Text = "Friends only"
    end
end

local function registerStudioVisitBtnListener(visitBtn, userIdOfPlrToVisit)
    local connection = visitBtn.Activated:Connect(function()
        Remotes.Studio.VisitOtherStudio:FireServer(userIdOfPlrToVisit)
    end)
    return connection
end

local function removeStudioListItem(userId: number)
    local instance = StudioListScrollingFrame:FindFirstChild(tostring(userId))
    instance:Destroy()

    -- disconnect and remove connection if any
    local visitBtnConnection = visitBtnConnections[userId]
    if visitBtnConnection then
        visitBtnConnections[userId]:Disconnect()
        visitBtnConnections[userId] = nil
    end
end

local function clearStudioList()
    for _i, instance in StudioListScrollingFrame:GetChildren() do
        if instance.Name == "Template" or instance.Name == "UIListLayout" then continue end

        removeStudioListItem(tonumber(instance.Name))
    end
end

local function createStudioListItem(userId: number, userStudioInfo)
    local template = StudioListScrollingFrameTemplate:clone()
    local plrNameText = template:FindFirstChild("PlrName")
    local plrIconImage = template:FindFirstChild("PlrIcon")
    local studioNameText = template:FindFirstChild("StudioName")
    local visitBtn = template:FindFirstChild("VisitBtn")
    
    template.Name = tostring(userId)
    studioNameText.Text = getPlrStudioName(userStudioInfo.StudioIndex)
    
    local plrName = getPlrNameFromUserId(userId)
    local plrIcon = getPlrIconImage(userId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
    if not plrName or not plrIcon then
        return
    end
    plrNameText.Text = plrName
    plrIconImage.Image = plrIcon

    setStudioVisitBtn(visitBtn, userStudioInfo.StudioStatus)
    if userStudioInfo.StudioStatus == "open" then
        visitBtnConnections[userId] = registerStudioVisitBtnListener(visitBtn, userId)
    end

    template.Visible = true
    template.Parent = StudioListScrollingFrame
end

local function populateStudioList()
    local studioPlrInfo = Remotes.Studio.GetStudioPlrInfo:InvokeServer()

    for userId, userStudioInfo in studioPlrInfo do
        -- don't show players own studio on the list
        if tonumber(userId) == localPlr.UserId then continue end

        createStudioListItem(userId, userStudioInfo)
    end
end

local function updateStudioListItem(userIdToUpdate: number, updateStatus: "add" | "remove" | "update", userStudioInfo)
    local studioInfoFrame = StudioListScrollingFrame:FindFirstChild(tostring(userIdToUpdate))
    if not studioInfoFrame then return end

    if updateStatus == "add" then
        createStudioListItem(userIdToUpdate, userStudioInfo)

    elseif updateStatus == "remove" then
        removeStudioListItem(userIdToUpdate)
    
    elseif updateStatus == "update" then
        local studioNameText = studioInfoFrame:FindFirstChild("StudioName")
        local visitBtn = studioInfoFrame:FindFirstChild("VisitBtn")
    
        -- disconnect old connection if any and replace
        local visitBtnConnection = visitBtnConnections[userIdToUpdate]
        if visitBtnConnection then
            visitBtnConnections[userIdToUpdate]:Disconnect()
            visitBtnConnections[userIdToUpdate] = registerStudioVisitBtnListener(visitBtn, userIdToUpdate)
        end
    
        setStudioVisitBtn(visitBtn, userStudioInfo.StudioStatus)
        studioNameText.Text = getPlrStudioName(userStudioInfo.StudioIndex)
    end
end

local function updateWhitelistBtn(whitelistSetting: "open" | "closed" | "friends")
    if whitelistSetting == "open" then
        StudioWhitelistBtn.BackgroundColor3 = GlobalVariables.Gui.ValidGreenColour
        StudioWhitelistBtn.Text = WHITELIST_BTN_TEXT_TEMPLATE:gsub("SETTING", "Open")

    elseif whitelistSetting == "closed" then
        StudioWhitelistBtn.BackgroundColor3 = GlobalVariables.Gui.InvalidRedColour
        StudioWhitelistBtn.Text = WHITELIST_BTN_TEXT_TEMPLATE:gsub("SETTING", "Closed")

    elseif whitelistSetting == "friends" then
        StudioWhitelistBtn.BackgroundColor3 = GlobalVariables.Gui.CantAffordColour
        StudioWhitelistBtn.Text = WHITELIST_BTN_TEXT_TEMPLATE:gsub("SETTING", "Friends")

    end
end

-- switches between the left-side studio btns (visit studio btn & build mode btn)
local function switchStudioBtns(btnToHide, btnToShow)
    btnToHide.Visible = false
    btnToShow.Visible = true
end

local tpDebounce = true
StudioTeleportBtn.Activated:Connect(function()
    if tpDebounce and localPlr:GetAttribute("IsAlive") then
        tpDebounce = false
        Remotes.Studio.VisitOwnStudio:FireServer()
        task.wait(1)
        tpDebounce = true
    end
end)

Remotes.Studio.VisitOwnStudio.OnClientEvent:Connect(function(_plr, _studioIndex, _interiorPlayerTpPart, _exteriorPlayerTpPart)
    task.delay(GlobalVariables.Gui.LoadingBgTweenTime, function()
        switchStudioBtns(StudioTeleportBtn, StudioBuildModeBtn)
    end)
end)

Remotes.Studio.VisitOtherStudio.OnClientEvent:Connect(function(_plr, _studioIndex, _interiorPlayerTpPart, _exteriorPlayerTpPart)
    task.delay(GlobalVariables.Gui.LoadingBgTweenTime, function()
        switchStudioBtns(StudioTeleportBtn, StudioBuildModeBtn)
    end)
end)

Remotes.Studio.LeaveStudio.OnClientEvent:Connect(function()
    task.delay(GlobalVariables.Gui.LoadingBgTweenTime, function()
        switchStudioBtns(StudioBuildModeBtn, StudioTeleportBtn)
    end)
end)

PlrStudiosBtn.Activated:Connect(function()
    clearStudioList()
    populateStudioList()
    GuiServices.ShowGuiStandard(StudioListContainer, visibleGuiPos, visibleGuiSize)
end)

StudioListExitBtn.Activated:Connect(function()
    GuiServices.HideGuiStandard(StudioListContainer, UDim2.new(visibleGuiPos.X.Scale, 0, visibleGuiPos.Y.Scale + GlobalVariables.Gui.MainGuiInvisiblePosOffset, 0), UDim2.new(visibleGuiSize.X.Scale, 0, visibleGuiSize.Y.Scale - 0.2, 0))
end)

StudioWhitelistBtn.Activated:Connect(function()
    Remotes.Studio.UpdateWhitelist:FireServer()
end)

local kickAllDebounce = true
StudioKickAllBtn.Activated:Connect(function()
    if kickAllDebounce then
        kickAllDebounce = false
        Remotes.Studio.KickFromStudio:FireServer()
        StudioKickAllBtn.BackgroundColor3 = GlobalVariables.Gui.InvalidGreyColour
        StudioKickAllBtn.Text = "Wait..."
        task.wait(KICK_PLRS_COOLDOWN)
        kickAllDebounce = true
        StudioKickAllBtn.BackgroundColor3 = GlobalVariables.Gui.InvalidRedColour
        StudioKickAllBtn.Text = "Kick players"
    end
end)

Remotes.GUI.Studio.UpdateStudioList.OnClientEvent:Connect(function(userIdToUpdate: number, updateStatus: "add" | "remove" | "update", userStudioInfo)
    updateStudioListItem(userIdToUpdate, updateStatus, userStudioInfo)
end)

Remotes.Studio.VisitOtherStudio.OnClientEvent:Connect(function(_studioIndex, _interiorPlrTpPart, _exteriorPlrTpPart)
    GuiServices.HideGuiStandard(StudioListContainer, UDim2.new(visibleGuiPos.X.Scale, 0, visibleGuiPos.Y.Scale + GlobalVariables.Gui.MainGuiInvisiblePosOffset, 0), UDim2.new(visibleGuiSize.X.Scale, 0, visibleGuiSize.Y.Scale - 0.2, 0))
end)

Remotes.Studio.UpdateWhitelist.OnClientEvent:Connect(function(newWhitelistSetting)
    updateWhitelistBtn(newWhitelistSetting)
end)

humanoid.Died:Connect(function()
    localPlr:SetAttribute("IsAlive", false)
end)

localPlr.CharacterAdded:Connect(function(character: Model)
    localPlr:SetAttribute("IsAlive", true)
    char = character
    humanoid = char:WaitForChild("Humanoid")
    humanoid.Died:Connect(function()
        localPlr:SetAttribute("IsAlive", false)
    end)
end)