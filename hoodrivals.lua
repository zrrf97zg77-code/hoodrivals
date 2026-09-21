--==================================================
-- IVORY
-- Hood Rivals - Mobile Combat UI
-- LocalScript
-- StarterPlayer > StarterPlayerScripts
--==================================================

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
    AimbotEnabled = false,

    AimFOV = 150,
    AimMaxDistance = 1000,
    AimPart = "Head",

    Triggerbot = false,
    TriggerDelay = 0.08,

    ESP = true,
    ESPHealth = true,
    ESPDistance = true,
    ESPTracers = false,

    FOVCircle = true,
    Crosshair = true,

    TeamCheck = true,
    VisibleCheck = true,
}

--==================================================
-- GUI
--==================================================

local Gui = Instance.new("ScreenGui")
Gui.Name = "Ivory"
Gui.ResetOnSpawn = false
Gui.IgnoreGuiInset = true
Gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

--==================================================
-- COLORS
--==================================================

local BG = Color3.fromRGB(16,16,19)
local PANEL = Color3.fromRGB(22,22,26)
local CARD = Color3.fromRGB(29,29,34)
local WHITE = Color3.fromRGB(245,245,245)
local MUTED = Color3.fromRGB(150,150,160)
local GREEN = Color3.fromRGB(70,220,125)
local ACCENT = Color3.fromRGB(125,95,255)

--==================================================
-- HELPERS
--==================================================

local function Corner(obj, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius)
    c.Parent = obj
end

local function Stroke(obj, color, thickness, transparency)
    local s = Instance.new("UIStroke")
    s.Color = color
    s.Thickness = thickness or 1
    s.Transparency = transparency or 0
    s.Parent = obj
end

local function Label(parent, text, size, color)
    local l = Instance.new("TextLabel")
    l.BackgroundTransparency = 1
    l.Text = text
    l.TextColor3 = color or WHITE
    l.TextSize = size or 13
    l.Font = Enum.Font.GothamMedium
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = parent
    return l
end

--==================================================
-- MAIN WINDOW
--==================================================

local Main = Instance.new("Frame")
Main.Name = "IvoryWindow"
Main.Size = UDim2.new(0,280,0,350)
Main.Position = UDim2.new(0,18,0.5,-175)
Main.BackgroundColor3 = BG
Main.BackgroundTransparency = 0.03
Main.Parent = Gui

Corner(Main,16)
Stroke(Main,Color3.fromRGB(65,65,75),1,0.35)

--==================================================
-- HEADER
--==================================================

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1,0,0,52)
Header.BackgroundTransparency = 1
Header.Parent = Main

local Title = Label(Header,"🔥  IVORY",16,WHITE)
Title.Position = UDim2.new(0,16,0,7)
Title.Size = UDim2.new(1,-65,0,22)

local Subtitle = Label(Header,"MOBILE CONTROL PANEL",8,MUTED)
Subtitle.Position = UDim2.new(0,17,0,29)
Subtitle.Size = UDim2.new(1,-70,0,13)

local HideButton = Instance.new("TextButton")
HideButton.Size = UDim2.new(0,34,0,34)
HideButton.Position = UDim2.new(1,-44,0,9)
HideButton.BackgroundColor3 = CARD
HideButton.Text = "—"
HideButton.TextColor3 = WHITE
HideButton.TextSize = 18
HideButton.Font = Enum.Font.GothamBold
HideButton.Parent = Header

Corner(HideButton,10)

--==================================================
-- TAB BAR
--==================================================

local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(1,-20,0,36)
TabBar.Position = UDim2.new(0,10,0,52)
TabBar.BackgroundColor3 = PANEL
TabBar.Parent = Main

Corner(TabBar,10)

local TabLayout = Instance.new("UIListLayout")
TabLayout.FillDirection = Enum.FillDirection.Horizontal
TabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
TabLayout.VerticalAlignment = Enum.VerticalAlignment.Center
TabLayout.Padding = UDim.new(0,3)
TabLayout.Parent = TabBar

local function MakeTab(text)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0,82,0,28)
    button.BackgroundTransparency = 1
    button.Text = text
    button.TextColor3 = MUTED
    button.TextSize = 9
    button.Font = Enum.Font.GothamBold
    button.AutoButtonColor = false
    button.Parent = TabBar

    Corner(button,8)

    return button
