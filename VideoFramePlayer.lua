local screenGui = Instance.new("ScreenGui")
screenGui.Name = "VideoFramePlayerGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = game:GetService("CoreGui")

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 500, 0, 400)
MainFrame.Position = UDim2.new(0.5, -250, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = screenGui

local UICorner_Main = Instance.new("UICorner")
UICorner_Main.CornerRadius = UDim.new(0, 12)
UICorner_Main.Parent = MainFrame

local UIStroke_Main = Instance.new("UIStroke")
UIStroke_Main.Thickness = 2
UIStroke_Main.Parent = MainFrame
local RunService = game:GetService("RunService")
RunService.RenderStepped:Connect(function()
	local hue = (tick() % 10) / 10
	UIStroke_Main.Color = Color3.fromHSV(hue, 1, 1)
end)

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "TitleLabel"
TitleLabel.Size = UDim2.new(1, 0, 0, 30)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "🎥 VideoFramePlayer"
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 24
TitleLabel.TextColor3 = Color3.new(1, 1, 1)
TitleLabel.Parent = MainFrame

local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -35, 0, 5)
CloseButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseButton.Text = "✖"
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextSize = 18
CloseButton.TextColor3 = Color3.new(1, 1, 1)
CloseButton.Parent = MainFrame
local CloseUICorner = Instance.new("UICorner")
CloseUICorner.CornerRadius = UDim.new(1, 0)
CloseUICorner.Parent = CloseButton
CloseButton.MouseButton1Click:Connect(function()
	screenGui:Destroy()
end)

local ControlPanel = Instance.new("Frame")
ControlPanel.Name = "ControlPanel"
ControlPanel.Size = UDim2.new(1, 0, 0, 70)
ControlPanel.Position = UDim2.new(0, 0, 0, 35)
ControlPanel.BackgroundTransparency = 1
ControlPanel.Parent = MainFrame

local VideoIDTextBox = Instance.new("TextBox")
VideoIDTextBox.Name = "VideoIDTextBox"
VideoIDTextBox.Size = UDim2.new(0, 300, 0, 30)
VideoIDTextBox.Position = UDim2.new(0, 10, 0, 10)
VideoIDTextBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
VideoIDTextBox.TextColor3 = Color3.new(1, 1, 1)
VideoIDTextBox.Text = ""
VideoIDTextBox.PlaceholderText = "Paste Video ID here"
VideoIDTextBox.ClearTextOnFocus = false
VideoIDTextBox.Font = Enum.Font.Gotham
VideoIDTextBox.TextSize = 18
VideoIDTextBox.Parent = ControlPanel
local TextBoxStroke = Instance.new("UIStroke")
TextBoxStroke.Thickness = 1
TextBoxStroke.Color = Color3.new(1, 1, 1)
TextBoxStroke.Parent = VideoIDTextBox

local EnterButton = Instance.new("TextButton")
EnterButton.Name = "EnterButton"
EnterButton.Size = UDim2.new(0, 80, 0, 30)
EnterButton.Position = UDim2.new(0, 320, 0, 10)
EnterButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
EnterButton.Text = "Enter 📥"
EnterButton.Font = Enum.Font.GothamBold
EnterButton.TextSize = 18
EnterButton.TextColor3 = Color3.new(1, 1, 1)
EnterButton.Parent = ControlPanel
local EnterUICorner = Instance.new("UICorner")
EnterUICorner.CornerRadius = UDim.new(0, 8)
EnterUICorner.Parent = EnterButton

local DropdownToggle = Instance.new("TextButton")
DropdownToggle.Name = "DropdownToggle"
DropdownToggle.Size = UDim2.new(0, 80, 0, 30)
DropdownToggle.Position = UDim2.new(0, 410, 0, 45)
DropdownToggle.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
DropdownToggle.Text = "Select 📋"
DropdownToggle.Font = Enum.Font.GothamBold
DropdownToggle.TextSize = 18
DropdownToggle.TextColor3 = Color3.new(1, 1, 1)
DropdownToggle.Parent = MainFrame
DropdownToggle.ZIndex = 12

