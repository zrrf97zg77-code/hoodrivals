--// HOOD RIVALS
--// DELTA EXECUTOR — CAMLOCK + ESP + TRIGGERBOT
--// v3.6  |  Fixed toggles (track + knob + big tap target)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local SoundService = game:GetService("SoundService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

--==================================================
-- CONFIG
--==================================================

local Settings = {
    Enabled = false,
    FOV = 180,
    Smoothness = 0.35,
    TeamCheck = true,
    WallCheck = true,
    TargetPart = "Head",
    ShowFOV = true,
    LockOn = true,
    PriorityMode = "FOV",
    IgnoreDowned = true,
    MinHealth = 0,
    MaxDistance = 500,

    TriggerBot = false,
    TriggerDelay = 0.05,
    lastTrigger = 0,

    HitSound = true,
    KillNotifier = true,

    Crosshair = true,
    CrosshairColor = Color3.fromRGB(0, 255, 140),
    CrosshairSize = 10,

    ESPEnabled = true,
    ESPBox = true,
    ESPHealth = true,
    ESPName = true,
    ESPTracer = true,
    ESPDistance = true,
    ESPHeadDot = true,
    ESPColor = Color3.fromRGB(255, 60, 60),
    ESPTeamColor = false,

    UIColors = {
        bg = Color3.fromRGB(10, 10, 14),
        panel = Color3.fromRGB(16, 16, 22),
        accent = Color3.fromRGB(120, 90, 255),
        accent2 = Color3.fromRGB(200, 80, 255),
        text = Color3.fromRGB(245, 245, 250),
        subtext = Color3.fromRGB(120, 120, 135),
        success = Color3.fromRGB(80, 220, 120),
    },
}

--==================================================
-- GUI PARENT
--==================================================

local function GetGuiParent()
    local pg = LocalPlayer:FindFirstChildOfClass("PlayerGui")
        or LocalPlayer:WaitForChild("PlayerGui", 5)
    if pg then return pg end
    if gethui then
        local ok, hui = pcall(gethui)
        if ok and hui then return hui end
    end
    return game:GetService("CoreGui")
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "HoodRivalsProUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.Enabled = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
task.defer(function() ScreenGui.Parent = GetGuiParent() end)

local ESPGui = Instance.new("ScreenGui")
ESPGui.Name = "HoodRivalsESP"
ESPGui.ResetOnSpawn = false
ESPGui.IgnoreGuiInset = true
ESPGui.Enabled = true
ESPGui.DisplayOrder = 5
ESPGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
task.defer(function() ESPGui.Parent = GetGuiParent() end)

--==================================================
-- UTILITY
--==================================================

local function Corner(parent, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 10)
    c.Parent = parent
    return c
end

local function Stroke(parent, color, thick, transparency)
    local s = Instance.new("UIStroke")
    s.Color = color or Color3.fromRGB(60, 60, 75)
    s.Thickness = thick or 1
    s.Transparency = transparency or 0
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = parent
    return s
end

local function Gradient(parent, c1, c2, rotation)
    local g = Instance.new("UIGradient")
    g.Color = ColorSequence.new(c1, c2)
    g.Rotation = rotation or 45
    g.Parent = parent
    return g
end

local function Padding(parent, t, r, b, l)
    local p = Instance.new("UIPadding")
    p.PaddingTop = UDim.new(0, t or 0)
    p.PaddingRight = UDim.new(0, r or 0)
    p.PaddingBottom = UDim.new(0, b or 0)
    p.PaddingLeft = UDim.new(0, l or 0)
    p.Parent = parent
    return p
end

--==================================================
-- FLOATING OPEN BUTTON
--==================================================

local OpenWrapper = Instance.new("Frame")
OpenWrapper.Name = "OpenWrapper"
OpenWrapper.Size = UDim2.fromOffset(54, 54)
OpenWrapper.Position = UDim2.new(0, 12, 0.5, -27)
OpenWrapper.BackgroundTransparency = 1
OpenWrapper.Parent = ScreenGui

local GlowRing = Instance.new("Frame")
GlowRing.Size = UDim2.fromOffset(54, 54)
GlowRing.BackgroundColor3 = Settings.UIColors.accent
GlowRing.BackgroundTransparency = 0.65
GlowRing.Parent = OpenWrapper
Corner(GlowRing, 27)

local GlowRingInner = Instance.new("Frame")
GlowRingInner.Size = UDim2.fromOffset(44, 44)
GlowRingInner.Position = UDim2.fromOffset(5, 5)
GlowRingInner.BackgroundColor3 = Color3.fromRGB(10, 10, 14)
GlowRingInner.Parent = OpenWrapper
Corner(GlowRingInner, 22)

local OpenButton = Instance.new("TextButton")
OpenButton.Size = UDim2.fromOffset(44, 44)
OpenButton.Position = UDim2.fromOffset(5, 5)
OpenButton.BackgroundColor3 = Settings.UIColors.bg
OpenButton.Text = "HR"
OpenButton.TextColor3 = Color3.fromRGB(255, 255, 255)
OpenButton.TextSize = 15
OpenButton.Font = Enum.Font.GothamBold
OpenButton.AutoButtonColor = false
OpenButton.Active = true
OpenButton.Parent = OpenWrapper
Corner(OpenButton, 22)
Stroke(OpenButton, Settings.UIColors.accent, 1.5, 0.3)

task.spawn(function()
    while OpenWrapper.Parent do
        TweenService:Create(GlowRing,
            TweenInfo.new(1.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
            { BackgroundTransparency = 0.35, Size = UDim2.fromOffset(60, 60), Position = UDim2.fromOffset(-3, -3) }
        ):Play()
        task.wait(1.4)
        TweenService:Create(GlowRing,
            TweenInfo.new(1.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
            { BackgroundTransparency = 0.7, Size = UDim2.fromOffset(54, 54), Position = UDim2.fromOffset(0, 0) }
        ):Play()
        task.wait(1.4)
    end
end)

do
    local dragging, dragStart, startPos
    OpenWrapper.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = OpenWrapper.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            OpenWrapper.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

--==================================================
-- MAIN WINDOW
--==================================================

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.fromOffset(310, 420)
Main.Position = UDim2.new(0.5, -155, 0.5, -210)
Main.BackgroundColor3 = Settings.UIColors.bg
Main.Visible = false
Main.Active = true
Main.ClipsDescendants = true
Main.Parent = ScreenGui
Corner(Main, 16)
Stroke(Main, Settings.UIColors.accent, 1.2, 0.35)

local MainGradient = Instance.new("Frame")
MainGradient.Size = UDim2.new(1, 0, 1, 0)
MainGradient.BackgroundColor3 = Settings.UIColors.accent
MainGradient.BackgroundTransparency = 0.94
MainGradient.ZIndex = 0
MainGradient.Parent = Main
Corner(MainGradient, 16)
Gradient(MainGradient, Settings.UIColors.accent, Settings.UIColors.accent2, 135)

local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 58)
TitleBar.BackgroundTransparency = 1
TitleBar.ZIndex = 2
TitleBar.Parent = Main

do
    local dragging, dragStart, startPos
    TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = Main.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch) then
            local d = input.Position - dragStart
            Main.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + d.X,
                startPos.Y.Scale, startPos.Y.Offset + d.Y
            )
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

