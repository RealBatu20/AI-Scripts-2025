--!strict

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local existingGui = playerGui:FindFirstChild("4NTEP_CRIMINAL")
if existingGui then
	existingGui:Destroy()
end

local CONFIG = {
	Theme = {
		Background = Color3.fromRGB(20, 20, 28),
		Surface = Color3.fromRGB(30, 30, 40),
		Accent = Color3.fromRGB(88, 101, 242),
		Text = Color3.fromRGB(255, 255, 255),
		TextMuted = Color3.fromRGB(180, 180, 190),
		Close = Color3.fromRGB(237, 66, 69),
		Minimize = Color3.fromRGB(88, 101, 242),
		Shadow = Color3.fromRGB(0, 0, 0)
	},
	Animation = {
		Speed = 0.35,
		Easing = Enum.EasingStyle.Quart,
		Direction = Enum.EasingDirection.Out
	},
	Size = {
		Main = Vector2.new(260, 340),
		HeaderOnly = 45
	},
	Drag = {
		ClickThreshold = 5,
		MaxClickTime = 0.3
	}
}

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "4NTEP_CRIMINAL"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = playerGui

local Shadow = Instance.new("ImageLabel")
Shadow.Name = "Shadow"
Shadow.Parent = ScreenGui
Shadow.AnchorPoint = Vector2.new(0.5, 0.5)
Shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
Shadow.Size = UDim2.new(0, CONFIG.Size.Main.X + 20, 0, CONFIG.Size.Main.Y + 20)
Shadow.BackgroundTransparency = 1
Shadow.Image = "rbxassetid://1316045217"
Shadow.ImageColor3 = CONFIG.Theme.Shadow
Shadow.ImageTransparency = 0.6
Shadow.ScaleType = Enum.ScaleType.Slice
Shadow.SliceCenter = Rect.new(10, 10, 118, 118)
Shadow.ZIndex = 0

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.Size = UDim2.new(0, CONFIG.Size.Main.X, 0, CONFIG.Size.Main.Y)
MainFrame.BackgroundColor3 = CONFIG.Theme.Background
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.ZIndex = 1

local MainCorner = Instance.new("UICorner")
MainCorner.Parent = MainFrame
MainCorner.CornerRadius = UDim.new(0, 12)

local MainStroke = Instance.new("UIStroke")
MainStroke.Parent = MainFrame
MainStroke.Color = Color3.fromRGB(50, 50, 65)
MainStroke.Thickness = 1.5

local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Parent = MainFrame
Header.Size = UDim2.new(1, 0, 0, 45)
Header.BackgroundColor3 = CONFIG.Theme.Surface
Header.BorderSizePixel = 0
Header.ZIndex = 2

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.Parent = Header
HeaderCorner.CornerRadius = UDim.new(0, 12)

local HeaderFix = Instance.new("Frame")
HeaderFix.Parent = Header
HeaderFix.Size = UDim2.new(1, 0, 0.5, 0)
HeaderFix.Position = UDim2.new(0, 0, 0.5, 0)
HeaderFix.BackgroundColor3 = CONFIG.Theme.Surface
HeaderFix.BorderSizePixel = 0
HeaderFix.ZIndex = 2

local DragHandle = Instance.new("Frame")
DragHandle.Name = "DragHandle"
DragHandle.Parent = Header
DragHandle.Size = UDim2.new(1, -100, 1, 0)
DragHandle.BackgroundTransparency = 1
DragHandle.Active = true
DragHandle.ZIndex = 3

local TitleIcon = Instance.new("TextLabel")
TitleIcon.Name = "Icon"
TitleIcon.Parent = Header
TitleIcon.Size = UDim2.new(0, 30, 0, 30)
TitleIcon.Position = UDim2.new(0, 12, 0.5, 0)
TitleIcon.AnchorPoint = Vector2.new(0, 0.5)
TitleIcon.BackgroundTransparency = 1
TitleIcon.Text = "🎲"
TitleIcon.TextSize = 20
TitleIcon.Font = Enum.Font.GothamBold
TitleIcon.ZIndex = 3

