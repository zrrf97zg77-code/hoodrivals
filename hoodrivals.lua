--// HOOD RIVALS - MOBILE COMBAT UI
--// Put this LocalScript in StarterPlayer > StarterPlayerScripts

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

--==================================================
-- SETTINGS
--==================================================

local Settings = {
    -- Combat
    AimbotEnabled = false,
    AimFOV = 150,
    AimMaxDistance = 1000,
    AimPart = "Head",

    Triggerbot = false,
    TriggerDelay = 0.08,

    -- Visuals
    ESP = true,
    ESPHealth = true,
    ESPDistance = true,
    ESPTracers = false,

    FOVCircle = true,
    Crosshair = true,

    -- Safety / targeting
    TeamCheck = true,
    VisibleCheck = true,
}

--==================================================
-- GUI
--==================================================

local Gui = Instance.new("ScreenGui")
Gui.Name = "HoodRivalsMobile"
Gui.ResetOnSpawn = false
Gui.IgnoreGuiInset = true
Gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

--==================================================
-- COLORS
--==================================================

local BG = Color3.fromRGB(17, 17, 20)
local PANEL = Color3.fromRGB(23, 23, 27)
local CARD = Color3.fromRGB(30, 30, 35)
local CARD_HOVER = Color3.fromRGB(38, 38, 44)
local WHITE = Color3.fromRGB(245, 245, 245)
local MUTED = Color3.fromRGB(155, 155, 165)
local GREEN = Color3.fromRGB(70, 220, 125)
local RED = Color3.fromRGB(235, 75, 85)
local ACCENT = Color3.fromRGB(125, 95, 255)

--==================================================
-- HELPER FUNCTIONS
--==================================================

local function Corner(obj, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius)
    c.Parent = obj
    return c
end

local function Stroke(obj, color, thickness, transparency)
    local s = Instance.new("UIStroke")
    s.Color = color
    s.Thickness = thickness or 1
    s.Transparency = transparency or 0
    s.Parent = obj
    return s
end

local function MakeLabel(parent, text, size, color)
    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = color or WHITE
    label.TextSize = size or 14
    label.Font = Enum.Font.GothamMedium
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = parent
    return label
end

--==================================================
-- MAIN WINDOW
--==================================================

local Main = Instance.new("Frame")
Main.Name = "MainWindow"
Main.Size = UDim2.new(0, 340, 0, 420)
Main.Position = UDim2.new(0, 25, 0.5, -210)
Main.BackgroundColor3 = BG
Main.BackgroundTransparency = 0.04
Main.Parent = Gui

Corner(Main, 18)
Stroke(Main, Color3.fromRGB(60, 60, 70), 1, 0.35)

--==================================================
-- HEADER
--==================================================

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 62)
Header.BackgroundTransparency = 1
Header.Parent = Main

local Title = MakeLabel(Header, "🔥  HOOD RIVALS", 19, WHITE)
Title.Position = UDim2.new(0, 20, 0, 9)
Title.Size = UDim2.new(1, -75, 0, 25)

local Subtitle = MakeLabel(Header, "MOBILE CONTROL PANEL", 9, MUTED)
Subtitle.Position = UDim2.new(0, 21, 0, 34)
Subtitle.Size = UDim2.new(1, -80, 0, 16)

-- Close/minimize
local HideButton = Instance.new("TextButton")
HideButton.Size = UDim2.new(0, 38, 0, 38)
HideButton.Position = UDim2.new(1, -48, 0, 12)
HideButton.BackgroundColor3 = CARD
HideButton.Text = "—"
HideButton.TextColor3 = WHITE
HideButton.TextSize = 20
HideButton.Font = Enum.Font.GothamBold
HideButton.Parent = Header

Corner(HideButton, 12)

--==================================================
-- TAB BAR
--==================================================

local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(1, -24, 0, 42)
TabBar.Position = UDim2.new(0, 12, 0, 62)
TabBar.BackgroundColor3 = PANEL
TabBar.Parent = Main