local Logo = Instance.new("Frame")
Logo.Size = UDim2.fromOffset(34, 34)
Logo.Position = UDim2.fromOffset(12, 12)
Logo.BackgroundColor3 = Settings.UIColors.accent
Logo.ZIndex = 3
Logo.Parent = TitleBar
Corner(Logo, 10)
Gradient(Logo, Settings.UIColors.accent, Settings.UIColors.accent2, 45)

local LogoText = Instance.new("TextLabel")
LogoText.Size = UDim2.new(1, 0, 1, 0)
LogoText.BackgroundTransparency = 1
LogoText.Text = "HR"
LogoText.TextColor3 = Color3.fromRGB(255, 255, 255)
LogoText.TextSize = 13
LogoText.Font = Enum.Font.GothamBlack
LogoText.ZIndex = 4
LogoText.Parent = Logo

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -130, 0, 18)
TitleLabel.Position = UDim2.fromOffset(54, 14)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "HOOD RIVALS"
TitleLabel.TextColor3 = Settings.UIColors.text
TitleLabel.TextSize = 14
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.ZIndex = 3
TitleLabel.Parent = TitleBar

local StatsLabel = Instance.new("TextLabel")
StatsLabel.Size = UDim2.fromOffset(110, 14)
StatsLabel.Position = UDim2.fromOffset(54, 32)
StatsLabel.BackgroundTransparency = 1
StatsLabel.Text = "FPS -- | --ms"
StatsLabel.TextColor3 = Settings.UIColors.subtext
StatsLabel.TextSize = 9
StatsLabel.Font = Enum.Font.GothamMedium
StatsLabel.TextXAlignment = Enum.TextXAlignment.Left
StatsLabel.ZIndex = 3
StatsLabel.Parent = TitleBar

local VersionPill = Instance.new("Frame")
VersionPill.Size = UDim2.fromOffset(38, 16)
VersionPill.Position = UDim2.new(1, -114, 0, 20)
VersionPill.BackgroundColor3 = Settings.UIColors.accent
VersionPill.BackgroundTransparency = 0.8
VersionPill.ZIndex = 3
VersionPill.Parent = TitleBar
Corner(VersionPill, 8)

local VersionText = Instance.new("TextLabel")
VersionText.Size = UDim2.new(1, 0, 1, 0)
VersionText.BackgroundTransparency = 1
VersionText.Text = "v3.6"
VersionText.TextColor3 = Settings.UIColors.accent
VersionText.TextSize = 9
VersionText.Font = Enum.Font.GothamBold
VersionText.ZIndex = 4
VersionText.Parent = VersionPill

local StatusDot = Instance.new("Frame")
StatusDot.Size = UDim2.fromOffset(7, 7)
StatusDot.Position = UDim2.new(1, -70, 0, 24)
StatusDot.BackgroundColor3 = Settings.UIColors.subtext
StatusDot.ZIndex = 3
StatusDot.Parent = TitleBar
Corner(StatusDot, 4)

local Close = Instance.new("TextButton")
Close.Size = UDim2.fromOffset(28, 28)
Close.Position = UDim2.new(1, -36, 0, 16)
Close.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
Close.Text = "×"
Close.TextColor3 = Color3.fromRGB(210, 210, 220)
Close.TextSize = 18
Close.Font = Enum.Font.GothamBold
Close.AutoButtonColor = false
Close.ZIndex = 3
Close.Parent = TitleBar
Corner(Close, 8)

local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(1, -24, 0, 30)
TabBar.Position = UDim2.fromOffset(12, 58)
TabBar.BackgroundColor3 = Settings.UIColors.panel
TabBar.ZIndex = 2
TabBar.Parent = Main
Corner(TabBar, 10)

local TabLayout = Instance.new("UIListLayout")
TabLayout.FillDirection = Enum.FillDirection.Horizontal
TabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
TabLayout.VerticalAlignment = Enum.VerticalAlignment.Center
TabLayout.Padding = UDim.new(0, 3)
TabLayout.Parent = TabBar

local TabIndicator = Instance.new("Frame")
TabIndicator.Size = UDim2.new(0, 0, 1, -6)
TabIndicator.Position = UDim2.new(0, 0, 0, 3)
TabIndicator.BackgroundColor3 = Settings.UIColors.accent
TabIndicator.ZIndex = 3
TabIndicator.Parent = TabBar
Corner(TabIndicator, 6)
Gradient(TabIndicator, Settings.UIColors.accent, Settings.UIColors.accent2, 0)

local PageFrame = Instance.new("Frame")
PageFrame.Size = UDim2.new(1, -24, 1, -144)
PageFrame.Position = UDim2.fromOffset(12, 94)
PageFrame.BackgroundTransparency = 1
PageFrame.ZIndex = 2
PageFrame.Parent = Main

local Pages = {}

local function CreatePage(name)
    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 2
    page.ScrollBarImageColor3 = Settings.UIColors.accent
    page.ScrollBarImageTransparency = 0.4
    page.CanvasSize = UDim2.new()
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.Visible = false
    page.ZIndex = 2
    page.Parent = PageFrame

    local list = Instance.new("UIListLayout")
    list.Padding = UDim.new(0, 7)
    list.Parent = page
    Padding(page, 2, 4, 8, 2)

    Pages[name] = page
    return page
end

local Tabs = {}
local currentPage = nil

local function CreateTab(name)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.fromOffset(58, 22)
    btn.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
    btn.BackgroundTransparency = 1
    btn.Text = name
    btn.TextColor3 = Settings.UIColors.subtext
    btn.TextSize = 10
    btn.Font = Enum.Font.GothamBold
    btn.AutoButtonColor = false
    btn.Parent = TabBar
    Corner(btn, 6)

    Tabs[name] = { btn = btn }

    btn.MouseButton1Click:Connect(function()
        for n, t in pairs(Tabs) do
            t.btn.TextColor3 = Settings.UIColors.subtext
            t.btn.BackgroundTransparency = 1
            if Pages[n] then Pages[n].Visible = false end
        end
        btn.TextColor3 = Settings.UIColors.text
        btn.BackgroundTransparency = 0.85
        btn.BackgroundColor3 = Settings.UIColors.accent
        if Pages[name] then
            Pages[name].Visible = true
            currentPage = name
        end
        local targetX = btn.AbsolutePosition.X - TabBar.AbsolutePosition.X
        TweenService:Create(TabIndicator, TweenInfo.new(0.22, Enum.EasingStyle.Quart), {
            Position = UDim2.fromOffset(targetX, 3),
            Size = UDim2.new(0, btn.AbsoluteSize.X, 1, -6),
        }):Play()
    end)

    return btn