local DropdownFrame = Instance.new("Frame")
DropdownFrame.Name = "DropdownFrame"
DropdownFrame.Size = UDim2.new(0, 80, 0, 120)
DropdownFrame.Position = UDim2.new(0, 410, 0, 75)
DropdownFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
DropdownFrame.BorderSizePixel = 0
DropdownFrame.Visible = false
DropdownFrame.Parent = MainFrame
DropdownFrame.ZIndex = 11

local DropdownUICorner = Instance.new("UICorner")
DropdownUICorner.CornerRadius = UDim.new(0, 8)
DropdownUICorner.Parent = DropdownFrame

local DropdownScroll = Instance.new("ScrollingFrame")
DropdownScroll.Name = "DropdownScroll"
DropdownScroll.Size = UDim2.new(1, 0, 1, 0)
DropdownScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
DropdownScroll.BackgroundTransparency = 1
DropdownScroll.ScrollBarThickness = 4
DropdownScroll.Parent = DropdownFrame
DropdownScroll.ZIndex = 11

local DropdownList = Instance.new("UIListLayout")
DropdownList.SortOrder = Enum.SortOrder.LayoutOrder
DropdownList.Parent = DropdownScroll
DropdownList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	DropdownScroll.CanvasSize = UDim2.new(0, 0, 0, DropdownList.AbsoluteContentSize.Y)
end)

local videoList = {
	{ id = "5670799859", name = "LittleDrive" },
	{ id = "5608359401", name = "WeaponSafety" },
	{ id = "5608321996", name = "BloxyCola" },
	{ id = "5608327482", name = "Eat!" },
	{ id = "5608304953", name = "PizzaAd" },
	{ id = "5608368298", name = "FightLoop" },
	{ id = "5608297917", name = "GuestStare" },
	{ id = "5608370112", name = "SwordSlashes" },
	{ id = "5608360493", name = "RedVSBlue" }
}

for i, video in ipairs(videoList) do
	local vidButton = Instance.new("TextButton")
	vidButton.Name = "VidButton_" .. i
	vidButton.Size = UDim2.new(1, 0, 0, 20)
	vidButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	vidButton.Text = video.name
	vidButton.Font = Enum.Font.Gotham
	vidButton.TextSize = 14
	vidButton.TextColor3 = Color3.new(1, 1, 1)
	vidButton.Parent = DropdownScroll
	vidButton.ZIndex = 11
	local vidButtonUICorner = Instance.new("UICorner")
	vidButtonUICorner.CornerRadius = UDim.new(0, 4)
	vidButtonUICorner.Parent = vidButton

	vidButton.MouseButton1Click:Connect(function()
		VideoIDTextBox.Text = ""
		VideoIDTextBox.Text = video.id
		DropdownFrame.Visible = false
	end)
end

local VideoFrame = Instance.new("VideoFrame")
VideoFrame.Name = "VideoFrame"
VideoFrame.Size = UDim2.new(0, 480, 0, 270)
VideoFrame.Position = UDim2.new(0, 10, 0, 120)
VideoFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
VideoFrame.Parent = MainFrame
VideoFrame.Video = "rbxassetid://0"
VideoFrame.Looped = false
VideoFrame.Volume = 0.5
VideoFrame.ZIndex = 1
local VideoStroke = Instance.new("UIStroke")
VideoStroke.Thickness = 2
VideoStroke.Color = Color3.new(1, 1, 1)
VideoStroke.Parent = VideoFrame

local function updateVideoFromTextBox()
	local vid = VideoIDTextBox.Text
	if vid and vid ~= "" then
		VideoFrame.Video = string.format("rbxassetid://%s", vid)
		VideoFrame:Play()
	end
end

EnterButton.MouseButton1Click:Connect(function()
	updateVideoFromTextBox()
end)

