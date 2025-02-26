local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "HealthSliderGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = CoreGui

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 300, 0, 200)
mainFrame.Position = UDim2.new(0.5, -150, 0.5, -100)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 12)
mainCorner.Parent = mainFrame

local mainStroke = Instance.new("UIStroke")
mainStroke.Parent = mainFrame
mainStroke.Thickness = 2
mainStroke.Color = Color3.new(1, 0, 0)
mainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

local titleBar = Instance.new("Frame")
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, 30)
titleBar.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "TitleLabel"
titleLabel.Size = UDim2.new(1, -60, 1, 0)
titleLabel.Position = UDim2.new(0, 10, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "Health Slider 💖"
titleLabel.TextColor3 = Color3.new(1, 1, 1)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 18
titleLabel.Parent = titleBar

local closeButton = Instance.new("TextButton")
closeButton.Name = "CloseButton"
closeButton.Size = UDim2.new(0, 25, 0, 25)
closeButton.Position = UDim2.new(1, -35, 0, 3)
closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeButton.Text = "X"
closeButton.TextColor3 = Color3.new(1, 1, 1)
closeButton.Font = Enum.Font.GothamBold
closeButton.TextSize = 16
closeButton.BorderSizePixel = 0
closeButton.Parent = titleBar

local minimizeButton = Instance.new("TextButton")
minimizeButton.Name = "MinimizeButton"
minimizeButton.Size = UDim2.new(0, 25, 0, 25)
minimizeButton.Position = UDim2.new(1, -70, 0, 3)
minimizeButton.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
minimizeButton.Text = "—"
minimizeButton.TextColor3 = Color3.new(1, 1, 1)
minimizeButton.Font = Enum.Font.GothamBold
minimizeButton.TextSize = 16
minimizeButton.BorderSizePixel = 0
minimizeButton.Parent = titleBar

local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Name = "ScrollFrame"
scrollFrame.Size = UDim2.new(1, 0, 1, -30)
scrollFrame.Position = UDim2.new(0, 0, 0, 30)
scrollFrame.BackgroundTransparency = 1
scrollFrame.ScrollBarThickness = 6
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 100)
scrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
scrollFrame.Parent = mainFrame

local sliderBg = Instance.new("Frame")
sliderBg.Name = "SliderBackground"
sliderBg.Size = UDim2.new(0.9, 0, 0, 40)
sliderBg.Position = UDim2.new(0.05, 0, 0.1, 0)
sliderBg.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
sliderBg.BorderSizePixel = 0
sliderBg.Parent = scrollFrame

local sliderCorner = Instance.new("UICorner")
sliderCorner.CornerRadius = UDim.new(0, 8)
sliderCorner.Parent = sliderBg

local sliderFill = Instance.new("Frame")
sliderFill.Name = "SliderFill"
sliderFill.Size = UDim2.new(0, 0, 1, 0)
sliderFill.BackgroundColor3 = Color3.fromRGB(80, 170, 80)
sliderFill.BorderSizePixel = 0
sliderFill.Parent = sliderBg

local fillCorner = Instance.new("UICorner")
fillCorner.CornerRadius = UDim.new(0, 8)
fillCorner.Parent = sliderFill

local sliderThumb = Instance.new("Frame")
sliderThumb.Name = "SliderThumb"
sliderThumb.Size = UDim2.new(0, 20, 1, 0)
sliderThumb.Position = UDim2.new(0, -10, 0, 0)
sliderThumb.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
sliderThumb.BorderSizePixel = 0
sliderThumb.Parent = sliderBg

local thumbCorner = Instance.new("UICorner")
thumbCorner.CornerRadius = UDim.new(0, 10)
thumbCorner.Parent = sliderThumb

local healthLabel = Instance.new("TextLabel")
healthLabel.Name = "HealthLabel"
healthLabel.Size = UDim2.new(1, 0, 0, 20)
healthLabel.Position = UDim2.new(0, 0, 1, 5)
healthLabel.BackgroundTransparency = 1
healthLabel.Text = "Health: 100%"
healthLabel.TextColor3 = Color3.new(1, 1, 1)
healthLabel.Font = Enum.Font.Gotham
healthLabel.TextSize = 16
healthLabel.Parent = sliderBg

local dragging, dragStart, startPos
titleBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = mainFrame.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)
titleBar.InputChanged:Connect(function(input)
	if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		local delta = input.Position - dragStart
		mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)

local maxHealth = 100
local function updateHealthBySlider(percent)
	local health = math.clamp(percent * maxHealth, 0, maxHealth)
	if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
		LocalPlayer.Character.Humanoid.Health = health
	end
	sliderFill.Size = UDim2.new(percent, 0, 1, 0)
	sliderThumb.Position = UDim2.new(percent, -10, 0, 0)
	healthLabel.Text = string.format("Health: %d%%", math.floor((health / maxHealth) * 100))
end

sliderBg.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		local relX = input.Position.X - sliderBg.AbsolutePosition.X
		local newPercent = math.clamp(relX / sliderBg.AbsoluteSize.X, 0, 1)
		updateHealthBySlider(newPercent)
	end
end)
sliderBg.InputChanged:Connect(function(input)
	if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
		local relX = input.Position.X - sliderBg.AbsolutePosition.X
		local newPercent = math.clamp(relX / sliderBg.AbsoluteSize.X, 0, 1)
		updateHealthBySlider(newPercent)
	end
end)

closeButton.MouseButton1Click:Connect(function()
	local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local tween = TweenService:Create(mainFrame, tweenInfo, {BackgroundTransparency = 1, Size = UDim2.new(0,0,0,0)})
	tween:Play()
	tween.Completed:Connect(function()
		screenGui:Destroy()
	end)
end)

local minimized = false
minimizeButton.MouseButton1Click:Connect(function()
	if not minimized then
		local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		local tween = TweenService:Create(mainFrame, tweenInfo, {Size = UDim2.new(0, 300, 0, 30)})
		tween:Play()
		minimized = true
	else
		local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		local tween = TweenService:Create(mainFrame, tweenInfo, {Size = UDim2.new(0, 300, 0, 200)})
		tween:Play()
		minimized = false
	end
end)

local hue = 0
RunService.RenderStepped:Connect(function(delta)
	hue = (hue + delta * 0.2) % 1
	mainStroke.Color = Color3.fromHSV(hue, 1, 1)
end)

local function adjustGui()
	local viewportSize = workspace.CurrentCamera.ViewportSize
	local scaleFactor = math.min(viewportSize.X / 1920, viewportSize.Y / 1080)
	mainFrame.Size = UDim2.new(0, 300 * scaleFactor, 0, (minimized and 30 or 200) * scaleFactor)
	mainFrame.Position = UDim2.new(0.5, -mainFrame.Size.X.Offset / 2, 0.5, -mainFrame.Size.Y.Offset / 2)
end
workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(adjustGui)
adjustGui()