local TitleText = Instance.new("TextLabel")
TitleText.Name = "Title"
TitleText.Parent = Header
TitleText.Size = UDim2.new(1, -120, 1, 0)
TitleText.Position = UDim2.new(0, 45, 0, 0)
TitleText.BackgroundTransparency = 1
TitleText.Text = "Lucky Block Giver"
TitleText.TextColor3 = CONFIG.Theme.Text
TitleText.Font = Enum.Font.GothamBold
TitleText.TextSize = 16
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.ZIndex = 3

local Controls = Instance.new("Frame")
Controls.Name = "Controls"
Controls.Parent = Header
Controls.Size = UDim2.new(0, 80, 0, 30)
Controls.Position = UDim2.new(1, -90, 0.5, 0)
Controls.AnchorPoint = Vector2.new(0, 0.5)
Controls.BackgroundTransparency = 1
Controls.ZIndex = 3

local ControlsLayout = Instance.new("UIListLayout")
ControlsLayout.Parent = Controls
ControlsLayout.FillDirection = Enum.FillDirection.Horizontal
ControlsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
ControlsLayout.SortOrder = Enum.SortOrder.LayoutOrder
ControlsLayout.Padding = UDim.new(0, 8)

local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Name = "Minimize"
MinimizeBtn.Parent = Controls
MinimizeBtn.Size = UDim2.new(0, 30, 0, 30)
MinimizeBtn.BackgroundColor3 = CONFIG.Theme.Minimize
MinimizeBtn.Text = "−"
MinimizeBtn.TextColor3 = CONFIG.Theme.Text
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.TextSize = 20
MinimizeBtn.AutoButtonColor = false
MinimizeBtn.LayoutOrder = 1
MinimizeBtn.ZIndex = 4

local MinimizeCorner = Instance.new("UICorner")
MinimizeCorner.Parent = MinimizeBtn
MinimizeCorner.CornerRadius = UDim.new(0, 8)

local CloseBtn = Instance.new("TextButton")
CloseBtn.Name = "Close"
CloseBtn.Parent = Controls
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.BackgroundColor3 = CONFIG.Theme.Close
CloseBtn.Text = "x"
CloseBtn.TextColor3 = CONFIG.Theme.Text
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 16
CloseBtn.AutoButtonColor = false
CloseBtn.LayoutOrder = 2
CloseBtn.ZIndex = 4

local CloseCorner = Instance.new("UICorner")
CloseCorner.Parent = CloseBtn
CloseCorner.CornerRadius = UDim.new(0, 8)

local Content = Instance.new("Frame")
Content.Name = "Content"
Content.Parent = MainFrame
Content.Size = UDim2.new(1, -20, 1, -65)
Content.Position = UDim2.new(0, 10, 0, 55)
Content.BackgroundTransparency = 1
Content.ZIndex = 1

local ContentLayout = Instance.new("UIListLayout")
ContentLayout.Parent = Content
ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
ContentLayout.Padding = UDim.new(0, 10)