Corner(TabBar, 12)

local TabLayout = Instance.new("UIListLayout")
TabLayout.FillDirection = Enum.FillDirection.Horizontal
TabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
TabLayout.VerticalAlignment = Enum.VerticalAlignment.Center
TabLayout.Padding = UDim.new(0, 5)
TabLayout.Parent = TabBar

local CombatTab = Instance.new("TextButton")
local VisualTab = Instance.new("TextButton")
local SettingsTab = Instance.new("TextButton")

local function SetupTab(button, text)
    button.Size = UDim2.new(0, 94, 0, 32)
    button.BackgroundTransparency = 1
    button.Text = text
    button.TextColor3 = MUTED
    button.TextSize = 11
    button.Font = Enum.Font.GothamBold
    button.AutoButtonColor = false
    button.Parent = TabBar
    Corner(button, 9)
end

SetupTab(CombatTab, "🎯 COMBAT")
SetupTab(VisualTab, "👁 VISUALS")
SetupTab(SettingsTab, "⚙ SETTINGS")

--==================================================
-- CONTENT
--==================================================

local Content = Instance.new("ScrollingFrame")
Content.Size = UDim2.new(1, -24, 1, -116)
Content.Position = UDim2.new(0, 12, 0, 110)
Content.BackgroundTransparency = 1
Content.BorderSizePixel = 0
Content.ScrollBarThickness = 3
Content.ScrollBarImageColor3 = ACCENT
Content.CanvasSize = UDim2.new(0, 0, 0, 0)
Content.Parent = Main

local Layout = Instance.new("UIListLayout")
Layout.Padding = UDim.new(0, 8)
Layout.Parent = Content

local Padding = Instance.new("UIPadding")
Padding.PaddingBottom = UDim.new(0, 10)
Padding.Parent = Content

--==================================================
-- TOGGLE CREATOR
--==================================================

local function CreateToggle(text, description, settingName)

    local Card = Instance.new("TextButton")
    Card.Size = UDim2.new(1, -4, 0, 58)
    Card.BackgroundColor3 = CARD
    Card.Text = ""
    Card.AutoButtonColor = false
    Card.Parent = Content

    Corner(Card, 13)

    local Name = MakeLabel(Card, text, 13, WHITE)
    Name.Position = UDim2.new(0, 14, 0, 8)
    Name.Size = UDim2.new(1, -75, 0, 19)

    local Desc = MakeLabel(Card, description, 9, MUTED)
    Desc.Position = UDim2.new(0, 14, 0, 30)
    Desc.Size = UDim2.new(1, -75, 0, 16)

    local Toggle = Instance.new("Frame")
    Toggle.Size = UDim2.new(0, 43, 0, 24)
    Toggle.Position = UDim2.new(1, -57, 0.5, -12)
    Toggle.BackgroundColor3 = Color3.fromRGB(55, 55, 60)
    Toggle.Parent = Card

    Corner(Toggle, 20)

    local Knob = Instance.new("Frame")
    Knob.Size = UDim2.new(0, 18, 0, 18)
    Knob.Position = UDim2.new(0, 3, 0.5, -9)
    Knob.BackgroundColor3 = Color3.fromRGB(190, 190, 195)
    Knob.Parent = Toggle

    Corner(Knob, 20)

    local function Update()
        if Settings[settingName] then
            Toggle.BackgroundColor3 = GREEN
            Knob.Position = UDim2.new(1, -21, 0.5, -9)
            Knob.BackgroundColor3 = WHITE
        else
            Toggle.BackgroundColor3 = Color3.fromRGB(55, 55, 60)
            Knob.Position = UDim2.new(0, 3, 0.5, -9)
            Knob.BackgroundColor3 = Color3.fromRGB(190, 190, 195)
        end
    end

    Card.Activated:Connect(function()
        Settings[settingName] = not Settings[settingName]
        Update()
    end)

    Update()

    return Card
