--// HOOD RIVALS
--// DELTA EXECUTOR AIM-ASSIST
--// Works as a LocalScript equivalent when executed via Delta

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

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
}

--==================================================
-- GUI PARENT (input-safe)
--==================================================
-- PlayerGui is used because gethui()/get_hidden_gui() place the GUI
-- in a protected layer that often blocks touch/mouse input on Delta.
-- That's why the HR button wasn't responding.

local function GetGuiParent()
    local pg = LocalPlayer:FindFirstChildOfClass("PlayerGui")
        or LocalPlayer:WaitForChild("PlayerGui", 5)
    if pg then return pg end

    -- Last resort fallbacks if PlayerGui is somehow missing
    if gethui then
        local ok, hui = pcall(gethui)
        if ok and hui then return hui end
    end
    return game:GetService("CoreGui")
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "HoodRivalsDeveloperUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.Enabled = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Delay parent assignment so PlayerGui is fully ready on mobile
task.defer(function()
    ScreenGui.Parent = GetGuiParent()
end)

--==================================================
-- FLOATING OPEN BUTTON
--==================================================

local OpenButton = Instance.new("TextButton")
OpenButton.Name = "OpenButton"
OpenButton.Size = UDim2.fromOffset(58, 58)
OpenButton.Position = UDim2.new(0, 18, 0.5, -29)
OpenButton.BackgroundColor3 = Color3.fromRGB(12, 12, 14)
OpenButton.Text = "HR"
OpenButton.TextColor3 = Color3.fromRGB(255, 255, 255)
OpenButton.TextSize = 17
OpenButton.Font = Enum.Font.GothamBold
OpenButton.AutoButtonColor = false
OpenButton.Active = true
OpenButton.Draggable = true
OpenButton.Parent = ScreenGui

local OpenCorner = Instance.new("UICorner")
OpenCorner.CornerRadius = UDim.new(0, 16)
OpenCorner.Parent = OpenButton

local OpenStroke = Instance.new("UIStroke")
OpenStroke.Color = Color3.fromRGB(70, 70, 75)
OpenStroke.Thickness = 1.5
OpenStroke.Parent = OpenButton

--==================================================
-- MAIN WINDOW
--==================================================

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.fromOffset(330, 420)
Main.Position = UDim2.new(0.5, -165, 0.5, -210)
Main.BackgroundColor3 = Color3.fromRGB(9, 9, 11)
Main.Visible = false
Main.Active = true
Main.Draggable = true
Main.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 20)
MainCorner.Parent = Main

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(55, 55, 60)
MainStroke.Thickness = 1.5
MainStroke.Parent = Main

--==================================================
-- HEADER
--==================================================

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 68)
Header.BackgroundTransparency = 1
Header.Parent = Main

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -80, 0, 32)
Title.Position = UDim2.fromOffset(20, 10)
Title.BackgroundTransparency = 1
Title.Text = "HOOD RIVALS"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 20
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local Subtitle = Instance.new("TextLabel")
Subtitle.Size = UDim2.new(1, -80, 0, 20)
Subtitle.Position = UDim2.fromOffset(21, 38)
Subtitle.BackgroundTransparency = 1
Subtitle.Text = "DELTA AIM TEST"
Subtitle.TextColor3 = Color3.fromRGB(120, 120, 125)
Subtitle.TextSize = 10
Subtitle.Font = Enum.Font.GothamMedium
Subtitle.TextXAlignment = Enum.TextXAlignment.Left
Subtitle.Parent = Header

local Close = Instance.new("TextButton")
Close.Size = UDim2.fromOffset(42, 42)
Close.Position = UDim2.new(1, -55, 0, 13)
Close.BackgroundColor3 = Color3.fromRGB(18, 18, 21)
Close.Text = "×"
Close.TextColor3 = Color3.fromRGB(220, 220, 220)
Close.TextSize = 25
Close.Font = Enum.Font.Gotham
Close.AutoButtonColor = false
Close.Parent = Header

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 12)
CloseCorner.Parent = Close

--==================================================
-- CONTENT
--==================================================

