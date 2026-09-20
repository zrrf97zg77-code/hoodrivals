--========================================================--
--        DEVELOPER SHOOTING TOOLKIT V2
--        DELTA EXECUTOR EDITION
--========================================================--

if getgenv and getgenv().DSTv2 and getgenv().DSTv2.Destroy then
    pcall(getgenv().DSTv2.Destroy)
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
while not LocalPlayer do
    task.wait(0.1)
    LocalPlayer = Players.LocalPlayer
end

local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Camera = workspace.CurrentCamera
while not Camera do
    task.wait(0.1)
    Camera = workspace.CurrentCamera
end

local Config = {
    AimEnabled = true,
    FOV = 180,
    AimStrength = 0.35,
    LockBreakAngle = 30,
    TargetPart = "Head",

    ESPEnabled = true,
    Boxes = true,
    HealthBars = true,
    Names = true,
    Distances = true,
    HeadMarkers = true,
    Tracers = true,

    TeamCheck = true,
    WallCheck = false,
}

local WHITE = Color3.fromRGB(255,255,255)
local BLACK = Color3.fromRGB(8,8,8)
local DARK = Color3.fromRGB(15,15,15)
local DARKER = Color3.fromRGB(11,11,11)
local LIGHT = Color3.fromRGB(35,35,35)
local MUTED = Color3.fromRGB(150,150,150)
local RED = Color3.fromRGB(255,75,75)
local GREEN = Color3.fromRGB(80,255,150)

local Script = { Gui = nil, Connections = {} }
function Script.Track(c) table.insert(Script.Connections, c); return c end
function Script.Destroy()
    for _, c in ipairs(Script.Connections) do pcall(function() c:Disconnect() end) end
    Script.Connections = {}
    if Script.Gui then pcall(function() Script.Gui:Destroy() end); Script.Gui = nil end
end
if getgenv then getgenv().DSTv2 = Script end

--========================================================--
-- SCREEN GUI
--========================================================--

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DeveloperShootingToolkitV2"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.DisplayOrder = 100
ScreenGui.Parent = PlayerGui
Script.Gui = ScreenGui

--========================================================--
-- OPEN BUTTON
--========================================================--

local OpenButton = Instance.new("TextButton")
OpenButton.Size = UDim2.fromOffset(60, 60)
OpenButton.Position = UDim2.fromOffset(25, 250)
OpenButton.BackgroundColor3 = BLACK
OpenButton.BorderSizePixel = 0
OpenButton.Text = "S"
OpenButton.TextColor3 = WHITE
OpenButton.TextSize = 20
OpenButton.Font = Enum.Font.GothamBlack
OpenButton.ZIndex = 100
OpenButton.Parent = ScreenGui

local OpenCorner = Instance.new("UICorner")
OpenCorner.CornerRadius = UDim.new(0, 16)
OpenCorner.Parent = OpenButton

local OpenStroke = Instance.new("UIStroke")
OpenStroke.Color = WHITE
OpenStroke.Transparency = 0.65
OpenStroke.Parent = OpenButton

--========================================================--
-- MAIN WINDOW
--========================================================--

local Main = Instance.new("Frame")
Main.Size = UDim2.fromOffset(350, 450)
Main.Position = UDim2.new(0.5, -175, 0.5, -225)
Main.BackgroundColor3 = DARKER
Main.BorderSizePixel = 0
Main.Visible = false
Main.ZIndex = 90
Main.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 18)
MainCorner.Parent = Main

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = WHITE
MainStroke.Transparency = 0.75
MainStroke.Parent = Main

--========================================================--
-- HEADER
--========================================================--

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 65)
Header.BackgroundColor3 = DARK
Header.BorderSizePixel = 0
Header.ZIndex = 91
Header.Parent = Main

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 18)
HeaderCorner.Parent = Header

local Title = Instance.new("TextLabel")
Title.BackgroundTransparency = 1
Title.Position = UDim2.fromOffset(18, 8)
Title.Size = UDim2.new(1, -70, 0, 25)
Title.Text = "SHOOTING TOOLKIT"
Title.TextColor3 = WHITE
Title.TextSize = 16
Title.Font = Enum.Font.GothamBlack
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.ZIndex = 92
Title.Parent = Header