end

local CombatTab = MakeTab("🎯 COMBAT")
local VisualTab = MakeTab("👁 VISUALS")
local SettingsTab = MakeTab("⚙ SETTINGS")

--==================================================
-- CONTENT
--==================================================

local Content = Instance.new("ScrollingFrame")
Content.Size = UDim2.new(1,-20,1,-96)
Content.Position = UDim2.new(0,10,0,94)
Content.BackgroundTransparency = 1
Content.BorderSizePixel = 0
Content.ScrollBarThickness = 2
Content.ScrollBarImageColor3 = ACCENT
Content.CanvasSize = UDim2.new(0,0,0,0)
Content.Parent = Main

local Layout = Instance.new("UIListLayout")
Layout.Padding = UDim.new(0,6)
Layout.Parent = Content

local Padding = Instance.new("UIPadding")
Padding.PaddingBottom = UDim.new(0,8)
Padding.Parent = Content

--==================================================
-- TOGGLE
--==================================================

local function CreateToggle(text,description,settingName)

    local Card = Instance.new("TextButton")
    Card.Size = UDim2.new(1,-4,0,48)
    Card.BackgroundColor3 = CARD
    Card.Text = ""
    Card.AutoButtonColor = false
    Card.Parent = Content

    Corner(Card,11)

    local Name = Label(Card,text,11,WHITE)
    Name.Position = UDim2.new(0,12,0,5)
    Name.Size = UDim2.new(1,-70,0,17)

    local Desc = Label(Card,description,8,MUTED)
    Desc.Position = UDim2.new(0,12,0,25)
    Desc.Size = UDim2.new(1,-70,0,13)

    local Toggle = Instance.new("Frame")
    Toggle.Size = UDim2.new(0,38,0,21)
    Toggle.Position = UDim2.new(1,-50,0.5,-10)
    Toggle.BackgroundColor3 = Color3.fromRGB(55,55,60)
    Toggle.Parent = Card

    Corner(Toggle,20)

    local Knob = Instance.new("Frame")
    Knob.Size = UDim2.new(0,15,0,15)
    Knob.Position = UDim2.new(0,3,0.5,-7)
    Knob.BackgroundColor3 = Color3.fromRGB(190,190,195)
    Knob.Parent = Toggle

    Corner(Knob,20)

    local function Update()

        if Settings[settingName] then
            Toggle.BackgroundColor3 = GREEN
            Knob.Position = UDim2.new(1,-18,0.5,-7)
            Knob.BackgroundColor3 = WHITE
        else
            Toggle.BackgroundColor3 = Color3.fromRGB(55,55,60)
            Knob.Position = UDim2.new(0,3,0.5,-7)
            Knob.BackgroundColor3 = Color3.fromRGB(190,190,195)
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

local function CreateSlider(text,settingName,minValue,maxValue)

    local Card = Instance.new("Frame")
    Card.Size = UDim2.new(1,-4,0,56)
    Card.BackgroundColor3 = CARD
    Card.Parent = Content

    Corner(Card,11)

    local Name = Label(Card,text,10,WHITE)
    Name.Position = UDim2.new(0,12,0,6)
    Name.Size = UDim2.new(.7,0,0,16)

    local Value = Label(Card,tostring(Settings[settingName]),9,ACCENT)
    Value.Position = UDim2.new(1,-55,0,6)
    Value.Size = UDim2.new(0,43,0,16)
    Value.TextXAlignment = Enum.TextXAlignment.Right

    local Bar = Instance.new("Frame")
    Bar.Size = UDim2.new(1,-24,0,5)
    Bar.Position = UDim2.new(0,12,0,36)
    Bar.BackgroundColor3 = Color3.fromRGB(55,55,62)
    Bar.Parent = Card

    Corner(Bar,10)

    local Fill = Instance.new("Frame")
    Fill.BackgroundColor3 = ACCENT
    Fill.Size = UDim2.new(
        (Settings[settingName]-minValue)/(maxValue-minValue),
        0,1,0
    )
    Fill.Parent = Bar

    Corner(Fill,10)

    local dragging = false

    local function UpdateSlider(x)

        local percent = math.clamp(
            (x-Bar.AbsolutePosition.X)/Bar.AbsoluteSize.X,
            0,1
        )

        local value = math.floor(
            minValue+((maxValue-minValue)*percent)
        )

        Settings[settingName] = value

        Fill.Size = UDim2.new(percent,0,1,0)
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

        if not dragging then
            return
        end

        if input.UserInputType == Enum.UserInputType.Touch
        or input.UserInputType == Enum.UserInputType.MouseMovement then

            UpdateSlider(input.Position.X)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)

        if input.UserInputType == Enum.UserInputType.Touch
        or input.UserInputType == Enum.UserInputType.MouseButton1 then

            dragging = false
        end
    end)