local Content = Instance.new("ScrollingFrame")
Content.Size = UDim2.new(1, -24, 1, -82)
Content.Position = UDim2.fromOffset(12, 72)
Content.BackgroundTransparency = 1
Content.BorderSizePixel = 0
Content.ScrollBarThickness = 3
Content.CanvasSize = UDim2.new()
Content.AutomaticCanvasSize = Enum.AutomaticSize.Y
Content.Parent = Main

local Layout = Instance.new("UIListLayout")
Layout.Padding = UDim.new(0, 9)
Layout.Parent = Content

local Padding = Instance.new("UIPadding")
Padding.PaddingLeft = UDim.new(0, 4)
Padding.PaddingRight = UDim.new(0, 4)
Padding.Parent = Content

--==================================================
-- HELPERS
--==================================================

local function CreateToggle(name, description, callback)
    local Holder = Instance.new("Frame")
    Holder.Size = UDim2.new(1, -8, 0, 64)
    Holder.BackgroundColor3 = Color3.fromRGB(16, 16, 19)
    Holder.Parent = Content

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 13)
    Corner.Parent = Holder

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -78, 0, 25)
    Label.Position = UDim2.fromOffset(14, 8)
    Label.BackgroundTransparency = 1
    Label.Text = name
    Label.TextColor3 = Color3.fromRGB(245, 245, 245)
    Label.TextSize = 14
    Label.Font = Enum.Font.GothamSemibold
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Holder

    local Desc = Instance.new("TextLabel")
    Desc.Size = UDim2.new(1, -78, 0, 18)
    Desc.Position = UDim2.fromOffset(14, 34)
    Desc.BackgroundTransparency = 1
    Desc.Text = description
    Desc.TextColor3 = Color3.fromRGB(105, 105, 110)
    Desc.TextSize = 10
    Desc.Font = Enum.Font.Gotham
    Desc.TextXAlignment = Enum.TextXAlignment.Left
    Desc.Parent = Holder

    local Button = Instance.new("TextButton")
    Button.Size = UDim2.fromOffset(48, 28)
    Button.Position = UDim2.new(1, -60, 0.5, -14)
    Button.BackgroundColor3 = Color3.fromRGB(35, 35, 39)
    Button.Text = "OFF"
    Button.TextColor3 = Color3.fromRGB(150, 150, 155)
    Button.TextSize = 10
    Button.Font = Enum.Font.GothamBold
    Button.AutoButtonColor = false
    Button.Parent = Holder

    local ButtonCorner = Instance.new("UICorner")
    ButtonCorner.CornerRadius = UDim.new(1, 0)
    ButtonCorner.Parent = Button

    local state = false

    Button.MouseButton1Click:Connect(function()
        state = not state
        if state then
            Button.Text = "ON"
            Button.TextColor3 = Color3.fromRGB(255, 255, 255)
            Button.BackgroundColor3 = Color3.fromRGB(65, 65, 70)
        else
            Button.Text = "OFF"
            Button.TextColor3 = Color3.fromRGB(150, 150, 155)
            Button.BackgroundColor3 = Color3.fromRGB(35, 35, 39)
        end
        callback(state)
    end)

    return Holder
end

