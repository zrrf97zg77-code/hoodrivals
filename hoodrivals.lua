--========================================================--
-- 🔥 DEVELOPER SHOOTING TOOLKIT V3
-- DELTA EXECUTOR EDITION
--========================================================--

-- Clean previous run
if getgenv and getgenv().DSTv3 and getgenv().DSTv3.Destroy then
    pcall(getgenv().DSTv3.Destroy)
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
while not LocalPlayer do
    task.wait(0.1)
    LocalPlayer = Players.LocalPlayer
end

local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

--========================================================--
-- CONFIG
--========================================================--

local Config = {
    AimEnabled = true,
    ShowFOV = true,
    FOV = 180,
    AimStrength = 0.35,
    LockBreakAngle = 30,
    TargetPart = "Head",

    ESPEnabled = true,
    Boxes = true,
    Names = true,
    HealthBars = true,
    Distances = true,
    HeadMarkers = true,
    Tracers = true,

    TeamCheck = true,
    WallCheck = false,

    CrosshairEnabled = true,
}

--========================================================--
-- THEME
--========================================================--

local Theme = {
    Background = Color3.fromRGB(8, 9, 13),
    Panel = Color3.fromRGB(13, 15, 21),
    Panel2 = Color3.fromRGB(20, 22, 30),

    Accent = Color3.fromRGB(255, 75, 35),
    AccentLight = Color3.fromRGB(255, 150, 65),

    Text = Color3.fromRGB(242, 244, 248),
    SubText = Color3.fromRGB(145, 150, 165),

    Stroke = Color3.fromRGB(42, 45, 55),

    Good = Color3.fromRGB(70, 220, 125),
    Bad = Color3.fromRGB(235, 70, 80),
    Warn = Color3.fromRGB(255, 210, 70),
}

--========================================================--
-- STATE
--========================================================--

local State = { Gui = nil, Connections = {} }
function State.Track(c) table.insert(State.Connections, c); return c end
function State.Destroy()
    for _, c in ipairs(State.Connections) do
        pcall(function() c:Disconnect() end)
    end
    State.Connections = {}
    if State.Gui then
        pcall(function() State.Gui:Destroy() end)
        State.Gui = nil
    end
end
if getgenv then getgenv().DSTv3 = State end

--========================================================--
-- CLEAN PREVIOUS VERSION
--========================================================--

local old = PlayerGui:FindFirstChild("DeveloperShootingToolkit")
if old then old:Destroy() end

--========================================================--
-- HELPERS
--========================================================--

local function New(className, properties)
    local object = Instance.new(className)
    for property, value in pairs(properties) do
        object[property] = value
    end
    return object
end

local function Corner(parent, radius)
    return New("UICorner", {
        CornerRadius = UDim.new(0, radius),
        Parent = parent,
    })
end

local function Stroke(parent, color, thickness, transparency)
    return New("UIStroke", {
        Color = color,
        Thickness = thickness or 1,
        Transparency = transparency or 0,
        Parent = parent,
    })
end

local function Tween(object, properties, duration)
    local tween = TweenService:Create(
        object,
        TweenInfo.new(
            duration or 0.2,
            Enum.EasingStyle.Quart,
            Enum.EasingDirection.Out
        ),
        properties
    )
    tween:Play()
    return tween
end

--========================================================--
-- SCREEN GUI
--========================================================--

local ScreenGui = New("ScreenGui", {
    Name = "DeveloperShootingToolkit",
    ResetOnSpawn = false,
    IgnoreGuiInset = true,
    DisplayOrder = 100,
    Parent = PlayerGui,
})
State.Gui = ScreenGui

--========================================================--
-- FOV CIRCLE
--========================================================--

local FOVCircle = New("Frame", {
    Name = "FOVCircle",
    Size = UDim2.fromOffset(Config.FOV * 2, Config.FOV * 2),
    AnchorPoint = Vector2.new(0.5, 0.5),
    BackgroundTransparency = 1,
    Visible = Config.AimEnabled and Config.ShowFOV,
    ZIndex = 10,
    Parent = ScreenGui,
})

