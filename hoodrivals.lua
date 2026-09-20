--[[
    DELTA EXECUTOR SHOOTING TOOLKIT
    Mobile compatible

    Features:
    • Strong head aim assist
    • FOV circle
    • Custom crosshair
    • ESP
    • Tracers
    • Triggerbot test
    • Team check
    • Wall check
    • Target priority
    • Lock-break angle
    • Smooth aim
    • Mobile GUI
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

local LocalPlayer = Players.LocalPlayer

--------------------------------------------------
-- CONFIG
--------------------------------------------------

local Config = {
    AimEnabled = true,
    ESPEnabled = true,
    TracersEnabled = true,
    TriggerEnabled = false,

    TeamCheck = true,
    WallCheck = true,

    FOV = 180,
    AimStrength = 0.35,
    LockBreakAngle = 30,

    TargetPart = "Head",

    CrosshairEnabled = true,
    CrosshairSize = 7,
    CrosshairGap = 5,
    CrosshairThickness = 2,

    ESPDistance = true,
    ESPNames = true,

    TracerOrigin = "Bottom",

    MenuOpen = true,
}

--------------------------------------------------
-- GUI
--------------------------------------------------

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DeltaShootingToolkit"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

--------------------------------------------------
-- CROSSHAIR
--------------------------------------------------

local Crosshair = Instance.new("Frame")
Crosshair.Name = "Crosshair"
Crosshair.BackgroundTransparency = 1
Crosshair.Size = UDim2.fromOffset(100, 100)
Crosshair.AnchorPoint = Vector2.new(0.5, 0.5)
Crosshair.Position = UDim2.fromScale(0.5, 0.5)
Crosshair.Parent = ScreenGui

local function CrossLine(name)
    local line = Instance.new("Frame")
    line.Name = name
    line.BorderSizePixel = 0
    line.BackgroundColor3 = Color3.fromRGB(255,255,255)
    line.AnchorPoint = Vector2.new(0.5,0.5)
    line.Parent = Crosshair
    return line
end

local CrossTop = CrossLine("Top")
local CrossBottom = CrossLine("Bottom")
local CrossLeft = CrossLine("Left")
local CrossRight = CrossLine("Right")
local CrossDot = CrossLine("Dot")

local function UpdateCrosshair()
    local size = Config.CrosshairSize
    local gap = Config.CrosshairGap
    local thickness = Config.CrosshairThickness

    CrossTop.Size = UDim2.fromOffset(thickness, size)
    CrossBottom.Size = UDim2.fromOffset(thickness, size)
    CrossLeft.Size = UDim2.fromOffset(size, thickness)
    CrossRight.Size = UDim2.fromOffset(size, thickness)
    CrossDot.Size = UDim2.fromOffset(thickness, thickness)

    CrossTop.Position = UDim2.fromOffset(50, 50 - gap - size/2)
    CrossBottom.Position = UDim2.fromOffset(50, 50 + gap + size/2)
    CrossLeft.Position = UDim2.fromOffset(50 - gap - size/2, 50)
    CrossRight.Position = UDim2.fromOffset(50 + gap + size/2, 50)
    CrossDot.Position = UDim2.fromOffset(50,50)
end

UpdateCrosshair()

--------------------------------------------------
-- FOV
--------------------------------------------------

local FOVCircle = Instance.new("Frame")
FOVCircle.Name = "FOV"
FOVCircle.AnchorPoint = Vector2.new(0.5,0.5)
FOVCircle.Position = UDim2.fromScale(0.5,0.5)
FOVCircle.BackgroundTransparency = 1
FOVCircle.Parent = ScreenGui

local FOVCorner = Instance.new("UICorner")
FOVCorner.CornerRadius = UDim.new(1,0)
FOVCorner.Parent = FOVCircle

local FOVStroke = Instance.new("UIStroke")
FOVStroke.Thickness = 1.5
FOVStroke.Color = Color3.fromRGB(255,255,255)
FOVStroke.Transparency = 0.35
FOVStroke.Parent = FOVCircle

local function UpdateFOV()
    FOVCircle.Size = UDim2.fromOffset(Config.FOV * 2, Config.FOV * 2)
end

UpdateFOV()

--------------------------------------------------
-- TARGET ESP
--------------------------------------------------

local ESPObjects = {}

local function RemoveESP(player)
    if ESPObjects[player] then
        for _, obj in pairs(ESPObjects[player]) do
            if obj and obj.Destroy then
                obj:Destroy()
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

    local highlight = Instance.new("Highlight")
    highlight.Name = "DeltaESP"
    highlight.FillTransparency = 0.82
    highlight.OutlineTransparency = 0
    highlight.FillColor = Color3.fromRGB(255,70,70)
    highlight.OutlineColor = Color3.fromRGB(255,255,255)
    highlight.Enabled = Config.ESPEnabled

    local function attach(character)
        if character then
            highlight.Adornee = character
            highlight.Parent = character
        end
    end

    attach(player.Character)

    player.CharacterAdded:Connect(function(character)
        task.wait(0.2)
        attach(character)
    end)

    ESPObjects[player] = {
        highlight
    }
end

for _, player in ipairs(Players:GetPlayers()) do
    CreateESP(player)
end

Players.PlayerAdded:Connect(CreateESP)
Players.PlayerRemoving:Connect(RemoveESP)

--------------------------------------------------
-- TARGET CHECKS
--------------------------------------------------

local function IsAlive(character)
    if not character then
        return false
    end

    local humanoid = character:FindFirstChildOfClass("Humanoid")

    return humanoid and humanoid.Health > 0
end

local function IsEnemy(player)
    if not Config.TeamCheck then
        return true
    end

    if not LocalPlayer.Team or not player.Team then
        return true
    end

    return LocalPlayer.Team ~= player.Team
end

local function HasLineOfSight(character, part)
    if not Config.WallCheck then
        return true
    end

    local origin = Camera.CFrame.Position
    local direction = part.Position - origin

    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {
        LocalPlayer.Character,
        Camera
    }

    local result = workspace:Raycast(
        origin,
        direction,
        params
    )

    if not result then
        return true
    end

    return result.Instance:IsDescendantOf(character)
end

--------------------------------------------------
-- TARGET SELECTION
--------------------------------------------------

local CurrentTarget = nil

local function GetTarget()
    local viewport = Camera.ViewportSize

    local center = Vector2.new(
        viewport.X / 2,
        viewport.Y / 2
    )

    local bestPlayer = nil
    local bestDistance = Config.FOV

    for _, player in ipairs(Players:GetPlayers()) do

        if player ~= LocalPlayer
        and IsEnemy(player)
        and player.Character
        and IsAlive(player.Character) then

            local head = player.Character:FindFirstChild(
                Config.TargetPart
            )

            if head then

                local screenPosition, visible =
                    Camera:WorldToViewportPoint(head.Position)

                if visible and screenPosition.Z > 0 then

                    local screenDistance =
                        (Vector2.new(
                            screenPosition.X,
                            screenPosition.Y
                        ) - center).Magnitude

                    if screenDistance <= bestDistance then

                        if HasLineOfSight(
                            player.Character,
                            head
                        ) then

                            bestDistance = screenDistance
                            bestPlayer = player
                        end
                    end
                end
            end
        end
    end

    return bestPlayer
end

--------------------------------------------------
-- AIM LOCK
--------------------------------------------------

local function GetTargetAngle(player)
    if not player
    or not player.Character then
        return math.huge
    end

    local head = player.Character:FindFirstChild(
        Config.TargetPart
    )

    if not head then
        return math.huge
    end

    local cameraPosition = Camera.CFrame.Position

    local direction =
        (head.Position - cameraPosition).Unit

    local dot =
        math.clamp(
            Camera.CFrame.LookVector:Dot(direction),
            -1,
            1
        )

    return math.deg(math.acos(dot))
end

local function AimAtTarget(player)
    if not player
    or not player.Character then
        return
    end

    local head = player.Character:FindFirstChild(
        Config.TargetPart
    )

    if not head then
        return
    end

    local cameraPosition = Camera.CFrame.Position

    local targetCFrame =
        CFrame.lookAt(
            cameraPosition,
            head.Position
        )

    Camera.CFrame =
        Camera.CFrame:Lerp(
            targetCFrame,
            Config.AimStrength
        )
end

--------------------------------------------------
-- TRIGGERBOT TEST
--------------------------------------------------

local function TriggerTest(target)
    if not target then
        return
    end

    -- Developer hook.
    --
    -- Connect your own weapon firing system here.
    --
    -- Example:
    -- ReplicatedStorage.Remotes.FireWeapon:FireServer()

    local character = target.Character

    if not character then
        return
    end

    local head = character:FindFirstChild("Head")

    if not head then
        return
    end

    -- This intentionally does not fire
    -- an arbitrary weapon or remote.
    --
    -- Use this location to connect your
    -- own game's authorized firing system.
end

--------------------------------------------------
-- TRACERS
--------------------------------------------------

local TracerFolder = Instance.new("Folder")
TracerFolder.Name = "DeltaTracers"
TracerFolder.Parent = ScreenGui

local function ClearTracers()
    for _, child in ipairs(TracerFolder:GetChildren()) do
        child:Destroy()
    end
end

local function DrawTracer(player)
    if not player.Character then
        return
    end

    local head = player.Character:FindFirstChild("Head")

    if not head then
        return
    end

    local viewport = Camera.ViewportSize

    local screenPosition, visible =
        Camera:WorldToViewportPoint(head.Position)

    if not visible or screenPosition.Z <= 0 then
        return
    end

    local origin

    if Config.TracerOrigin == "Center" then
        origin = Vector2.new(
            viewport.X/2,
            viewport.Y/2
        )
    else
        origin = Vector2.new(
            viewport.X/2,
            viewport.Y
        )
    end

    local destination = Vector2.new(
        screenPosition.X,
        screenPosition.Y
    )

    local difference = destination - origin

    local line = Instance.new("Frame")
    line.BorderSizePixel = 0
    line.BackgroundColor3 =
        player == CurrentTarget
        and Color3.fromRGB(255,255,255)
        or Color3.fromRGB(255,80,80)

    line.Size = UDim2.fromOffset(
        difference.Magnitude,
        1
    )

    line.Position = UDim2.fromOffset(
        (origin.X + destination.X)/2,
        (origin.Y + destination.Y)/2
    )

    line.AnchorPoint = Vector2.new(0.5,0.5)

    line.Rotation =
        math.deg(
            math.atan2(
                difference.Y,
                difference.X
            )
        )

    line.Parent = TracerFolder
end

--------------------------------------------------
-- TARGET INFO
--------------------------------------------------

local TargetLabel = Instance.new("TextLabel")
TargetLabel.BackgroundTransparency = 1
TargetLabel.Size = UDim2.fromOffset(300,40)
TargetLabel.Position = UDim2.new(0.5,-150,0.5,65)
TargetLabel.Text = ""
TargetLabel.TextColor3 = Color3.fromRGB(255,255,255)
TargetLabel.TextSize = 15
TargetLabel.Font = Enum.Font.GothamBold
TargetLabel.Parent = ScreenGui

--------------------------------------------------
-- MAIN GUI
--------------------------------------------------

local OpenButton = Instance.new("TextButton")
OpenButton.Size = UDim2.fromOffset(58,58)
OpenButton.Position = UDim2.new(0,25,0.5,-29)
OpenButton.Text = "HR"
OpenButton.TextSize = 16
OpenButton.Font = Enum.Font.GothamBold
OpenButton.TextColor3 = Color3.fromRGB(255,255,255)
OpenButton.BackgroundColor3 = Color3.fromRGB(12,12,12)
OpenButton.Parent = ScreenGui

local OpenCorner = Instance.new("UICorner")
OpenCorner.CornerRadius = UDim.new(0,14)
OpenCorner.Parent = OpenButton

local Main = Instance.new("Frame")
Main.Size = UDim2.fromOffset(300,420)
Main.Position = UDim2.new(0,90,0.5,-210)
Main.BackgroundColor3 = Color3.fromRGB(10,10,10)
Main.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0,16)
MainCorner.Parent = Main

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(55,55,55)
MainStroke.Thickness = 1
MainStroke.Parent = Main

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1,-50,0,50)
Title.Position = UDim2.fromOffset(18,5)
Title.BackgroundTransparency = 1
Title.Text = "SHOOTING TOOLKIT"
Title.TextColor3 = Color3.fromRGB(255,255,255)
Title.TextSize = 17
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Main