end

--==================================================
-- SLIDER
--==================================================

local function CreateSlider(text, settingName, minValue, maxValue)

    local Card = Instance.new("Frame")
    Card.Size = UDim2.new(1, -4, 0, 65)
    Card.BackgroundColor3 = CARD
    Card.Parent = Content

    Corner(Card, 13)

    local Name = MakeLabel(Card, text, 12, WHITE)
    Name.Position = UDim2.new(0, 14, 0, 8)
    Name.Size = UDim2.new(0.7, 0, 0, 18)

    local Value = MakeLabel(Card, tostring(Settings[settingName]), 11, ACCENT)
    Value.Position = UDim2.new(1, -70, 0, 8)
    Value.Size = UDim2.new(0, 55, 0, 18)
    Value.TextXAlignment = Enum.TextXAlignment.Right

    local Bar = Instance.new("Frame")
    Bar.Size = UDim2.new(1, -28, 0, 6)
    Bar.Position = UDim2.new(0, 14, 0, 42)
    Bar.BackgroundColor3 = Color3.fromRGB(55, 55, 62)
    Bar.Parent = Card

    Corner(Bar, 10)

    local Fill = Instance.new("Frame")
    Fill.BackgroundColor3 = ACCENT
    Fill.Size = UDim2.new(
        (Settings[settingName] - minValue) / (maxValue - minValue),
        0,
        1,
        0
    )
    Fill.Parent = Bar

    Corner(Fill, 10)

    local dragging = false

    local function UpdateSlider(inputX)
        local percent = math.clamp(
            (inputX - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X,
            0,
            1
        )

        local value = math.floor(
            minValue + ((maxValue - minValue) * percent)
        )

        Settings[settingName] = value

        Fill.Size = UDim2.new(percent, 0, 1, 0)
        Value.Text = tostring(value)
    end

    Bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch
        or input.UserInputType == Enum.UserInputType.MouseButton1 then

            dragging = true
            UpdateSlider(input.Position.X)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging then
            if input.UserInputType == Enum.UserInputType.Touch
            or input.UserInputType == Enum.UserInputType.MouseMovement then

                UpdateSlider(input.Position.X)
            end
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch
        or input.UserInputType == Enum.UserInputType.MouseButton1 then

            dragging = false
        end
    end)

    return Card
end

--==================================================
-- DROPDOWN
--==================================================

local function CreateDropdown(text, settingName, options)

    local Card = Instance.new("TextButton")
    Card.Size = UDim2.new(1, -4, 0, 54)
    Card.BackgroundColor3 = CARD
    Card.Text = ""
    Card.AutoButtonColor = false
    Card.Parent = Content

    Corner(Card, 13)

    local Name = MakeLabel(Card, text, 12, WHITE)
    Name.Position = UDim2.new(0, 14, 0, 9)
    Name.Size = UDim2.new(0.55, 0, 0, 20)

    local Current = MakeLabel(Card, Settings[settingName], 11, ACCENT)
    Current.Position = UDim2.new(0.55, 0, 0, 9)
    Current.Size = UDim2.new(0.35, 0, 0, 20)
    Current.TextXAlignment = Enum.TextXAlignment.Right

    local Index = table.find(options, Settings[settingName]) or 1

    Card.Activated:Connect(function()
        Index += 1

        if Index > #options then
            Index = 1
        end

        Settings[settingName] = options[Index]
        Current.Text = options[Index]
    end)

    return Card
end

--==================================================
-- BUILD COMBAT TAB
--==================================================

local function ClearContent()
    for _, child in ipairs(Content:GetChildren()) do
        if child:IsA("GuiObject") then
            child:Destroy()
        end
    end
end