Corner(FOVCircle, 999)
Stroke(FOVCircle, Theme.Accent, 2, 0.15)

--========================================================--
-- CROSSHAIR
--========================================================--

local Crosshair = New("Frame", {
    Name = "Crosshair",
    Size = UDim2.fromOffset(2, 2),
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5),
    BackgroundTransparency = 1,
    Visible = Config.CrosshairEnabled,
    ZIndex = 20,
    Parent = ScreenGui,
})

local function CrosshairPart(size, position)
    local part = New("Frame", {
        Size = size,
        Position = position,
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Theme.Text,
        BorderSizePixel = 0,
        ZIndex = 21,
        Parent = Crosshair,
    })
    Corner(part, 4)
    return part
end

CrosshairPart(UDim2.fromOffset(2, 9), UDim2.fromOffset(0, -7))
CrosshairPart(UDim2.fromOffset(2, 9), UDim2.fromOffset(0, 7))
CrosshairPart(UDim2.fromOffset(9, 2), UDim2.fromOffset(-7, 0))
CrosshairPart(UDim2.fromOffset(9, 2), UDim2.fromOffset(7, 0))

--========================================================--
-- OPEN BUTTON
--========================================================--

local OpenButton = New("TextButton", {
    Name = "OpenButton",
    Size = UDim2.fromOffset(56, 56),
    Position = UDim2.fromOffset(20, 250),
    BackgroundColor3 = Theme.Accent,
    BorderSizePixel = 0,
    Text = "S",
    TextColor3 = Color3.new(1, 1, 1),
    TextSize = 20,
    Font = Enum.Font.GothamBlack,
    ZIndex = 100,
    Parent = ScreenGui,
})

Corner(OpenButton, 16)

--========================================================--
-- MAIN WINDOW
--========================================================--

local Main = New("Frame", {
    Name = "Main",
    Size = UDim2.fromOffset(740, 480),
    Position = UDim2.new(0.5, -370, 0.5, -240),
    BackgroundColor3 = Theme.Background,
    BorderSizePixel = 0,
    Visible = false,
    ZIndex = 50,
    Parent = ScreenGui,
})

Corner(Main, 15)
Stroke(Main, Theme.Stroke, 1)

--========================================================--
-- HEADER
--========================================================--

local Header = New("Frame", {
    Size = UDim2.new(1, 0, 0, 70),
    BackgroundColor3 = Theme.Panel,
    BorderSizePixel = 0,
    ZIndex = 55,
    Parent = Main,
})

Corner(Header, 15)

New("Frame", {
    Size = UDim2.new(1, 0, 0, 18),
    Position = UDim2.new(0, 0, 1, -18),
    BackgroundColor3 = Theme.Panel,
    BorderSizePixel = 0,
    ZIndex = 55,
    Parent = Header,
})

New("Frame", {
    Size = UDim2.new(1, 0, 0, 3),
    BackgroundColor3 = Theme.Accent,
    BorderSizePixel = 0,
    ZIndex = 70,
    Parent = Main,
})

local Logo = New("TextLabel", {
    Size = UDim2.fromOffset(50, 50),
    Position = UDim2.fromOffset(14, 10),
    BackgroundColor3 = Theme.Accent,
    Text = "🔥",
    TextSize = 24,
    Font = Enum.Font.GothamBold,
    TextColor3 = Color3.new(1, 1, 1),
    ZIndex = 60,
    Parent = Header,
})

Corner(Logo, 12)

New("TextLabel", {
    Size = UDim2.fromOffset(450, 28),
    Position = UDim2.fromOffset(78, 10),
    BackgroundTransparency = 1,
    Text = "DEVELOPER SHOOTING TOOLKIT",
    TextColor3 = Theme.Text,
    TextSize = 18,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 60,
    Parent = Header,
})