local function createBlockButton(data: {string})
	local name, remoteName, color = data[1], data[2], data[3]
	
	local btn = Instance.new("TextButton")
	btn.Name = remoteName
	btn.Size = UDim2.new(1, 0, 0, 45)
	btn.BackgroundColor3 = color
	btn.Text = ""
	btn.AutoButtonColor = false
	btn.LayoutOrder = #Content:GetChildren()
	btn.ZIndex = 2
	
	local btnCorner = Instance.new("UICorner")
	btnCorner.Parent = btn
	btnCorner.CornerRadius = UDim.new(0, 10)
	
	local gradient = Instance.new("UIGradient")
	gradient.Parent = btn
	gradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
		ColorSequenceKeypoint.new(1, Color3.new(0.9, 0.9, 0.9))
	})
	gradient.Transparency = NumberSequence.new(0.1, 0.3)
	gradient.Rotation = 90
	
	local icon = Instance.new("TextLabel")
	icon.Parent = btn
	icon.Size = UDim2.new(0, 30, 0, 30)
	icon.Position = UDim2.new(0, 12, 0.5, 0)
	icon.AnchorPoint = Vector2.new(0, 0.5)
	icon.BackgroundTransparency = 1
	icon.Text = name:sub(1, 2)
	icon.TextSize = 20
	icon.ZIndex = 3
	
	local text = Instance.new("TextLabel")
	text.Parent = btn
	text.Size = UDim2.new(1, -50, 1, 0)
	text.Position = UDim2.new(0, 45, 0, 0)
	text.BackgroundTransparency = 1
	text.Text = name:sub(4) .. " Block"
	text.TextColor3 = CONFIG.Theme.Text
	text.Font = Enum.Font.GothamBold
	text.TextSize = 15
	text.TextXAlignment = Enum.TextXAlignment.Left
	text.ZIndex = 3
	
	local originalColor = color
	
	btn.MouseEnter:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.2), {
			BackgroundColor3 = originalColor:Lerp(Color3.new(1, 1, 1), 0.2)
		}):Play()
	end)
	
	btn.MouseLeave:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.2), {
			BackgroundColor3 = originalColor
		}):Play()
	end)
	
	btn.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			TweenService:Create(btn, TweenInfo.new(0.1), {
				Size = UDim2.new(0.95, 0, 0, 43),
				Position = UDim2.new(0.025, 0, 0, btn.Position.Y.Offset + 1)
			}):Play()
		end
	end)
	
	btn.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			TweenService:Create(btn, TweenInfo.new(0.1), {
				Size = UDim2.new(1, 0, 0, 45),
				Position = UDim2.new(0, 0, 0, btn.Position.Y.Offset - 1)
			}):Play()
		end
	end)
	
	btn.MouseButton1Click:Connect(function()
		local ReplicatedStorage = game:GetService("ReplicatedStorage")
		local remote = ReplicatedStorage:FindFirstChild(remoteName)
		if remote and remote:IsA("RemoteEvent") then
			remote:FireServer()
			
			local flash = Instance.new("Frame")
			flash.Parent = btn
			flash.Size = UDim2.new(1, 0, 1, 0)
			flash.BackgroundColor3 = Color3.new(1, 1, 1)
			flash.BackgroundTransparency = 0.5
			flash.BorderSizePixel = 0
			flash.ZIndex = 10
			
			local flashCorner = Instance.new("UICorner")
			flashCorner.Parent = flash
			flashCorner.CornerRadius = btnCorner.CornerRadius
			
			TweenService:Create(flash, TweenInfo.new(0.3), {
				BackgroundTransparency = 1
			}):Play()
			
			game:GetService("Debris"):AddItem(flash, 0.3)
		end
	end)
	
	return btn
end

local blocks = {
	{"💛 Lucky", "SpawnLuckyBlock", Color3.fromRGB(255, 193, 7)},
	{"💙 Super", "SpawnSuperBlock", Color3.fromRGB(33, 150, 243)},
	{"💎 Diamond", "SpawnDiamondBlock", Color3.fromRGB(0, 188, 212)},
	{"🌈 Rainbow", "SpawnRainbowBlock", Color3.fromRGB(233, 30, 99)},
	{"🌌 Galaxy", "SpawnGalaxyBlock", Color3.fromRGB(156, 39, 176)}
}

for _, blockData in ipairs(blocks) do
	createBlockButton(blockData).Parent = Content
end

local isMinimized = false
local isDragging = false
local dragStart, startPos
local dragStartTime = 0
local dragStartMousePos = Vector2.zero

local function updateDrag(input)
	local delta = input.Position - dragStart
	local newX = startPos.X.Offset + delta.X
	local newY = startPos.Y.Offset + delta.Y
	
	MainFrame.Position = UDim2.new(startPos.X.Scale, newX, startPos.Y.Scale, newY)
	Shadow.Position = MainFrame.Position
end

DragHandle.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		isDragging = true
		dragStart = input.Position
		startPos = MainFrame.Position
		dragStartTime = tick()
		dragStartMousePos = Vector2.new(input.Position.X, input.Position.Y)
		
		ScreenGui.DisplayOrder = ScreenGui.DisplayOrder + 1
		
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				isDragging = false
			end
		end)
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		updateDrag(input)
	end
