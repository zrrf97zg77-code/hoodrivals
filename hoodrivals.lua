--// HOOD RIVALS
--// DELTA EXECUTOR — AIM-ASSIST + ESP + TRIGGERBOT + PRO GUI
--// v3.2  |  Mobile-friendly

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local SoundService = game:GetService("SoundService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

--==================================================
-- CONFIG
--==================================================

local Settings = {
    -- Aim
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
    AimCurve = "Linear",

    -- Triggerbot
    TriggerBot = false,
    TriggerDelay = 0.05,
    lastTrigger = 0,

    -- Notifications
    HitSound = true,
    KillNotifier = true,

    -- Crosshair
    Crosshair = true,
    CrosshairColor = Color3.fromRGB(0, 255, 140),
    CrosshairSize = 12,

    -- ESP
    ESPEnabled = true,
    ESPBox = true,
    ESPHealth = true,
    ESPName = true,
    ESPTracer = true,
    ESPDistance = true,
    ESPHeadDot = true,
    ESPColor = Color3.fromRGB(255, 60, 60),
    ESPTeamColor = false,

    -- Visual
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
    c.CornerRadius = UDim.new(0, r or 12)
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
OpenWrapper.Size = UDim2.fromOffset(72, 72)
OpenWrapper.Position = UDim2.new(0, 14, 0.5, -36)
OpenWrapper.BackgroundTransparency = 1
OpenWrapper.Parent = ScreenGui

local GlowRing = Instance.new("Frame")
GlowRing.Size = UDim2.fromOffset(72, 72)
GlowRing.BackgroundColor3 = Settings.UIColors.accent
GlowRing.BackgroundTransparency = 0.65
GlowRing.Parent = OpenWrapper
Corner(GlowRing, 36)

local GlowRingInner = Instance.new("Frame")
GlowRingInner.Size = UDim2.fromOffset(58, 58)
GlowRingInner.Position = UDim2.fromOffset(7, 7)
GlowRingInner.BackgroundColor3 = Color3.fromRGB(10, 10, 14)
GlowRingInner.Parent = OpenWrapper
Corner(GlowRingInner, 29)

local OpenButton = Instance.new("TextButton")
OpenButton.Size = UDim2.fromOffset(58, 58)
OpenButton.Position = UDim2.fromOffset(7, 7)
OpenButton.BackgroundColor3 = Settings.UIColors.bg
OpenButton.Text = "HR"
OpenButton.TextColor3 = Color3.fromRGB(255, 255, 255)
OpenButton.TextSize = 18
OpenButton.Font = Enum.Font.GothamBold
OpenButton.AutoButtonColor = false
OpenButton.Active = true
OpenButton.Parent = OpenWrapper
Corner(OpenButton, 29)
Stroke(OpenButton, Settings.UIColors.accent, 1.5, 0.3)

task.spawn(function()
    while OpenWrapper.Parent do
        TweenService:Create(GlowRing,
            TweenInfo.new(1.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
            { BackgroundTransparency = 0.35, Size = UDim2.fromOffset(80, 80), Position = UDim2.fromOffset(-4, -4) }
        ):Play()
        task.wait(1.4)
        TweenService:Create(GlowRing,
            TweenInfo.new(1.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
            { BackgroundTransparency = 0.7, Size = UDim2.fromOffset(72, 72), Position = UDim2.fromOffset(0, 0) }
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
Main.Size = UDim2.fromOffset(380, 520)
Main.Position = UDim2.new(0.5, -190, 0.5, -260)
Main.BackgroundColor3 = Settings.UIColors.bg
Main.Visible = false
Main.Active = true
Main.ClipsDescendants = true
Main.Parent = ScreenGui
Corner(Main, 22)
Stroke(Main, Settings.UIColors.accent, 1.5, 0.35)

local MainGradient = Instance.new("Frame")
MainGradient.Size = UDim2.new(1, 0, 1, 0)
MainGradient.BackgroundColor3 = Settings.UIColors.accent
MainGradient.BackgroundTransparency = 0.94
MainGradient.ZIndex = 0
MainGradient.Parent = Main
Corner(MainGradient, 22)
Gradient(MainGradient, Settings.UIColors.accent, Settings.UIColors.accent2, 135)

--==================================================
-- TITLE BAR
--==================================================

local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 74)
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
Logo.Size = UDim2.fromOffset(42, 42)
Logo.Position = UDim2.fromOffset(16, 16)
Logo.BackgroundColor3 = Settings.UIColors.accent
Logo.ZIndex = 3
Logo.Parent = TitleBar
Corner(Logo, 12)
Gradient(Logo, Settings.UIColors.accent, Settings.UIColors.accent2, 45)

local LogoText = Instance.new("TextLabel")
LogoText.Size = UDim2.new(1, 0, 1, 0)
LogoText.BackgroundTransparency = 1
LogoText.Text = "HR"
LogoText.TextColor3 = Color3.fromRGB(255, 255, 255)
LogoText.TextSize = 15
LogoText.Font = Enum.Font.GothamBlack
LogoText.ZIndex = 4
LogoText.Parent = Logo

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -160, 0, 24)
TitleLabel.Position = UDim2.fromOffset(70, 20)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "HOOD RIVALS"
TitleLabel.TextColor3 = Settings.UIColors.text
TitleLabel.TextSize = 18
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.ZIndex = 3
TitleLabel.Parent = TitleBar

local StatsLabel = Instance.new("TextLabel")
StatsLabel.Size = UDim2.fromOffset(130, 16)
StatsLabel.Position = UDim2.fromOffset(70, 44)
StatsLabel.BackgroundTransparency = 1
StatsLabel.Text = "FPS -- | --ms"
StatsLabel.TextColor3 = Settings.UIColors.subtext
StatsLabel.TextSize = 10
StatsLabel.Font = Enum.Font.GothamMedium
StatsLabel.TextXAlignment = Enum.TextXAlignment.Left
StatsLabel.ZIndex = 3
StatsLabel.Parent = TitleBar

local VersionPill = Instance.new("Frame")
VersionPill.Size = UDim2.fromOffset(44, 18)
VersionPill.Position = UDim2.new(1, -138, 0, 26)
VersionPill.BackgroundColor3 = Settings.UIColors.accent
VersionPill.BackgroundTransparency = 0.8
VersionPill.ZIndex = 3
VersionPill.Parent = TitleBar
Corner(VersionPill, 9)

local VersionText = Instance.new("TextLabel")
VersionText.Size = UDim2.new(1, 0, 1, 0)
VersionText.BackgroundTransparency = 1
VersionText.Text = "v3.2"
VersionText.TextColor3 = Settings.UIColors.accent
VersionText.TextSize = 10
VersionText.Font = Enum.Font.GothamBold
VersionText.ZIndex = 4
VersionText.Parent = VersionPill

local StatusDot = Instance.new("Frame")
StatusDot.Size = UDim2.fromOffset(8, 8)
StatusDot.Position = UDim2.new(1, -84, 0, 31)
StatusDot.BackgroundColor3 = Settings.UIColors.subtext
StatusDot.ZIndex = 3
StatusDot.Parent = TitleBar
Corner(StatusDot, 4)

local Close = Instance.new("TextButton")
Close.Size = UDim2.fromOffset(34, 34)
Close.Position = UDim2.new(1, -44, 0, 20)
Close.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
Close.Text = "×"
Close.TextColor3 = Color3.fromRGB(210, 210, 220)
Close.TextSize = 22
Close.Font = Enum.Font.GothamBold
Close.AutoButtonColor = false
Close.ZIndex = 3
Close.Parent = TitleBar
Corner(Close, 10)

--==================================================
-- TAB BAR
--==================================================

local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(1, -32, 0, 36)
TabBar.Position = UDim2.fromOffset(16, 74)
TabBar.BackgroundColor3 = Settings.UIColors.panel
TabBar.ZIndex = 2
TabBar.Parent = Main
Corner(TabBar, 12)

local TabLayout = Instance.new("UIListLayout")
TabLayout.FillDirection = Enum.FillDirection.Horizontal
TabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
TabLayout.VerticalAlignment = Enum.VerticalAlignment.Center
TabLayout.Padding = UDim.new(0, 4)
TabLayout.Parent = TabBar

local TabIndicator = Instance.new("Frame")
TabIndicator.Size = UDim2.new(0, 0, 1, -8)
TabIndicator.Position = UDim2.new(0, 0, 0, 4)
TabIndicator.BackgroundColor3 = Settings.UIColors.accent
TabIndicator.ZIndex = 3
TabIndicator.Parent = TabBar
Corner(TabIndicator, 8)
Gradient(TabIndicator, Settings.UIColors.accent, Settings.UIColors.accent2, 0)

--==================================================
-- PAGE CONTAINER
--==================================================

local PageFrame = Instance.new("Frame")
PageFrame.Size = UDim2.new(1, -32, 1, -188)
PageFrame.Position = UDim2.fromOffset(16, 120)
PageFrame.BackgroundTransparency = 1
PageFrame.ZIndex = 2
PageFrame.Parent = Main

local Pages = {}

local function CreatePage(name)
    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 3
    page.ScrollBarImageColor3 = Settings.UIColors.accent
    page.ScrollBarImageTransparency = 0.4
    page.CanvasSize = UDim2.new()
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.Visible = false
    page.ZIndex = 2
    page.Parent = PageFrame

    local list = Instance.new("UIListLayout")
    list.Padding = UDim.new(0, 10)
    list.Parent = page
    Padding(page, 4, 6, 10, 4)

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
    btn.Size = UDim2.fromOffset(72, 28)
    btn.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
    btn.BackgroundTransparency = 1
    btn.Text = name
    btn.TextColor3 = Settings.UIColors.subtext
    btn.TextSize = 11
    btn.Font = Enum.Font.GothamBold
    btn.AutoButtonColor = false
    btn.Parent = TabBar
    Corner(btn, 8)

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
        -- move indicator under this tab
        local targetX = btn.AbsolutePosition.X - TabBar.AbsolutePosition.X
        TweenService:Create(TabIndicator, TweenInfo.new(0.22, Enum.EasingStyle.Quart), {
            Position = UDim2.fromOffset(targetX, 4),
            Size = UDim2.new(0, btn.AbsoluteSize.X, 1, -8),
        }):Play()
    end)

    return btn
end

--==================================================
-- COMPONENTS
--==================================================

local function CreateSectionLabel(parent, text)
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1, -8, 0, 22)
    holder.BackgroundTransparency = 1
    holder.Parent = parent

    local bar = Instance.new("Frame")
    bar.Size = UDim2.fromOffset(3, 14)
    bar.Position = UDim2.fromOffset(0, 4)
    bar.BackgroundColor3 = Settings.UIColors.accent
    bar.Parent = holder
    Corner(bar, 2)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -14, 1, 0)
    label.Position = UDim2.fromOffset(12, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Settings.UIColors.subtext
    label.TextSize = 10
    label.Font = Enum.Font.GothamBold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = holder
end

local function CreateToggle(parent, name, description, default, callback)
    local Holder = Instance.new("Frame")
    Holder.Size = UDim2.new(1, -8, 0, 60)
    Holder.BackgroundColor3 = Settings.UIColors.panel
    Holder.Parent = parent
    Corner(Holder, 12)
    Stroke(Holder, Color3.fromRGB(35, 35, 48), 1, 0.4)

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -84, 0, 22)
    Label.Position = UDim2.fromOffset(14, 8)
    Label.BackgroundTransparency = 1
    Label.Text = name
    Label.TextColor3 = Settings.UIColors.text
    Label.TextSize = 13
    Label.Font = Enum.Font.GothamSemibold
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Holder

    local Desc = Instance.new("TextLabel")
    Desc.Size = UDim2.new(1, -84, 0, 16)
    Desc.Position = UDim2.fromOffset(14, 32)
    Desc.BackgroundTransparency = 1
    Desc.Text = description
    Desc.TextColor3 = Settings.UIColors.subtext
    Desc.TextSize = 10
    Desc.Font = Enum.Font.Gotham
    Desc.TextXAlignment = Enum.TextXAlignment.Left
    Desc.Parent = Holder

    local Button = Instance.new("TextButton")
    Button.Size = UDim2.fromOffset(50, 28)
    Button.Position = UDim2.new(1, -64, 0.5, -14)
    Button.BackgroundColor3 = Color3.fromRGB(32, 32, 42)
    Button.Text = ""
    Button.AutoButtonColor = false
    Button.Parent = Holder
    Corner(Button, 14)
    Stroke(Button, Color3.fromRGB(50, 50, 65), 1, 0.4)

    local Knob = Instance.new("Frame")
    Knob.Size = UDim2.fromOffset(22, 22)
    Knob.Position = UDim2.fromOffset(3, 3)
    Knob.BackgroundColor3 = Color3.fromRGB(150, 150, 160)
    Knob.Parent = Button
    Corner(Knob, 11)

    local state = default or false

    local function Update()
        local info = TweenInfo.new(0.18, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
        if state then
            TweenService:Create(Knob, info, {
                Position = UDim2.fromOffset(25, 3),
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
    Holder.Size = UDim2.new(1, -8, 0, 74)
    Holder.BackgroundColor3 = Settings.UIColors.panel
    Holder.Parent = parent
    Corner(Holder, 12)
    Stroke(Holder, Color3.fromRGB(35, 35, 48), 1, 0.4)

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -110, 0, 22)
    Label.Position = UDim2.fromOffset(14, 8)
    Label.BackgroundTransparency = 1
    Label.Text = name
    Label.TextColor3 = Settings.UIColors.text
    Label.TextSize = 13
    Label.Font = Enum.Font.GothamSemibold
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Holder

    local ValuePill = Instance.new("Frame")
    ValuePill.Size = UDim2.fromOffset(72, 22)
    ValuePill.Position = UDim2.new(1, -86, 0, 8)
    ValuePill.BackgroundColor3 = Settings.UIColors.accent
    ValuePill.BackgroundTransparency = 0.85
    ValuePill.Parent = Holder
    Corner(ValuePill, 8)

    local ValueText = Instance.new("TextLabel")
    ValueText.Size = UDim2.new(1, 0, 1, 0)
    ValueText.BackgroundTransparency = 1
    ValueText.Text = tostring(default)
    ValueText.TextColor3 = Settings.UIColors.accent
    ValueText.TextSize = 11
    ValueText.Font = Enum.Font.GothamBold
    ValueText.Parent = ValuePill

    local Bar = Instance.new("Frame")
    Bar.Size = UDim2.new(1, -28, 0, 8)
    Bar.Position = UDim2.fromOffset(14, 48)
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
    Knob.Size = UDim2.fromOffset(16, 16)
    Knob.AnchorPoint = Vector2.new(0.5, 0.5)
    Knob.Position = UDim2.new(Fill.Size.X.Scale, 0, 0.5, 0)
    Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Knob.Parent = Bar
    Corner(Knob, 8)
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
    Holder.Size = UDim2.new(1, -8, 0, 60)
    Holder.BackgroundColor3 = Settings.UIColors.panel
    Holder.ClipsDescendants = true
    Holder.Parent = parent
    Corner(Holder, 12)
    Stroke(Holder, Color3.fromRGB(35, 35, 48), 1, 0.4)

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -100, 1, 0)
    Label.Position = UDim2.fromOffset(14, 0)
    Label.BackgroundTransparency = 1
    Label.Text = name
    Label.TextColor3 = Settings.UIColors.text
    Label.TextSize = 13
    Label.Font = Enum.Font.GothamSemibold
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Holder

    local Selector = Instance.new("TextButton")
    Selector.Size = UDim2.fromOffset(110, 30)
    Selector.Position = UDim2.new(1, -122, 0.5, -15)
    Selector.BackgroundColor3 = Color3.fromRGB(32, 32, 42)
    Selector.Text = tostring(default)
    Selector.TextColor3 = Settings.UIColors.text
    Selector.TextSize = 11
    Selector.Font = Enum.Font.GothamSemibold
    Selector.AutoButtonColor = false
    Selector.Parent = Holder
    Corner(Selector, 10)
    Stroke(Selector, Color3.fromRGB(50, 50, 65), 1, 0.4)

    local open = false

    local function Build()
        local overlay = Instance.new("Frame")
        overlay.Size = UDim2.new(1, 0, 0, #options * 32)
        overlay.Position = UDim2.fromOffset(0, 60)
        overlay.BackgroundColor3 = Settings.UIColors.panel
        overlay.BorderSizePixel = 0
        overlay.Parent = Holder

        local list = Instance.new("UIListLayout")
        list.Padding = UDim.new(0, 2)
        list.Parent = overlay
        Padding(overlay, 4, 6, 4, 6)

        for _, opt in ipairs(options) do
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, 0, 0, 28)
            btn.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
            btn.Text = tostring(opt)
            btn.TextColor3 = Settings.UIColors.text
            btn.TextSize = 11
            btn.Font = Enum.Font.Gotham
            btn.AutoButtonColor = false
            btn.Parent = overlay
            Corner(btn, 8)

            btn.MouseButton1Click:Connect(function()
                Selector.Text = tostring(opt)
                callback(opt)
                overlay:Destroy()
                TweenService:Create(Holder, TweenInfo.new(0.18), {
                    Size = UDim2.new(1, -8, 0, 60)
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
            Size = UDim2.new(1, -8, 0, 60 + #options * 32)
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
    CreateToggle(p, "SHOW FOV", "Display aim radius circle", Settings.ShowFOV, function(v)
        Settings.ShowFOV = v
    end)
    CreateToggle(p, "TEAM CHECK", "Ignore teammates", Settings.TeamCheck, function(v)
        Settings.TeamCheck = v
    end)
    CreateToggle(p, "WALL CHECK", "Raycast line-of-sight", Settings.WallCheck, function(v)
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
    CreateToggle(p, "LOCK-ON", "Sticky target locking", Settings.LockOn, function(v)
        Settings.LockOn = v
    end)
    CreateToggle(p, "IGNORE LOW HP", "Skip downed targets", Settings.IgnoreDowned, function(v)
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
    CreateToggle(p, "ESP ENABLED", "Show all ESP features", Settings.ESPEnabled, function(v)
        Settings.ESPEnabled = v
    end)

    CreateSectionLabel(p, "ELEMENTS")
    CreateToggle(p, "BOX", "Bounding box", Settings.ESPBox, function(v) Settings.ESPBox = v end)
    CreateToggle(p, "HEALTH BAR", "HP indicator", Settings.ESPHealth, function(v) Settings.ESPHealth = v end)
    CreateToggle(p, "NAME", "Player username", Settings.ESPName, function(v) Settings.ESPName = v end)
    CreateToggle(p, "TRACER", "Line to target", Settings.ESPTracer, function(v) Settings.ESPTracer = v end)
    CreateToggle(p, "DISTANCE", "Stud distance", Settings.ESPDistance, function(v) Settings.ESPDistance = v end)
    CreateToggle(p, "HEAD DOT", "Dot on head", Settings.ESPHeadDot, function(v) Settings.ESPHeadDot = v end)

    CreateSectionLabel(p, "STYLE")
    CreateToggle(p, "TEAM COLOR", "Use team colors", Settings.ESPTeamColor, function(v)
        Settings.ESPTeamColor = v
    end)
end

--==== EXTRAS PAGE ====
do
    local p = Pages["Extras"]

    CreateSectionLabel(p, "FEEDBACK")
    CreateToggle(p, "HIT SOUND", "Play sound on damage", Settings.HitSound, function(v)
        Settings.HitSound = v
    end)
    CreateToggle(p, "KILL NOTIFIER", "Popup when someone dies", Settings.KillNotifier, function(v)
        Settings.KillNotifier = v
    end)

    CreateSectionLabel(p, "CROSSHAIR")
    CreateToggle(p, "SHOW CROSSHAIR", "Custom center dot", Settings.Crosshair, function(v)
        Settings.Crosshair = v
    end)
    CreateSlider(p, "CROSSHAIR SIZE", 4, 40, Settings.CrosshairSize, function(v)
        Settings.CrosshairSize = v
    end)
end

--==== MISC PAGE ====
do
    local p = Pages["Misc"]

    CreateSectionLabel(p, "TARGET PART")
    CreateDropdown(p, "TARGET PART",
        {"Head", "UpperTorso", "HumanoidRootPart", "LowerTorso"},
        Settings.TargetPart,
        function(v) Settings.TargetPart = v end)

    CreateSectionLabel(p, "CONFIG")
    local saveBtn = Instance.new("TextButton")
    saveBtn.Size = UDim2.new(1, -8, 0, 42)
    saveBtn.BackgroundColor3 = Settings.UIColors.panel
    saveBtn.Text = "SAVE CONFIG"
    saveBtn.TextColor3 = Settings.UIColors.text
    saveBtn.TextSize = 12
    saveBtn.Font = Enum.Font.GothamBold
    saveBtn.AutoButtonColor = false
    saveBtn.Parent = p
    Corner(saveBtn, 12)
    Stroke(saveBtn, Color3.fromRGB(35, 35, 48), 1, 0.4)

    saveBtn.MouseButton1Click:Connect(function()
        local ok, err = pcall(function()
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
            else
                saveBtn.Text = "NO FILE API"
                task.wait(1.2)
                saveBtn.Text = "SAVE CONFIG"
            end
        end)
        if not ok then
            saveBtn.Text = "SAVE FAILED"
            task.wait(1.2)
            saveBtn.Text = "SAVE CONFIG"
        end
    end)

    local loadBtn = Instance.new("TextButton")
    loadBtn.Size = UDim2.new(1, -8, 0, 42)
    loadBtn.BackgroundColor3 = Settings.UIColors.panel
    loadBtn.Text = "LOAD CONFIG"
    loadBtn.TextColor3 = Settings.UIColors.text
    loadBtn.TextSize = 12
    loadBtn.Font = Enum.Font.GothamBold
    loadBtn.AutoButtonColor = false
    loadBtn.Parent = p
    Corner(loadBtn, 12)
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
            else
                loadBtn.Text = "NO FILE API"
                task.wait(1.2)
                loadBtn.Text = "LOAD CONFIG"
            end
        end)
    end)

    CreateSectionLabel(p, "INFO")
    local infoHolder = Instance.new("Frame")
    infoHolder.Size = UDim2.new(1, -8, 0, 60)
    infoHolder.BackgroundColor3 = Settings.UIColors.panel
    infoHolder.Parent = p
    Corner(infoHolder, 12)
    Stroke(infoHolder, Color3.fromRGB(35, 35, 48), 1, 0.4)

    local info = Instance.new("TextLabel")
    info.Size = UDim2.new(1, -28, 1, 0)
    info.Position = UDim2.fromOffset(14, 0)
    info.BackgroundTransparency = 1
    info.Text = "Hood Rivals v3.2  •  Delta Executor\nMade for testing • Use responsibly"
    info.TextColor3 = Settings.UIColors.subtext
    info.TextSize = 11
    info.Font = Enum.Font.Gotham
    info.TextXAlignment = Enum.TextXAlignment.Left
    info.Parent = infoHolder

    local unloadBtn = Instance.new("TextButton")
    unloadBtn.Size = UDim2.new(1, -8, 0, 44)
    unloadBtn.BackgroundColor3 = Color3.fromRGB(60, 20, 30)
    unloadBtn.Text = "UNLOAD SCRIPT"
    unloadBtn.TextColor3 = Color3.fromRGB(255, 160, 160)
    unloadBtn.TextSize = 13
    unloadBtn.Font = Enum.Font.GothamBold
    unloadBtn.AutoButtonColor = false
    unloadBtn.Parent = p
    Corner(unloadBtn, 12)
    Stroke(unloadBtn, Color3.fromRGB(255, 80, 80), 1, 0.5)

    unloadBtn.MouseButton1Click:Connect(function()
        if _G.HoodRivalsUnload then _G.HoodRivalsUnload() end
    end)
end

-- Default tab selection
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
        TabIndicator.Position = UDim2.fromOffset(targetX, 4)
        TabIndicator.Size = UDim2.new(0, firstTab.btn.AbsoluteSize.X, 1, -8)
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
CrosshairH.Size = UDim2.fromOffset(12, 2)
CrosshairH.AnchorPoint = Vector2.new(0.5, 0.5)
CrosshairH.BackgroundColor3 = Settings.CrosshairColor
CrosshairH.Parent = ScreenGui

local CrosshairV = Instance.new("Frame")
CrosshairV.Size = UDim2.fromOffset(2, 12)
CrosshairV.AnchorPoint = Vector2.new(0.5, 0.5)
CrosshairV.BackgroundColor3 = Settings.CrosshairColor
CrosshairV.Parent = ScreenGui

--==================================================
-- TARGET INFO PANEL (bottom-right)
--==================================================

local TargetPanel = Instance.new("Frame")
TargetPanel.Size = UDim2.fromOffset(200, 64)
TargetPanel.Position = UDim2.new(1, -216, 1, -80)
TargetPanel.BackgroundColor3 = Settings.UIColors.bg
TargetPanel.BackgroundTransparency = 0.15
TargetPanel.Visible = false
TargetPanel.Parent = ScreenGui
Corner(TargetPanel, 14)
Stroke(TargetPanel, Settings.UIColors.accent, 1.5, 0.3)

local TargetName = Instance.new("TextLabel")
TargetName.Size = UDim2.new(1, -20, 0, 22)
TargetName.Position = UDim2.fromOffset(10, 8)
TargetName.BackgroundTransparency = 1
TargetName.Text = ""
TargetName.TextColor3 = Settings.UIColors.text
TargetName.TextSize = 14
TargetName.Font = Enum.Font.GothamBold
TargetName.TextXAlignment = Enum.TextXAlignment.Left
TargetName.Parent = TargetPanel

local TargetInfo = Instance.new("TextLabel")
TargetInfo.Size = UDim2.new(1, -20, 0, 18)
TargetInfo.Position = UDim2.fromOffset(10, 30)
TargetInfo.BackgroundTransparency = 1
TargetInfo.Text = ""
TargetInfo.TextColor3 = Settings.UIColors.subtext
TargetInfo.TextSize = 11
TargetInfo.Font = Enum.Font.Gotham
TargetInfo.TextXAlignment = Enum.TextXAlignment.Left
TargetInfo.Parent = TargetPanel

local TargetHPBar = Instance.new("Frame")
TargetHPBar.Size = UDim2.new(1, -20, 0, 4)
TargetHPBar.Position = UDim2.fromOffset(10, 52)
TargetHPBar.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
TargetHPBar.Parent = TargetPanel
Corner(TargetHPBar, 2)

local TargetHPFill = Instance.new("Frame")
TargetHPFill.Size = UDim2.new(1, 0, 1, 0)
TargetHPFill.BackgroundColor3 = Settings.UIColors.success
TargetHPFill.Parent = TargetHPBar
Corner(TargetHPFill, 2)

--==================================================
-- NOTIFICATION SYSTEM (top-right)
--==================================================

local NotifHolder = Instance.new("Frame")
NotifHolder.Size = UDim2.fromOffset(240, 300)
NotifHolder.Position = UDim2.new(1, -256, 0, 16)
NotifHolder.BackgroundTransparency = 1
NotifHolder.Parent = ScreenGui

local NotifLayout = Instance.new("UIListLayout")
NotifLayout.Padding = UDim.new(0, 8)
NotifLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
NotifLayout.Parent = NotifHolder

local function Notify(text, color)
    local notif = Instance.new("Frame")
    notif.Size = UDim2.fromOffset(240, 44)
    notif.BackgroundColor3 = Settings.UIColors.bg
    notif.BackgroundTransparency = 0.1
    notif.Parent = NotifHolder
    Corner(notif, 10)
    Stroke(notif, color or Settings.UIColors.accent, 1.5, 0.3)

    local bar = Instance.new("Frame")
    bar.Size = UDim2.fromOffset(3, 32)
    bar.Position = UDim2.fromOffset(8, 6)
    bar.BackgroundColor3 = color or Settings.UIColors.accent
    bar.Parent = notif
    Corner(bar, 2)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -24, 1, 0)
    label.Position = UDim2.fromOffset(18, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Settings.UIColors.text
    label.TextSize = 12
    label.Font = Enum.Font.GothamSemibold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = notif

    -- Slide in
    notif.Position = UDim2.fromOffset(260, 0)
    TweenService:Create(notif, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
        Position = UDim2.fromOffset(0, 0),
    }):Play()

    task.delay(3, function()
        TweenService:Create(notif, TweenInfo.new(0.3), {
            BackgroundTransparency = 1,
        }):Play()
        TweenService:Create(label, TweenInfo.new(0.3), {
            TextTransparency = 1,
        }):Play()
        TweenService:Create(notif, TweenInfo.new(0.3), {
            Position = UDim2.fromOffset(260, 0),
        }):Play()
        task.wait(0.35)
        notif:Destroy()
    end)
end

--==================================================
-- ESP DRAWINGS
--==================================================

local Drawings = {}

local function NewDrawing(class, props)
    local ok, obj = pcall(function() return Drawing.new(class) end)
    if not ok or not obj then return nil end
    for k, v in pairs(props) do pcall(function() obj[k] = v end) end
    return obj
end

local function CreateESP(player)
    if Drawings[player] then return Drawings[player] end
    local entry = {}
    if Drawing then
        entry.Box = NewDrawing("Square", { Thickness = 1.5, Filled = false, Transparency = 1, Color = Settings.ESPColor, Visible = false })
        entry.HealthBg = NewDrawing("Square", { Thickness = 1, Filled = true, Transparency = 1, Color = Color3.fromRGB(20, 20, 20), Visible = false })
        entry.Health = NewDrawing("Square", { Thickness = 1, Filled = true, Transparency = 1, Color = Color3.fromRGB(0, 255, 80), Visible = false })
        entry.Name = NewDrawing("Text", { Size = 14, Center = true, Outline = true, OutlineColor = Color3.fromRGB(0, 0, 0), Color = Color3.fromRGB(255, 255, 255), Font = 2, Visible = false })
        entry.Distance = NewDrawing("Text", { Size = 12, Center = true, Outline = true, OutlineColor = Color3.fromRGB(0, 0, 0), Color = Color3.fromRGB(200, 200, 200), Font = 2, Visible = false })
        entry.Tracer = NewDrawing("Line", { Thickness = 1.5, Transparency = 1, Color = Settings.ESPColor, Visible = false })
        entry.HeadDot = NewDrawing("Circle", { Thickness = 1, Filled = true, Transparency = 1, Color = Settings.ESPColor, Radius = 4, Visible = false })
    end
    Drawings[player] = entry
    return entry
end

local function RemoveESP(player)
    local entry = Drawings[player]
    if not entry then return end
    for _, obj in pairs(entry) do pcall(function() obj:Remove() end) end
    Drawings[player] = nil
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

    -- Priority selection
    local best = list[1]
    for _, t in ipairs(list) do
        if Settings.PriorityMode == "Distance" then
            if t.worldDist < best.worldDist then best = t end
        elseif Settings.PriorityMode == "Health" then
            if t.hp < best.hp then best = t end
        elseif Settings.PriorityMode == "FOV" then
            if t.fovDist < best.fovDist then best = t end
        elseif Settings.PriorityMode == "Threat" then
            -- Threat = closest + lowest HP combo
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
    if not Drawing then return end

    local viewport = Camera.ViewportSize
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        local entry = Drawings[player]

        if not Settings.ESPEnabled or not IsEnemy(player) or not player.Character then
            if entry then
                for _, obj in pairs(entry) do pcall(function() obj.Visible = false end) end
            end
            continue
        end

        entry = entry or CreateESP(player)
        if not entry or not entry.Box then continue end

        local char = player.Character
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        local rootPart = char:FindFirstChild("HumanoidRootPart")
        local headPart = char:FindFirstChild("Head")

        if not humanoid or not rootPart or not headPart or humanoid.Health <= 0 then
            for _, obj in pairs(entry) do pcall(function() obj.Visible = false end) end
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

        if not onScreen then
            for _, obj in pairs(entry) do pcall(function() obj.Visible = false end) end
            continue
        end

        local color = GetPlayerColor(player)
        local boxH = bottomY - topY
        local boxW = rightX - leftX

        if Settings.ESPBox and entry.Box then
            entry.Box.Visible = true
            entry.Box.Color = color
            entry.Box.Size = Vector2.new(boxW, boxH)
            entry.Box.Position = Vector2.new(leftX, topY)
        elseif entry.Box then entry.Box.Visible = false end

        if Settings.ESPHealth and entry.Health and entry.HealthBg then
            local hpPercent = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
            local bw = 3
            entry.HealthBg.Visible = true
            entry.HealthBg.Size = Vector2.new(bw, boxH)
            entry.HealthBg.Position = Vector2.new(leftX - 6, topY)
            entry.Health.Visible = true
            entry.Health.Size = Vector2.new(bw, boxH * hpPercent)
            entry.Health.Position = Vector2.new(leftX - 6, topY + (boxH * (1 - hpPercent)))
            if hpPercent > 0.5 then
                entry.Health.Color = Color3.fromRGB(0, 255, 80)
            elseif hpPercent > 0.25 then
                entry.Health.Color = Color3.fromRGB(255, 200, 0)
            else
                entry.Health.Color = Color3.fromRGB(255, 40, 40)
            end
        else
            if entry.Health then entry.Health.Visible = false end
            if entry.HealthBg then entry.HealthBg.Visible = false end
        end

        if Settings.ESPName and entry.Name then
            entry.Name.Visible = true
            entry.Name.Color = color
            entry.Name.Position = Vector2.new(leftX + boxW / 2, topY - 16)
            entry.Name.Text = player.Name
        elseif entry.Name then entry.Name.Visible = false end

        if Settings.ESPDistance and entry.Distance then
            local dist = (Camera.CFrame.Position - rootPart.Position).Magnitude
            entry.Distance.Visible = true
            entry.Distance.Position = Vector2.new(leftX + boxW / 2, bottomY + 4)
            entry.Distance.Text = string.format("[%d studs]", math.floor(dist))
        elseif entry.Distance then entry.Distance.Visible = false end

        if Settings.ESPTracer and entry.Tracer then
            entry.Tracer.Visible = true
            entry.Tracer.Color = color
            entry.Tracer.From = Vector2.new(viewport.X / 2, viewport.Y)
            entry.Tracer.To = Vector2.new(leftX + boxW / 2, bottomY)
        elseif entry.Tracer then entry.Tracer.Visible = false end

        if Settings.ESPHeadDot and entry.HeadDot then
            local hp, hv = Camera:WorldToViewportPoint(headPart.Position)
            if hv then
                entry.HeadDot.Visible = true
                entry.HeadDot.Color = color
                entry.HeadDot.Position = Vector2.new(hp.X, hp.Y)
            else
                entry.HeadDot.Visible = false
            end
        elseif entry.HeadDot then entry.HeadDot.Visible = false end
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

-- Hit sound setup
local hitSound = Instance.new("Sound")
hitSound.SoundId = "rbxassetid://9125402735"
hitSound.Volume = 0.5
hitSound.Parent = SoundService

--==================================================
-- OPEN / CLOSE
--==================================================

local function SetMenuVisible(value)
    Main.Visible = value
    if value then
        Main.Size = UDim2.fromOffset(340, 460)
        TweenService:Create(Main,
            TweenInfo.new(0.22, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
            { Size = UDim2.fromOffset(380, 520) }
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
local fps = 0

RunService.RenderStepped:Connect(function(dt)
    -- FPS/Ping display
    frameCount = frameCount + 1
    fpsTimer = fpsTimer + dt
    if fpsTimer >= 0.5 then
        fps = math.floor(frameCount / fpsTimer)
        frameCount = 0
        fpsTimer = 0
        local ping = 0
        pcall(function()
            ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
        end)
        StatsLabel.Text = string.format("FPS %d | %dms", fps, ping)
    end

    local viewport = Camera.ViewportSize
    local center = Vector2.new(viewport.X / 2, viewport.Y / 2)

    -- FOV circle
    FOVCircle.Position = UDim2.fromOffset(center.X, center.Y)
    FOVCircle.Size = UDim2.fromOffset(Settings.FOV * 2, Settings.FOV * 2)
    FOVCircle.Visible = Settings.ShowFOV and Settings.Enabled

    -- Crosshair
    CrosshairH.Visible = Settings.Crosshair
    CrosshairV.Visible = Settings.Crosshair
    if Settings.Crosshair then
        CrosshairH.Size = UDim2.fromOffset(Settings.CrosshairSize, 2)
        CrosshairV.Size = UDim2.fromOffset(2, Settings.CrosshairSize)
        CrosshairH.Position = UDim2.fromOffset(center.X, center.Y)
        CrosshairV.Position = UDim2.fromOffset(center.X, center.Y)
        CrosshairH.BackgroundColor3 = Settings.CrosshairColor
        CrosshairV.BackgroundColor3 = Settings.CrosshairColor
    end

    -- ESP
    pcall(UpdateESP)

    -- Get current target
    local targets = GetTargetsList()
    local best = nil

    if Settings.LockOn and lockedTarget then
        for _, t in ipairs(targets) do
            if t.player == lockedTarget then best = t; break end
        end
    end

    if not best then
        best = PickTarget(targets)
    end

    lockedTarget = best and best.player or nil

    -- Target info panel
    if best and Settings.Enabled then
        TargetPanel.Visible = true
        TargetName.Text = best.player.Name
        TargetInfo.Text = string.format("%d studs  •  %d HP", math.floor(best.worldDist), math.floor(best.hp))
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

    -- Aim assist
    if Settings.Enabled and best then
        local cameraPos = Camera.CFrame.Position
        local desired = CFrame.lookAt(cameraPos, best.part.Position)
        local alpha = Settings.Smoothness

        -- Smoothness curve for a more human feel
        if Settings.Smoothness < 1 then
            alpha = Settings.Smoothness
        end

        Camera.CFrame = Camera.CFrame:Lerp(desired, alpha)
    end

    -- Triggerbot
    if Settings.TriggerBot and best then
        local now = tick()
        if now - Settings.lastTrigger >= Settings.TriggerDelay then
            Settings.lastTrigger = now
            pcall(function()
                if mouse1click then
                    mouse1click()
                elseif mouse1down and mouse1up then
                    mouse1down()
                    task.wait(0.02)
                    mouse1up()
                end
            end)
        end
    end
end)

--==================================================
-- CLEANUP
--==================================================

_G.HoodRivalsUnload = function()
    for player, _ in pairs(Drawings) do
        RemoveESP(player)
    end
    if ScreenGui then ScreenGui:Destroy() end
    if hitSound then hitSound:Destroy() end
end