local Subtitle = Instance.new("TextLabel")
Subtitle.BackgroundTransparency = 1
Subtitle.Position = UDim2.fromOffset(19, 33)
Subtitle.Size = UDim2.new(1, -70, 0, 18)
Subtitle.Text = "DELTA EDITION"
Subtitle.TextColor3 = MUTED
Subtitle.TextSize = 9
Subtitle.Font = Enum.Font.GothamMedium
Subtitle.TextXAlignment = Enum.TextXAlignment.Left
Subtitle.ZIndex = 92
Subtitle.Parent = Header

local Close = Instance.new("TextButton")
Close.Size = UDim2.fromOffset(40, 40)
Close.Position = UDim2.new(1, -50, 0, 12)
Close.BackgroundColor3 = LIGHT
Close.BorderSizePixel = 0
Close.Text = "×"
Close.TextColor3 = WHITE
Close.TextSize = 24
Close.Font = Enum.Font.GothamMedium
Close.ZIndex = 92
Close.Parent = Header

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 10)
CloseCorner.Parent = Close

--========================================================--
-- SIDEBAR
--========================================================--

local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.fromOffset(90, 365)
Sidebar.Position = UDim2.fromOffset(10, 75)
Sidebar.BackgroundColor3 = DARK
Sidebar.BorderSizePixel = 0
Sidebar.ZIndex = 91
Sidebar.Parent = Main

local SidebarCorner = Instance.new("UICorner")
SidebarCorner.CornerRadius = UDim.new(0, 12)
SidebarCorner.Parent = Sidebar

local Content = Instance.new("ScrollingFrame")
Content.Size = UDim2.new(1, -115, 1, -85)
Content.Position = UDim2.fromOffset(105, 75)
Content.BackgroundTransparency = 1
Content.BorderSizePixel = 0
Content.ScrollBarThickness = 2
Content.CanvasSize = UDim2.fromOffset(0, 500)
Content.ZIndex = 91
Content.Parent = Main

--========================================================--
-- SIDEBAR BUTTONS
--========================================================--

local function SectionButton(text, index)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -12, 0, 44)
    button.Position = UDim2.fromOffset(6, 8 + (index - 1) * 50)
    button.BackgroundColor3 = index == 1 and LIGHT or DARK
    button.BorderSizePixel = 0
    button.Text = text
    button.TextColor3 = WHITE
    button.TextSize = 10
    button.Font = Enum.Font.GothamBold
    button.ZIndex = 92
    button.Parent = Sidebar

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 9)
    corner.Parent = button

    return button
end

local CombatTab = SectionButton("COMBAT", 1)
local VisualTab = SectionButton("VISUALS", 2)
local CrossTab = SectionButton("CROSSHAIR", 3)
local SettingsTab = SectionButton("SETTINGS", 4)

--========================================================--
-- CONTENT HELPERS
--========================================================--

local function ClearContent()
    for _, child in ipairs(Content:GetChildren()) do
        child:Destroy()
    end
end

local function Label(text, y)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -10, 0, 25)
    label.Position = UDim2.fromOffset(5, y)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = MUTED
    label.TextSize = 10
    label.Font = Enum.Font.GothamBold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 92
    label.Parent = Content
    return label
end

local function Toggle(text, value, y, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -10, 0, 42)
    button.Position = UDim2.fromOffset(5, y)
    button.BackgroundColor3 = DARK
    button.BorderSizePixel = 0
    button.Text = ""
    button.ZIndex = 92
    button.Parent = Content

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = button

    local name = Instance.new("TextLabel")
    name.Size = UDim2.new(1, -60, 1, 0)
    name.Position = UDim2.fromOffset(13, 0)
    name.BackgroundTransparency = 1
    name.Text = text
    name.TextColor3 = WHITE
    name.TextSize = 11
    name.Font = Enum.Font.GothamMedium
    name.TextXAlignment = Enum.TextXAlignment.Left
    name.ZIndex = 93
    name.Parent = button

    local pill = Instance.new("Frame")
    pill.Size = UDim2.fromOffset(38, 20)
    pill.Position = UDim2.new(1, -50, 0.5, -10)
    pill.BackgroundColor3 = value and WHITE or LIGHT
    pill.BorderSizePixel = 0
    pill.ZIndex = 93
    pill.Parent = button

    local pillCorner = Instance.new("UICorner")
    pillCorner.CornerRadius = UDim.new(1, 0)
    pillCorner.Parent = pill

    local dot = Instance.new("Frame")
    dot.Size = UDim2.fromOffset(14, 14)
    dot.Position = value and UDim2.new(1, -17, 0.5, -7) or UDim2.fromOffset(3, 3)
    dot.BackgroundColor3 = value and BLACK or MUTED
    dot.BorderSizePixel = 0
    dot.ZIndex = 94
    dot.Parent = pill

    local dotCorner = Instance.new("UICorner")
    dotCorner.CornerRadius = UDim.new(1, 0)
    dotCorner.Parent = dot

    button.Activated:Connect(function()
        value = not value
        pill.BackgroundColor3 = value and WHITE or LIGHT
        dot.BackgroundColor3 = value and BLACK or MUTED
        dot.Position = value and UDim2.new(1, -17, 0.5, -7) or UDim2.fromOffset(3, 3)
        callback(value)
    end)

    return button