end)

local minimizedIsDragging = false
local minimizedDragStart = Vector2.zero
local minimizedStartPos = UDim2.new()
local minimizedDragStartTime = 0
local minimizedDragStartMousePos = Vector2.zero
local hasDraggedMinimized = false

Header.InputBegan:Connect(function(input)
	if not isMinimized then return end
	if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
	
	local mousePos = UserInputService:GetMouseLocation()
	local minimizeAbs = MinimizeBtn.AbsolutePosition
	local minimizeSize = MinimizeBtn.AbsoluteSize
	local closeAbs = CloseBtn.AbsolutePosition
	local closeSize = CloseBtn.AbsoluteSize
	
	local inMinimize = mousePos.X >= minimizeAbs.X and mousePos.X <= minimizeAbs.X + minimizeSize.X and
					  mousePos.Y >= minimizeAbs.Y and mousePos.Y <= minimizeAbs.Y + minimizeSize.Y
	local inClose = mousePos.X >= closeAbs.X and mousePos.X <= closeAbs.X + closeSize.X and
				   mousePos.Y >= closeAbs.Y and mousePos.Y <= closeAbs.Y + closeSize.Y
	
	if inMinimize or inClose then return end
	
	minimizedIsDragging = true
	minimizedDragStart = Vector2.new(input.Position.X, input.Position.Y)
	minimizedStartPos = MainFrame.Position
	minimizedDragStartTime = tick()
	minimizedDragStartMousePos = minimizedDragStart
	hasDraggedMinimized = false
	
	ScreenGui.DisplayOrder = ScreenGui.DisplayOrder + 1
end)

UserInputService.InputChanged:Connect(function(input)
	if not isMinimized or not minimizedIsDragging then return end
	if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then return end
	
	local currentPos = Vector2.new(input.Position.X, input.Position.Y)
	local distanceMoved = (currentPos - minimizedDragStartMousePos).Magnitude
	
	if distanceMoved > CONFIG.Drag.ClickThreshold then
		hasDraggedMinimized = true
		
		local delta = currentPos - minimizedDragStart
		local newX = minimizedStartPos.X.Offset + delta.X
		local newY = minimizedStartPos.Y.Offset + delta.Y
		
		MainFrame.Position = UDim2.new(minimizedStartPos.X.Scale, newX, minimizedStartPos.Y.Scale, newY)
		Shadow.Position = MainFrame.Position
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if not isMinimized then return end
	if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
	if not minimizedIsDragging then return end
	
	minimizedIsDragging = false
	local releaseTime = tick()
	local timeHeld = releaseTime - minimizedDragStartTime
	
	if not hasDraggedMinimized and timeHeld < CONFIG.Drag.MaxClickTime then
		maximizeGUI()
	end
end)

local function setupButtonHover(btn: TextButton, normalColor: Color3)
	btn.MouseEnter:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.2), {
			BackgroundColor3 = normalColor:Lerp(Color3.new(1, 1, 1), 0.15)
		}):Play()
	end)
	
	btn.MouseLeave:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.2), {
			BackgroundColor3 = normalColor
		}):Play()
	end)
end

setupButtonHover(MinimizeBtn, CONFIG.Theme.Minimize)
setupButtonHover(CloseBtn, CONFIG.Theme.Close)

local originalSize = UDim2.new(0, CONFIG.Size.Main.X, 0, CONFIG.Size.Main.Y)
local originalShadowSize = UDim2.new(0, CONFIG.Size.Main.X + 20, 0, CONFIG.Size.Main.Y + 20)
local minimizedSize = UDim2.new(0, CONFIG.Size.Main.X, 0, CONFIG.Size.HeaderOnly)
local minimizedShadowSize = UDim2.new(0, CONFIG.Size.Main.X + 20, 0, CONFIG.Size.HeaderOnly + 20)

