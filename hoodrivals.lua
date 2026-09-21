--========================================================
-- HOOD RIVALS - MOBILE COMBAT DEBUG SYSTEM
-- Delta Executor Version
--========================================================

--[[
    INSTRUCTIONS:
    1. Copy this entire script
    2. Open Delta Executor
    3. Paste and Execute
    
    Re-execution safe: will destroy old GUI and rebuild.
--]]

if not game:IsLoaded() then
    game.Loaded:Wait()
end

--========================================================
-- CLEANUP OLD INSTANCE (re-execution safe)
--========================================================

if _G.HoodRivalsCleanup then
    pcall(_G.HoodRivalsCleanup)
end

--========================================================
-- SERVICES
--========================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then
    return
end

local Camera = Workspace.CurrentCamera

--========================================================
-- GUI PARENT (Delta-friendly)
--========================================================

local function getGuiParent()
    -- Prefer gethui (Delta supports it) for better stealth + persistence
    if gethui then
        local ok, hui = pcall(gethui)
        if ok and hui then
            return hui
        end
    end

    -- Fallback to CoreGui (Delta Mobile often supports this)
    if game:GetService("CoreGui") then
        local ok, cg = pcall(function()
            return game:GetService("CoreGui")
        end)
        if ok and cg then
            return cg
        end
    end

    -- Last resort
    return LocalPlayer:WaitForChild("PlayerGui")
end

local GuiParent = getGuiParent()

--========================================================
-- SETTINGS
--========================================================

local Settings = {
    ESP = true,
    ESPHealth = true,
    ESPDistance = true,

    AimbotEnabled = false,
    AimFOV = 150,
    AimMaxDistance = 1000,
    AimPart = "Head",

    TeamCheck = true,
    VisibleCheck = true,

    Triggerbot = false,
    TriggerDelay = 0.08,

    Crosshair = true,
    FOVCircle = true,

    HoldToAim = false,
}

--========================================================
-- GUI
--========================================================

local Gui = Instance.new("ScreenGui")
Gui.Name = "HoodRivalsMobile_" .. tostring(math.random(1000,9999))
Gui.ResetOnSpawn = false
Gui.IgnoreGuiInset = true
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
if syn and syn.protect_gui then
    syn.protect_gui(Gui)
end
Gui.Parent = GuiParent

--========================================================
-- MENU
--========================================================

local Main = Instance.new("Frame")
Main.Size = UDim2.fromOffset(225, 310)
Main.Position = UDim2.new(0, 12, 0.5, -155)
Main.BackgroundColor3 = Color3.fromRGB(18,18,18)
Main.BackgroundTransparency = 0.08
Main.BorderSizePixel = 0
Main.Active = true
Main.Parent = Gui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0,12)
MainCorner.Parent = Main

local Padding = Instance.new("UIPadding")
Padding.PaddingTop = UDim.new(0,8)
Padding.PaddingLeft = UDim.new(0,8)
Padding.PaddingRight = UDim.new(0,8)
Padding.PaddingBottom = UDim.new(0,8)
Padding.Parent = Main

local Layout = Instance.new("UIListLayout")
Layout.Padding = UDim.new(0,6)
Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
Layout.SortOrder = Enum.SortOrder.LayoutOrder
Layout.Parent = Main

local Title = Instance.new("TextLabel")
Title.Size = UDim2.fromOffset(205,35)
Title.BackgroundTransparency = 1
Title.Text = "🔥 HOOD RIVALS"
Title.TextColor3 = Color3.new(1,1,1)
Title.TextSize = 18
Title.Font = Enum.Font.GothamBold
Title.LayoutOrder = 1
Title.Parent = Main

-- Drag support (mobile-friendly)
do
    local dragging, dragStart, startPos = false, nil, nil

    Title.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = Main.Position
        end
    end)

    Title.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            Main.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

