--========================================================--
--        DEVELOPER SHOOTING TOOLKIT V2
--        DELTA EXECUTOR EDITION
--        Mobile Friendly
--
--        Combat:
--          • Head Aim Assist
--          • FOV
--          • Smooth Lock
--          • Lock Break Angle
--
--        Visuals:
--          • Health Bar ESP
--          • Name ESP
--          • Distance ESP
--          • Box ESP
--          • Head Marker
--          • Tracers
--          • Locked Target Highlight
--
--        UI:
--          • Modern black/white interface
--          • Categories
--          • Animated toggles
--          • Mobile draggable window
--========================================================--

--========================================================--
-- RE-EXECUTION CLEANUP
--========================================================--

if getgenv().DSTv2 and getgenv().DSTv2.Destroy then
	pcall(getgenv().DSTv2.Destroy)
end

local Script = {
	Gui = nil,
	Connections = {},
}

function Script.Track(connection)
	table.insert(Script.Connections, connection)
	return connection
end

function Script.Destroy()
	for _, connection in ipairs(Script.Connections) do
		pcall(function()
			connection:Disconnect()
		end)
	end
	Script.Connections = {}
	if Script.Gui then
		pcall(function()
			Script.Gui:Destroy()
		end)
		Script.Gui = nil
	end
end

getgenv().DSTv2 = Script

--========================================================--
-- SERVICES
--========================================================--

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
	or Players:WaitForChild("LocalPlayer", 10)

if not LocalPlayer then
	warn("[DSTv2] LocalPlayer not available.")
	return
end

local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Camera = workspace.CurrentCamera
	or workspace:WaitForChild("Camera", 10)

--========================================================--
-- CONFIG
--========================================================--

local Config = {
	-- Combat
	AimEnabled = true,
	FOV = 180,
	AimStrength = 0.35,
	LockBreakAngle = 30,
	TargetPart = "Head",

	-- Visuals
	ESPEnabled = true,
	Boxes = true,
	HealthBars = true,
	Names = true,
	Distances = true,
	HeadMarkers = true,
	Tracers = true,

	TeamCheck = true,
	WallCheck = true,

	-- UI
	MenuOpen = true,
}

--========================================================--
-- COLORS
--========================================================--

local WHITE = Color3.fromRGB(255, 255, 255)
local BLACK = Color3.fromRGB(8, 8, 8)
local DARK = Color3.fromRGB(15, 15, 15)
local DARKER = Color3.fromRGB(11, 11, 11)
local LIGHT = Color3.fromRGB(35, 35, 35)
local MUTED = Color3.fromRGB(150, 150, 150)
local RED = Color3.fromRGB(255, 75, 75)
local GREEN = Color3.fromRGB(80, 255, 150)

--========================================================--
-- SCREEN GUI
--========================================================--

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DeveloperShootingToolkitV2"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.DisplayOrder = 100
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = PlayerGui
Script.Gui = ScreenGui

--========================================================--
-- CROSSHAIR
--========================================================--

local Crosshair = Instance.new("Frame")
Crosshair.Name = "Crosshair"
Crosshair.Size = UDim2.fromOffset(100, 100)
Crosshair.Position = UDim2.fromScale(0.5, 0.5)
Crosshair.AnchorPoint = Vector2.new(.5, .5)
Crosshair.BackgroundTransparency = 1
Crosshair.Parent = ScreenGui

local function NewCrossLine()
	local f = Instance.new("Frame")
	f.BackgroundColor3 = WHITE
	f.BorderSizePixel = 0
	f.AnchorPoint = Vector2.new(.5, .5)
	f.Parent = Crosshair
	return f
end

local CrossTop = NewCrossLine()
local CrossBottom = NewCrossLine()
local CrossLeft = NewCrossLine()
local CrossRight = NewCrossLine()
local CrossDot = NewCrossLine()