New("TextLabel", {
    Size = UDim2.fromOffset(450, 20),
    Position = UDim2.fromOffset(79, 38),
    BackgroundTransparency = 1,
    Text = "🔥 DELTA EDITION  •  V3",
    TextColor3 = Theme.SubText,
    TextSize = 10,
    Font = Enum.Font.GothamMedium,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 60,
    Parent = Header,
})

local Status = New("TextLabel", {
    Size = UDim2.fromOffset(120, 31),
    Position = UDim2.new(1, -135, 0, 20),
    BackgroundColor3 = Color3.fromRGB(18, 45, 30),
    Text = "●  ONLINE",
    TextColor3 = Theme.Good,
    TextSize = 10,
    Font = Enum.Font.GothamBold,
    ZIndex = 60,
    Parent = Header,
})

Corner(Status, 8)

--========================================================--
-- SIDEBAR
--========================================================--

local Sidebar = New("Frame", {
    Size = UDim2.fromOffset(160, 390),
    Position = UDim2.fromOffset(12, 78),
    BackgroundColor3 = Theme.Panel,
    BorderSizePixel = 0,
    ZIndex = 55,
    Parent = Main,
})

Corner(Sidebar, 12)

New("UIPadding", {
    PaddingTop = UDim.new(0, 12),
    Parent = Sidebar,
})

New("UIListLayout", {
    Padding = UDim.new(0, 7),
    HorizontalAlignment = Enum.HorizontalAlignment.Center,
    SortOrder = Enum.SortOrder.LayoutOrder,
    Parent = Sidebar,
})

--========================================================--
-- CONTENT
--========================================================--

local Content = New("Frame", {
    Size = UDim2.new(1, -187, 1, -91),
    Position = UDim2.fromOffset(179, 78),
    BackgroundTransparency = 1,
    ZIndex = 55,
    Parent = Main,
})

--========================================================--
-- DRAGGING
--========================================================--

local dragging = false
local dragStart
local startPosition

State.Track(Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPosition = Main.Position
    end
end))

State.Track(UserInputService.InputChanged:Connect(function(input)
    if not dragging then return end
    if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(
            startPosition.X.Scale,
            startPosition.X.Offset + delta.X,
            startPosition.Y.Scale,
            startPosition.Y.Offset + delta.Y
        )
    end
end))

State.Track(UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end))

--========================================================--
-- TABS
--========================================================--

local Tabs = {}
local CurrentTab = nil

local function CreateTab(name, icon)
    local button = New("TextButton", {
        Name = name,
        Size = UDim2.fromOffset(140, 44),
        BackgroundTransparency = 1,
        BackgroundColor3 = Theme.Panel2,
        Text = icon .. "  " .. name,
        TextColor3 = Theme.SubText,
        TextSize = 12,
        Font = Enum.Font.GothamBold,
        AutoButtonColor = false,
        ZIndex = 60,
        Parent = Sidebar,
    })

    Corner(button, 9)
    Tabs[name] = button

    button.MouseEnter:Connect(function()
        if CurrentTab ~= name then
            Tween(button, { BackgroundTransparency = 0.5 }, 0.12)
        end
    end)

    button.MouseLeave:Connect(function()
        if CurrentTab ~= name then
            Tween(button, { BackgroundTransparency = 1 }, 0.12)
        end
    end)

    return button
end

local function SetActiveTab(name)
    CurrentTab = name
    for tabName, button in pairs(Tabs) do
        if tabName == name then
            Tween(button, {
                BackgroundTransparency = 0,
                TextColor3 = Theme.Accent,
            }, 0.15)
        else
            Tween(button, {
                BackgroundTransparency = 1,
                TextColor3 = Theme.SubText,
            }, 0.15)
        end
    end
end

local function ClearContent()
    for _, child in ipairs(Content:GetChildren()) do
        child:Destroy()
    end
end

local function SectionTitle(text)
    return New("TextLabel", {
        Size = UDim2.new(1, 0, 0, 32),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Theme.Text,
        TextSize = 15,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 60,
        Parent = Content,
    })