local function BuildCombat()

    ClearContent()

    CreateToggle(
        "Aimbot",
        "Instantly lock onto the selected target",
        "AimbotEnabled"
    )

    CreateSlider(
        "Aim FOV",
        "AimFOV",
        25,
        500
    )

    CreateDropdown(
        "Aim Part",
        "AimPart",
        {"Head", "UpperTorso", "HumanoidRootPart"}
    )

    CreateSlider(
        "Max Distance",
        "AimMaxDistance",
        100,
        3000
    )

    CreateToggle(
        "Triggerbot",
        "Fire when the crosshair is over an enemy",
        "Triggerbot"
    )

    CreateSlider(
        "Trigger Delay",
        "TriggerDelay",
        0,
        50
    )
end

--==================================================
-- BUILD VISUALS TAB
--==================================================

local function BuildVisuals()

    ClearContent()

    CreateToggle(
        "ESP",
        "Show enemy information",
        "ESP"
    )

    CreateToggle(
        "Health",
        "Display player health",
        "ESPHealth"
    )

    CreateToggle(
        "Distance",
        "Display player distance",
        "ESPDistance"
    )

    CreateToggle(
        "Tracers",
        "Draw lines toward players",
        "ESPTracers"
    )

    CreateToggle(
        "FOV Circle",
        "Show your current aim radius",
        "FOVCircle"
    )

    CreateToggle(
        "Crosshair",
        "Show the center crosshair",
        "Crosshair"
    )
end

--==================================================
-- BUILD SETTINGS TAB
--==================================================

local function BuildSettings()

    ClearContent()

    CreateToggle(
        "Team Check",
        "Ignore players on your team",
        "TeamCheck"
    )

    CreateToggle(
        "Visible Only",
        "Ignore targets behind walls",
        "VisibleCheck"
    )
end

--==================================================
-- TAB LOGIC
--==================================================

local function SelectTab(tab)
    CombatTab.BackgroundTransparency = 1
    VisualTab.BackgroundTransparency = 1
    SettingsTab.BackgroundTransparency = 1

    CombatTab.TextColor3 = MUTED
    VisualTab.TextColor3 = MUTED
    SettingsTab.TextColor3 = MUTED

    if tab == "Combat" then
        CombatTab.BackgroundColor3 = ACCENT
        CombatTab.BackgroundTransparency = 0
        CombatTab.TextColor3 = WHITE
        BuildCombat()

    elseif tab == "Visuals" then
        VisualTab.BackgroundColor3 = ACCENT
        VisualTab.BackgroundTransparency = 0
        VisualTab.TextColor3 = WHITE
        BuildVisuals()

    elseif tab == "Settings" then
        SettingsTab.BackgroundColor3 = ACCENT
        SettingsTab.BackgroundTransparency = 0
        SettingsTab.TextColor3 = WHITE
        BuildSettings()
    end

    task.wait()
    Content.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 15)
end

CombatTab.Activated:Connect(function()
    SelectTab("Combat")
end)

VisualTab.Activated:Connect(function()
    SelectTab("Visuals")
end)

SettingsTab.Activated:Connect(function()
    SelectTab("Settings")
end)

SelectTab("Combat")

--==================================================
-- MENU TOGGLE BUTTON
--==================================================

local MenuButton = Instance.new("TextButton")
MenuButton.Name = "MenuButton"
MenuButton.Size = UDim2.new(0, 48, 0, 48)
MenuButton.Position = UDim2.new(0, 18, 0, 90)
MenuButton.BackgroundColor3 = BG
MenuButton.Text = "🔥"
MenuButton.TextSize = 21
MenuButton.Font = Enum.Font.GothamBold
MenuButton.TextColor3 = WHITE
MenuButton.Visible = false
MenuButton.Parent = Gui

Corner(MenuButton, 15)
Stroke(MenuButton, Color3.fromRGB(70, 70, 80), 1, 0.3)

HideButton.Activated:Connect(function()
    Main.Visible = false
    MenuButton.Visible = true
end)