local PlayButton = Instance.new("TextButton")
PlayButton.Name = "PlayButton"
PlayButton.Size = UDim2.new(0, 80, 0, 20)
PlayButton.Position = UDim2.new(0, 10, 0, 45)
PlayButton.BackgroundColor3 = Color3.fromRGB(70, 130, 70)
PlayButton.Text = "Play ▶️"
PlayButton.Font = Enum.Font.GothamBold
PlayButton.TextSize = 16
PlayButton.TextColor3 = Color3.new(1, 1, 1)
PlayButton.Parent = ControlPanel
local PlayUICorner = Instance.new("UICorner")
PlayUICorner.CornerRadius = UDim.new(0, 6)
PlayUICorner.Parent = PlayButton

local PauseButton = Instance.new("TextButton")
PauseButton.Name = "PauseButton"
PauseButton.Size = UDim2.new(0, 80, 0, 20)
PauseButton.Position = UDim2.new(0, 100, 0, 45)
PauseButton.BackgroundColor3 = Color3.fromRGB(218, 165, 32)
PauseButton.Text = "Pause ⏸️"
PauseButton.Font = Enum.Font.GothamBold
PauseButton.TextSize = 16
PauseButton.TextColor3 = Color3.new(1, 1, 1)
PauseButton.Parent = ControlPanel
local PauseUICorner = Instance.new("UICorner")
PauseUICorner.CornerRadius = UDim.new(0, 6)
PauseUICorner.Parent = PauseButton

local StopButton = Instance.new("TextButton")
StopButton.Name = "StopButton"
StopButton.Size = UDim2.new(0, 80, 0, 20)
StopButton.Position = UDim2.new(0, 190, 0, 45)
StopButton.BackgroundColor3 = Color3.fromRGB(178, 34, 34)
StopButton.Text = "Stop ⏹️"
StopButton.Font = Enum.Font.GothamBold
StopButton.TextSize = 16
StopButton.TextColor3 = Color3.new(1, 1, 1)
StopButton.Parent = ControlPanel
local StopUICorner = Instance.new("UICorner")
StopUICorner.CornerRadius = UDim.new(0, 6)
StopUICorner.Parent = StopButton

local LoopButton = Instance.new("TextButton")
LoopButton.Name = "LoopButton"
LoopButton.Size = UDim2.new(0, 80, 0, 20)
LoopButton.Position = UDim2.new(0, 280, 0, 45)
LoopButton.BackgroundColor3 = Color3.fromRGB(70, 130, 180)
LoopButton.Text = "Loop: OFF 🔁"
LoopButton.Font = Enum.Font.GothamBold
LoopButton.TextSize = 16
LoopButton.TextColor3 = Color3.new(1, 1, 1)
LoopButton.Parent = ControlPanel
local LoopUICorner = Instance.new("UICorner")
LoopUICorner.CornerRadius = UDim.new(0, 6)
LoopUICorner.Parent = LoopButton

PlayButton.MouseButton1Click:Connect(function()
	VideoFrame:Play()
end)

PauseButton.MouseButton1Click:Connect(function()
	VideoFrame:Pause()
end)

StopButton.MouseButton1Click:Connect(function()
	VideoFrame:Pause()
	VideoFrame.TimePosition = 0
end)

local loopState = false
LoopButton.MouseButton1Click:Connect(function()
	loopState = not loopState
	VideoFrame.Looped = loopState
	if loopState then
		LoopButton.Text = "Loop: ON 🔁"
	else
		LoopButton.Text = "Loop: OFF 🔁"
	end
end)

DropdownToggle.MouseButton1Click:Connect(function()
	DropdownFrame.Visible = not DropdownFrame.Visible
end)

local UserInputService = game:GetService("UserInputService")
local Dragging, DragInput, DragStart, StartPos
local function Update(input)
	local delta = input.Position - DragStart
	MainFrame.Position = UDim2.new(
		StartPos.X.Scale, 
		StartPos.X.Offset + delta.X,
		StartPos.Y.Scale, 
		StartPos.Y.Offset + delta.Y
	)
end
MainFrame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		Dragging = true
		DragStart = input.Position
		StartPos = MainFrame.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				Dragging = false
			end
		end)
	end
end)
MainFrame.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement then
		DragInput = input
	end
end)
UserInputService.InputChanged:Connect(function(input)
	if input == DragInput and Dragging then
		Update(input)
	end
end)