local Close = Instance.new("TextButton")
Close.Size = UDim2.fromOffset(35,35)
Close.Position = UDim2.new(1,-45,0,10)
Close.Text = "×"
Close.TextSize = 25
Close.TextColor3 = Color3.fromRGB(255,255,255)
Close.BackgroundTransparency = 1
Close.Parent = Main

--------------------------------------------------
-- BUTTON CREATOR
--------------------------------------------------

local function MakeToggle(text, y, callback)

    local button = Instance.new("TextButton")

    button.Size = UDim2.new(1,-30,0,42)
    button.Position = UDim2.fromOffset(15,y)

    button.BackgroundColor3 =
        Color3.fromRGB(22,22,22)

    button.TextColor3 =
        Color3.fromRGB(255,255,255)

    button.TextSize = 13
    button.Font = Enum.Font.GothamMedium

    button.Text = text

    button.Parent = Main

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0,10)
    corner.Parent = button

    button.Activated:Connect(function()
        callback(button)
    end)

    return button
end

local AimButton = MakeToggle(
    "AIM ASSIST  •  ON",
    65,
    function(button)

        Config.AimEnabled =
            not Config.AimEnabled

        button.Text =
            "AIM ASSIST  •  "
            .. (Config.AimEnabled
                and "ON"
                or "OFF")
    end
)

