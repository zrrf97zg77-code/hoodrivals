--========================================================--
--        DEVELOPER SHOOTING TOOLKIT
--        ROBLOX STUDIO / OWN-GAME EDITION
--========================================================--

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local Camera = workspace.CurrentCamera

--========================================================--
-- CONFIG
--========================================================--

local Config = {
	-- AIM
	AimEnabled = true,
	FOV = 180,
	AimStrength = 0.35,
	LockBreakAngle = 30,
	TargetPart = "Head",

	-- ESP
	ESPEnabled = true,
	Boxes = true,
	HealthBars = true,
	Names = true,
	Distances = true,
	HeadMarkers = true,
	Tracers = true,

	-- FILTERS
	TeamCheck = true,
	WallCheck = false,
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
local YELLOW = Color3.fromRGB(255, 210, 70)

--========================================================--
-- GUI
--========================================================--

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DeveloperShootingToolkit"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.DisplayOrder = 100
ScreenGui.Parent = PlayerGui

--========================================================--
-- FOV CIRCLE
--========================================================--

local FOVCircle = Instance.new("Frame")
FOVCircle.Name = "AimFOV"
FOVCircle.AnchorPoint = Vector2.new(0.5, 0.5)
FOVCircle.BackgroundTransparency = 1
FOVCircle.BorderSizePixel = 0
FOVCircle.ZIndex = 40
FOVCircle.Parent = ScreenGui

local FOVCorner = Instance.new("UICorner")
FOVCorner.CornerRadius = UDim.new(1, 0)
FOVCorner.Parent = FOVCircle

local FOVStroke = Instance.new("UIStroke")
FOVStroke.Color = WHITE
FOVStroke.Thickness = 1
FOVStroke.Transparency = 0.25
FOVStroke.Parent = FOVCircle

local function UpdateFOVCircle()
	Camera = workspace.CurrentCamera

	if not Camera then
		return
	end

	local viewport = Camera.ViewportSize

	FOVCircle.Position = UDim2.fromOffset(
		viewport.X / 2,
		viewport.Y / 2
	)

	FOVCircle.Size = UDim2.fromOffset(
		Config.FOV * 2,
		Config.FOV * 2
	)

	FOVCircle.Visible = Config.AimEnabled
end

--========================================================--
-- OPEN BUTTON
--========================================================--

local OpenButton = Instance.new("TextButton")
OpenButton.Name = "OpenButton"
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
Main.Name = "Main"
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
Subtitle.Text = "STUDIO EDITION"
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
Content.CanvasSize = UDim2.fromOffset(0, 600)
Content.ZIndex = 91
Content.Parent = Main

--========================================================--
-- SIDEBAR BUTTON
--========================================================--

local function SectionButton(text, index)

	local button = Instance.new("TextButton")

	button.Size = UDim2.new(1, -12, 0, 44)
	button.Position = UDim2.fromOffset(
		6,
		8 + (index - 1) * 50
	)

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

	dot.Position =
		value
		and UDim2.new(1, -17, 0.5, -7)
		or UDim2.fromOffset(3, 3)

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

		dot.Position =
			value
			and UDim2.new(1, -17, 0.5, -7)
			or UDim2.fromOffset(3, 3)

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

	Toggle(
		"Aim Assist",
		Config.AimEnabled,
		35,
		function(value)
			Config.AimEnabled = value
			UpdateFOVCircle()
		end
	)

	Toggle(
		"Team Check",
		Config.TeamCheck,
		85,
		function(value)
			Config.TeamCheck = value
		end
	)

	Toggle(
		"Wall Check",
		Config.WallCheck,
		135,
		function(value)
			Config.WallCheck = value
		end
	)

	Label("AIM SETTINGS", 195)

	local info = Instance.new("TextLabel")

	info.Size = UDim2.new(1, -10, 0, 120)
	info.Position = UDim2.fromOffset(5, 225)

	info.BackgroundColor3 = DARK

	info.Text =
		"HEAD LOCK\n\n"
		.. "FOV: " .. Config.FOV .. "\n"
		.. "STRENGTH: " .. Config.AimStrength .. "\n"
		.. "BREAK ANGLE: " .. Config.LockBreakAngle .. "°"

	info.TextColor3 = WHITE
	info.TextSize = 11
	info.Font = Enum.Font.GothamMedium

	info.TextXAlignment = Enum.TextXAlignment.Left
	info.TextYAlignment = Enum.TextYAlignment.Top

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

	Toggle(
		"ESP Enabled",
		Config.ESPEnabled,
		35,
		function(value)
			Config.ESPEnabled = value
		end
	)

	Toggle(
		"Player Boxes",
		Config.Boxes,
		85,
		function(value)
			Config.Boxes = value
		end
	)

	Toggle(
		"Health Bars",
		Config.HealthBars,
		135,
		function(value)
			Config.HealthBars = value
		end
	)

	Toggle(
		"Names",
		Config.Names,
		185,
		function(value)
			Config.Names = value
		end
	)

	Toggle(
		"Distance",
		Config.Distances,
		235,
		function(value)
			Config.Distances = value
		end
	)

	Toggle(
		"Head Markers",
		Config.HeadMarkers,
		285,
		function(value)
			Config.HeadMarkers = value
		end
	)

	Toggle(
		"Tracers",
		Config.Tracers,
		335,
		function(value)
			Config.Tracers = value
		end
	)
end

--========================================================--
-- CROSSHAIR PAGE
--========================================================--

local function ShowCross