end

--==================================================
-- COMPONENTS
--==================================================

local function CreateSectionLabel(parent, text)
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1, -6, 0, 18)
    holder.BackgroundTransparency = 1
    holder.Parent = parent

    local bar = Instance.new("Frame")
    bar.Size = UDim2.fromOffset(3, 12)
    bar.Position = UDim2.fromOffset(0, 3)
    bar.BackgroundColor3 = Settings.UIColors.accent
    bar.Parent = holder
    Corner(bar, 2)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -12, 1, 0)
    label.Position = UDim2.fromOffset(10, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Settings.UIColors.subtext
    label.TextSize = 9
    label.Font = Enum.Font.GothamBold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = holder
end

local function CreateToggle(parent, name, description, default, callback)
    local Holder = Instance.new("Frame")
    Holder.Size = UDim2.new(1, -6, 0, 50)
    Holder.BackgroundColor3 = Settings.UIColors.panel
    Holder.Parent = parent
    Corner(Holder, 10)
    Stroke(Holder, Color3.fromRGB(35, 35, 48), 1, 0.4)

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -80, 0, 18)
    Label.Position = UDim2.fromOffset(10, 6)
    Label.BackgroundTransparency = 1
    Label.Text = name
    Label.TextColor3 = Settings.UIColors.text
    Label.TextSize = 12
    Label.Font = Enum.Font.GothamSemibold
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Holder

    local Desc = Instance.new("TextLabel")
    Desc.Size = UDim2.new(1, -80, 0, 14)
    Desc.Position = UDim2.fromOffset(10, 26)
    Desc.BackgroundTransparency = 1
    Desc.Text = description
    Desc.TextColor3 = Settings.UIColors.subtext
    Desc.TextSize = 9
    Desc.Font = Enum.Font.Gotham
    Desc.TextXAlignment = Enum.TextXAlignment.Left
    Desc.Parent = Holder

    -- Visible track (pill)
    local Track = Instance.new("Frame")
    Track.Size = UDim2.fromOffset(52, 28)
    Track.Position = UDim2.new(1, -62, 0.5, -14)
    Track.BackgroundColor3 = Color3.fromRGB(60, 60, 78)
    Track.BorderSizePixel = 0
    Track.Parent = Holder
    Corner(Track, 14)
    local TrackStroke = Stroke(Track, Color3.fromRGB(100, 100, 130), 1.5, 0)

    -- Big invisible button covering the track + extra tap area
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.fromOffset(64, 40)
    Button.Position = UDim2.new(1, -68, 0.5, -20)
    Button.BackgroundTransparency = 1
    Button.Text = ""
    Button.AutoButtonColor = false
    Button.Active = true
    Button.ZIndex = 5
    Button.Parent = Holder

    -- Sliding knob
    local Knob = Instance.new("Frame")
    Knob.Size = UDim2.fromOffset(22, 22)
    Knob.Position = UDim2.fromOffset(3, 3)
    Knob.BackgroundColor3 = Color3.fromRGB(235, 235, 245)
    Knob.BorderSizePixel = 0
    Knob.ZIndex = 4
    Knob.Parent = Track
    Corner(Knob, 11)

    local state = default or false

    local function Update()
        local info = TweenInfo.new(0.18, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
        if state then
            TweenService:Create(Knob, info, {
                Position = UDim2.fromOffset(27, 3),
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            }):Play()
            TweenService:Create(Track, info, {
                BackgroundColor3 = Settings.UIColors.accent,
            }):Play()
            TrackStroke.Color = Settings.UIColors.accent
        else
            TweenService:Create(Knob, info, {
                Position = UDim2.fromOffset(3, 3),
                BackgroundColor3 = Color3.fromRGB(235, 235, 245),
            }):Play()
            TweenService:Create(Track, info, {
                BackgroundColor3 = Color3.fromRGB(60, 60, 78),
            }):Play()
            TrackStroke.Color = Color3.fromRGB(100, 100, 130)
        end
    end

    local function flip()
        state = not state
        Update()
        callback(state)
    end

    Button.MouseButton1Click:Connect(flip)
    Button.Activated:Connect(flip)

    Update()
    return Holder
end

local function CreateSlider(parent, name, minimum, maximum, default, callback)
    local Holder = Instance.new("Frame")
    Holder.Size = UDim2.new(1, -6, 0, 62)
    Holder.BackgroundColor3 = Settings.UIColors.panel
    Holder.Parent = parent
    Corner(Holder, 10)
    Stroke(Holder, Color3.fromRGB(35, 35, 48), 1, 0.4)

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -90, 0, 18)
    Label.Position = UDim2.fromOffset(10, 6)
    Label.BackgroundTransparency = 1
    Label.Text = name
    Label.TextColor3 = Settings.UIColors.text
    Label.TextSize = 12
    Label.Font = Enum.Font.GothamSemibold
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Holder

    local ValuePill = Instance.new("Frame")
    ValuePill.Size = UDim2.fromOffset(60, 18)
    ValuePill.Position = UDim2.new(1, -70, 0, 6)
    ValuePill.BackgroundColor3 = Settings.UIColors.accent
    ValuePill.BackgroundTransparency = 0.85
    ValuePill.Parent = Holder
    Corner(ValuePill, 6)

    local ValueText = Instance.new("TextLabel")
    ValueText.Size = UDim2.new(1, 0, 1, 0)
    ValueText.BackgroundTransparency = 1
    ValueText.Text = tostring(default)
    ValueText.TextColor3 = Settings.UIColors.accent
    ValueText.TextSize = 10
    ValueText.Font = Enum.Font.GothamBold
    ValueText.Parent = ValuePill

    local Bar = Instance.new("Frame")
    Bar.Size = UDim2.new(1, -20, 0, 7)
    Bar.Position = UDim2.fromOffset(10, 40)
    Bar.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
    Bar.Parent = Holder
    Corner(Bar, 4)

    local Fill = Instance.new("Frame")
    Fill.Size = UDim2.new((default - minimum) / (maximum - minimum), 0, 1, 0)
    Fill.BackgroundColor3 = Settings.UIColors.accent
    Fill.Parent = Bar
    Corner(Fill, 4)
    Gradient(Fill, Settings.UIColors.accent, Settings.UIColors.accent2, 0)

    local Knob = Instance.new("Frame")
    Knob.Size = UDim2.fromOffset(14, 14)
    Knob.AnchorPoint = Vector2.new(0.5, 0.5)
    Knob.Position = UDim2.new(Fill.Size.X.Scale, 0, 0.5, 0)
    Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Knob.Parent = Bar
    Corner(Knob, 7)
    Stroke(Knob, Settings.UIColors.accent, 2, 0)

    local dragging = false

    local function Update(x)
        local percent = math.clamp((x - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
        local value = minimum + (maximum - minimum) * percent
        value = math.floor(value * 100) / 100
        Fill.Size = UDim2.new(percent, 0, 1, 0)
        Knob.Position = UDim2.new(percent, 0, 0.5, 0)
        ValueText.Text = tostring(value)
        callback(value)
    end

    Bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch
        or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            Update(input.Position.X)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.Touch
        or input.UserInputType == Enum.UserInputType.MouseMovement) then
            Update(input.Position.X)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch
        or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    return Holder
end

local function CreateDropdown(parent, name, options, default, callback)
    local Holder = Instance.new("Frame")
    Holder.Size = UDim2.new(1, -6, 0, 50)
    Holder.BackgroundColor3 = Settings.UIColors.panel
    Holder.ClipsDescendants = true
    Holder.Parent = parent
    Corner(Holder, 10)
    Stroke(Holder, Color3.fromRGB(35, 35, 48), 1, 0.4)

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -90, 1, 0)
    Label.Position = UDim2.fromOffset(10, 0)
    Label.BackgroundTransparency = 1
    Label.Text = name
    Label.TextColor3 = Settings.UIColors.text
    Label.TextSize = 12
    Label.Font = Enum.Font.GothamSemibold
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Holder

    local Selector = Instance.new("TextButton")
    Selector.Size = UDim2.fromOffset(90, 26)
    Selector.Position = UDim2.new(1, -100, 0.5, -13)
    Selector.BackgroundColor3 = Color3.fromRGB(32, 32, 42)
    Selector.Text = tostring(default)
    Selector.TextColor3 = Settings.UIColors.text
    Selector.TextSize = 10
    Selector.Font = Enum.Font.GothamSemibold
    Selector.AutoButtonColor = false
    Selector.Parent = Holder
    Corner(Selector, 8)
    Stroke(Selector, Color3.fromRGB(50, 50, 65), 1, 0.4)

    local open = false

    local function Build()
        local overlay = Instance.new("Frame")
        overlay.Size = UDim2.new(1, 0, 0, #options * 26)
        overlay.Position = UDim2.fromOffset(0, 50)
        overlay.BackgroundColor3 = Settings.UIColors.panel
        overlay.BorderSizePixel = 0
        overlay.Parent = Holder

        local list = Instance.new("UIListLayout")
        list.Padding = UDim.new(0, 2)
        list.Parent = overlay
        Padding(overlay, 3, 4, 3, 4)

        for _, opt in ipairs(options) do
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, 0, 0, 22)
            btn.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
            btn.Text = tostring(opt)
            btn.TextColor3 = Settings.UIColors.text
            btn.TextSize = 10
            btn.Font = Enum.Font.Gotham
            btn.AutoButtonColor = false
            btn.Parent = overlay
            Corner(btn, 6)

            btn.MouseButton1Click:Connect(function()
                Selector.Text = tostring(opt)
                callback(opt)
                overlay:Destroy()
                TweenService:Create(Holder, TweenInfo.new(0.18), {
                    Size = UDim2.new(1, -6, 0, 50)
                }):Play()
                open = false
            end)
        end
    end

    Selector.MouseButton1Click:Connect(function()
        if open then return end
        open = true
        Build()
        TweenService:Create(Holder, TweenInfo.new(0.2, Enum.EasingStyle.Quart), {
            Size = UDim2.new(1, -6, 0, 50 + #options * 26)
        }):Play()
    end)

    return Holder
end

--==================================================
-- BUILD TABS + PAGES
--==================================================

CreatePage("Aim")
CreatePage("ESP")
CreatePage("Extras")
CreatePage("Misc")

CreateTab("Aim")
CreateTab("ESP")
CreateTab("Extras")
CreateTab("Misc")

-- AIM
do
    local p = Pages["Aim"]
    CreateSectionLabel(p, "CORE")
    CreateToggle(p, "AIM ASSIST", "Master toggle", Settings.Enabled, function(v)
        Settings.Enabled = v
        StatusDot.BackgroundColor3 = v and Settings.UIColors.success or Settings.UIColors.subtext
    end)
    CreateToggle(p, "SHOW FOV", "Aim radius circle", Settings.ShowFOV, function(v) Settings.ShowFOV = v end)
    CreateToggle(p, "TEAM CHECK", "Ignore teammates", Settings.TeamCheck, function(v) Settings.TeamCheck = v end)
    CreateToggle(p, "WALL CHECK", "Line-of-sight only", Settings.WallCheck, function(v) Settings.WallCheck = v end)

    CreateSectionLabel(p, "TRIGGERBOT")
    CreateToggle(p, "TRIGGERBOT", "Auto-fire on target", Settings.TriggerBot, function(v) Settings.TriggerBot = v end)
    CreateSlider(p, "TRIGGER DELAY", 0.01, 0.5, Settings.TriggerDelay, function(v) Settings.TriggerDelay = v end)

    CreateSectionLabel(p, "BEHAVIOR")
    CreateDropdown(p, "PRIORITY", {"FOV", "Distance", "Health", "Threat"}, Settings.PriorityMode, function(v) Settings.PriorityMode = v end)
    CreateToggle(p, "LOCK-ON", "Sticky targeting", Settings.LockOn, function(v) Settings.LockOn = v end)
    CreateToggle(p, "IGNORE LOW HP", "Skip downed", Settings.IgnoreDowned, function(v) Settings.IgnoreDowned = v end)

    CreateSectionLabel(p, "TUNING")
    CreateSlider(p, "FOV", 30, 600, Settings.FOV, function(v) Settings.FOV = v end)
    CreateSlider(p, "SMOOTHNESS", 0.05, 1, Settings.Smoothness, function(v) Settings.Smoothness = v end)
    CreateSlider(p, "MAX DISTANCE", 50, 1000, Settings.MaxDistance, function(v) Settings.MaxDistance = v end)
    CreateSlider(p, "MIN HEALTH %", 0, 100, Settings.MinHealth, function(v) Settings.MinHealth = v end)
end

-- ESP
do
    local p = Pages["ESP"]
    CreateSectionLabel(p, "MASTER")
    CreateToggle(p, "ESP ENABLED", "Show all ESP", Settings.ESPEnabled, function(v) Settings.ESPEnabled = v end)

    CreateSectionLabel(p, "ELEMENTS")
    CreateToggle(p, "BOX", "Bounding box", Settings.ESPBox, function(v) Settings.ESPBox = v end)
    CreateToggle(p, "HEALTH BAR", "HP indicator", Settings.ESPHealth, function(v) Settings.ESPHealth = v end)
    CreateToggle(p, "NAME", "Player username", Settings.ESPName, function(v) Settings.ESPName = v end)
    CreateToggle(p, "TRACER", "Line to target", Settings.ESPTracer, function(v) Settings.ESPTracer = v end)
    CreateToggle(p, "DISTANCE", "Stud distance", Settings.ESPDistance, function(v) Settings.ESPDistance = v end)
    CreateToggle(p, "HEAD DOT", "Dot on head", Settings.ESPHeadDot, function(v) Settings.ESPHeadDot = v end)

    CreateSectionLabel(p, "STYLE")
    CreateToggle(p, "TEAM COLOR", "Use team colors", Settings.ESPTeamColor, function(v) Settings.ESPTeamColor = v end)
end

-- EXTRAS
do
    local p = Pages["Extras"]
    CreateSectionLabel(p, "FEEDBACK")
    CreateToggle(p, "HIT SOUND", "Sound on damage", Settings.HitSound, function(v) Settings.HitSound = v end)
    CreateToggle(p, "KILL NOTIFIER", "Death popup", Settings.KillNotifier, function(v) Settings.KillNotifier = v end)

    CreateSectionLabel(p, "CROSSHAIR")
    CreateToggle(p, "SHOW CROSSHAIR", "Center dot", Settings.Crosshair, function(v) Settings.Crosshair = v end)
    CreateSlider(p, "CROSSHAIR SIZE", 4, 40, Settings.CrosshairSize, function(v) Settings.CrosshairSize = v end)
end

-- MISC
do
    local p = Pages["Misc"]
    CreateSectionLabel(p, "TARGET PART")
    CreateDropdown(p, "TARGET PART", {"Head", "UpperTorso", "HumanoidRootPart", "LowerTorso"}, Settings.TargetPart, function(v) Settings.TargetPart = v end)

    CreateSectionLabel(p, "CONFIG")
    local saveBtn = Instance.new("TextButton")
    saveBtn.Size = UDim2.new(1, -6, 0, 36)
    saveBtn.BackgroundColor3 = Settings.UIColors.panel
    saveBtn.Text = "SAVE CONFIG"
    saveBtn.TextColor3 = Settings.UIColors.text
    saveBtn.TextSize = 11
    saveBtn.Font = Enum.Font.GothamBold
    saveBtn.AutoButtonColor = false
    saveBtn.Parent = p
    Corner(saveBtn, 10)
    Stroke(saveBtn, Color3.fromRGB(35, 35, 48), 1, 0.4)

    saveBtn.MouseButton1Click:Connect(function()
        pcall(function()
            local data = {}
            for k, v in pairs(Settings) do
                if type(v) == "number" or type(v) == "boolean" or type(v) == "string" then
                    data[k] = v
                end
            end
            if writefile then
                writefile("hoodrivals_config.json", HttpService:JSONEncode(data))
                saveBtn.Text = "SAVED ✓"
                task.wait(1.2)
                saveBtn.Text = "SAVE CONFIG"
            end
        end)
    end)

    local loadBtn = Instance.new("TextButton")
    loadBtn.Size = UDim2.new(1, -6, 0, 36)
    loadBtn.BackgroundColor3 = Settings.UIColors.panel
    loadBtn.Text = "LOAD CONFIG"
    loadBtn.TextColor3 = Settings.UIColors.text
    loadBtn.TextSize = 11
    loadBtn.Font = Enum.Font.GothamBold
    loadBtn.AutoButtonColor = false
    loadBtn.Parent = p
    Corner(loadBtn, 10)
    Stroke(loadBtn, Color3.fromRGB(35, 35, 48), 1, 0.4)

    loadBtn.MouseButton1Click:Connect(function()
        pcall(function()
            if readfile and isfile and isfile("hoodrivals_config.json") then
                local data = HttpService:JSONDecode(readfile("hoodrivals_config.json"))
                for k, v in pairs(data) do
                    if Settings[k] ~= nil then Settings[k] = v end
                end
                loadBtn.Text = "LOADED ✓"
                task.wait(1.2)
                loadBtn.Text = "LOAD CONFIG"
            end
        end)
    end)

    CreateSectionLabel(p, "INFO")
    local unloadBtn = Instance.new("TextButton")
    unloadBtn.Size = UDim2.new(1, -6, 0, 38)
    unloadBtn.BackgroundColor3 = Color3.fromRGB(60, 20, 30)
    unloadBtn.Text = "UNLOAD SCRIPT"
    unloadBtn.TextColor3 = Color3.fromRGB(255, 160, 160)
    unloadBtn.TextSize = 12
    unloadBtn.Font = Enum.Font.GothamBold
    unloadBtn.AutoButtonColor = false
    unloadBtn.Parent = p
    Corner(unloadBtn, 10)
    Stroke(unloadBtn, Color3.fromRGB(255, 80, 80), 1, 0.5)

    unloadBtn.MouseButton1Click:Connect(function()
        if _G.HoodRivalsUnload then _G.HoodRivalsUnload() end
    end)
end

task.defer(function()
    task.wait(0.1)
    local firstTab = Tabs["Aim"]
    if firstTab and firstTab.btn then
        firstTab.btn.TextColor3 = Settings.UIColors.text
        firstTab.btn.BackgroundColor3 = Settings.UIColors.accent
        firstTab.btn.BackgroundTransparency = 0.85
        Pages["Aim"].Visible = true
        currentPage = "Aim"
        local targetX = firstTab.btn.AbsolutePosition.X - TabBar.AbsolutePosition.X
        TabIndicator.Position = UDim2.fromOffset(targetX, 3)
        TabIndicator.Size = UDim2.new(0, firstTab.btn.AbsoluteSize.X, 1, -6)
    end
end)

--==================================================
-- FOV CIRCLE
--==================================================

local FOVCircle = Instance.new("Frame")
FOVCircle.Name = "FOVCircle"
FOVCircle.AnchorPoint = Vector2.new(0.5, 0.5)
FOVCircle.BackgroundTransparency = 1
FOVCircle.Parent = ScreenGui

local CircleCorner = Instance.new("UICorner")
CircleCorner.CornerRadius = UDim.new(1, 0)
CircleCorner.Parent = FOVCircle

local CircleStroke = Instance.new("UIStroke")
CircleStroke.Color = Color3.fromRGB(255, 255, 255)
CircleStroke.Thickness = 1.5
CircleStroke.Transparency = 0.25
CircleStroke.Parent = FOVCircle

--==================================================
-- CROSSHAIR
--==================================================

local CrosshairH = Instance.new("Frame")
CrosshairH.Size = UDim2.fromOffset(10, 2)
CrosshairH.AnchorPoint = Vector2.new(0.5, 0.5)
CrosshairH.BackgroundColor3 = Settings.CrosshairColor
CrosshairH.Parent = ScreenGui

local CrosshairV = Instance.new("Frame")
CrosshairV.Size = UDim2.fromOffset(2, 10)
CrosshairV.AnchorPoint = Vector2.new(0.5, 0.5)
CrosshairV.BackgroundColor3 = Settings.CrosshairColor
CrosshairV.Parent = ScreenGui

--==================================================
-- TARGET INFO PANEL
--==================================================

local TargetPanel = Instance.new("Frame")
TargetPanel.Size = UDim2.fromOffset(160, 54)
TargetPanel.Position = UDim2.new(1, -172, 1, -66)
TargetPanel.BackgroundColor3 = Settings.UIColors.bg
TargetPanel.BackgroundTransparency = 0.15
TargetPanel.Visible = false
TargetPanel.Parent = ScreenGui
Corner(TargetPanel, 12)
Stroke(TargetPanel, Settings.UIColors.accent, 1.2, 0.3)

local TargetName = Instance.new("TextLabel")
TargetName.Size = UDim2.new(1, -16, 0, 18)
TargetName.Position = UDim2.fromOffset(8, 6)
TargetName.BackgroundTransparency = 1
TargetName.Text = ""
TargetName.TextColor3 = Settings.UIColors.text
TargetName.TextSize = 12
TargetName.Font = Enum.Font.GothamBold
TargetName.TextXAlignment = Enum.TextXAlignment.Left
TargetName.Parent = TargetPanel

local TargetInfo = Instance.new("TextLabel")
TargetInfo.Size = UDim2.new(1, -16, 0, 14)
TargetInfo.Position = UDim2.fromOffset(8, 24)
TargetInfo.BackgroundTransparency = 1
TargetInfo.Text = ""
TargetInfo.TextColor3 = Settings.UIColors.subtext
TargetInfo.TextSize = 10
TargetInfo.Font = Enum.Font.Gotham
TargetInfo.TextXAlignment = Enum.TextXAlignment.Left
TargetInfo.Parent = TargetPanel

local TargetHPBar = Instance.new("Frame")
TargetHPBar.Size = UDim2.new(1, -16, 0, 3)
TargetHPBar.Position = UDim2.fromOffset(8, 44)
TargetHPBar.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
TargetHPBar.Parent = TargetPanel
Corner(TargetHPBar, 2)

local TargetHPFill = Instance.new("Frame")
TargetHPFill.Size = UDim2.new(1, 0, 1, 0)
TargetHPFill.BackgroundColor3 = Settings.UIColors.success
TargetHPFill.Parent = TargetHPBar
Corner(TargetHPFill, 2)

--==================================================
-- NOTIFICATIONS
--==================================================

local NotifHolder = Instance.new("Frame")
NotifHolder.Size = UDim2.fromOffset(200, 260)
NotifHolder.Position = UDim2.new(1, -212, 0, 12)
NotifHolder.BackgroundTransparency = 1
NotifHolder.Parent = ScreenGui

local NotifLayout = Instance.new("UIListLayout")
NotifLayout.Padding = UDim.new(0, 6)
NotifLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
NotifLayout.Parent = NotifHolder

local function Notify(text, color)
    local notif = Instance.new("Frame")
    notif.Size = UDim2.fromOffset(200, 36)
    notif.BackgroundColor3 = Settings.UIColors.bg
    notif.BackgroundTransparency = 0.1
    notif.Parent = NotifHolder
    Corner(notif, 8)
    Stroke(notif, color or Settings.UIColors.accent, 1.2, 0.3)

    local bar = Instance.new("Frame")
    bar.Size = UDim2.fromOffset(3, 26)
    bar.Position = UDim2.fromOffset(6, 5)
    bar.BackgroundColor3 = color or Settings.UIColors.accent
    bar.Parent = notif
    Corner(bar, 2)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -20, 1, 0)
    label.Position = UDim2.fromOffset(14, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Settings.UIColors.text
    label.TextSize = 11
    label.Font = Enum.Font.GothamSemibold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = notif

    notif.Position = UDim2.fromOffset(220, 0)
    TweenService:Create(notif, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
        Position = UDim2.fromOffset(0, 0),
    }):Play()

    task.delay(3, function()
        TweenService:Create(notif, TweenInfo.new(0.3), { BackgroundTransparency = 1 }):Play()
        TweenService:Create(label, TweenInfo.new(0.3), { TextTransparency = 1 }):Play()
        TweenService:Create(notif, TweenInfo.new(0.3), { Position = UDim2.fromOffset(220, 0) }):Play()
        task.wait(0.35)
        notif:Destroy()
    end)