end

--==================================================
-- DROPDOWN
--==================================================

local function CreateDropdown(text,settingName,options)

    local Card = Instance.new("TextButton")
    Card.Size = UDim2.new(1,-4,0,45)
    Card.BackgroundColor3 = CARD
    Card.Text = ""
    Card.AutoButtonColor = false
    Card.Parent = Content

    Corner(Card,11)

    local Name = Label(Card,text,10,WHITE)
    Name.Position = UDim2.new(0,12,0,7)
    Name.Size = UDim2.new(.55,0,0,20)

    local Current = Label(Card,Settings[settingName],9,ACCENT)
    Current.Position = UDim2.new(.55,0,0,7)
    Current.Size = UDim2.new(.35,0,0,20)
    Current.TextXAlignment = Enum.TextXAlignment.Right

    local Index = table.find(options,Settings[settingName]) or 1

    Card.Activated:Connect(function()

        Index += 1

        if Index > #options then
            Index = 1
        end

        Settings[settingName] = options[Index]
        Current.Text = options[Index]
    end)
end

--==================================================
-- CONTENT CLEAR
--==================================================

local function ClearContent()

    for _,child in ipairs(Content:GetChildren()) do

        if child:IsA("GuiObject") then
            child:Destroy()
        end
    end
end

--==================================================
-- COMBAT TAB
--==================================================