end

--========================================================--
-- COMBAT PAGE
--========================================================--

local function ShowCombat()
    ClearContent()
    Label("AIM ASSIST", 5)
    Toggle("Aim Assist", Config.AimEnabled, 35, function(v) Config.AimEnabled = v end)
    Toggle("Team Check", Config.TeamCheck, 85, function(v) Config.TeamCheck = v end)
    Toggle("Wall Check", Config.WallCheck, 135, function(v) Config.WallCheck = v end)

    Label("AIM SETTINGS", 195)

    local info = Instance.new("TextLabel")
    info.Size = UDim2.new(1, -10, 0, 90)
    info.Position = UDim2.fromOffset(5, 225)
    info.BackgroundColor3 = DARK
    info.Text = "HEAD LOCK\n\nFOV: "..Config.FOV.."\nSTRENGTH: "..Config.AimStrength.."\nBREAK ANGLE: "..Config.LockBreakAngle.."°"
    info.TextColor3 = WHITE
    info.TextSize = 11
    info.Font = Enum.Font.GothamMedium
    info.TextXAlignment = Enum.TextXAlignment.Left
    info.ZIndex = 92
    info.Parent = Content

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 10)
    c.Parent = info
end

--========================================================--
-- VISUAL PAGE
--========================================================--

local function ShowVisuals()
    ClearContent()
    Label("ESP", 5)
    Toggle("ESP Enabled", Config.ESPEnabled, 35, function(v) Config.ESPEnabled = v end)
    Toggle("Player Boxes", Config.Boxes, 85, function(v) Config.Boxes = v end)
    Toggle("Health Bars", Config.HealthBars, 135, function(v) Config.HealthBars = v end)
    Toggle("Names", Config.Names, 185, function(v) Config.Names = v end)
    Toggle("Distance", Config.Distances, 235, function(v) Config.Distances = v end)
    Toggle("Head Markers", Config.HeadMarkers, 285, function(v) Config.HeadMarkers = v end)
    Toggle("Tracers", Config.Tracers, 335, function(v) Config.Tracers = v end)
end

--========================================================--
-- CROSSHAIR PAGE
--========================================================--

local function ShowCrosshair()
    ClearContent()
    Label("CROSSHAIR", 5)
    local info = Instance.new("TextLabel")
    info.Size = UDim2.new(1, -10, 0, 100)
    info.Position = UDim2.fromOffset(5, 35)
    info.BackgroundColor3 = DARK
    info.Text = "ACTIVE CROSSHAIR\n\nSize: 7\nGap: 5\nThickness: 2\n\nCenter dot enabled"
    info.TextColor3 = WHITE
    info.TextSize = 11
    info.Font = Enum.Font.GothamMedium
    info.TextXAlignment = Enum.TextXAlignment.Left
    info.ZIndex = 92
    info.Parent = Content
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 10)
    c.Parent = info
end

--========================================================--
-- SETTINGS PAGE
--========================================================--

local function ShowSettings()
    ClearContent()
    Label("SYSTEM", 5)
    local info = Instance.new("TextLabel")
    info.Size = UDim2.new(1, -10, 0, 125)
    info.Position = UDim2.fromOffset(5, 35)
    info.BackgroundColor3 = DARK
    info.Text = "DEVELOPER MODE\n\nUser ID: "..LocalPlayer.UserId.."\n\nExecutor: DELTA\nTarget Part: "..Config.TargetPart
    info.TextColor3 = WHITE
    info.TextSize = 11
    info.Font = Enum.Font.GothamMedium
    info.TextXAlignment = Enum.TextXAlignment.Left
    info.ZIndex = 92
    info.Parent = Content
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 10)
    c.Parent = info