local function createButton(text, order, callback)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.fromOffset(200,37)
    Button.BackgroundColor3 = Color3.fromRGB(38,38,38)
    Button.TextColor3 = Color3.new(1,1,1)
    Button.TextSize = 13
    Button.Font = Enum.Font.GothamBold
    Button.Text = text
    Button.AutoButtonColor = true
    Button.LayoutOrder = order
    Button.Parent = Main

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0,8)
    Corner.Parent = Button

    Button.Activated:Connect(callback)
    return Button
end

--========================================================
-- CUSTOM CROSSHAIR
--========================================================

local Crosshair = Instance.new("Frame")
Crosshair.Name = "CustomCrosshair"
Crosshair.AnchorPoint = Vector2.new(0.5,0.5)
Crosshair.Position = UDim2.fromScale(0.5,0.5)
Crosshair.Size = UDim2.fromOffset(34,34)
Crosshair.BackgroundTransparency = 1
Crosshair.Visible = Settings.Crosshair
Crosshair.Parent = Gui

local function crosshairLine(size, position)
    local Line = Instance.new("Frame")
    Line.Size = size
    Line.Position = position
    Line.AnchorPoint = Vector2.new(0.5,0.5)
    Line.BackgroundColor3 = Color3.new(1,1,1)
    Line.BorderSizePixel = 0
    Line.Parent = Crosshair

    local Stroke = Instance.new("UIStroke")
    Stroke.Thickness = 1
    Stroke.Color = Color3.new(0,0,0)
    Stroke.Parent = Line
end

crosshairLine(UDim2.fromOffset(12,2), UDim2.new(0.5,0,0,3))
crosshairLine(UDim2.fromOffset(12,2), UDim2.new(0.5,0,1,-3))
crosshairLine(UDim2.fromOffset(2,12), UDim2.new(0,3,0.5,0))
crosshairLine(UDim2.fromOffset(2,12), UDim2.new(1,-3,0.5,0))

local Dot = Instance.new("Frame")
Dot.Size = UDim2.fromOffset(4,4)
Dot.Position = UDim2.fromScale(0.5,0.5)
Dot.AnchorPoint = Vector2.new(0.5,0.5)
Dot.BackgroundColor3 = Color3.new(1,1,1)
Dot.BorderSizePixel = 0
Dot.Parent = Crosshair

local DotCorner = Instance.new("UICorner")
DotCorner.CornerRadius = UDim.new(1,0)
DotCorner.Parent = Dot

--========================================================
-- FOV CIRCLE
--========================================================

local FOV = Instance.new("Frame")
FOV.Name = "FOV"
FOV.AnchorPoint = Vector2.new(0.5,0.5)
FOV.Position = UDim2.fromScale(0.5,0.5)
FOV.Size = UDim2.fromOffset(Settings.AimFOV * 2, Settings.AimFOV * 2)
FOV.BackgroundTransparency = 1
FOV.BorderSizePixel = 0
FOV.Visible = Settings.FOVCircle
FOV.Parent = Gui

local FOVCorner = Instance.new("UICorner")
FOVCorner.CornerRadius = UDim.new(1,0)
FOVCorner.Parent = FOV

local FOVStroke = Instance.new("UIStroke")
FOVStroke.Thickness = 2
FOVStroke.Transparency = 0.15
FOVStroke.Parent = FOV

--========================================================
-- ESP
--========================================================

local ESPObjects = {}

local function removeESP(Player)
    local Data = ESPObjects[Player]
    if not Data then return end

    if Data.Highlight then Data.Highlight:Destroy() end
    if Data.Billboard then Data.Billboard:Destroy() end

    ESPObjects[Player] = nil
end