end

--==================================================
-- ESP (ScreenGui-based)
--==================================================

local ESPStore = {}

local function MakeFrame(parent, color)
    local f = Instance.new("Frame")
    f.BackgroundColor3 = color or Settings.ESPColor
    f.BorderSizePixel = 0
    f.Visible = false
    f.ZIndex = 10
    f.Parent = parent
    return f
end

local function CreateESP(player)
    if ESPStore[player] then return ESPStore[player] end
    local e = {}

    e.Box = MakeFrame(ESPGui)
    e.Box.BackgroundTransparency = 1
    local boxStroke = Instance.new("UIStroke")
    boxStroke.Color = Settings.ESPColor
    boxStroke.Thickness = 1.5
    boxStroke.Parent = e.Box
    e.BoxStroke = boxStroke

    e.HealthBg = MakeFrame(ESPGui, Color3.fromRGB(20, 20, 20))
    e.Health = MakeFrame(ESPGui, Color3.fromRGB(0, 255, 80))

    e.Name = Instance.new("TextLabel")
    e.Name.BackgroundTransparency = 1
    e.Name.TextColor3 = Color3.fromRGB(255, 255, 255)
    e.Name.TextSize = 13
    e.Name.Font = Enum.Font.GothamBold
    e.Name.TextStrokeTransparency = 0
    e.Name.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    e.Name.Visible = false
    e.Name.ZIndex = 11
    e.Name.Parent = ESPGui

    e.Distance = Instance.new("TextLabel")
    e.Distance.BackgroundTransparency = 1
    e.Distance.TextColor3 = Color3.fromRGB(220, 220, 220)
    e.Distance.TextSize = 11
    e.Distance.Font = Enum.Font.Gotham
    e.Distance.TextStrokeTransparency = 0
    e.Distance.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    e.Distance.Visible = false
    e.Distance.ZIndex = 11
    e.Distance.Parent = ESPGui

    e.Tracer = MakeFrame(ESPGui)
    e.Tracer.AnchorPoint = Vector2.new(0, 0.5)
    e.Tracer.BorderSizePixel = 0

    e.HeadDot = MakeFrame(ESPGui)
    e.HeadDot.Size = UDim2.fromOffset(8, 8)
    e.HeadDot.AnchorPoint = Vector2.new(0.5, 0.5)
    local dotCorner = Instance.new("UICorner")
    dotCorner.CornerRadius = UDim.new(1, 0)
    dotCorner.Parent = e.HeadDot

    ESPStore[player] = e
    return e