MenuButton.Activated:Connect(function()
    Main.Visible = true
    MenuButton.Visible = false
end)

--==================================================
-- DRAGGABLE MOBILE WINDOW
--==================================================

local dragging = false
local dragStart
local startPosition

Header.InputBegan:Connect(function(input)

    if input.UserInputType == Enum.UserInputType.Touch
    or input.UserInputType == Enum.UserInputType.MouseButton1 then

        dragging = true
        dragStart = input.Position
        startPosition = Main.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)

    if not dragging then
        return
    end

    if input.UserInputType == Enum.UserInputType.Touch
    or input.UserInputType == Enum.UserInputType.MouseMovement then

        local delta = input.Position - dragStart

        Main.Position = UDim2.new(
            startPosition.X.Scale,
            startPosition.X.Offset + delta.X,
            startPosition.Y.Scale,
            startPosition.Y.Offset + delta.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(input)

    if input.UserInputType == Enum.UserInputType.Touch
    or input.UserInputType == Enum.UserInputType.MouseButton1 then

        dragging = false
    end
end)

--==================================================
-- CROSSHAIR
--==================================================

local Crosshair = Instance.new("Frame")
Crosshair.Name = "Crosshair"
Crosshair.Size = UDim2.new(0, 30, 0, 30)
Crosshair.AnchorPoint = Vector2.new(0.5, 0.5)
Crosshair.Position = UDim2.new(0.5, 0, 0.5, 0)
Crosshair.BackgroundTransparency = 1
Crosshair.Parent = Gui

local function CrossBar(size, position)
    local bar = Instance.new("Frame")
    bar.Size = size
    bar.Position = position
    bar.BackgroundColor3 = WHITE
    bar.BorderSizePixel = 0
    bar.Parent = Crosshair
    Corner(bar, 2)
end

CrossBar(UDim2.new(0, 3, 0, 10), UDim2.new(0.5, -1, 0, 0))
CrossBar(UDim2.new(0, 3, 0, 10), UDim2.new(0.5, -1, 1, -10))
CrossBar(UDim2.new(0, 10, 0, 3), UDim2.new(0, 0, 0.5, -1))
CrossBar(UDim2.new(0, 10, 0, 3), UDim2.new(1, -10, 0.5, -1))

local Dot = Instance.new("Frame")
Dot.Size = UDim2.new(0, 4, 0, 4)
Dot.Position = UDim2.new(0.5, -2, 0.5, -2)
Dot.BackgroundColor3 = WHITE
Dot.BorderSizePixel = 0
Dot.Parent = Crosshair

Corner(Dot, 5)

--==================================================
-- FOV CIRCLE
--==================================================

local FOVCircle = Instance.new("Frame")
FOVCircle.Name = "FOVCircle"
FOVCircle.AnchorPoint = Vector2.new(0.5, 0.5)
FOVCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
FOVCircle.BackgroundTransparency = 1
FOVCircle.Parent = Gui

Corner(FOVCircle, 999)
Stroke(FOVCircle, ACCENT, 2, 0.25)

--==================================================
-- TARGETING
--==================================================

local function IsEnemy(player)

    if player == LocalPlayer then
        return false
    end

    if not Settings.TeamCheck then
        return true
    end

    if not LocalPlayer.Team or not player.Team then
        return true
    end

    return LocalPlayer.Team ~= player.Team
end

local function IsVisible(part)

    if not Settings.VisibleCheck then
        return true
    end

    if not part then
        return false
    end

    local origin = Camera.CFrame.Position
    local direction = part.Position - origin

    local Params = RaycastParams.new()
    Params.FilterType = Enum.RaycastFilterType.Exclude

    Params.FilterDescendantsInstances = {
        LocalPlayer.Character,
        Camera
    }

    local Result = Workspace:Raycast(
        origin,
        direction,
        Params
    )

    if not Result then
        return true
    end

    return Result.Instance:IsDescendantOf(part.Parent)