local function createESP(Player)
    if Player == LocalPlayer then return end

    removeESP(Player)

    local Character = Player.Character
    if not Character then return end

    local Root = Character:FindFirstChild("HumanoidRootPart")
    local Humanoid = Character:FindFirstChildOfClass("Humanoid")
    if not Root or not Humanoid then return end

    local Highlight = Instance.new("Highlight")
    Highlight.Name = "ESP"
    Highlight.Adornee = Character
    Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    Highlight.FillTransparency = 0.65
    Highlight.OutlineTransparency = 0
    Highlight.FillColor = Color3.fromRGB(255,50,50)
    Highlight.OutlineColor = Color3.new(1,1,1)
    Highlight.Enabled = Settings.ESP
    Highlight.Parent = Character

    local Billboard = Instance.new("BillboardGui")
    Billboard.Name = "ESPInfo"
    Billboard.Adornee = Root
    Billboard.Size = UDim2.fromOffset(200,60)
    Billboard.StudsOffset = Vector3.new(0,3,0)
    Billboard.AlwaysOnTop = true
    Billboard.Enabled = Settings.ESP
    Billboard.Parent = Gui

    local Info = Instance.new("TextLabel")
    Info.Size = UDim2.fromScale(1,1)
    Info.BackgroundTransparency = 1
    Info.TextColor3 = Color3.new(1,1,1)
    Info.TextStrokeTransparency = 0
    Info.TextSize = 13
    Info.Font = Enum.Font.GothamBold
    Info.Text = Player.DisplayName
    Info.Parent = Billboard

    ESPObjects[Player] = {
        Highlight = Highlight,
        Billboard = Billboard,
        Info = Info
    }
end

local function setupPlayer(Player)
    if Player == LocalPlayer then return end

    Player.CharacterAdded:Connect(function()
        task.wait(0.5)
        if Settings.ESP then
            createESP(Player)
        end
    end)

    if Player.Character then
        createESP(Player)
    end
end

for _,Player in ipairs(Players:GetPlayers()) do
    setupPlayer(Player)
end

Players.PlayerAdded:Connect(setupPlayer)
Players.PlayerRemoving:Connect(removeESP)

--========================================================
-- TEAM CHECK
--========================================================

local function isEnemy(Player)
    if Player == LocalPlayer then return false end
    if not Settings.TeamCheck then return true end

    if not LocalPlayer.Team or not Player.Team then
        return true
    end

    return LocalPlayer.Team ~= Player.Team
end

--========================================================
-- VISIBILITY
--========================================================

local function isVisible(Character, Part)
    if not Settings.VisibleCheck then return true end

    local Origin = Camera.CFrame.Position
    local Direction = Part.Position - Origin

    local Params = RaycastParams.new()
    Params.FilterType = Enum.RaycastFilterType.Exclude
    Params.FilterDescendantsInstances = {
        LocalPlayer.Character,
        Camera
    }

    local Result = Workspace:Raycast(Origin, Direction, Params)
    if not Result then return true end

    return Result.Instance:IsDescendantOf(Character)
end

--========================================================
-- FIND CLOSEST TARGET
--========================================================

local function getClosestTarget()
    local Closest = nil
    local ClosestDistance = math.huge

    local Center = Vector2.new(
        Camera.ViewportSize.X / 2,
        Camera.ViewportSize.Y / 2
    )

    for _,Player in ipairs(Players:GetPlayers()) do
        if Player ~= LocalPlayer and isEnemy(Player) then
            local Character = Player.Character
            if Character then
                local Humanoid = Character:FindFirstChildOfClass("Humanoid")
                local Root = Character:FindFirstChild("HumanoidRootPart")
                local Head = Character:FindFirstChild(Settings.AimPart)

                if Humanoid and Humanoid.Health > 0 and Root and Head then
                    local WorldDistance = (Root.Position - Camera.CFrame.Position).Magnitude

                    if WorldDistance <= Settings.AimMaxDistance then
                        local ScreenPosition, OnScreen = Camera:WorldToViewportPoint(Head.Position)

                        if OnScreen then
                            local ScreenDistance = (Vector2.new(ScreenPosition.X, ScreenPosition.Y) - Center).Magnitude

                            if ScreenDistance <= Settings.AimFOV then
                                if isVisible(Character, Head) then
                                    if ScreenDistance < ClosestDistance then
                                        ClosestDistance = ScreenDistance
                                        Closest = Player
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    return Closest
end