end

local function Card(height)
    local frame = New("Frame", {
        Size = UDim2.new(1, 0, 0, height),
        BackgroundColor3 = Theme.Panel,
        BorderSizePixel = 0,
        ZIndex = 56,
        Parent = Content,
    })
    Corner(frame, 10)
    Stroke(frame, Theme.Stroke, 1)
    return frame
end

--========================================================--
-- TOGGLE
--========================================================--

local function Toggle(parent, text, configName, y)
    local holder = New("Frame", {
        Size = UDim2.new(1, -24, 0, 40),
        Position = UDim2.fromOffset(12, y),
        BackgroundTransparency = 1,
        ZIndex = 60,
        Parent = parent,
    })

    New("TextLabel", {
        Size = UDim2.new(1, -65, 1, 0),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Theme.Text,
        TextSize = 12,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 61,
        Parent = holder,
    })

    local switch = New("TextButton", {
        Size = UDim2.fromOffset(44, 24),
        Position = UDim2.new(1, -44, 0.5, -12),
        BackgroundColor3 = Config[configName] and Theme.Accent or Theme.Stroke,
        Text = "",
        AutoButtonColor = false,
        ZIndex = 61,
        Parent = holder,
    })

    Corner(switch, 20)

    local knob = New("Frame", {
        Size = UDim2.fromOffset(18, 18),
        Position = Config[configName]
            and UDim2.new(1, -21, 0.5, -9)
            or UDim2.new(0, 3, 0.5, -9),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0,
        ZIndex = 62,
        Parent = switch,
    })

    Corner(knob, 20)

    switch.MouseButton1Click:Connect(function()
        Config[configName] = not Config[configName]
        Tween(switch, {
            BackgroundColor3 = Config[configName] and Theme.Accent or Theme.Stroke,
        }, 0.15)
        Tween(knob, {
            Position = Config[configName]
                and UDim2.new(1, -21, 0.5, -9)
                or UDim2.new(0, 3, 0.5, -9),
        }, 0.15)
    end)
end

--========================================================--
-- TARGETING VARIABLES
--========================================================--

local CurrentTarget = nil

local function Camera()
    return workspace.CurrentCamera
end

local function Alive(character)
    if not character then return false end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    return humanoid and humanoid.Health > 0
end

local function Enemy(player)
    if player == LocalPlayer then return false end
    if Config.TeamCheck then
        if LocalPlayer.Team ~= nil
            and player.Team ~= nil
            and LocalPlayer.Team == player.Team then
            return false
        end
    end
    return true
end

--========================================================--
-- COMBAT PAGE
--========================================================--

local function ShowCombat()
    ClearContent()

    SectionTitle("🎯  AIM ASSIST")

    local combat = Card(330)

    Toggle(combat, "Aim Assist", "AimEnabled", 10)
    Toggle(combat, "FOV Circle", "ShowFOV", 55)
    Toggle(combat, "Team Check", "TeamCheck", 100)
    Toggle(combat, "Wall Check", "WallCheck", 145)

    New("TextLabel", {
        Size = UDim2.new(1, -24, 0, 70),
        Position = UDim2.fromOffset(12, 205),
        BackgroundTransparency = 1,
        Text = "Target Part: " .. Config.TargetPart
            .. "\nFOV Radius: " .. Config.FOV .. " px"
            .. "\nAim Strength: " .. Config.AimStrength,
        TextColor3 = Theme.SubText,
        TextSize = 11,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        ZIndex = 60,
        Parent = combat,
    })

    local targetStatus = New("TextLabel", {
        Size = UDim2.fromOffset(160, 32),
        Position = UDim2.new(1, -175, 0, 15),
        BackgroundColor3 = Color3.fromRGB(40, 27, 22),
        Text = "TARGET: NONE",
        TextColor3 = Theme.AccentLight,
        TextSize = 9,
        Font = Enum.Font.GothamBold,
        ZIndex = 60,
        Parent = combat,
    })

    Corner(targetStatus, 8)

    State.Track(RunService.RenderStepped:Connect(function()
        if targetStatus.Parent then
            if CurrentTarget then
                targetStatus.Text = "TARGET: " .. CurrentTarget.DisplayName
            else
                targetStatus.Text = "TARGET: NONE"
            end
        end
    end))