local function BuildCombat()

    ClearContent()

    CreateToggle(
        "Aimbot",
        "Instant target lock",
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
        {"Head","UpperTorso","HumanoidRootPart"}
    )

    CreateSlider(
        "Max Distance",
        "AimMaxDistance",
        100,
        3000
    )

    CreateToggle(
        "Triggerbot",
        "Fire when crosshair is on target",
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
-- VISUALS TAB
--==================================================

local function BuildVisuals()

    ClearContent()

    CreateToggle(
        "ESP",
        "Player information",
        "ESP"
    )

    CreateToggle(
        "Health",
        "Show player health",
        "ESPHealth"
    )

    CreateToggle(
        "Distance",
        "Show player distance",
        "ESPDistance"
    )

    CreateToggle(
        "Tracers",
        "Draw player lines",
        "ESPTracers"
    )

    CreateToggle(
        "FOV Circle",
        "Show aim radius",
        "FOVCircle"
    )

    CreateToggle(
        "Crosshair",
        "Center crosshair",
        "Crosshair"
    )
end

--==================================================
-- SETTINGS TAB
--==================================================

local function BuildSettings()

    ClearContent()

    CreateToggle(
        "Team Check",
        "Ignore teammates",
        "TeamCheck"
    )

    CreateToggle(
        "Visible Only",
        "Ignore players behind walls",
        "VisibleCheck"
    )
end

--==================================================
-- TAB SELECTION
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

    Content.CanvasSize = UDim2.new(
        0,0,
        0,
        Layout.AbsoluteContentSize.Y + 10
    )
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
-- HIDE / SHOW IVORY
--==================================================

local MenuButton = Instance.new("TextButton")
MenuButton.Name = "IvoryOpen"
MenuButton.Size = UDim2.new(0,44,0,44)
MenuButton.Position = UDim2.new(0,16,0,85)
MenuButton.BackgroundColor3 = BG
MenuButton.Text = "🔥"
MenuButton.TextSize = 19
MenuButton.Font = Enum.Font.GothamBold
MenuButton.TextColor3 = WHITE
MenuButton.Visible = false
MenuButton.Parent = Gui

Corner(MenuButton,13)
Stroke(MenuButton,Color3.fromRGB(70,70,80),1,.3)

HideButton.Activated:Connect(function()

    Main.Visible = false
    MenuButton.Visible = true
end)

MenuButton.Activated:Connect(function()

    Main.Visible = true
    MenuButton.Visible = false
end)

--==================================================
-- DRAGGING
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

        local delta = input.Position-dragStart

        Main.Position = UDim2.new(
            startPosition.X.Scale,
            startPosition.X.Offset+delta.X,
            startPosition.Y.Scale,
            startPosition.Y.Offset+delta.Y
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
Crosshair.Name = "IvoryCrosshair"
Crosshair.Size = UDim2.new(0,30,0,30)
Crosshair.AnchorPoint = Vector2.new(.5,.5)
Crosshair.Position = UDim2.new(.5,0,.5,0)
Crosshair.BackgroundTransparency = 1
Crosshair.Parent = Gui

local function CrossBar(size,position)

    local bar = Instance.new("Frame")
    bar.Size = size
    bar.Position = position
    bar.BackgroundColor3 = WHITE
    bar.BorderSizePixel = 0
    bar.Parent = Crosshair

    Corner(bar,2)
end

CrossBar(
    UDim2.new(0,3,0,9),
    UDim2.new(.5,-1,0,0)
)

CrossBar(
    UDim2.new(0,3,0,9),
    UDim2.new(.5,-1,1,-9)
)

CrossBar(
    UDim2.new(0,9,0,3),
    UDim2.new(0,0,.5,-1)
)

CrossBar(
    UDim2.new(0,9,0,3),
    UDim2.new(1,-9,.5,-1)
)

local Dot = Instance.new("Frame")
Dot.Size = UDim2.new(0,4,0,4)
Dot.Position = UDim2.new(.5,-2,.5,-2)
Dot.BackgroundColor3 = WHITE
Dot.BorderSizePixel = 0
Dot.Parent = Crosshair

Corner(Dot,5)

--==================================================
-- FOV CIRCLE
--==================================================

local FOVCircle = Instance.new("Frame")
FOVCircle.Name = "IvoryFOV"
FOVCircle.AnchorPoint = Vector2.new(.5,.5)
FOVCircle.Position = UDim2.new(.5,0,.5,0)
FOVCircle.BackgroundTransparency = 1
FOVCircle.Parent = Gui

Corner(FOVCircle,999)
Stroke(FOVCircle,ACCENT,2,.25)

--==================================================
-- TARGET CHECK
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

    local origin = Camera.CFrame.Position
    local direction = part.Position-origin

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

--==================================================
-- GET TARGET
--==================================================

local function GetTarget()

    local BestTarget = nil
    local BestDistance = Settings.AimFOV

    local Viewport = Camera.ViewportSize

    local Center = Vector2.new(
        Viewport.X/2,
        Viewport.Y/2
    )

    for _,player in ipairs(Players:GetPlayers()) do

        if not IsEnemy(player) then
            continue
        end

        local Character = player.Character

        if not Character then
            continue
        end

        local Humanoid =
            Character:FindFirstChildOfClass("Humanoid")

        if not Humanoid or Humanoid.Health <= 0 then
            continue
        end

        local Part =
            Character:FindFirstChild(Settings.AimPart)

        if not Part then
            continue
        end

        local Distance3D =
            (Camera.CFrame.Position-Part.Position).Magnitude

        if Distance3D > Settings.AimMaxDistance then
            continue
        end

        if not IsVisible(Part) then
            continue
        end

        local ScreenPosition,OnScreen =
            Camera:WorldToViewportPoint(Part.Position)

        if not OnScreen then
            continue
        end

        local Distance2D =
            (
                Vector2.new(
                    ScreenPosition.X,
                    ScreenPosition.Y
                )-Center
            ).Magnitude

        if Distance2D <= BestDistance then

            BestDistance = Distance2D
            BestTarget = Part
        end
    end

    return BestTarget
end

--==================================================
-- AIMBOT
--==================================================

local function RunAimbot()

    -- Aimbot is controlled ONLY by the Ivory toggle.

    if not Settings.AimbotEnabled then
        return
    end

    local Target = GetTarget()

    if not Target then
        return
    end

    Camera.CFrame = CFrame.lookAt(
        Camera.CFrame.Position,
        Target.Position
    )
end

--==================================================
-- TRIGGERBOT
--==================================================

local LastTrigger = 0

local function TriggerShot()

    -- Connect this to your own weapon system.
    -- Example:
    --
    -- local WeaponSystem =
    --     LocalPlayer:FindFirstChild("WeaponSystem")
    --
    -- local Fire =
    --     WeaponSystem and WeaponSystem:FindFirstChild("Fire")
    --
    -- if Fire and Fire:IsA("RemoteEvent") then
    --     Fire:FireServer()
    -- end

end

local function TriggerCheck()

    if not Settings.Triggerbot then
        return
    end

    local Viewport = Camera.ViewportSize

    local Center = Vector2.new(
        Viewport.X/2,
        Viewport.Y/2
    )

    local Ray =
        Camera:ViewportPointToRay(
            Center.X,
            Center.Y
        )

    local Params = RaycastParams.new()
    Params.FilterType = Enum.RaycastFilterType.Exclude

    Params.FilterDescendantsInstances = {
        LocalPlayer.Character
    }

    local Result = Workspace:Raycast(
        Ray.Origin,
        Ray.Direction*Settings.AimMaxDistance,
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

    if os.clock()-LastTrigger < Settings.TriggerDelay then
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

    if not ESPObjects[player] then
        return
    end

    for _,object in ipairs(ESPObjects[player]) do

        if object and object.Parent then
            object:Destroy()
        end
    end

    ESPObjects[player] = nil
end

local function CreateESP(player)

    if player == LocalPlayer then
        return
    end

    RemoveESP(player)

    local Character = player.Character

    if not Character then
        return
    end

    local Head = Character:FindFirstChild("Head")

    if not Head then
        return
    end

    local Objects = {}

    local Highlight = Instance.new("Highlight")
    Highlight.Name = "IvoryESP"
    Highlight.Adornee = Character
    Highlight.FillTransparency = .85
    Highlight.OutlineTransparency = 0
    Highlight.OutlineColor = Color3.fromRGB(255,80,80)
    Highlight.Parent = Character

    table.insert(Objects,Highlight)

    local Billboard = Instance.new("BillboardGui")
    Billboard.Name = "IvoryInfo"
    Billboard.Adornee = Head
    Billboard.Size = UDim2.new(0,160,0,55)
    Billboard.StudsOffset = Vector3.new(0,3,0)
    Billboard.AlwaysOnTop = true
    Billboard.Parent = Head

    table.insert(Objects,Billboard)

    local Info = Instance.new("TextLabel")
    Info.Size = UDim2.new(1,0,1,0)
    Info.BackgroundTransparency = 1
    Info.TextColor3 = WHITE
    Info.TextStrokeTransparency = 0
    Info.TextSize = 11
    Info.Font = Enum.Font.GothamBold
    Info.TextWrapped = true
    Info.Parent = Billboard

    table.insert(Objects,Info)

    ESPObjects[player] = {
        Objects = Objects,
        Info = Info
    }
end

local function UpdateESP()

    for _,player in ipairs(Players:GetPlayers()) do

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

        local Character = player.Character

        if not Character then
            RemoveESP(player)
            continue
        end

        local Humanoid =
            Character:FindFirstChildOfClass("Humanoid")

        local Head =
            Character:FindFirstChild("Head")

        if not Humanoid or not Head then
            continue
        end

        if not ESPObjects[player] then
            CreateESP(player)
        end

        local Data = ESPObjects[player]

        if Data and Data.Info then

            local Text = player.DisplayName

            if Settings.ESPHealth then
                Text ..= "\nHP: "..math.floor(Humanoid.Health)
            end

            if Settings.ESPDistance then

                local Distance =
                    math.floor(
                        (Camera.CFrame.Position-Head.Position).Magnitude
                    )

                Text ..= "\n"..Distance.." studs"
            end

            Data.Info.Text = Text
        end
    end
end

--==================================================
-- PLAYERS
--==================================================

local function SetupPlayer(player)

    player.CharacterAdded:Connect(function()

        task.wait(.5)

        if Settings.ESP then
            CreateESP(player)
        end
    end)
end

for _,player in ipairs(Players:GetPlayers()) do
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

    -- FOV
    local Diameter = Settings.AimFOV*2

    FOVCircle.Size = UDim2.new(
        0,Diameter,
        0,Diameter
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