end

ShowCombat()

Script.Track(CombatTab.Activated:Connect(ShowCombat))
Script.Track(VisualTab.Activated:Connect(ShowVisuals))
Script.Track(CrossTab.Activated:Connect(ShowCrosshair))
Script.Track(SettingsTab.Activated:Connect(ShowSettings))

--========================================================--
-- OPEN / CLOSE
--========================================================--

Script.Track(Close.Activated:Connect(function()
    Main.Visible = false
end))

Script.Track(OpenButton.Activated:Connect(function()
    Main.Visible = not Main.Visible
end))

--========================================================--
-- DRAGGING
--========================================================--

local dragging = false
local dragStart
local startPosition

Script.Track(Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch
        or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPosition = Main.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end))

Script.Track(UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.Touch
        or input.UserInputType == Enum.UserInputType.MouseMovement) then
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(
            startPosition.X.Scale,
            startPosition.X.Offset + delta.X,
            startPosition.Y.Scale,
            startPosition.Y.Offset + delta.Y
        )
    end
end))

--========================================================--
-- ESP CONTAINER
--========================================================--

local ESPContainer = Instance.new("Folder")
ESPContainer.Name = "ESP"
ESPContainer.Parent = ScreenGui

local ESPObjects = {}
local CurrentTarget = nil

--========================================================--
-- HELPERS
--========================================================--

local function IsAlive(character)
    if not character then return false end
    local h = character:FindFirstChildOfClass("Humanoid")
    return h and h.Health > 0
end

local function IsEnemy(player)
    if not Config.TeamCheck then return true end
    if not LocalPlayer.Team or not player.Team then return true end
    return LocalPlayer.Team ~= player.Team
end

local function HasLineOfSight(character, part)
    if not Config.WallCheck then return true end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = { LocalPlayer.Character, Camera }
    local result = workspace:Raycast(Camera.CFrame.Position, part.Position - Camera.CFrame.Position, params)
    if not result then return true end
    return result.Instance:IsDescendantOf(character)
end

--========================================================--
-- ESP CREATE / REMOVE
--========================================================--

local function RemoveESP(player)
    if ESPObjects[player] then
        for _, obj in pairs(ESPObjects[player]) do
            if typeof(obj) == "Instance" then
                pcall(function() obj:Destroy() end)
            end
        end
        ESPObjects[player] = nil
    end
end