local function UpdateCrosshair()
	local size = 7
	local gap = 5
	local thickness = 2

	CrossTop.Size = UDim2.fromOffset(thickness, size)
	CrossBottom.Size = UDim2.fromOffset(thickness, size)
	CrossLeft.Size = UDim2.fromOffset(size, thickness)
	CrossRight.Size = UDim2.fromOffset(size, thickness)
	CrossDot.Size = UDim2.fromOffset(thickness, thickness)

	CrossTop.Position = UDim2.fromOffset(50, 50 - gap - size / 2)
	CrossBottom.Position = UDim2.fromOffset(50, 50 + gap + size / 2)
	CrossLeft.Position = UDim2.fromOffset(50 - gap - size / 2, 50)
	CrossRight.Position = UDim2.fromOffset(50 + gap + size / 2, 50)
	CrossDot.Position = UDim2.fromOffset(50, 50)
end

UpdateCrosshair()

--========================================================--
-- FOV
--========================================================--

local FOVCircle = Instance.new("Frame")
FOVCircle.Name = "FOVCircle"
FOVCircle.AnchorPoint = Vector2.new(.5, .5)
FOVCircle.Position = UDim2.fromScale(.5, .5)
FOVCircle.BackgroundTransparency = 1
FOVCircle.Parent = ScreenGui

local FOVCorner = Instance.new("UICorner")
FOVCorner.CornerRadius = UDim.new(1, 0)
FOVCorner.Parent = FOVCircle

local FOVStroke = Instance.new("UIStroke")
FOVStroke.Color = WHITE
FOVStroke.Thickness = 1.5
FOVStroke.Transparency = .45
FOVStroke.Parent = FOVCircle

local function UpdateFOV()
	FOVCircle.Size = UDim2.fromOffset(Config.FOV * 2, Config.FOV * 2)
end

UpdateFOV()

--========================================================--
-- ESP CONTAINER
--========================================================--

local ESPContainer = Instance.new("Folder")
ESPContainer.Name = "ESP"
ESPContainer.Parent = ScreenGui

local ESPObjects = {}

--========================================================--
-- HELPERS
--========================================================--

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
		Camera,
	}

	local result = workspace:Raycast(origin, direction, params)

	if not result then
		return true
	end

	return result.Instance:IsDescendantOf(character)
end

--========================================================--
-- ESP CREATION
--========================================================--

local function RemoveESP(player)
	if ESPObjects[player] then
		for _, object in pairs(ESPObjects[player]) do
			if typeof(object) == "Instance" and object then
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

	-- Billboard
	local billboard = Instance.new("BillboardGui")
	billboard.Name = "PlayerInfo"
	billboard.Size = UDim2.fromOffset(180, 70)
	billboard.StudsOffset = Vector3.new(0, 3.3, 0)
	billboard.AlwaysOnTop = true
	billboard.Enabled = Config.ESPEnabled
	billboard.Parent = ESPContainer

	-- Main card
	local card = Instance.new("Frame")
	card.Size = UDim2.fromScale(1, 1)
	card.BackgroundColor3 = BLACK
	card.BackgroundTransparency = .2
	card.Parent = billboard

	local cardCorner = Instance.new("UICorner")
	cardCorner.CornerRadius = UDim.new(0, 8)
	cardCorner.Parent = card

	local cardStroke = Instance.new("UIStroke")
	cardStroke.Color = WHITE
	cardStroke.Transparency = .65
	cardStroke.Thickness = 1
	cardStroke.Parent = card

	-- Name
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

	-- Username
	local username = Instance.new("TextLabel")
	username.BackgroundTransparency = 1
	username.Size = UDim2.new(1, -16, 0, 15)
	username.Position = UDim2.fromOffset(8, 22)
	username.Text = "@" .. player.Name
	username.TextColor3 = MUTED
	username.TextSize = 10
	username.Font = Enum.Font.Gotham
	username.TextXAlignment = Enum.TextXAlignment.Left
	username.Parent = card

	-- Health background
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

	-- Health fill
	local healthFill = Instance.new("Frame")
	healthFill.Name = "Health"
	healthFill.Size = UDim2.fromScale(1, 1)
	healthFill.BackgroundColor3 = GREEN
	healthFill.BorderSizePixel = 0
	healthFill.Parent = healthBack

	local healthFillCorner = Instance.new("UICorner")
	healthFillCorner.CornerRadius = UDim.new(1, 0)
	healthFillCorner.Parent = healthFill

	-- Bottom information
	local info = Instance.new("TextLabel")
	info.Name = "Info"
	info.BackgroundTransparency = 1
	info.Size = UDim2.new(1, -16, 0, 17)
	info.Position = UDim2.fromOffset(8, 50)
	info.Text = "100 HP  •  0 studs"
	info.TextColor3 = WHITE
	info.TextSize = 9
	info.Font = Enum.Font.GothamMedium
	info.TextXAlignment = Enum.TextXAlignment.Left
	info.Parent = card

	-- Box
	local box = Instance.new("SelectionBox")
	box.Name = "Box"
	box.LineThickness = .025
	box.Color3 = WHITE
	box.SurfaceTransparency = 1
	box.Visible = Config.Boxes
	box.Parent = ESPContainer

	-- Head marker
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

	-- Tracer (2D frame line from bottom-center of screen to target)
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

	local function CharacterAdded(character)
		local head = character:WaitForChild("Head", 5)
		local humanoid = character:WaitForChild("Humanoid", 5)

		if head then
			billboard.Adornee = head
			headMarker.Adornee = head
		end

		if character then
			box.Adornee = character
		end

		if humanoid then
			Script.Track(humanoid.Died:Connect(function()
				billboard.Enabled = false
				headMarker.Enabled = false
				box.Visible = false
				tracer.Visible = false
			end))
		end
	end

	if player.Character then
		CharacterAdded(player.Character)
	end

	Script.Track(player.CharacterAdded:Connect(function(character)
		task.wait(.2)
		CharacterAdded(character)
	end))
