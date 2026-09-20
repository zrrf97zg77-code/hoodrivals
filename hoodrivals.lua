--// HOOD RIVALS
--// DELTA EXECUTOR — AIM-ASSIST + ESP + TRIGGERBOT + COMPACT GUI
--// v3.3  |  Mobile-friendly

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
    Smoothness = 0.18,
    TeamCheck = true,
    WallCheck = true,
    TargetPart = "Head",
    ShowFOV = true,
    LockOn = false,
    PriorityMode = "Distance",
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
-- FLOATING OPEN BUTTON (compact 54px)
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
-- MAIN WINDOW (compact 310x420)
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

--==================================================
-- TITLE BAR (compact 58px)
--==================================================

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
VersionText.Text = "v3.3"
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

--==================================================
-- TAB BAR (compact 30px)
--==================================================

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

--==================================================
-- PAGE CONTAINER
--==================================================

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

--==================================================
-- TAB SWITCHING
--==================================================

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
-- COMPONENTS (compact)
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
    Label.Size = UDim2.new(1, -70, 0, 18)
    Label.Position = UDim2.fromOffset(10, 6)
    Label.BackgroundTransparency = 1
    Label.Text = name
    Label.TextColor3 = Settings.UIColors.text
    Label.TextSize = 12
    Label.Font = Enum.Font.GothamSemibold
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Holder

    local Desc = Instance.new("TextLabel")
    Desc.Size = UDim2.new(1, -70, 0, 14)
    Desc.Position = UDim2.fromOffset(10, 26)
    Desc.BackgroundTransparency = 1
    Desc.Text = description
    Desc.TextColor3 = Settings.UIColors.subtext
    Desc.TextSize = 9
    Desc.Font = Enum.Font.Gotham
    Desc.TextXAlignment = Enum.TextXAlignment.Left
    Desc.Parent = Holder

    local Button = Instance.new("TextButton")
    Button.Size = UDim2.fromOffset(42, 24)
    Button.Position = UDim2.new(1, -52, 0.5, -12)
    Button.BackgroundColor3 = Color3.fromRGB(32, 32, 42)
    Button.Text = ""
    Button.AutoButtonColor = false
    Button.Parent = Holder
    Corner(Button, 12)
    Stroke(Button, Color3.fromRGB(50, 50, 65), 1, 0.4)

    local Knob = Instance.new("Frame")
    Knob.Size = UDim2.fromOffset(18, 18)
    Knob.Position = UDim2.fromOffset(3, 3)
    Knob.BackgroundColor3 = Color3.fromRGB(150, 150, 160)
    Knob.Parent = Button
    Corner(Knob, 9)

    local state = default or false

    local function Update()
        local info = TweenInfo.new(0.18, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
        if state then
            TweenService:Create(Knob, info, {
                Position = UDim2.fromOffset(21, 3),
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            }):Play()
            TweenService:Create(Button, info, {
                BackgroundColor3 = Settings.UIColors.accent,
            }):Play()
            Button.UIStroke.Color = Settings.UIColors.accent
        else
            TweenService:Create(Knob, info, {
                Position = UDim2.fromOffset(3, 3),
                BackgroundColor3 = Color3.fromRGB(150, 150, 160),
            }):Play()
            TweenService:Create(Button, info, {
                BackgroundColor3 = Color3.fromRGB(32, 32, 42),
            }):Play()
            Button.UIStroke.Color = Color3.fromRGB(50, 50, 65)
        end
    end

    Button.MouseButton1Click:Connect(function()
        state = not state
        Update()
        callback(state)
    end)
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

--==== AIM PAGE ====
do
    local p = Pages["Aim"]

    CreateSectionLabel(p, "CORE")
    CreateToggle(p, "AIM ASSIST", "Master toggle", Settings.Enabled, function(v)
        Settings.Enabled = v
        StatusDot.BackgroundColor3 = v and Settings.UIColors.success or Settings.UIColors.subtext
    end)
    CreateToggle(p, "SHOW FOV", "Aim radius circle", Settings.ShowFOV, function(v)
        Settings.ShowFOV = v
    end)
    CreateToggle(p, "TEAM CHECK", "Ignore teammates", Settings.TeamCheck, function(v)
        Settings.TeamCheck = v
    end)
    CreateToggle(p, "WALL CHECK", "Line-of-sight only", Settings.WallCheck, function(v)
        Settings.WallCheck = v
    end)

    CreateSectionLabel(p, "TRIGGERBOT")
    CreateToggle(p, "TRIGGERBOT", "Auto-fire on target", Settings.TriggerBot, function(v)
        Settings.TriggerBot = v
    end)
    CreateSlider(p, "TRIGGER DELAY", 0.01, 0.5, Settings.TriggerDelay, function(v)
        Settings.TriggerDelay = v
    end)

    CreateSectionLabel(p, "BEHAVIOR")
    CreateDropdown(p, "PRIORITY", {"Distance", "Health", "FOV", "Threat"}, Settings.PriorityMode, function(v)
        Settings.PriorityMode = v
    end)
    CreateToggle(p, "LOCK-ON", "Sticky targeting", Settings.LockOn, function(v)
        Settings.LockOn = v
    end)
    CreateToggle(p, "IGNORE LOW HP", "Skip downed", Settings.IgnoreDowned, function(v)
        Settings.IgnoreDowned = v
    end)

    CreateSectionLabel(p, "TUNING")
    CreateSlider(p, "FOV", 30, 600, Settings.FOV, function(v) Settings.FOV = v end)
    CreateSlider(p, "SMOOTHNESS", 0.02, 1, Settings.Smoothness, function(v) Settings.Smoothness = v end)
    CreateSlider(p, "MAX DISTANCE", 50, 1000, Settings.MaxDistance, function(v) Settings.MaxDistance = v end)
    CreateSlider(p, "MIN HEALTH %", 0, 100, Settings.MinHealth, function(v) Settings.MinHealth = v end)
end

--==== ESP PAGE ====
do
    local p = Pages["ESP"]

    CreateSectionLabel(p, "MASTER")
    CreateToggle(p, "ESP ENABLED", "Show all ESP", Settings.ESPEnabled, function(v)
        Settings.ESPEnabled = v
    end)

    CreateSectionLabel(p, "ELEMENTS")
    CreateToggle(p, "BOX", "Bounding box", Settings.ESPBox, function(v) Settings.ESPBox = v end)
    CreateToggle(p, "HEALTH BAR", "HP indicator", Settings.ESPHealth, function(v) Settings.ESPHealth = v end)
    CreateToggle(p, "NAME", "Player username", Settings.ESPName, function(v) Settings.ESPName = v end)
    CreateToggle(p, "TRACER", "Line to target", Settings.ESPTracer, function(v) Settings.ESPTracer = v end)
    CreateToggle(p, "DISTANCE", "