end

local function RemoveESP(player)
    local e = ESPStore[player]
    if not e then return end
    for _, v in pairs(e) do
        pcall(function() v:Destroy() end)
    end
    ESPStore[player] = nil
end

Players.PlayerRemoving:Connect(RemoveESP)

--==================================================
-- TARGETING
--==================================================

local lockedTarget = nil

local function IsEnemy(player)
    if not Settings.TeamCheck then return true end
    if not LocalPlayer.Team or not player.Team then return true end
    return player.Team ~= LocalPlayer.Team
end

local function HasLineOfSight(character, targetPart)
    if not Settings.WallCheck then return true end
    local origin = Camera.CFrame.Position
    local direction = targetPart.Position - origin
    local Params = RaycastParams.new()
    Params.FilterType = Enum.RaycastFilterType.Exclude
    Params.FilterDescendantsInstances = { LocalPlayer.Character }
    local Result = workspace:Raycast(origin, direction, Params)
    return Result and Result.Instance and Result.Instance:IsDescendantOf(character)
end

local function GetTargetsList()
    local list = {}
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local camPos = Camera.CFrame.Position

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and IsEnemy(player) and player.Character then
            local character = player.Character
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            local targetPart = character:FindFirstChild(Settings.TargetPart)

            if humanoid and humanoid.Health > 0 and targetPart then
                local hpPercent = (humanoid.Health / humanoid.MaxHealth) * 100
                local worldDist = (camPos - targetPart.Position).Magnitude

                if hpPercent >= Settings.MinHealth
                and (not Settings.IgnoreDowned or hpPercent > 15)
                and worldDist <= Settings.MaxDistance then

                    local position, visible = Camera:WorldToViewportPoint(targetPart.Position)
                    if visible then
                        local screenPos = Vector2.new(position.X, position.Y)
                        local fovDist = (screenPos - center).Magnitude

                        if fovDist < Settings.FOV and HasLineOfSight(character, targetPart) then
                            table.insert(list, {
                                part = targetPart,
                                player = player,
                                fovDist = fovDist,
                                worldDist = worldDist,
                                hp = hpPercent,
                                humanoid = humanoid,
                            })
                        end
                    end
                end
            end
        end
    end
    return list