end

--========================================================--
-- CREATE ESP FOR EXISTING PLAYERS
--========================================================--

for _, player in ipairs(Players:GetPlayers()) do
	CreateESP(player)
end

Script.Track(Players.PlayerAdded:Connect(CreateESP))
Script.Track(Players.PlayerRemoving:Connect(RemoveESP))

--========================================================--
-- TARGETING
--========================================================--

local CurrentTarget = nil

local function GetTarget()
	local viewport = Camera.ViewportSize
	local center = Vector2.new(viewport.X / 2, viewport.Y / 2)

	local best = nil
	local bestDistance = Config.FOV

	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer
			and IsEnemy(player)
			and player.Character
			and IsAlive(player.Character)
		then
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
	if not player or not player.Character then
		return math.huge
	end

	local head = player.Character:FindFirstChild(Config.TargetPart)
	if not head then
		return math.huge
	end

	local direction = (head.Position - Camera.CFrame.Position).Unit
	local dot = math.clamp(Camera.CFrame.LookVector:Dot(direction), -1, 1)

	return math.deg(math.acos(dot))
end

local function AimAt(player)
	if not player or not player.Character then
		return
	end

	local head = player.Character:FindFirstChild(Config.TargetPart)
	if not head then
		return
	end

	local targetCFrame = CFrame.lookAt(Camera.CFrame.Position, head.Position)
	Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, Config.AimStrength)
end

--========================================================--
-- LOCK STATUS
--========================================================--

local Status = Instance.new("Frame")
Status.Size = UDim2.fromOffset(250, 48)
Status.Position = UDim2.new(.5, -125, 1, -65)
Status.BackgroundColor3 = BLACK
Status.BackgroundTransparency = .15
Status.Visible = true
Status.Parent = ScreenGui

local StatusCorner = Instance.new("UICorner")
StatusCorner.CornerRadius = UDim.new(0, 12)
StatusCorner.Parent = Status

local StatusStroke = Instance.new("UIStroke")
StatusStroke.Color = WHITE
StatusStroke.Transparency = .75
StatusStroke.Parent = Status

local StatusText = Instance.new("TextLabel")
StatusText.Size = UDim2.fromScale(1, 1)
StatusText.BackgroundTransparency = 1
StatusText.Text = "NO TARGET"
StatusText.TextColor3 = MUTED
StatusText.TextSize = 12
StatusText.Font = Enum.Font.GothamBold
StatusText.Parent = Status

--========================================================--
-- OPEN BUTTON
--========================================================--