local ESPButton = MakeToggle(
    "ESP  •  ON",
    115,
    function(button)

        Config.ESPEnabled =
            not Config.ESPEnabled

        button.Text =
            "ESP  •  "
            .. (Config.ESPEnabled
                and "ON"
                or "OFF")

        for _, objects in pairs(ESPObjects) do
            for _, object in pairs(objects) do
                if object:IsA("Highlight") then
                    object.Enabled =
                        Config.ESPEnabled
                end
            end
        end
    end
)

local TracerButton = MakeToggle(
    "TRACERS  •  ON",
    165,
    function(button)

        Config.TracersEnabled =
            not Config.TracersEnabled

        button.Text =
            "TRACERS  •  "
            .. (Config.TracersEnabled
                and "ON"
                or "OFF")
    end
)

local TriggerButton = MakeToggle(
    "TRIGGER TEST  •  OFF",
    215,
    function(button)

        Config.TriggerEnabled =
            not Config.TriggerEnabled

        button.Text =
            "TRIGGER TEST  •  "
            .. (Config.TriggerEnabled
                and "ON"
                or "OFF")
    end
)

local CrossButton = MakeToggle(
    "CROSSHAIR  •  ON",
    265,
    function(button)

        Config.CrosshairEnabled =
            not Config.CrosshairEnabled

        button.Text =
            "CROSSHAIR  •  "
            .. (Config.CrosshairEnabled
                and "ON"
                or "OFF")

        Crosshair.Visible =
            Config.CrosshairEnabled
    end
)