local function CreateSlider(name, minimum, maximum, default, callback)
    local Holder = Instance.new("Frame")
    Holder.Size = UDim2.new(1, -8, 0, 76)
    Holder.BackgroundColor3 = Color3.fromRGB(16, 16, 19)
    Holder.Parent = Content

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 13)
    Corner.Parent = Holder

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -30, 0, 25)
    Label.Position = UDim2.fromOffset(14, 8)
    Label.BackgroundTransparency = 1
    Label.Text = name .. "  " .. tostring(default)
    Label.TextColor3 = Color3.fromRGB(245, 245, 245)
    Label.TextSize = 13
    Label.Font = Enum.Font.GothamSemibold
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Holder

    local Bar = Instance.new("Frame")
    Bar.Size = UDim2.new(1, -28, 0, 7)
    Bar.Position = UDim2.fromOffset(14, 49)
    Bar.BackgroundColor3 = Color3.fromRGB(35, 35, 39)
    Bar.Parent = Holder

    local BarCorner = Instance.new("UICorner")
    BarCorner.CornerRadius = UDim.new(1, 0)
    BarCorner.Parent = Bar

    local Fill = Instance.new("Frame")
    Fill.Size = UDim2.new((default - minimum) / (maximum - minimum), 0, 1, 0)
    Fill.BackgroundColor3 = Color3.fromRGB(230, 230, 235)
    Fill.Parent = Bar

    local FillCorner = Instance.new("UICorner")
    FillCorner.CornerRadius = UDim.new(1, 0)
    FillCorner.Parent = Fill

    local dragging = false

    local function Update(x)
        local percent = math.clamp((x - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
        local value = minimum + (maximum - minimum) * percent
        value = math.floor(value * 100) / 100
        Fill.Size = UDim2.new(percent, 0, 1, 0)
        Label.Text = name .. "  " .. tostring(value)
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
end

--==================================================
-- SETTINGS UI
--==================================================

CreateToggle("AIM ASSIST", "Enable target tracking", function(v) Settings.Enabled = v end)
CreateToggle("FOV CIRCLE", "Display aim radius",    function(v) Settings.ShowFOV = v end)
CreateToggle("TEAM CHECK", "Ignore teammates",      function(v) Settings.TeamCheck = v end)
CreateToggle("WALL CHECK", "Ignore behind walls",   function(v) Settings.WallCheck = v end)

CreateSlider("FOV", 50, 500, Settings.FOV, function(v) Settings.FOV = v end)
CreateSlider("SMOOTHNESS", 0.05, 1, Settings.Smoothness, function(v) Settings.Smoothness = v end)

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
-- TARGETING
--==================================================

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

local function GetClosestTarget()
    local closest = nil
    local closestDistance = Settings.FOV

    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and IsEnemy(player) and player.Character then
            local character = player.Character
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            local targetPart = character:FindFirstChild(Settings.TargetPart)

            if humanoid and humanoid.Health > 0 and targetPart then
                local position, visible = Camera:WorldToViewportPoint(targetPart.Position)

                if visible then
                    local screenPosition = Vector2.new(position.X, position.Y)
                    local distance = (screenPosition - center).Magnitude

                    if distance < closestDistance and HasLineOfSight(character, targetPart) then
                        closestDistance = distance
                        closest = targetPart
                    end
                end
            end
        end
    end

    return closest
end

--==================================================
-- OPEN / CLOSE
--==================================================

local function SetMenuVisible(value)
    Main.Visible = value
    if value then
        Main.Size = UDim2.fromOffset(300, 390)
        TweenService:Create(Main,
            TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
            { Size = UDim2.fromOffset(330, 420) }
        ):Play()
    end
end

-- Two click handlers for maximum mobile compatibility
OpenButton.MouseButton1Click:Connect(function()
    SetMenuVisible(not Main.Visible)
end)
OpenButton.Activated:Connect(function()
    SetMenuVisible(not Main.Visible)
end)

Close.MouseButton1Click:Connect(function()
    SetMenuVisible(false)
end)
Close.Activated:Connect(function()
    SetMenuVisible(false)
end)

--==================================================
-- MAIN LOOP
--==================================================

RunService.RenderStepped:Connect(function()
    local viewport = Camera.ViewportSize
    local center = Vector2.new(viewport.X / 2, viewport.Y / 2)

    FOVCircle.Position = UDim2.fromOffset(center.X, center.Y)
    FOVCircle.Size = UDim2.fromOffset(Settings.FOV * 2, Settings.FOV * 2)
    FOVCircle.Visible = Settings.ShowFOV and Settings.Enabled

    if not Settings.Enabled then return end

    local target = GetClosestTarget()
    if target then
        local cameraPosition = Camera.CFrame.Position
        local desired = CFrame.lookAt(cameraPosition, target.Position)
        Camera.CFrame = Camera.CFrame:Lerp(desired, Settings.Smoothness)
    end
end)

--==================================================
-- CLEANUP (in case you want to unload)
--==================================================

-- _G.HoodRivalsUnload = function()
--     if ScreenGui then ScreenGui:Destroy() end
-- end