local OpenButton = Instance.new("TextButton")
OpenButton.Size = UDim2.fromOffset(58, 58)
OpenButton.Position = UDim2.new(0, 22, .5, -29)
OpenButton.BackgroundColor3 = BLACK
OpenButton.Text = "S"
OpenButton.TextColor3 = WHITE
OpenButton.TextSize = 20
OpenButton.Font = Enum.Font.GothamBlack
OpenButton.Parent = ScreenGui

local OpenCorner = Instance.new("UICorner")
OpenCorner.CornerRadius = UDim.new(0, 16)
OpenCorner.Parent = OpenButton

local OpenStroke = Instance.new("UIStroke")
OpenStroke.Color = WHITE
OpenStroke.Transparency = .65
OpenStroke.Parent = OpenButton

--========================================================--
-- MAIN WINDOW
--========================================================--

local Main = Instance.new("Frame")
Main.Size = UDim2.fromOffset(350, 450)
Main.Position = UDim2.new(0, 95, .5, -225)
Main.BackgroundColor3 = DARKER
Main.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 18)
MainCorner.Parent = Main

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = WHITE
MainStroke.Transparency = .75
MainStroke.Parent = Main

--========================================================--
-- HEADER
--========================================================--

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 65)
Header.BackgroundColor3 = DARK
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
Title.Parent = Header

local Subtitle = Instance.new("TextLabel")
Subtitle.BackgroundTransparency = 1
Subtitle.Position = UDim2.fromOffset(19, 33)
Subtitle.Size = UDim2.new(1, -70, 0, 18)
Subtitle.Text = "DEVELOPER CONTROL PANEL"
Subtitle.TextColor3 = MUTED
Subtitle.TextSize = 9
Subtitle.Font = Enum.Font.GothamMedium
Subtitle.TextXAlignment = Enum.TextXAlignment.Left
Subtitle.Parent = Header

local Close = Instance.new("TextButton")
Close.Size = UDim2.fromOffset(40, 40)
Close.Position = UDim2.new(1, -50, 0, 12)
Close.BackgroundColor3 = LIGHT
Close.Text = "×"
Close.TextColor3 = WHITE
Close.TextSize = 24
Close.Font = Enum.Font.GothamMedium
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
Content.Parent = Main

--========================================================--
-- SIDEBAR BUTTON
--========================================================--

local function SectionButton(text, index)
	local button = Instance.new("TextButton")
	button.Size = UDim2.new(1, -12, 0, 44)
	button.Position = UDim2.fromOffset(6, 8 + (index - 1) * 50)
	button.BackgroundColor3 = index == 1 and LIGHT or DARK
	button.Text = text
	button.TextColor3 = WHITE
	button.TextSize = 10
	button.Font = Enum.Font.GothamBold
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
	label.Parent = Content

	return label
end