local function CreateESP(player)
    if player == LocalPlayer then return end
    RemoveESP(player)

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "PlayerInfo"
    billboard.Size = UDim2.fromOffset(180, 70)
    billboard.StudsOffset = Vector3.new(0, 3.3, 0)
    billboard.AlwaysOnTop = true
    billboard.Enabled = Config.ESPEnabled
    billboard.Parent = ESPContainer

    local card = Instance.new("Frame")
    card.Size = UDim2.fromScale(1, 1)
    card.BackgroundColor3 = BLACK
    card.BackgroundTransparency = 0.2
    card.Parent = billboard

    local cardCorner = Instance.new("UICorner")
    cardCorner.CornerRadius = UDim.new(0, 8)
    cardCorner.Parent = card

    local cardStroke = Instance.new("UIStroke")
    cardStroke.Color = WHITE
    cardStroke.Transparency = 0.65
    cardStroke.Thickness = 1
    cardStroke.Parent = card

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "Name"
    nameLabel.BackgroundTransparency = 1
    nameLabel.Size = UDim2.new(1, -16, 0, 22)
    nameLabel.Position = UDim2.fromOffset(8, 3)
    nameLabel.Text = player.DisplayName
    nameLabel.TextColor3 = WHITE
    nameLabel.TextSize = 13
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Parent = card

    local username = Instance.new("TextLabel")
    username.BackgroundTransparency = 1
    username.Size = UDim2.new(1, -16, 0, 15)
    username.Position = UDim2.fromOffset(8, 22)
    username.Text = "@"..player.Name
    username.TextColor3 = MUTED
    username.TextSize = 10
    username.Font = Enum.Font.Gotham
    username.TextXAlignment = Enum.TextXAlignment.Left
    username.Parent = card

    local healthBack = Instance.new("Frame")
    healthBack.Name = "HealthBack"
    healthBack.Size = UDim2.new(1, -16, 0, 7)
    healthBack.Position = UDim2.fromOffset(8, 42)
    healthBack.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    healthBack.BorderSizePixel = 0
    healthBack.Parent = card

    local healthCorner = Instance.new("UICorner")
    healthCorner.CornerRadius = UDim.new(1, 0)
    healthCorner.Parent = healthBack

    local healthFill = Instance.new("Frame")
    healthFill.Name = "Health"
    healthFill.Size = UDim2.fromScale(1, 1)
    healthFill.BackgroundColor3 = GREEN
    healthFill.BorderSizePixel = 0
    healthFill.Parent = healthBack

    local healthFillCorner = Instance.new("UICorner")
    healthFillCorner.CornerRadius = UDim.new(1, 0)
    healthFillCorner.Parent = healthFill

    local info = Instance.new("TextLabel")
    info.Name = "Info"
    info.BackgroundTransparency = 1
    info.Size = UDim2.new(1, -16, 0, 17)
    info.Position = UDim2.fromOffset(8, 50)
    info.Text = ""
    info.TextColor3 = WHITE
    info.TextSize = 9
    info.Font = Enum.Font.GothamMedium
    info.TextXAlignment = Enum.TextXAlignment.Left
    info.Parent = card

    local box = Instance.new("SelectionBox")
    box.Name = "Box"
    box.LineThickness = 0.025
    box.Color3 = WHITE
    box.SurfaceTransparency = 1
    box.Visible = Config.Boxes
    box.Parent = ESPContainer

    local headMarker = Instance.new("BillboardGui")
    headMarker.Name = "HeadMarker"
    headMarker.Size = UDim2.fromOffset(12, 12)
    headMarker.AlwaysOnTop = true
    headMarker.Enabled = Config.HeadMarkers
    headMarker.Parent = ESPContainer

    local marker = Instance.new("Frame")
    marker.Size = UDim2.fromScale(1, 1)
    marker.BackgroundColor3 = RED
    marker.BorderSizePixel = 0
    marker.Parent = headMarker

    local markerCorner = Instance.new("UICorner")
    markerCorner.CornerRadius = UDim.new(1, 0)
    markerCorner.Parent = marker

    local tracer = Instance.new("Frame")
    tracer.Name = "Tracer"
    tracer.BackgroundColor3 = WHITE
    tracer.BorderSizePixel = 0
    tracer.AnchorPoint = Vector2.new(0.5, 0.5)
    tracer.Visible = false
    tracer.ZIndex = 1
    tracer.Parent = ScreenGui

    ESPObjects[player] = {
        Billboard = billboard,
        Card = card,
        CardStroke = cardStroke,
        Name = nameLabel,
        HealthFill = healthFill,
        Info = info,
        Box = box,
        HeadMarker = headMarker,
        Marker = marker,
        Tracer = tracer,
    }

    local function BindCharacter(character)
        local head = character:WaitForChild("Head", 5)
        if head then
            billboard.Adornee = head
            headMarker.Adornee = head
        end
        box.Adornee = character
    end

    if player.Character then
        task.spawn(BindCharacter, player.Character)
    end

    Script.Track(player.CharacterAdded:Connect(function(character)
        task.wait(0.2)
        BindCharacter(character)
    end))
end

for _, player in ipairs(Players:GetPlayers()) do
    CreateESP(player)
end

Script.Track(Players.PlayerAdded:Connect(CreateESP))
Script.Track(Players.PlayerRemoving:Connect(RemoveESP))

--========================================================--
-- TARGETING
--========================================================--

local function GetTarget()
    local viewport = Camera.ViewportSize
    local center = Vector2.new(viewport.X / 2, viewport.Y / 2)
    local best, bestDistance = nil, Config.FOV

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and IsEnemy(player) and IsAlive(player.Character) then
            local head = player.Character:FindFirstChild(Config.TargetPart)
            if head then
                local screen, visible = Camera:WorldToViewportPoint(head.Position)
                if visible and screen.Z > 0 then
                    local distance = (Vector2.new(screen.X, screen.Y) - center).Magnitude
                    if distance < bestDistance and HasLineOfSight(player.Character, head) then
                        bestDistance = distance
                        best = player
                    end
                end
            end
        end
    end
    return best
end

local function GetAngle(player)
    if not player or not player.Character then return math.huge end
    local head = player.Character:FindFirstChild(Config.TargetPart)
    if not head then return math.huge end
    local direction = (head.Position - Camera.CFrame.Position).Unit
    local dot = math.clamp(Camera.CFrame.LookVector:Dot(direction), -1, 1)
    return math.deg(math.acos(dot))