end

local function PickTarget(list)
    if #list == 0 then return nil end
    local best = list[1]
    for _, t in ipairs(list) do
        if Settings.PriorityMode == "Distance" then
            if t.worldDist < best.worldDist then best = t end
        elseif Settings.PriorityMode == "Health" then
            if t.hp < best.hp then best = t end
        elseif Settings.PriorityMode == "FOV" then
            if t.fovDist < best.fovDist then best = t end
        elseif Settings.PriorityMode == "Threat" then
            local s1 = t.worldDist * 0.6 + (100 - t.hp) * 3
            local s2 = best.worldDist * 0.6 + (100 - best.hp) * 3
            if s1 < s2 then best = t end
        end
    end
    return best
end

--==================================================
-- ESP UPDATER
--==================================================

local function GetPlayerColor(player)
    if Settings.ESPTeamColor and player.Team and player.Team.TeamColor then
        return player.Team.TeamColor.Color
    end
    return Settings.ESPColor
end

local function UpdateESP()
    local viewport = Camera.ViewportSize

    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        local e = ESPStore[player]

        if not Settings.ESPEnabled or not IsEnemy(player) or not player.Character then
            if e then
                e.Box.Visible = false
                e.Health.Visible = false
                e.HealthBg.Visible = false
                e.Name.Visible = false
                e.Distance.Visible = false
                e.Tracer.Visible = false
                e.HeadDot.Visible = false
            end
            continue
        end

        e = e or CreateESP(player)

        local char = player.Character
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        local rootPart = char:FindFirstChild("HumanoidRootPart")
        local headPart = char:FindFirstChild("Head")

        if not humanoid or not rootPart or not headPart or humanoid.Health <= 0 then
            e.Box.Visible = false
            e.Health.Visible = false
            e.HealthBg.Visible = false
            e.Name.Visible = false
            e.Distance.Visible = false
            e.Tracer.Visible = false
            e.HeadDot.Visible = false
            continue
        end

        local topY, bottomY = math.huge, -math.huge
        local leftX, rightX = math.huge, -math.huge
        local onScreen = false

        for _, part in ipairs(char:GetChildren()) do
            if part:IsA("BasePart") then
                local pos, vis = Camera:WorldToViewportPoint(part.Position)
                if vis then
                    onScreen = true
                    local half = part.Size.Y * 0.5
                    local top = pos.Y - half * 6
                    local bottom = pos.Y + half * 6
                    if top < topY then topY = top end
                    if bottom > bottomY then bottomY = bottom end
                    if pos.X < leftX then leftX = pos.X end
                    if pos.X > rightX then rightX = pos.X end
                end
            end
        end

        if not onScreen or topY == math.huge then
            e.Box.Visible = false
            e.Health.Visible = false
            e.HealthBg.Visible = false
            e.Name.Visible = false
            e.Distance.Visible = false
            e.Tracer.Visible = false
            e.HeadDot.Visible = false
            continue
        end

        local color = GetPlayerColor(player)
        local boxH = bottomY - topY
        local boxW = rightX - leftX

        if Settings.ESPBox then
            e.Box.Visible = true
            e.Box.Size = UDim2.fromOffset(boxW, boxH)
            e.Box.Position = UDim2.fromOffset(leftX, topY)
            e.BoxStroke.Color = color
        else
            e.Box.Visible = false
        end

        if Settings.ESPHealth then
            local hpPercent = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
            local bw = 3
            e.HealthBg.Visible = true
            e.HealthBg.Size = UDim2.fromOffset(bw, boxH)
            e.HealthBg.Position = UDim2.fromOffset(leftX - 6, topY)
            e.Health.Visible = true
            e.Health.Size = UDim2.fromOffset(bw, boxH * hpPercent)
            e.Health.Position = UDim2.fromOffset(leftX - 6, topY + boxH * (1 - hpPercent))
            if hpPercent > 0.5 then
                e.Health.BackgroundColor3 = Color3.fromRGB(0, 255, 80)
            elseif hpPercent > 0.25 then
                e.Health.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
            else
                e.Health.BackgroundColor3 = Color3.fromRGB(255, 40, 40)
            end
        else
            e.Health.Visible = false
            e.HealthBg.Visible = false
        end

        if Settings.ESPName then
            e.Name.Visible = true
            e.Name.Text = player.Name
            e.Name.TextColor3 = color
            e.Name.Size = UDim2.fromOffset(200, 16)
            e.Name.Position = UDim2.fromOffset(leftX + boxW / 2 - 100, topY - 18)
        else
            e.Name.Visible = false
        end

        if Settings.ESPDistance then
            local dist = (Camera.CFrame.Position - rootPart.Position).Magnitude
            e.Distance.Visible = true
            e.Distance.Text = string.format("[%d]", math.floor(dist))
            e.Distance.Size = UDim2.fromOffset(100, 14)
            e.Distance.Position = UDim2.fromOffset(leftX + boxW / 2 - 50, bottomY + 2)
        else
            e.Distance.Visible = false
        end

        if Settings.ESPTracer then
            local fromX = viewport.X / 2
            local fromY = viewport.Y
            local toX = leftX + boxW / 2
            local toY = bottomY

            local dx = toX - fromX
            local dy = toY - fromY
            local length = math.sqrt(dx * dx + dy * dy)
            local angle = math.atan2(dy, dx)

            e.Tracer.Visible = true
            e.Tracer.BackgroundColor3 = color
            e.Tracer.Size = UDim2.fromOffset(length, 1.5)
            e.Tracer.Position = UDim2.fromOffset(fromX, fromY)
            e.Tracer.Rotation = math.deg(angle)
        else
            e.Tracer.Visible = false
        end

        if Settings.ESPHeadDot then
            local hp, hv = Camera:WorldToViewportPoint(headPart.Position)
            if hv then
                e.HeadDot.Visible = true
                e.HeadDot.BackgroundColor3 = color
                e.HeadDot.Position = UDim2.fromOffset(hp.X, hp.Y)
            else
                e.HeadDot.Visible = false
            end
        else
            e.HeadDot.Visible = false
        end
    end