end

--========================================================--
-- VISUAL PAGE
--========================================================--

local function ShowVisuals()
    ClearContent()

    SectionTitle("👁  ESP / VISUALS")

    local visual = Card(365)

    Toggle(visual, "Enable ESP", "ESPEnabled", 10)
    Toggle(visual, "Player Names", "Names", 55)
    Toggle(visual, "Health Bars", "HealthBars", 100)
    Toggle(visual, "Distance", "Distances", 145)
    Toggle(visual, "3D Boxes", "Boxes", 190)
    Toggle(visual, "Head Markers", "HeadMarkers", 235)
    Toggle(visual, "Tracers", "Tracers", 280)
    Toggle(visual, "Crosshair", "CrosshairEnabled", 325)
end

--========================================================--
-- CROSSHAIR PAGE
--========================================================--

local function ShowCrosshair()
    ClearContent()

    SectionTitle("✚  CROSSHAIR")

    local cross = Card(220)

    Toggle(cross, "Enable Crosshair", "CrosshairEnabled", 15)

    New("TextLabel", {
        Size = UDim2.new(1, -24, 0, 65),
        Position = UDim2.fromOffset(12, 75),
        BackgroundTransparency = 1,
        Text = "Your crosshair stays centered on the screen.\n"
            .. "The FOV circle surrounds your current aim area.",
        TextColor3 = Theme.SubText,
        TextSize = 11,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        ZIndex = 60,
        Parent = cross,
    })
end

--========================================================--
-- SETTINGS PAGE
--========================================================--

local function ShowSettings()
    ClearContent()

    SectionTitle("⚙  SETTINGS")

    local settings = Card(280)

    local function Setting(name, value, y)
        New("TextLabel", {
            Size = UDim2.new(0.5, -12, 0, 35),
            Position = UDim2.fromOffset(12, y),
            BackgroundTransparency = 1,
            Text = name,
            TextColor3 = Theme.SubText,
            TextSize = 11,
            Font = Enum.Font.GothamMedium,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 60,
            Parent = settings,
        })

        New("TextLabel", {
            Size = UDim2.new(0.5, -12, 0, 35),
            Position = UDim2.new(0.5, 0, 0, y),
            BackgroundTransparency = 1,
            Text = value,
            TextColor3 = Theme.Text,
            TextSize = 11,
            Font = Enum.Font.GothamBold,
            TextXAlignment = Enum.TextXAlignment.Right,
            ZIndex = 60,
            Parent = settings,
        })
    end

    Setting("Edition", "DELTA V3", 12)
    Setting("Target Part", Config.TargetPart, 52)
    Setting("FOV", Config.FOV .. " px", 92)
    Setting("Aim Strength", tostring(Config.AimStrength), 132)
    Setting("Break Angle", Config.LockBreakAngle .. "°", 172)
    Setting("Team Check", Config.TeamCheck and "ON" or "OFF", 212)
end

--========================================================--
-- TAB BUTTONS + INITIAL
--========================================================--

local CombatTab   = CreateTab("COMBAT", "🎯")
local VisualTab   = CreateTab("VISUALS", "👁")
local CrossTab    = CreateTab("CROSSHAIR", "✚")
local SettingsTab = CreateTab("SETTINGS", "⚙")

State.Track(CombatTab.MouseButton1Click:Connect(function()
    SetActiveTab("COMBAT"); ShowCombat()
end))
State.Track(VisualTab.MouseButton1Click:Connect(function()
    SetActiveTab("VISUALS"); ShowVisuals()
end))
State.Track(CrossTab.MouseButton1Click:Connect(function()
    SetActiveTab("CROSSHAIR"); ShowCrosshair()
end))
State.Track(SettingsTab.MouseButton1Click:Connect(function()
    SetActiveTab("SETTINGS"); ShowSettings()
end))