end

local function AimAt(player)
    if not player or not player.Character then return end
    local head = player.Character:FindFirstChild(Config.TargetPart)
    if not head then return end
    local targetCFrame = CFrame.lookAt(Camera.CFrame.Position, head.Position)
    Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, Config.AimStrength)
end

--========================================================--
-- UPDATE ESP
--========================================================--

local function UpdateESP()
    local viewport = Camera.ViewportSize
    local tracerOrigin = Vector2.new(viewport.X / 2, viewport.Y)

    for player, data in pairs(ESPObjects) do
        if not player.Parent then
            RemoveESP(player)
            continue
        end

        local character = player.Character
        if not character or not IsAlive(character) then
            data.Billboard.Enabled = false
            data.HeadMarker.Enabled = false
            data.Box.Visible = false
            data.Tracer.Visible = false
            continue
        end

        local humanoid = character:FindFirstChildOfClass("Humanoid")
        local head = character:FindFirstChild("Head")
        if not humanoid or not head then continue end

        local enabled = Config.ESPEnabled and IsEnemy(player)

        data.Billboard.Enabled = enabled and (Config.Names or Config.HealthBars or Config.Distances)
        data.HeadMarker.Enabled = enabled and Config.HeadMarkers
        data.Box.Visible = enabled and Config.Boxes
        data.Billboard.Adornee = head
        data.HeadMarker.Adornee = head
        data.Box.Adornee = character

        local healthPercent = math.clamp(humanoid.Health / math.max(humanoid.MaxHealth, 1), 0, 1)
        data.HealthFill.Size = UDim2.new(healthPercent, 0, 1, 0)

        if healthPercent > 0.5 then
            data.HealthFill.BackgroundColor3 = GREEN
        elseif healthPercent > 0.25 then
            data.HealthFill.BackgroundColor3 = Color3.fromRGB(255, 210, 70)
        else
            data.HealthFill.BackgroundColor3 = RED
        end

        local distance = (Camera.CFrame.Position - head.Position).Magnitude
        data.Info.Text = math.floor(humanoid.Health).." / "..math.floor(humanoid.MaxHealth).." HP  •  "..math.floor(distance).." studs"
        data.Name.Visible = Config.Names
        data.Info.Visible = Config.HealthBars or Config.Distances
        data.HealthFill.Parent.Visible = Config.HealthBars

        if enabled and Config.Tracers then
            local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
            if onScreen and screenPos.Z > 0 then
                local target2D = Vector2.new(screenPos.X, screenPos.Y)
                local delta = target2D - tracerOrigin
                local length = delta.Magnitude
                data.Tracer.Visible = true
                data.Tracer.Size = UDim2.fromOffset(length, 1)
                data.Tracer.Position = UDim2.fromOffset(
                    (tracerOrigin.X + target2D.X) / 2,
                    (tracerOrigin.Y + target2D.Y) / 2
                )
                data.Tracer.Rotation = math.deg(math.atan2(delta.Y, delta.X))
                data.Tracer.BackgroundColor3 = (player == CurrentTarget) and WHITE or MUTED
            else
                data.Tracer.Visible = false
            end
        else
            data.Tracer.Visible = false
        end

        if player == CurrentTarget then
            data.CardStroke.Transparency = 0.1
            data.Marker.BackgroundColor3 = WHITE
        else
            data.CardStroke.Transparency = 0.65
            data.Marker.BackgroundColor3 = RED
        end
    end
end

--========================================================--
-- MAIN LOOP
--========================================================--

Script.Track(RunService.RenderStepped:Connect(function()
    Camera = workspace.CurrentCamera
    if not Camera then return end

    if CurrentTarget then
        if not CurrentTarget.Character
            or not IsAlive(CurrentTarget.Character)
            or not IsEnemy(CurrentTarget)
            or GetAngle(CurrentTarget) > Config.LockBreakAngle then
            CurrentTarget = nil
        end
    end

    if not CurrentTarget then
        CurrentTarget = GetTarget()
    end

    if Config.AimEnabled and CurrentTarget then
        AimAt(CurrentTarget)
    end

    UpdateESP()
end))

print("[DSTv2] Loaded. Tap the 'S' button on the left side to open the menu.")