--========================================================
-- INSTANT HEAD LOCK
--========================================================

local function lockOntoHead(Player)
    if not Player then return end

    local Character = Player.Character
    if not Character then return end

    local Head = Character:FindFirstChild("Head")
    if not Head then return end

    Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, Head.Position)
end

--========================================================
-- AIM BUTTON
--========================================================

local Aiming = false

local AimTouch = Instance.new("TextButton")
AimTouch.Name = "AimButton"
AimTouch.Size = UDim2.fromOffset(78,78)
AimTouch.Position = UDim2.new(1,-100,1,-120)
AimTouch.BackgroundColor3 = Color3.fromRGB(30,30,30)
AimTouch.BackgroundTransparency = 0.1
AimTouch.Text = "AIM"
AimTouch.TextColor3 = Color3.new(1,1,1)
AimTouch.TextSize = 18
AimTouch.Font = Enum.Font.GothamBold
AimTouch.Parent = Gui

local AimCorner = Instance.new("UICorner")
AimCorner.CornerRadius = UDim.new(1,0)
AimCorner.Parent = AimTouch

AimTouch.Activated:Connect(function()
    if Settings.HoldToAim then
        Aiming = true
    else
        Aiming = not Aiming
    end
end)

--========================================================
-- TRIGGERBOT
--========================================================

local LastTrigger = 0

local function triggerShot()
    local WeaponSystem = LocalPlayer:FindFirstChild("WeaponSystem")
    if not WeaponSystem then return end

    local Fire = WeaponSystem:FindFirstChild("Fire")
    if Fire and Fire:IsA("RemoteEvent") then
        Fire:FireServer()
    end
end

local function triggerCheck()
    if not Settings.Triggerbot then return end

    local Viewport = Camera.ViewportSize
    local X = Viewport.X / 2
    local Y = Viewport.Y / 2

    local Ray = Camera:ViewportPointToRay(X, Y)

    local Params = RaycastParams.new()
    Params.FilterType = Enum.RaycastFilterType.Exclude
    Params.FilterDescendantsInstances = { LocalPlayer.Character }

    local Result = Workspace:Raycast(Ray.Origin, Ray.Direction * Settings.AimMaxDistance, Params)
    if not Result then return end

    local Character = Result.Instance:FindFirstAncestorOfClass("Model")
    if not Character then return end

    local Target = Players:GetPlayerFromCharacter(Character)
    if not Target then return end

    if not isEnemy(Target) then return end

    local Humanoid = Character:FindFirstChildOfClass("Humanoid")
    if not Humanoid or Humanoid.Health <= 0 then return end

    if os.clock() - LastTrigger < Settings.TriggerDelay then return end
    LastTrigger = os.clock()

    triggerShot()
end

--========================================================
-- BUTTONS
--========================================================

local ESPButton
ESPButton = createButton("ESP: ON", 2, function()
    Settings.ESP = not Settings.ESP
    ESPButton.Text = "ESP: " .. (Settings.ESP and "ON" or "OFF")

    for _,Data in pairs(ESPObjects) do
        if Data.Highlight then Data.Highlight.Enabled = Settings.ESP end
        if Data.Billboard then Data.Billboard.Enabled = Settings.ESP end
    end
end)

local AimButton
AimButton = createButton("AIMBOT: OFF", 3, function()
    Settings.AimbotEnabled = not Settings.AimbotEnabled
    AimButton.Text = "AIMBOT: " .. (Settings.AimbotEnabled and "ON" or "OFF")
end)

local TriggerButton
TriggerButton = createButton("TRIGGERBOT: OFF", 4, function()
    Settings.Triggerbot = not Settings.Triggerbot
    TriggerButton.Text = "TRIGGERBOT: " .. (Settings.Triggerbot and "ON" or "OFF")
end)