SetActiveTab("COMBAT")
ShowCombat()

--========================================================--
-- OPEN / CLOSE
--========================================================--

State.Track(OpenButton.MouseButton1Click:Connect(function()
    Main.Visible = not Main.Visible
end))

--========================================================--
-- WALL CHECK
--========================================================--

local function Visible(targetPart, character)
    if not Config.WallCheck then return true end
    local camera = Camera()
    if not camera then return false end

    local origin = camera.CFrame.Position
    local direction = targetPart.Position - origin

    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = { LocalPlayer.Character, camera }

    local result = workspace:Raycast(origin, direction, params)
    if not result then return true end
    return result.Instance:IsDescendantOf(character)
end

--========================================================--
-- GET BEST TARGET
--========================================================--

local function GetTarget()
    local camera = Camera()
    if not camera then return nil end

    local viewport = camera.ViewportSize
    local center = Vector2.new(viewport.X / 2, viewport.Y / 2)

    local bestPlayer = nil
    local bestDistance = Config.FOV

    for _, player in ipairs(Players:GetPlayers()) do
        if Enemy(player) then
            local character = player.Character
            if Alive(character) then
                local targetPart = character:FindFirstChild(Config.TargetPart)
                    or character:FindFirstChild("Head")

                if targetPart then
                    local screen, onScreen = camera:WorldToViewportPoint(targetPart.Position)
                    if onScreen and screen.Z > 0 then
                        local point = Vector2.new(screen.X, screen.Y)
                        local distance = (point - center).Magnitude
                        if distance <= bestDistance then
                            if Visible(targetPart, character) then
                                bestDistance = distance
                                bestPlayer = player
                            end
                        end
                    end
                end
            end
        end
    end

    return bestPlayer
end

--========================================================--
-- ANGLE CHECK
--========================================================--

local function GetAngle(player)
    local camera = Camera()
    if not camera then return math.huge end

    local character = player.Character
    if not character then return math.huge end

    local targetPart = character:FindFirstChild(Config.TargetPart)
        or character:FindFirstChild("Head")
    if not targetPart then return math.huge end

    local direction = (targetPart.Position - camera.CFrame.Position).Unit
    local dot = math.clamp(camera.CFrame.LookVector:Dot(direction), -1, 1)
    return math.deg(math.acos(dot))
end

--========================================================--
-- AIM
--========================================================--

local function AimAt(player)
    local camera = Camera()
    if not camera then return end

    local character = player.Character
    if not character then return end

    local targetPart = character:FindFirstChild(Config.TargetPart)
        or character:FindFirstChild("Head")
    if not targetPart then return end

    local desired = CFrame.lookAt(camera.CFrame.Position, targetPart.Position)
    camera.CFrame = camera.CFrame:Lerp(desired, Config.AimStrength)
end

--========================================================--
-- ESP
--========================================================--

local ESP = {}