end

--==================================================
-- KILL NOTIFIER
--==================================================

local function WatchPlayer(player)
    player.CharacterAdded:Connect(function(char)
        local humanoid = char:WaitForChild("Humanoid", 5)
        if not humanoid then return end
        humanoid.Died:Connect(function()
            if Settings.KillNotifier then
                Notify(player.Name .. " died", Color3.fromRGB(255, 80, 80))
            end
        end)
    end)
end

for _, p in ipairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then WatchPlayer(p) end
end
Players.PlayerAdded:Connect(WatchPlayer)

local hitSound = Instance.new("Sound")
hitSound.SoundId = "rbxassetid://9125402735"
hitSound.Volume = 0.5
hitSound.Parent = SoundService

--==================================================
-- TRIGGERBOT (multi-method)
--==================================================

local function FireWeapon()
    local methods = {
        function() if mouse1click then mouse1click() return true end end,
        function() if mouse1down and mouse1up then mouse1down() task.wait(0.01) mouse1up() return true end end,
        function() if syn and syn.mouse1click then syn.mouse1click() return true end end,
        function() if virtualmouse and virtualmouse.click then virtualmouse.click() return true end end,
        function()
            if VirtualUser then
                local vu = game:GetService("VirtualUser")
                vu:CaptureController()
                vu:ClickButton2(Vector2.new())
                return true
            end
        end,
    }
    for _, m in ipairs(methods) do
        local ok, result = pcall(m)
        if ok and result then return true end
    end
    return false