local FOVButton
FOVButton = createButton("FOV CIRCLE: ON", 5, function()
    Settings.FOVCircle = not Settings.FOVCircle
    FOV.Visible = Settings.FOVCircle
    FOVButton.Text = "FOV CIRCLE: " .. (Settings.FOVCircle and "ON" or "OFF")
end)

local CrosshairButton
CrosshairButton = createButton("CROSSHAIR: ON", 6, function()
    Settings.Crosshair = not Settings.Crosshair
    Crosshair.Visible = Settings.Crosshair
    CrosshairButton.Text = "CROSSHAIR: " .. (Settings.Crosshair and "ON" or "OFF")
end)

local TeamButton
TeamButton = createButton("TEAM CHECK: ON", 7, function()
    Settings.TeamCheck = not Settings.TeamCheck
    TeamButton.Text = "TEAM CHECK: " .. (Settings.TeamCheck and "ON" or "OFF")
end)

local VisibleButton
VisibleButton = createButton("VISIBLE ONLY: ON", 8, function()
    Settings.VisibleCheck = not Settings.VisibleCheck
    VisibleButton.Text = "VISIBLE ONLY: " .. (Settings.VisibleCheck and "ON" or "OFF")
end)

--========================================================
-- MAIN LOOP (connections stored for cleanup)
--========================================================

local Connections = {}

table.insert(Connections, RunService.RenderStepped:Connect(function()
    FOV.Size = UDim2.fromOffset(Settings.AimFOV * 2, Settings.AimFOV * 2)

    if Settings.AimbotEnabled and Aiming then
        local Target = getClosestTarget()
        if Target then
            lockOntoHead(Target)
        end
    end

    triggerCheck()

    for Player,Data in pairs(ESPObjects) do
        if Player.Character then
            local Humanoid = Player.Character:FindFirstChildOfClass("Humanoid")
            local Root = Player.Character:FindFirstChild("HumanoidRootPart")

            if Humanoid and Root then
                local Distance = (Root.Position - Camera.CFrame.Position).Magnitude
                local Text = Player.DisplayName

                if Settings.ESPHealth then
                    Text = Text .. "\nHP: " .. math.floor(Humanoid.Health)
                end

                if Settings.ESPDistance then
                    Text = Text .. "\n" .. math.floor(Distance) .. " studs"
                end

                Data.Info.Text = Text
            end
        end
    end
end))

--========================================================
-- AIM HOLD SUPPORT
--========================================================

table.insert(Connections, AimTouch.MouseButton1Down:Connect(function()
    if Settings.HoldToAim then
        Aiming = true
    end
end))

table.insert(Connections, AimTouch.MouseButton1Up:Connect(function()
    if Settings.HoldToAim then
        Aiming = false
    end
end))

--========================================================
-- PC TEST KEYS
--========================================================

table.insert(Connections, UserInputService.InputBegan:Connect(function(Input, Processed)
    if Processed then return end

    if Input.KeyCode == Enum.KeyCode.Q then
        Settings.AimbotEnabled = not Settings.AimbotEnabled
    end

    if Input.KeyCode == Enum.KeyCode.E then
        Settings.Triggerbot = not Settings.Triggerbot
    end
end))

--========================================================
-- CLEANUP FUNCTION (allows re-execution)
--========================================================

_G.HoodRivalsCleanup = function()
    for _, conn in ipairs(Connections) do
        pcall(function() conn:Disconnect() end)
    end
    for _,Data in pairs(ESPObjects) do
        if Data.Highlight then pcall(function() Data.Highlight:Destroy() end) end
        if Data.Billboard then pcall(function() Data.Billboard:Destroy() end) end
    end
    ESPObjects = {}
    if Gui then
        pcall(function() Gui:Destroy() end)
    end
end

--========================================================
-- MOBILE NOTIFICATION (Delta has notify)
--========================================================

if notify then
    pcall(function()
        notify("Hood Rivals", "Mobile combat system loaded ✅")
    end)
end

print("🔥 Hood Rivals mobile combat system loaded (Delta).")