local function Toggle(text, value, y, callback)
	local button = Instance.new("TextButton")
	button.Size = UDim2.new(1, -10, 0, 42)
	button.Position = UDim2.fromOffset(5, y)
	button.BackgroundColor3 = DARK
	button.Text = ""
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
	name.Parent = button

	local pill = Instance.new("Frame")
	pill.Size = UDim2.fromOffset(38, 20)
	pill.Position = UDim2.new(1, -50, .5, -10)
	pill.BackgroundColor3 = value and WHITE or LIGHT
	pill.Parent = button

	local pillCorner = Instance.new("UICorner")
	pillCorner.CornerRadius = UDim.new(1, 0)
	pillCorner.Parent = pill

	local dot = Instance.new("Frame")
	dot.Size = UDim2.fromOffset(14, 14)
	dot.Position = value
		and UDim2.new(1, -17, .5, -7)
		or UDim2.fromOffset(3, 3)
	dot.BackgroundColor3 = value and BLACK or MUTED
	dot.Parent = pill

	local dotCorner = Instance.new("UICorner")
	dotCorner.CornerRadius = UDim.new(1, 0)
	dotCorner.Parent = dot

	button.Activated:Connect(function()
		value = not value

		pill.BackgroundColor3 = value and WHITE or LIGHT
		dot.BackgroundColor3 = value and BLACK or MUTED

		dot:TweenPosition(
			value
				and UDim2.new(1, -17, .5, -7)
				or UDim2.fromOffset(3, 3),
			Enum.EasingDirection.Out,
			Enum.EasingStyle.Quad,
			.15,
			true
		)

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

	Toggle("Aim Assist", Config.AimEnabled, 35, function(v)
		Config.AimEnabled = v
	end)

	Toggle("Team Check", Config.TeamCheck, 85, function(v)
		Config.TeamCheck = v
	end)

	Toggle("Wall Check", Config.WallCheck, 135, function(v)
		Config.WallCheck = v
	end)

	Label("AIM SETTINGS", 195)

	local info = Instance.new("TextLabel")
	info.Size = UDim2.new(1, -10, 0, 90)
	info.Position = UDim2.fromOffset(5, 225)
	info.BackgroundColor3 = DARK
	info.Text = "HEAD LOCK\n\n"
		.. "FOV: " .. Config.FOV .. "\n"
		.. "STRENGTH: " .. Config.AimStrength .. "\n"
		.. "BREAK ANGLE: " .. Config.LockBreakAngle .. "°"
	info.TextColor3 = WHITE
	info.TextSize = 11
	info.Font = Enum.Font.GothamMedium
	info.TextXAlignment = Enum.TextXAlignment.Left
	info.Parent = Content

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = info
end

--========================================================--
-- VISUAL PAGE
--========================================================--

local function ShowVisuals()
	ClearContent()

	Label("ESP", 5)

	Toggle("ESP Enabled", Config.ESPEnabled, 35, function(v)
		Config.ESPEnabled = v
	end)

	Toggle("Player Boxes", Config.Boxes, 85, function(v)
		Config.Boxes = v
	end)

	Toggle("Health Bars", Config.HealthBars, 135, function(v)
		Config.HealthBars = v
	end)

	Toggle("Names", Config.Names, 185, function(v)
		Config.Names = v
	end)

	Toggle("Distance", Config.Distances, 235, function(v)
		Config.Distances = v
	end)

	Toggle("Head Markers", Config.HeadMarkers, 285, function(v)
		Config.HeadMarkers = v
	end)

	Toggle("Tracers", Config.Tracers, 335, function(v)
		Config.Tracers = v
	end)
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
	info.Text = "ACTIVE CROSSHAIR\n\n"
		.. "Size: 7\n"
		.. "Gap: 5\n"
		.. "Thickness: 2\n\n"
		.. "Center dot enabled"
	info.TextColor3 = WHITE
	info.TextSize = 11
	info.Font = Enum.Font.GothamMedium
	info.TextXAlignment = Enum.TextXAlignment.Left
	info.Parent = Content

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = info
end

--========================================================--
-- SETTINGS PAGE
--========================================================--

local function ShowSettings()
	ClearContent()

	Label("SYSTEM", 5)

	local info = Instance.new("TextLabel")
	info.Size = UDim2.new(========================1, -10, 0, 125)
	info.Position = UDim2.fromOffset(5, 35)
	info.BackgroundColor3 = DARK
	info.Text = "DEVELOPER MODE\n\n"
		.. "User ID: " .. LocalPlayer.UserId .. "\n\n"
		.. "Executor: DELTA\n"
		.. "Mobile Interface: ACTIVE\n"
		.. "Target Part: " .. Config.TargetPart
	info.TextColor3 = WHITE
	info.TextSize = 11
	info.Font = Enum.Font.GothamMedium
	info.TextXAlignment = Enum.TextXAlignment.Left
	info.Parent = Content

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = info
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
	Config.MenuOpen = false
end))

Script.Track(OpenButton.Activated:Connect(function()
	Main.Visible = not Main.Visible
	Config.MenuOpen = Main.Visible
end))

--========================================================--
-- DRAGGING (Touch + Mouse)
--================================--

local dragging = false
local dragStart
local startPosition

Script.Track(Header.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch
		or input.UserInputType == Enum.UserInputType.MouseButton1
	then
		dragging = true
		dragStart = input.Position
		startPosition = Main.Position

		Script.Track(input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end))
	end
end))