end

--==================================================
-- OPEN / CLOSE
--==================================================

local function SetMenuVisible(value)
    Main.Visible = value
    if value then
        Main.Size = UDim2.fromOffset(280, 380)
        TweenService:Create(Main,
            TweenInfo.new(0.22, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
            { Size = UDim2.fromOffset(310, 420) }
        ):Play()
    end
end

OpenButton.MouseButton1Click:Connect(function()
    SetMenuVisible(not Main.Visible)
end)
Close.MouseButton1Click:Connect(function()
    SetMenuVisible(false)
end)

--==================================================
-- MAIN LOOP
--==================================================

local frameCount = 0
local fpsTimer = 0

RunService.RenderStepped:Connect(function(dt)
    frameCount = frameCount + 1
    fpsTimer = fpsTimer + dt
    if fpsTimer >= 0.5 then
        local fps = math.floor(frameCount / fpsTimer)
        frameCount = 0
        fpsTimer = 0
        local ping = 0
        pcall(function()
            ping = math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
        end)
        StatsLabel.Text = string.format("FPS %d | %dms", fps, ping)
    end

    local viewport = Camera.ViewportSize
    local center = Vector2.new(viewport.X / 2, viewport.Y / 2)

    FOVCircle.Position = UDim2.fromOffset(center.X, center.Y)
    FOVCircle.Size = UDim2.fromOffset(Settings.FOV * 2, Settings.FOV * 2)
    FOVCircle.Visible = Settings.ShowFOV and Settings.Enabled

    CrosshairH.Visible = Settings.Crosshair
    CrosshairV.Visible = Settings.Crosshair
    if Settings.Crosshair then
        CrosshairH.Size = UDim2.fromOffset(Settings.CrosshairSize, 2)
        CrosshairV.Size = UDim2.fromOffset(2, Settings.CrosshairSize)
        CrosshairH.Position = UDim2.fromOffset(center.X, center.Y)
        CrosshairV.Position = UDim2.fromOffset(center.X, center.Y)
    end

    pcall(UpdateESP)

    local targets = GetTargetsList()
    local best = nil

    if Settings.LockOn and lockedTarget then
        for _, t in ipairs(targets) do
            if t.player == lockedTarget then best = t; break end
        end
    end
    if not best then best = PickTarget(targets) end

    lockedTarget = best and best.player or nil

    if best and Settings.Enabled then
        TargetPanel.Visible = true
        TargetName.Text = best.player.Name
        TargetInfo.Text = string.format("%d studs • %d HP", math.floor(best.worldDist), math.floor(best.hp))
        TargetHPFill.Size = UDim2.new(best.hp / 100, 0, 1, 0)
        if best.hp > 50 then
            TargetHPFill.BackgroundColor3 = Settings.UIColors.success
        elseif best.hp > 25 then
            TargetHPFill.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
        else
            TargetHPFill.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
        end
    else
        TargetPanel.Visible = false
    end

    if Settings.Enabled and best then
        local cameraPos = Camera.CFrame.Position
        local desired = CFrame.lookAt(cameraPos, best.part.Position)
        if Settings.Smoothness >= 0.99 then
            Camera.CFrame = desired
        else
            Camera.CFrame = Camera.CFrame:Lerp(desired, Settings.Smoothness)
        end
    end

    if Settings.TriggerBot and best and Settings.Enabled then
        local now = tick()
        if now - Settings.lastTrigger >= Settings.TriggerDelay then
            Settings.lastTrigger = now
            FireWeapon()
        end
    end
end)

--==================================================
-- CLEANUP
--==================================================

_G.HoodRivalsUnload = function()
    for player, _ in pairs(ESPStore) do
        RemoveESP(player)
    end
    if ScreenGui then ScreenGui:Destroy() end
    if ESPGui then ESPGui:Destroy() end
    if hitSound then hitSound:Destroy() end
end