local FOVButton = MakeToggle(
    "FOV CIRCLE  •  ON",
    315,
    function(button)

        FOVCircle.Visible =
            not FOVCircle.Visible

        button.Text =
            "FOV CIRCLE  •  "
            .. (FOVCircle.Visible
                and "ON"
                or "OFF")
    end
)

--------------------------------------------------
-- MENU
--------------------------------------------------

Close.Activated:Connect(function()
    Main.Visible = false
end)

OpenButton.Activated:Connect(function()
    Main.Visible = not Main.Visible
end)

--------------------------------------------------
-- MOBILE DRAGGING
--------------------------------------------------

local dragging = false
local dragStart
local startPosition

local function Drag(input)

    local delta =
        input.Position - dragStart

    Main.Position =
        UDim2.new(
            startPosition.X.Scale,
            startPosition.X.Offset + delta.X,
            startPosition.Y.Scale,
            startPosition.Y.Offset + delta.Y
        )
end

Title.InputBegan:Connect(function(input)

    if input.UserInputType ==
        Enum.UserInputType.Touch then

        dragging = true
        dragStart = input.Position
        startPosition = Main.Position
    end
end)

Title.InputChanged:Connect(function(input)

    if input.UserInputType ==
        Enum.UserInputType.Touch then

        input.Changed:Connect(function()

            if input.UserInputState ==
                Enum.UserInputState.End then

                dragging = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)

    if dragging
    and input.UserInputType ==
        Enum.UserInputType.Touch then

        Drag(input)
    end
end)

--------------------------------------------------
-- MAIN LOOP
--------------------------------------------------

RunService.RenderStepped:Connect(function()

    if not Camera then
        Camera = workspace.CurrentCamera
    end

    ------------------------------------------------
    -- TARGET
    ------------------------------------------------

    local target = GetTarget()

    if CurrentTarget then

        if not CurrentTarget.Character
        or not IsAlive(CurrentTarget.Character)
        or not IsEnemy(CurrentTarget) then

            CurrentTarget = nil

        else

            local angle =
                GetTargetAngle(CurrentTarget)

            if angle > Config.LockBreakAngle then
                CurrentTarget = nil
            end
        end
    end

    if not CurrentTarget then
        CurrentTarget = target
    end

    ------------------------------------------------
    -- AIM
    ------------------------------------------------

    if Config.AimEnabled
    and CurrentTarget then

        AimAtTarget(CurrentTarget)
    end

    ------------------------------------------------
    -- TRIGGER
    ------------------------------------------------

    if Config.TriggerEnabled
    and CurrentTarget then

        TriggerTest(CurrentTarget)
    end

    ------------------------------------------------
    -- TARGET INFO
    ------------------------------------------------

    if CurrentTarget
    and CurrentTarget.Character then

        local head =
            CurrentTarget.Character:FindFirstChild("Head")

        if head then

            local distance =
                (Camera.CFrame.Position -
                head.Position).Magnitude

            TargetLabel.Text =
                "LOCKED  •  "
                .. CurrentTarget.DisplayName
                .. "  •  "
                .. math.floor(distance)
                .. " studs"

        end

    else
        TargetLabel.Text = ""
    end

    ------------------------------------------------
    -- TRACERS
    ------------------------------------------------

    ClearTracers()

    if Config.TracersEnabled then

        for _, player in ipairs(
            Players:GetPlayers()
        ) do

            if player ~= LocalPlayer
            and IsEnemy(player)
            and player.Character
            and IsAlive(player.Character) then

                DrawTracer(player)
            end
        end
    end

end)