local function CreateESP(player)
    if player == LocalPlayer then return end
    if ESP[player] then return end

    local data = {}

    -- Overhead card
    local billboard = New("BillboardGui", {
        Name = "PlayerESP",
        Size = UDim2.fromOffset(135, 52),
        StudsOffset = Vector3.new(0, 2.8, 0),
        AlwaysOnTop = true,
        LightInfluence = 0,
        Enabled = false,
        Parent = ScreenGui,
    })

    data.Billboard = billboard

    local background = New("Frame", {
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Theme.Background,
        BackgroundTransparency = 0.1,
        BorderSizePixel = 0,
        Parent = billboard,
    })

    Corner(background, 7)
    data.Outline = Stroke(background, Theme.Accent, 1, 0.15)

    data.Name = New("TextLabel", {
        Size = UDim2.new(1, -10, 0, 16),
        Position = UDim2.fromOffset(5, 3),
        BackgroundTransparency = 1,
        Text = player.DisplayName,
        TextColor3 = Theme.Text,
        TextSize = 10,
        Font = Enum.Font.GothamBold,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = background,
    })

    data.Username = New("TextLabel", {
        Size = UDim2.new(1, -10, 0, 12),
        Position = UDim2.fromOffset(5, 18),
        BackgroundTransparency = 1,
        Text = "@" .. player.Name,
        TextColor3 = Theme.SubText,
        TextSize = 8,
        Font = Enum.Font.GothamMedium,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = background,
    })

    data.HealthBack = New("Frame", {
        Size = UDim2.new(1, -10, 0, 4),
        Position = UDim2.fromOffset(5, 32),
        BackgroundColor3 = Color3.fromRGB(35, 37, 45),
        BorderSizePixel = 0,
        Parent = background,
    })

    Corner(data.HealthBack, 5)

    data.Health = New("Frame", {
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Theme.Good,
        BorderSizePixel = 0,
        Parent = data.HealthBack,
    })

    Corner(data.Health, 5)

    data.Distance = New("TextLabel", {
        Size = UDim2.new(1, -10, 0, 12),
        Position = UDim2.fromOffset(5, 39),
        BackgroundTransparency = 1,
        Text = "",
        TextColor3 = Theme.SubText,
        TextSize = 7,
        Font = Enum.Font.GothamMedium,
        Parent = background,
    })

    -- Head marker
    data.HeadMarker = New("BillboardGui", {
        Name = "HeadMarker",
        Size = UDim2.fromOffset(11, 11),
        AlwaysOnTop = true,
        LightInfluence = 0,
        Enabled = false,
        Parent = ScreenGui,
    })

    local marker = New("Frame", {
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0,
        Parent = data.HeadMarker,
    })

    Corner(marker, 999)

    -- 3D box
    data.Box = New("Highlight", {
        Name = "ESPHighlight",
        DepthMode = Enum.HighlightDepthMode.AlwaysOnTop,
        FillTransparency = 1,
        OutlineTransparency = 0.15,
        OutlineColor = Theme.Accent,
        Enabled = false,
        Parent = ScreenGui,
    })

    -- Tracer (fixed: attach to camera & target root, not Terrain)
    data.TracerStart = New("Attachment", {
        Name = "DST_TracerStart_" .. player.Name,
        Parent = workspace.CurrentCamera,
    })

    data.TracerEnd = New("Attachment", {
        Name = "DST_TracerEnd_" .. player.Name,
        Parent = workspace.CurrentCamera,
    })

    data.Tracer = New("Beam", {
        Name = "DST_Tracer_" .. player.Name,
        Attachment0 = data.TracerStart,
        Attachment1 = data.TracerEnd,
        FaceCamera = true,
        Width0 = 0.03,
        Width1 = 0.03,
        Color = ColorSequence.new(Theme.Accent),
        Enabled = false,
        Parent = workspace.CurrentCamera,
    })

    -- Character binding
    local function Bind(character)
        local head = character:FindFirstChild("Head")
        local root = character:FindFirstChild("HumanoidRootPart")

        if head then
            billboard.Adornee = head
            data.HeadMarker.Adornee = head
        end

        data.Box.Adornee = character

        if root then
            data.TracerEnd.Parent = root
        end
    end

    if player.Character then
        task.spawn(Bind, player.Character)
    end

    data.CharacterConnection = player.CharacterAdded:Connect(function(character)
        character:WaitForChild("HumanoidRootPart", 5)
        character:WaitForChild("Head", 5)
        task.wait(0.1)
        Bind(character)
    end)

    ESP[player] = data
end

local function RemoveESP(player)
    local data = ESP[player]
    if not data then return end

    if data.CharacterConnection then
        data.CharacterConnection:Disconnect()
    end

    for _, object in pairs(data) do
        if typeof(object) == "Instance" then
            pcall(function() object:Destroy() end)
        end
    end

    ESP[player] = nil
end