Script.Track(UserInputService.InputChanged:Connect(function(input)
	if dragging
		and (input.UserInputType == Enum.UserInputType.Touch
			or input.UserInputType == Enum.UserInputType.MouseMovement)
	then
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

		if not humanoid or not head then
			continue
		end

		local enabled = Config.ESPEnabled and IsEnemy(player)

		-- Billboard visible if any of its sub-components are on
		local billboardOn = enabled
			and (Config.Names or Config.HealthBars or Config.Distances)

		data.Billboard.Enabled = billboardOn
		data.HeadMarker.Enabled = enabled and Config.HeadMarkers
		data.Box.Visible = enabled and Config.Boxes

		data.Billboard.Adornee = head
		data.HeadMarker.Adornee = head
		data.Box.Adornee = character

		-- Health
		local healthPercent = math.clamp(
			humanoid.Health / math.max(humanoid.MaxHealth, 1),
			0,
			1
		)

		data.HealthFill.Size = UDim2.new(healthPercent, 0, 1, 0)

		if healthPercent > .5 then
			data.HealthFill.BackgroundColor3 = GREEN
		elseif healthPercent > .25 then
			data.HealthFill.BackgroundColor3 = Color3.fromRGB(255, 210, 70)
		else
			data.HealthFill.BackgroundColor3 = RED
		end

		-- Info text
		local distance = (Camera.CFrame.Position - head.Position).Magnitude

		local hpText = math.floor(humanoid.Health)
			.. " / "
			.. math.floor(humanoid.MaxHealth)
			.. " HP"

		local distanceText = math.floor(distance) .. " studs"

		data.Info.Text = hpText .. "  •  " .. distanceText

		data.Name.Visible = Config.Names
		data.Info.Visible = Config.HealthBars or Config.Distances
		data.HealthFill.Parent.Visible = Config.HealthBars

		-- Tracer
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
				data.Tracer.Rotation = math.deg(
					math.atan2(delta.Y, delta.X)
				)
				data.Tracer.BackgroundColor3 = (player == CurrentTarget) and WHITE or MUTED
			else
				data.Tracer.Visible = false
			end
		else
			data.Tracer.Visible = false
		end

		-- Locked target highlight
		if player == CurrentTarget then
			data.CardStroke.Color = WHITE
			data.CardStroke.Transparency = .1
			data.Marker.BackgroundColor3 = WHITE
		else
			data.CardStroke.Color = WHITE
			data.CardStroke.Transparency = .65
			data.Marker.BackgroundColor3 = RED
		end
	end
end

--========================================================--
-- MAIN LOOP
--========================================================--

Script.Track(RunService.RenderStepped:Connect(function()
	Camera = workspace.CurrentCamera
	if not Camera then
		return
	end

	-- Target lock validation
	if CurrentTarget then
		if not CurrentTarget.Character
			or not IsAlive(CurrentTarget.Character)
			or not IsEnemy(CurrentTarget)
		then
			CurrentTarget = nil
		else
			local angle = GetAngle(CurrentTarget)
			if angle > Config.LockBreakAngle then
				CurrentTarget = nil
			end
		end
	end

	-- Acquire new target
	if not CurrentTarget then
		CurrentTarget = GetTarget()
	end

	-- Aim
	if Config.AimEnabled and CurrentTarget then
		AimAt(CurrentTarget)
	end

	-- Status display
	if CurrentTarget and CurrentTarget.Character then
		local humanoid = CurrentTarget.Character:FindFirstChildOfClass("Humanoid")

		if humanoid then
			StatusText.Text = "●  "
				.. CurrentTarget.DisplayName
				.. "   "
				.. math.floor(humanoid.Health)
				.. " HP"
			StatusText.TextColor3 = GREEN
		end
	else
		StatusText.Text = "NO TARGET"
		StatusText.TextColor3 = MUTED
	end

	UpdateESP()
end))

--========================================================--
-- LOADED NOTIFICATION
--========================================================--

pcall(function()
	if setclipboard then
		-- no-op; placeholder for potential future features
	end
end)

print("[DSTv2] Developer Shooting Toolkit loaded (Delta Executor edition).")