end

local function GetTarget()

    local bestTarget = nil
    local bestDistance = Settings.AimFOV

    local viewport = Camera.ViewportSize
    local center = Vector2.new(
        viewport.X / 2,
        viewport.Y / 2
    )

    for _, player in ipairs(Players:GetPlayers()) do

        if not IsEnemy(player) then
            continue
        end

        local character = player.Character

        if not character then
            continue
        end

        local humanoid =
            character:FindFirstChildOfClass("Humanoid")

        if not humanoid or humanoid.Health <= 0 then
            continue
        end

        local part = character:FindFirstChild(Settings.AimPart)

        if not part then
            continue
        end

        local distance3D =
            (Camera.CFrame.Position - part.Position).Magnitude

        if distance3D > Settings.AimMaxDistance then
            continue
        end

        if not IsVisible(part) then
            continue
        end

        local screenPosition, onScreen =
            Camera:WorldToViewportPoint(part.Position)

        if not onScreen then
            continue
        end

        local distance2D =
            (Vector2.new(
                screenPosition.X,
                screenPosition.Y
            ) - center).Magnitude

        if distance2D <= bestDistance then
            bestDistance = distance2D
            bestTarget = part
        end
    end

    return bestTarget
end

--==================================================
-- AIMBOT
--==================================================

local function RunAimbot()

    -- IMPORTANT:
    -- No separate mobile AIM button.
    -- This is controlled ONLY by Settings.AimbotEnabled.

    if not Settings.AimbotEnabled then
        return
    end

    local target = GetTarget()

    if not target then
        return
    end

    Camera.CFrame = CFrame.lookAt(
        Camera.CFrame.Position,
        target.Position
    )
end

--==================================================
-- TRIGGERBOT
--==================================================

local LastTrigger = 0

local function TriggerShot()

    -- CHANGE THIS TO YOUR GAME'S ACTUAL WEAPON SYSTEM.
    --
    -- Example:
    -- local WeaponSystem = LocalPlayer:FindFirstChild("WeaponSystem")
    -- local Fire = WeaponSystem and WeaponSystem:FindFirstChild("Fire")
    --
    -- if Fire and Fire:IsA("RemoteEvent") then
    --     Fire:FireServer()
    -- end

    local WeaponSystem =
        LocalPlayer:FindFirstChild("WeaponSystem")

    if not WeaponSystem then
        return
    end

    local Fire =
        WeaponSystem:FindFirstChild("Fire")

    if Fire and Fire:IsA("RemoteEvent") then
        Fire:FireServer()
    end
end

local function TriggerCheck()

    if not Settings.Triggerbot then
        return
    end

    local viewport = Camera.ViewportSize

    local center = Vector2.new(
        viewport.X / 2,
        viewport.Y / 2
    )

    local ray =
        Camera:ViewportPointToRay(
            center.X,
            center.Y
        )

    local Params = RaycastParams.new()
    Params.FilterType = Enum.RaycastFilterType.Exclude

    Params.FilterDescendantsInstances = {
        LocalPlayer.Character
    }

    local Result = Workspace:Raycast(
        ray.Origin,
        ray.Direction * Settings.AimMaxDistance,
        Params
    )

    if not Result then
        return
    end

    local Character =
        Result.Instance:FindFirstAncestorOfClass("Model")

    if not Character then
        return
    end

    local TargetPlayer =
        Players:GetPlayerFromCharacter(Character)

    if not TargetPlayer then
        return
    end

    if not IsEnemy(TargetPlayer) then
        return
    end

    local Humanoid =
        Character:FindFirstChildOfClass("Humanoid")

    if not Humanoid or Humanoid.Health <= 0 then
        return
    end

    if os.clock() - LastTrigger < Settings.TriggerDelay then
        return
    end

    LastTrigger = os.clock()

    TriggerShot()
end

--==================================================
-- ESP
--==================================================

local ESPObjects = {}