MinimizeBtn.MouseButton1Click:Connect(function()
	if isMinimized then
		maximizeGUI()
		return
	end
	
	isMinimized = true
	print("📥 Minimizing GUI...")
	
	MinimizeBtn.Text = "+"
	
	for _, child in ipairs(Content:GetChildren()) do
		if child:IsA("GuiObject") then
			TweenService:Create(child, TweenInfo.new(0.2), {
				TextTransparency = 1,
				BackgroundTransparency = 1
			}):Play()
		end
	end
	
	TweenService:Create(MainFrame, TweenInfo.new(CONFIG.Animation.Speed, CONFIG.Animation.Easing), {
		Size = minimizedSize
	}):Play()
	
	TweenService:Create(Shadow, TweenInfo.new(CONFIG.Animation.Speed, CONFIG.Animation.Easing), {
		Size = minimizedShadowSize
	}):Play()
	
	Content.Visible = false
end)

function maximizeGUI()
	if not isMinimized then return end
	isMinimized = false
	
	print("📤 Maximizing GUI...")
	
	MinimizeBtn.Text = "−"
	
	Content.Visible = true
	
	TweenService:Create(MainFrame, TweenInfo.new(CONFIG.Animation.Speed, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = originalSize
	}):Play()
	
	TweenService:Create(Shadow, TweenInfo.new(CONFIG.Animation.Speed, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = originalShadowSize
	}):Play()
	
	for _, child in ipairs(Content:GetChildren()) do
		if child:IsA("GuiObject") then
			child.TextTransparency = 0
			child.BackgroundTransparency = 0
		end
	end
	
	for i, child in ipairs(Content:GetChildren()) do
		if child:IsA("TextButton") then
			child.Size = UDim2.new(0.8, 0, 0, 45)
			task.delay(0.05 * i, function()
				TweenService:Create(child, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
					Size = UDim2.new(1, 0, 0, 45)
				}):Play()
			end)
		end
	end
end

CloseBtn.MouseButton1Click:Connect(function()
	print("❌ Closing GUI...")
	
	local currentSize = isMinimized and minimizedSize or originalSize
	
	TweenService:Create(MainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
		Size = UDim2.new(0, 0, 0, 0),
		Position = UDim2.new(
			MainFrame.Position.X.Scale, 
			MainFrame.Position.X.Offset, 
			MainFrame.Position.Y.Scale, 
			MainFrame.Position.Y.Offset + (isMinimized and 20 or 170)
		)
	}):Play()
	
	TweenService:Create(Shadow, TweenInfo.new(0.25), {
		ImageTransparency = 1,
		Size = UDim2.new(0, 0, 0, 0)
	}):Play()
	
	TweenService:Create(Header, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
	TweenService:Create(TitleText, TweenInfo.new(0.2), {TextTransparency = 1}):Play()
	TweenService:Create(TitleIcon, TweenInfo.new(0.2), {TextTransparency = 1}):Play()
	TweenService:Create(MinimizeBtn, TweenInfo.new(0.2), {BackgroundTransparency = 1, TextTransparency = 1}):Play()
	TweenService:Create(CloseBtn, TweenInfo.new(0.2), {BackgroundTransparency = 1, TextTransparency = 1}):Play()
	
	task.delay(0.3, function()
		ScreenGui:Destroy()
	end)
end)

MainFrame.Size = UDim2.new(0, CONFIG.Size.Main.X, 0, 0)
Shadow.Size = UDim2.new(0, CONFIG.Size.Main.X + 20, 0, 0)
Shadow.ImageTransparency = 1

TweenService:Create(Shadow, TweenInfo.new(0.5), {
	ImageTransparency = 0.6,
	Size = originalShadowSize
}):Play()

TweenService:Create(MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
	Size = originalSize
}):Play()

for i, child in ipairs(Content:GetChildren()) do
	if child:IsA("TextButton") then
		child.Size = UDim2.new(1, 0, 0, 0)
		task.delay(0.1 + (i * 0.05), function()
			TweenService:Create(child, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				Size = UDim2.new(1, 0, 0, 45)
			}):Play()
		end)
	end
end

print("✅ Lucky Block GUI loaded")