for _, player in ipairs(Players:GetPlayers()) do
    CreateESP(player)
end

State.Track(Players.PlayerAdded:Connect(CreateESP))
State.Track(Players.PlayerRemoving:Connect(RemoveESP))

--========================================================--
-- UPDATE ESP
--========================================================--

local function UpdateESP()
    local camera = Camera()
    if not camera then return end

    for player, data in pairs(ESP) do
        if not player.Parent then
            RemoveESP(player)
            continue
        end

        local character = player.Character
        local alive = Alive(character)
        local enemy = Enemy(player)
        local enabled = Config.ESPEnabled and alive and enemy

        data.Billboard.Enabled = enabled and (Config.Names or Config.HealthBars or Config.Distances)
        data.HeadMarker.Enabled = enabled and Config.HeadMarkers
        data.Box.Enabled = enabled and Config.Boxes
        data.Tracer.Enabled = enabled and Config.Tracers

        if enabled then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            local root = character:FindFirstChild("HumanoidRootPart")
            local head = character:FindFirstChild("Head")

            data.Name.Visible = Config.Names
            data.Username.Visible = Config.Names
            data.HealthBack.Visible = Config.HealthBars
            data.Distance.Visible = Config.Distances

            if humanoid then
                local percentage = math.clamp(humanoid.Health / math.max(humanoid.MaxHealth, 1), 0, 1)
                data.Health.Size = UDim2.new(percentage, 0, 1, 0)

                if percentage > 0.5 then
                    data.Health.BackgroundColor3 = Theme.Good
                elseif percentage > 0.25 then
                    data.Health.BackgroundColor3 = Theme.Warn
                else
                    data.Health.BackgroundColor3 = Theme.Bad
                end
            end

            -- Distance
            if root and head then
                local distance = (camera.CFrame.Position - head.Position).Magnitude
                data.Distance.Text = math.floor(distance) .. " studs"
            end

            -- Tracer endpoints
            if data.TracerStart and data.TracerStart.Parent then
                data.TracerStart.WorldPosition = camera.CFrame.Position
                    - camera.CFrame.LookVector * 0.5
                    + camera.CFrame.RightVector * 0.6
                    - camera.CFrame.UpVector * 0.5
            end

            if root and data.TracerEnd.Parent ~= root then
                data.TracerEnd.Parent = root
            end
            if root then
                data.TracerEnd.Position = Vector3.new(0, 0, 0)
            end

            -- Highlight target
            if player == CurrentTarget then
                data.Outline.Transparency = 0.1
                data.Box.OutlineColor = Color3.new(1, 1, 1)
            else
                data.Outline.Transparency = 0.15
                data.Box.OutlineColor = Theme.Accent
            end
        end
    end
end

--========================================================--
-- MAIN LOOP
--========================================================--

State.Track(RunService.RenderStepped:Connect(function()
    local camera = workspace.CurrentCamera
    if not camera then return end

    -- FOV circle follows center + toggles
    local viewport = camera.ViewportSize
    FOVCircle.Position = UDim2.fromOffset(viewport.X / 2, viewport.Y / 2)
    FOVCircle.Size = UDim2.fromOffset(Config.FOV * 2, Config.FOV * 2)
    FOVCircle.Visible = Config.AimEnabled and Config.ShowFOV
    Crosshair.Visible = Config.CrosshairEnabled

    -- Target retention
    if CurrentTarget then
        if not CurrentTarget.Character
            or not Alive(CurrentTarget.Character)
            or not Enemy(CurrentTarget)
            or GetAngle(CurrentTarget) > Config.LockBreakAngle then
            CurrentTarget = nil
        end
    end

    -- Acquire
    if not CurrentTarget then
        CurrentTarget = GetTarget()
    end

    -- Aim
    if Config.AimEnabled and CurrentTarget then
        AimAt(CurrentTarget)
    end

    -- ESP
    UpdateESP()
end))

print("[DSTv3] Loaded. Tap the 'S' button on the left to open the menu.")