local function RemoveESP(player)

    if ESPObjects[player] then

        for _, object in pairs(ESPObjects[player]) do
            if object and object.Parent then
                object:Destroy()
            end
        end

        ESPObjects[player] = nil
    end
end

local function CreateESP(player)

    if player == LocalPlayer then
        return
    end

    RemoveESP(player)

    local character = player.Character

    if not character then
        return
    end

    local head = character:FindFirstChild("Head")

    if not head then
        return
    end

    local objects = {}

    local highlight = Instance.new("Highlight")
    highlight.Name = "HR_ESP"
    highlight.Adornee = character
    highlight.FillTransparency = 0.85
    highlight.OutlineTransparency = 0
    highlight.OutlineColor = Color3.fromRGB(255, 80, 80)
    highlight.Parent = character

    table.insert(objects, highlight)

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "HR_Info"
    billboard.Adornee = head
    billboard.Size = UDim2.new(0, 170, 0, 65)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = head

    table.insert(objects, billboard)

    local info = Instance.new("TextLabel")
    info.Size = UDim2.new(1, 0, 1, 0)
    info.BackgroundTransparency = 1
    info.TextColor3 = WHITE
    info.TextStrokeTransparency = 0
    info.TextSize = 12
    info.Font = Enum.Font.GothamBold
    info.TextWrapped = true
    info.Parent = billboard

    table.insert(objects, info)

    ESPObjects[player] = {
        Objects = objects,
        Info = info,
    }
end

local function UpdateESP()

    for _, player in ipairs(Players:GetPlayers()) do

        if player == LocalPlayer then
            continue
        end

        if not Settings.ESP then
            RemoveESP(player)
            continue
        end

        if not IsEnemy(player) then
            RemoveESP(player)
            continue
        end

        local character = player.Character

        if not character then
            RemoveESP(player)
            continue
        end

        local humanoid =
            character:FindFirstChildOfClass("Humanoid")

        local head =
            character:FindFirstChild("Head")

        if not humanoid or not head then
            continue
        end

        if not ESPObjects[player] then
            CreateESP(player)
        end

        local data = ESPObjects[player]

        if data and data.Info then

            local text = player.DisplayName

            if Settings.ESPHealth then
                text ..= "\nHP: " .. math.floor(humanoid.Health)
            end

            if Settings.ESPDistance then

                local distance =
                    math.floor(
                        (Camera.CFrame.Position - head.Position).Magnitude
                    )

                text ..= "\n" .. distance .. " studs"
            end

            data.Info.Text = text
        end
    end
end

--==================================================
-- PLAYER CONNECTIONS
--==================================================

local function SetupPlayer(player)

    player.CharacterAdded:Connect(function()
        task.wait(0.5)

        if Settings.ESP then
            CreateESP(player)
        end
    end)
end

for _, player in ipairs(Players:GetPlayers()) do
    SetupPlayer(player)
end

Players.PlayerAdded:Connect(SetupPlayer)

Players.PlayerRemoving:Connect(function(player)
    RemoveESP(player)
end)

--==================================================
-- MAIN LOOP
--==================================================

local ESPTimer = 0

RunService.RenderStepped:Connect(function()

    -- FOV circle
    local diameter = Settings.AimFOV * 2

    FOVCircle.Size = UDim2.new(
        0,
        diameter,
        0,
        diameter
    )

    FOVCircle.Visible = Settings.FOVCircle

    -- Crosshair
    Crosshair.Visible = Settings.Crosshair

    -- Aimbot
    RunAimbot()

    -- Triggerbot
    TriggerCheck()

    -- ESP
    ESPTimer += 1

    if ESPTimer >= 5 then
        ESPTimer = 0
        UpdateESP()
    end
end)

--==================================================
-- CLEANUP
--==================================================

Gui.Destroying:Connect(function()

    for player in pairs(ESPObjects) do
        RemoveESP(player)
    end
end)
