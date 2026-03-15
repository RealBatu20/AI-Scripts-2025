-- INSTALLATION: local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/RealBatu20/AI-Scripts-2025/refs/heads/main/crimsonui.lua"))()

--!strict
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")

local CrimsonUI = {
	Version = "1.0.0",
	Windows = {},
	ActiveConnections = {},
	IsRunning = true
}

-- Aspect ratio configurations
local ASPECT_RATIOS = {
	["16:9"] = { Width = 16, Height = 9, Name = "Widescreen" },
	["9:16"] = { Width = 9, Height = 16, Name = "Vertical" },
	["1:1"] = { Width = 1, Height = 1, Name = "Square" },
	["4:3"] = { Width = 4, Height = 3, Name = "Classic" },
	["3:2"] = { Width = 3, Height = 2, Name = "Photography" }
}

-- Theme configuration
local CONFIG = {
	Theme = {
		Background = Color3.fromRGB(20, 20, 28),
		Surface = Color3.fromRGB(30, 30, 40),
		SurfaceHover = Color3.fromRGB(40, 40, 52),
		Accent = Color3.fromRGB(88, 101, 242),
		AccentHover = Color3.fromRGB(103, 115, 255),
		Text = Color3.fromRGB(255, 255, 255),
		TextMuted = Color3.fromRGB(180, 180, 190),
		TextDark = Color3.fromRGB(120, 120, 130),
		Close = Color3.fromRGB(237, 66, 69),
		Minimize = Color3.fromRGB(88, 101, 242),
		Shadow = Color3.fromRGB(0, 0, 0),
		Border = Color3.fromRGB(50, 50, 65),
		InnerShadow = Color3.fromRGB(0, 0, 0)
	},
	Animation = {
		Speed = 0.35,
		Easing = Enum.EasingStyle.Quart,
		Direction = Enum.EasingDirection.Out
	},
	Drag = {
		ClickThreshold = 5,
		MaxClickTime = 0.3
	}
}

-- Utility to create instances cleanly
local function Create(className, properties, children)
	local inst = Instance.new(className)
	for k, v in pairs(properties or {}) do
		if k ~= "Parent" then inst[k] = v end
	end
	for _, child in ipairs(children or {}) do
		child.Parent = inst
	end
	if properties and properties.Parent then
		inst.Parent = properties.Parent
	end
	return inst
end

-- Utility for smooth tweens
local function Tween(obj, props, time, style, direction)
	time = time or CONFIG.Animation.Speed
	style = style or CONFIG.Animation.Easing
	direction = direction or CONFIG.Animation.Direction
	local tweenInfo = TweenInfo.new(time, style, direction)
	local tween = TweenService:Create(obj, tweenInfo, props)
	tween:Play()
	return tween
end

-- Create inner shadow effect for 3D depth
local function CreateInnerShadow(parent, radius)
	local shadow = Create("ImageLabel", {
		Name = "InnerShadow",
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Image = "rbxassetid://1316045217",
		ImageColor3 = CONFIG.Theme.InnerShadow,
		ImageTransparency = 0.7,
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(10, 10, 118, 118),
		ZIndex = parent.ZIndex + 1
	})
	
	-- Inset shadow by using negative scale trick with clipping
	local shadowContainer = Create("Frame", {
		Name = "ShadowContainer",
		Parent = parent,
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		ClipsDescendants = true,
		ZIndex = parent.ZIndex + 1
	}, {
		Create("UICorner", { CornerRadius = UDim.new(0, radius or 8) }),
		Create("Frame", {
			Name = "ShadowFrame",
			Position = UDim2.new(0, -10, 0, -10),
			Size = UDim2.new(1, 20, 1, 20),
			BackgroundTransparency = 1,
			ClipsDescendants = false
		}, {
			shadow
		})
	})
	
	return shadowContainer
end

-- Clean up existing instances if re-executed
if getgenv().CrimsonUI_Instance then
	pcall(function() 
		if getgenv().CrimsonUI_Cleanup then
			getgenv().CrimsonUI_Cleanup()
		end
		getgenv().CrimsonUI_Instance:Destroy() 
	end)
end

local screenGui = Create("ScreenGui", {
	Name = "CrimsonUI_" .. tostring(math.random(1000, 9999)),
	ResetOnSpawn = false,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	DisplayOrder = 100,
	IgnoreGuiInset = true
})

-- Attempt to parent to CoreGui to bypass standard anti-cheats scanning PlayerGui
local success = pcall(function() screenGui.Parent = CoreGui end)
if not success then
	screenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
end
getgenv().CrimsonUI_Instance = screenGui

-- Global cleanup function
local function Cleanup()
	CrimsonUI.IsRunning = false
	for _, conn in ipairs(CrimsonUI.ActiveConnections) do
		if conn then
			pcall(function() conn:Disconnect() end)
		end
	end
	CrimsonUI.ActiveConnections = {}
	
	-- Turn off all active toggles
	for _, window in ipairs(CrimsonUI.Windows) do
		if window.ActiveToggles then
			for toggleName, toggleData in pairs(window.ActiveToggles) do
				if toggleData and toggleData.SetState then
					pcall(function() toggleData.SetState(false) end)
				end
			end
		end
	end
end

getgenv().CrimsonUI_Cleanup = Cleanup

function CrimsonUI:CreateWindow(options)
	options = options or {}
	local title = options.Title or "Crimson Window"
	local icon = options.Icon or ""
	local baseSize = options.Size or Vector2.new(400, 500)
	local currentAspectRatio = "16:9"
	local isMinimized = false
	
	-- Calculate initial size based on aspect ratio
	local function CalculateSize(ratioKey, height)
		local ratio = ASPECT_RATIOS[ratioKey]
		local width = height * (ratio.Width / ratio.Height)
		return Vector2.new(width, height)
	end
	
	local windowSize = CalculateSize(currentAspectRatio, baseSize.Y)
	
	local window = {
		Tabs = {},
		CurrentTab = nil,
		IsMinimized = false,
		ActiveToggles = {},
		CurrentRatio = currentAspectRatio,
		BaseHeight = baseSize.Y
	}
	
	table.insert(CrimsonUI.Windows, window)
	
	-- Main Frame
	local mainFrame = Create("Frame", {
		Name = "MainFrame",
		Parent = screenGui,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(0, windowSize.X, 0, 0), -- Start collapsed for intro
		BackgroundColor3 = CONFIG.Theme.Background,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		ZIndex = 1
	}, {
		Create("UICorner", { CornerRadius = UDim.new(0, 12) }),
		Create("UIStroke", { Color = CONFIG.Theme.Border, Thickness = 1.5 })
	})
	
	-- Add inner shadow to main frame
	CreateInnerShadow(mainFrame, 12)
	
	-- Header
	local header = Create("Frame", {
		Name = "Header",
		Parent = mainFrame,
		Size = UDim2.new(1, 0, 0, 45),
		BackgroundColor3 = CONFIG.Theme.Surface,
		BorderSizePixel = 0,
		ZIndex = 2
	}, {
		Create("UICorner", { CornerRadius = UDim.new(0, 12) }),
		Create("Frame", {
			Size = UDim2.new(1, 0, 0.5, 0),
			Position = UDim2.new(0, 0, 0.5, 0),
			BackgroundColor3 = CONFIG.Theme.Surface,
			BorderSizePixel = 0,
			ZIndex = 2
		}),
		CreateInnerShadow(nil, 12), -- Will be parented properly below
		Create("TextLabel", {
			Name = "Icon",
			Size = UDim2.new(0, 30, 0, 30),
			Position = UDim2.new(0, 12, 0.5, 0),
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundTransparency = 1,
			Text = icon,
			TextSize = 20,
			Font = Enum.Font.GothamBold,
			ZIndex = 3
		}),
		Create("TextLabel", {
			Name = "Title",
			Size = UDim2.new(1, -180, 1, 0),
			Position = UDim2.new(0, 45, 0, 0),
			BackgroundTransparency = 1,
			Text = title,
			TextColor3 = CONFIG.Theme.Text,
			Font = Enum.Font.GothamBold,
			TextSize = 16,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 3
		})
	})
	
	-- Fix inner shadow parenting for header
	local headerShadow = header:FindFirstChild("ShadowContainer")
	if headerShadow then
		headerShadow.Parent = header
		headerShadow.ZIndex = 3
	end
	
	local controls = Create("Frame", {
		Name = "Controls",
		Parent = header,
		Size = UDim2.new(0, 130, 0, 30),
		Position = UDim2.new(1, -10, 0.5, 0),
		AnchorPoint = Vector2.new(1, 0.5),
		BackgroundTransparency = 1,
		ZIndex = 3
	}, {
		Create("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Right,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 8)
		})
	})
	
	-- Aspect Ratio Button (cycling button)
	local aspectKeys = {"16:9", "9:16", "1:1", "4:3", "3:2"}
	local currentAspectIndex = 1
	
	local aspectBtn = Create("TextButton", {
		Name = "AspectRatio",
		Parent = controls,
		Size = UDim2.new(0, 50, 0, 26),
		BackgroundColor3 = CONFIG.Theme.Background,
		Text = currentAspectRatio,
		TextColor3 = CONFIG.Theme.TextMuted,
		Font = Enum.Font.GothamBold,
		TextSize = 12,
		AutoButtonColor = false,
		LayoutOrder = 0,
		ZIndex = 4
	}, { 
		Create("UICorner", { CornerRadius = UDim.new(0, 6) }),
		CreateInnerShadow(nil, 6)
	})
	
	local aspectShadow = aspectBtn:FindFirstChild("ShadowContainer")
	if aspectShadow then
		aspectShadow.Parent = aspectBtn
		aspectShadow.ZIndex = 5
	end
	
	local minimizeBtn = Create("TextButton", {
		Name = "Minimize",
		Parent = controls,
		Size = UDim2.new(0, 30, 0, 30),
		BackgroundColor3 = CONFIG.Theme.Minimize,
		Text = "−",
		TextColor3 = CONFIG.Theme.Text,
		Font = Enum.Font.GothamBold,
		TextSize = 20,
		AutoButtonColor = false,
		LayoutOrder = 1,
		ZIndex = 4
	}, { 
		Create("UICorner", { CornerRadius = UDim.new(0, 8) }),
		CreateInnerShadow(nil, 8)
	})
	
	local minShadow = minimizeBtn:FindFirstChild("ShadowContainer")
	if minShadow then
		minShadow.Parent = minimizeBtn
		minShadow.ZIndex = 5
	end
	
	local closeBtn = Create("TextButton", {
		Name = "Close",
		Parent = controls,
		Size = UDim2.new(0, 30, 0, 30),
		BackgroundColor3 = CONFIG.Theme.Close,
		Text = "×",
		TextColor3 = CONFIG.Theme.Text,
		Font = Enum.Font.GothamBold,
		TextSize = 18,
		AutoButtonColor = false,
		LayoutOrder = 2,
		ZIndex = 4
	}, { 
		Create("UICorner", { CornerRadius = UDim.new(0, 8) }),
		CreateInnerShadow(nil, 8)
	})
	
	local closeShadow = closeBtn:FindFirstChild("ShadowContainer")
	if closeShadow then
		closeShadow.Parent = closeBtn
		closeShadow.ZIndex = 5
	end
	
	local tabContainer = Create("Frame", {
		Name = "TabContainer",
		Parent = mainFrame,
		Size = UDim2.new(1, -20, 0, 30),
		Position = UDim2.new(0, 10, 0, 55),
		BackgroundTransparency = 1,
		ClipsDescendants = true,
		ZIndex = 2
	}, {
		Create("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 5)
		})
	})

	local contentContainer = Create("Frame", {
		Name = "ContentContainer",
		Parent = mainFrame,
		Size = UDim2.new(1, -20, 1, -95),
		Position = UDim2.new(0, 10, 0, 90),
		BackgroundTransparency = 1,
		ZIndex = 2
	})
	
	-- Drag & Interaction Logic
	local isDragging = false
	local dragStart, startPos
	local dragStartTime = 0
	local dragStartMousePos = Vector2.zero
	local hasDragged = false

	local dragConnection1 = header.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			local mousePos = UserInputService:GetMouseLocation()
			local minAbs, minSize = minimizeBtn.AbsolutePosition, minimizeBtn.AbsoluteSize
			local closeAbs, closeSize = closeBtn.AbsolutePosition, closeBtn.AbsoluteSize
			local aspectAbs, aspectSize = aspectBtn.AbsolutePosition, aspectBtn.AbsoluteSize
			
			if (mousePos.X >= minAbs.X and mousePos.X <= minAbs.X + minSize.X and mousePos.Y >= minAbs.Y and mousePos.Y <= minAbs.Y + minSize.Y) or
			   (mousePos.X >= closeAbs.X and mousePos.X <= closeAbs.X + closeSize.X and mousePos.Y >= closeAbs.Y and mousePos.Y <= closeAbs.Y + closeSize.Y) or
			   (mousePos.X >= aspectAbs.X and mousePos.X <= aspectAbs.X + aspectSize.X and mousePos.Y >= aspectAbs.Y and mousePos.Y <= aspectAbs.Y + aspectSize.Y) then
				return
			end
			
			isDragging = true
			dragStart = input.Position
			startPos = mainFrame.Position
			dragStartTime = tick()
			dragStartMousePos = Vector2.new(input.Position.X, input.Position.Y)
			hasDragged = false
			screenGui.DisplayOrder = screenGui.DisplayOrder + 1
		end
	end)
	table.insert(CrimsonUI.ActiveConnections, dragConnection1)

	local dragConnection2 = UserInputService.InputChanged:Connect(function(input)
		if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local currentPos = Vector2.new(input.Position.X, input.Position.Y)
			local distanceMoved = (currentPos - dragStartMousePos).Magnitude
			
			if distanceMoved > CONFIG.Drag.ClickThreshold then
				hasDragged = true
				local delta = input.Position - dragStart
				local newX = startPos.X.Offset + delta.X
				local newY = startPos.Y.Offset + delta.Y
				mainFrame.Position = UDim2.new(startPos.X.Scale, newX, startPos.Y.Scale, newY)
			end
		end
	end)
	table.insert(CrimsonUI.ActiveConnections, dragConnection2)

	local dragConnection3 = UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			if not isDragging then return end
			isDragging = false
			
			if window.IsMinimized and not hasDragged and (tick() - dragStartTime) < CONFIG.Drag.MaxClickTime then
				window:Maximize()
			end
		end
	end)
	table.insert(CrimsonUI.ActiveConnections, dragConnection3)
	
	-- Button Hovers
	local function setupHover(btn, normalColor, hoverColor)
		local shadow = btn:FindFirstChild("ShadowContainer")
		btn.MouseEnter:Connect(function() 
			Tween(btn, {BackgroundColor3 = hoverColor}, 0.2) 
			if shadow then
				Tween(shadow:FindFirstChild("InnerShadow"), {ImageTransparency = 0.5}, 0.2)
			end
		end)
		btn.MouseLeave:Connect(function() 
			Tween(btn, {BackgroundColor3 = normalColor}, 0.2) 
			if shadow then
				Tween(shadow:FindFirstChild("InnerShadow"), {ImageTransparency = 0.7}, 0.2)
			end
		end)
	end
	
	setupHover(minimizeBtn, CONFIG.Theme.Minimize, CONFIG.Theme.Minimize:Lerp(Color3.new(1,1,1), 0.15))
	setupHover(closeBtn, CONFIG.Theme.Close, CONFIG.Theme.Close:Lerp(Color3.new(1,1,1), 0.15))
	setupHover(aspectBtn, CONFIG.Theme.Background, CONFIG.Theme.SurfaceHover)
	
	-- Aspect Ratio Logic with smooth transition
	local function UpdateAspectRatio(newRatioKey)
		if not CrimsonUI.IsRunning then return end
		
		currentAspectIndex = table.find(aspectKeys, newRatioKey) or 1
		window.CurrentRatio = newRatioKey
		
		local ratio = ASPECT_RATIOS[newRatioKey]
		local newWidth = window.BaseHeight * (ratio.Width / ratio.Height)
		
		-- Animate size change
		if not window.IsMinimized then
			Tween(mainFrame, {
				Size = UDim2.new(0, newWidth, 0, window.BaseHeight)
			}, 0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
		end
		
		aspectBtn.Text = newRatioKey
	end
	
	aspectBtn.MouseButton1Click:Connect(function()
		currentAspectIndex = currentAspectIndex % #aspectKeys + 1
		UpdateAspectRatio(aspectKeys[currentAspectIndex])
	end)
	
	-- Minimize/Maximize with new animation (slide up into title bar)
	local originalSize = UDim2.new(0, windowSize.X, 0, windowSize.Y)
	local minimizedSize = UDim2.new(0, 180, 0, 45) -- Only show title bar width, header height
	
	function window:Minimize()
		if not CrimsonUI.IsRunning then return end
		window.IsMinimized = true
		minimizeBtn.Text = "+"
		tabContainer.Visible = false
		contentContainer.Visible = false
		
		-- Slide up and shrink to title bar only
		local currentWidth = mainFrame.Size.X.Offset
		Tween(mainFrame, {
			Size = UDim2.new(0, 200, 0, 45),
			Position = UDim2.new(
				mainFrame.Position.X.Scale, 
				mainFrame.Position.X.Offset, 
				mainFrame.Position.Y.Scale, 
				mainFrame.Position.Y.Offset - (window.BaseHeight / 2) + 22.5
			)
		}, CONFIG.Animation.Speed, Enum.EasingStyle.Back, Enum.EasingDirection.In)
	end
	
	function window:Maximize()
		if not CrimsonUI.IsRunning then return end
		window.IsMinimized = false
		minimizeBtn.Text = "−"
		
		local ratio = ASPECT_RATIOS[window.CurrentRatio]
		local targetWidth = window.BaseHeight * (ratio.Width / ratio.Height)
		
		-- Return to center and restore size
		Tween(mainFrame, {
			Size = UDim2.new(0, targetWidth, 0, window.BaseHeight),
			Position = UDim2.new(0.5, 0, 0.5, 0)
		}, CONFIG.Animation.Speed, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
		
		task.delay(0.1, function()
			if CrimsonUI.IsRunning then
				tabContainer.Visible = true
				contentContainer.Visible = true
			end
		end)
	end
	
	minimizeBtn.MouseButton1Click:Connect(function()
		if window.IsMinimized then 
			window:Maximize() 
		else 
			window:Minimize() 
		end
	end)
	
	-- Close with cleanup
	closeBtn.MouseButton1Click:Connect(function()
		-- Turn off all toggles first
		for toggleName, toggleData in pairs(window.ActiveToggles) do
			if toggleData and toggleData.SetState then
				pcall(function() toggleData.SetState(false) end)
			end
		end
		
		-- Animate out
		Tween(mainFrame, {
			Size = UDim2.new(0, 0, 0, 0),
			Position = UDim2.new(mainFrame.Position.X.Scale, mainFrame.Position.X.Offset, mainFrame.Position.Y.Scale, mainFrame.Position.Y.Offset + 100)
		}, 0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
		
		task.delay(0.3, function()
			Cleanup()
			screenGui:Destroy()
		end)
	end)
	
	-- Intro Animation
	Tween(mainFrame, {Size = UDim2.new(0, windowSize.X, 0, windowSize.Y)}, 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

	-- API: Create Tab
	function window:CreateTab(tabName)
		local tab = { Elements = {} }
		
		local tabBtn = Create("TextButton", {
			Name = "Tab_" .. tabName,
			Parent = tabContainer,
			Size = UDim2.new(0, 0, 1, 0),
			AutomaticSize = Enum.AutomaticSize.X,
			BackgroundColor3 = CONFIG.Theme.Surface,
			Text = tabName,
			TextColor3 = CONFIG.Theme.TextMuted,
			Font = Enum.Font.GothamBold,
			TextSize = 13,
			AutoButtonColor = false,
			ZIndex = 3
		}, { 
			Create("UICorner", { CornerRadius = UDim.new(0, 6) }),
			CreateInnerShadow(nil, 6),
			Create("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10) })
		})
		
		local tabShadow = tabBtn:FindFirstChild("ShadowContainer")
		if tabShadow then
			tabShadow.Parent = tabBtn
			tabShadow.ZIndex = 4
		end
		
		local scrollFrame = Create("ScrollingFrame", {
			Name = "Content_" .. tabName,
			Parent = contentContainer,
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			ScrollBarThickness = 2,
			ScrollBarImageColor3 = CONFIG.Theme.Accent,
			BorderSizePixel = 0,
			Visible = false,
			CanvasSize = UDim2.new(0, 0, 0, 0),
			AutomaticCanvasSize = Enum.AutomaticSize.Y
		}, {
			Create("UIListLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, 8)
			}),
			Create("UIPadding", {
				PaddingBottom = UDim.new(0, 5),
				PaddingRight = UDim.new(0, 4)
			})
		})
		
		tab.Container = scrollFrame
		
		local function SelectThisTab()
			if window.CurrentTab == tab or not CrimsonUI.IsRunning then return end
			window.CurrentTab = tab
			
			for _, child in ipairs(tabContainer:GetChildren()) do
				if child:IsA("TextButton") then
					Tween(child, {BackgroundColor3 = CONFIG.Theme.Surface, TextColor3 = CONFIG.Theme.TextMuted}, 0.2)
				end
			end
			for _, child in ipairs(contentContainer:GetChildren()) do
				if child:IsA("ScrollingFrame") then child.Visible = false end
			end
			
			Tween(tabBtn, {BackgroundColor3 = CONFIG.Theme.Accent, TextColor3 = CONFIG.Theme.Text}, 0.2)
			scrollFrame.Visible = true
		end
		
		tabBtn.MouseButton1Click:Connect(SelectThisTab)
		
		if #tabContainer:GetChildren() == 2 then
			SelectThisTab()
		end

		-- API: Elements with Inner Shadows
		function tab:CreateButton(options)
			local btnName = options.Name or "Button"
			local callback = options.Callback or function() end
			
			local function randomVibrantColor()
				local hue = math.random()
				local saturation = 0.7 + (math.random() * 0.3)
				local value = 0.8 + (math.random() * 0.2)
				return Color3.fromHSV(hue, saturation, value)
			end
			
			local startColor = randomVibrantColor()
			local endColor = Color3.fromHSV(
				(select(1, startColor:ToHSV()) + 0.05) % 1,
				math.clamp(select(2, startColor:ToHSV()) + (math.random() - 0.5) * 0.2, 0.5, 1),
				math.clamp(select(3, startColor:ToHSV()) + (math.random() - 0.5) * 0.2, 0.6, 1)
			)
			
			local btnFrame = Create("TextButton", {
				Name = btnName,
				Parent = tab.Container,
				Size = UDim2.new(1, 0, 0, 48),
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				Text = "",
				AutoButtonColor = false,
				ClipsDescendants = true
			}, {
				Create("UICorner", { CornerRadius = UDim.new(0, 10) }),
				Create("UIGradient", {
					Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0, startColor),
						ColorSequenceKeypoint.new(1, endColor)
					}),
					Rotation = 0
				}),
				CreateInnerShadow(nil, 10),
				Create("TextLabel", {
					Name = "Icon",
					Position = UDim2.new(0, 15, 0.5, 0),
					AnchorPoint = Vector2.new(0, 0.5),
					Size = UDim2.new(0, 24, 0, 24),
					BackgroundTransparency = 1,
					Text = "◆",
					TextColor3 = Color3.fromRGB(255, 255, 255),
					Font = Enum.Font.GothamBold,
					TextSize = 18,
					TextXAlignment = Enum.TextXAlignment.Center,
					TextYAlignment = Enum.TextYAlignment.Center
				}),
				Create("TextLabel", {
					Name = "Title",
					Position = UDim2.new(0, 48, 0, 0),
					Size = UDim2.new(1, -60, 1, 0),
					BackgroundTransparency = 1,
					Text = btnName,
					TextColor3 = Color3.fromRGB(255, 255, 255),
					Font = Enum.Font.GothamBold,
					TextSize = 16,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextYAlignment = Enum.TextYAlignment.Center
				})
			})
			
			local btnShadow = btnFrame:FindFirstChild("ShadowContainer")
			if btnShadow then
				btnShadow.Parent = btnFrame
				btnShadow.ZIndex = 5
			end
			
			local gradient = btnFrame:FindFirstChildOfClass("UIGradient")
			local originalColor = gradient.Color
			
			btnFrame.MouseEnter:Connect(function()
				local brightenedStart = startColor:Lerp(Color3.new(1, 1, 1), 0.15)
				local brightenedEnd = endColor:Lerp(Color3.new(1, 1, 1), 0.15)
				Tween(gradient, {
					Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0, brightenedStart),
						ColorSequenceKeypoint.new(1, brightenedEnd)
					})
				}, 0.2)
			end)
			
			btnFrame.MouseLeave:Connect(function()
				Tween(gradient, {Color = originalColor}, 0.2)
			end)
			
			btnFrame.MouseButton1Click:Connect(function()
				Tween(btnFrame, {Size = UDim2.new(0.97, 0, 0, 46)}, 0.08, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
				task.delay(0.08, function()
					Tween(btnFrame, {Size = UDim2.new(1, 0, 0, 48)}, 0.12, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
				end)
				if CrimsonUI.IsRunning then
					pcall(callback)
				end
			end)
		end

		function tab:CreateToggle(options)
			local togName = options.Name or "Toggle"
			local default = options.Default or false
			local callback = options.Callback or function() end
			
			local state = default
			local toggleId = tostring(math.random(100000, 999999))
			
			local toggleFrame = Create("TextButton", {
				Name = togName .. "_" .. toggleId,
				Parent = tab.Container,
				Size = UDim2.new(1, 0, 0, 35),
				BackgroundColor3 = CONFIG.Theme.Surface,
				Text = "",
				AutoButtonColor = false
			}, {
				Create("UICorner", { CornerRadius = UDim.new(0, 8) }),
				CreateInnerShadow(nil, 8),
				Create("TextLabel", {
					Position = UDim2.new(0, 10, 0, 0),
					Size = UDim2.new(1, -60, 1, 0),
					BackgroundTransparency = 1,
					Text = togName,
					TextColor3 = CONFIG.Theme.TextMuted,
					Font = Enum.Font.GothamMedium,
					TextSize = 14,
					TextXAlignment = Enum.TextXAlignment.Left
				})
			})
			
			local tShadow = toggleFrame:FindFirstChild("ShadowContainer")
			if tShadow then
				tShadow.Parent = toggleFrame
				tShadow.ZIndex = 5
			end
			
			local titleText = toggleFrame:FindFirstChildOfClass("TextLabel")
			
			local switchBg = Create("Frame", {
				Parent = toggleFrame,
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, -10, 0.5, 0),
				Size = UDim2.new(0, 36, 0, 18),
				BackgroundColor3 = state and CONFIG.Theme.Accent or CONFIG.Theme.Background
			}, { Create("UICorner", { CornerRadius = UDim.new(1, 0) }) })
			
			local switchKnob = Create("Frame", {
				Parent = switchBg,
				AnchorPoint = Vector2.new(0, 0.5),
				Position = UDim2.new(0, state and 20 or 2, 0.5, 0),
				Size = UDim2.new(0, 14, 0, 14),
				BackgroundColor3 = Color3.new(1, 1, 1)
			}, { Create("UICorner", { CornerRadius = UDim.new(1, 0) }) })
			
			local function SetState(newState)
				if not CrimsonUI.IsRunning then 
					state = false
					return 
				end
				state = newState
				Tween(switchBg, {BackgroundColor3 = state and CONFIG.Theme.Accent or CONFIG.Theme.Background}, 0.2)
				Tween(switchKnob, {Position = UDim2.new(0, state and 20 or 2, 0.5, 0)}, 0.2, Enum.EasingStyle.Back)
				Tween(titleText, {TextColor3 = state and CONFIG.Theme.Text or CONFIG.Theme.TextMuted}, 0.2)
				pcall(callback, state)
			end
			
			-- Register for cleanup
			window.ActiveToggles[toggleId] = {
				SetState = SetState,
				GetState = function() return state end
			}
			
			toggleFrame.MouseButton1Click:Connect(function()
				SetState(not state)
			end)
			
			if state then SetState(true) end
		end

		function tab:CreateSlider(options)
			local slName = options.Name or "Slider"
			local min = options.Min or 0
			local max = options.Max or 100
			local default = options.Default or min
			local callback = options.Callback or function() end
			
			local val = default
			
			local sliderFrame = Create("Frame", {
				Name = slName,
				Parent = tab.Container,
				Size = UDim2.new(1, 0, 0, 50),
				BackgroundColor3 = CONFIG.Theme.Surface,
				BorderSizePixel = 0
			}, { 
				Create("UICorner", { CornerRadius = UDim.new(0, 8) }),
				CreateInnerShadow(nil, 8)
			})
			
			local sShadow = sliderFrame:FindFirstChild("ShadowContainer")
			if sShadow then
				sShadow.Parent = sliderFrame
				sShadow.ZIndex = 5
			end
			
			local titleText = Create("TextLabel", {
				Parent = sliderFrame,
				Position = UDim2.new(0, 10, 0, 5),
				Size = UDim2.new(0.7, 0, 0, 15),
				BackgroundTransparency = 1,
				Text = slName,
				TextColor3 = CONFIG.Theme.TextMuted,
				Font = Enum.Font.GothamMedium,
				TextSize = 13,
				TextXAlignment = Enum.TextXAlignment.Left
			})
			
			local valText = Create("TextLabel", {
				Parent = sliderFrame,
				Position = UDim2.new(0.7, -10, 0, 5),
				Size = UDim2.new(0.3, 0, 0, 15),
				BackgroundTransparency = 1,
				Text = tostring(val),
				TextColor3 = CONFIG.Theme.Text,
				Font = Enum.Font.GothamBold,
				TextSize = 13,
				TextXAlignment = Enum.TextXAlignment.Right
			})
			
			local track = Create("TextButton", {
				Parent = sliderFrame,
				Position = UDim2.new(0, 10, 0, 30),
				Size = UDim2.new(1, -20, 0, 6),
				BackgroundColor3 = CONFIG.Theme.Background,
				Text = "",
				AutoButtonColor = false
			}, { Create("UICorner", { CornerRadius = UDim.new(1, 0) }) })
			
			local fill = Create("Frame", {
				Parent = track,
				Size = UDim2.new((val - min)/(max - min), 0, 1, 0),
				BackgroundColor3 = CONFIG.Theme.Accent,
				BorderSizePixel = 0
			}, { Create("UICorner", { CornerRadius = UDim.new(1, 0) }) })
			
			local knob = Create("Frame", {
				Parent = fill,
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.new(1, 0, 0.5, 0),
				Size = UDim2.new(0, 12, 0, 12),
				BackgroundColor3 = Color3.new(1, 1, 1)
			}, { Create("UICorner", { CornerRadius = UDim.new(1, 0) }) })
			
			local dragging = false
			
			local function UpdateSlider(input)
				if not CrimsonUI.IsRunning then return end
				local percent = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
				val = math.floor(min + (max - min) * percent)
				valText.Text = tostring(val)
				Tween(fill, {Size = UDim2.new(percent, 0, 1, 0)}, 0.1)
				pcall(callback, val)
			end
			
			local sliderConn1 = track.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					dragging = true
					UpdateSlider(input)
				end
			end)
			table.insert(CrimsonUI.ActiveConnections, sliderConn1)
			
			local sliderConn2 = UserInputService.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					dragging = false
				end
			end)
			table.insert(CrimsonUI.ActiveConnections, sliderConn2)
			
			local sliderConn3 = UserInputService.InputChanged:Connect(function(input)
				if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
					UpdateSlider(input)
				end
			end)
			table.insert(CrimsonUI.ActiveConnections, sliderConn3)
		end

		function tab:CreateDropdown(options)
			local dropName = options.Name or "Dropdown"
			local list = options.Options or {}
			local default = options.Default
			local callback = options.Callback or function() end
			
			local selected = default or "Select..."
			local expanded = false
			
			local dropFrame = Create("Frame", {
				Name = dropName,
				Parent = tab.Container,
				Size = UDim2.new(1, 0, 0, 35),
				BackgroundColor3 = CONFIG.Theme.Surface,
				ClipsDescendants = true
			}, { 
				Create("UICorner", { CornerRadius = UDim.new(0, 8) }),
				CreateInnerShadow(nil, 8)
			})
			
			local dShadow = dropFrame:FindFirstChild("ShadowContainer")
			if dShadow then
				dShadow.Parent = dropFrame
				dShadow.ZIndex = 5
			end
			
			local headerBtn = Create("TextButton", {
				Parent = dropFrame,
				Size = UDim2.new(1, 0, 0, 35),
				BackgroundTransparency = 1,
				Text = ""
			})
			
			Create("TextLabel", {
				Parent = headerBtn,
				Position = UDim2.new(0, 10, 0, 0),
				Size = UDim2.new(0.5, 0, 1, 0),
				BackgroundTransparency = 1,
				Text = dropName,
				TextColor3 = CONFIG.Theme.TextMuted,
				Font = Enum.Font.GothamMedium,
				TextSize = 14,
				TextXAlignment = Enum.TextXAlignment.Left
			})
			
			local selectedText = Create("TextLabel", {
				Parent = headerBtn,
				Position = UDim2.new(0.5, -30, 0, 0),
				Size = UDim2.new(0.5, 0, 1, 0),
				BackgroundTransparency = 1,
				Text = selected,
				TextColor3 = CONFIG.Theme.Accent,
				Font = Enum.Font.GothamBold,
				TextSize = 13,
				TextXAlignment = Enum.TextXAlignment.Right
			})
			
			local arrow = Create("TextLabel", {
				Parent = headerBtn,
				Position = UDim2.new(1, -25, 0, 0),
				Size = UDim2.new(0, 20, 1, 0),
				BackgroundTransparency = 1,
				Text = "▼",
				TextColor3 = CONFIG.Theme.TextDark,
				Font = Enum.Font.GothamBold,
				TextSize = 12
			})
			
			local listFrame = Create("Frame", {
				Parent = dropFrame,
				Position = UDim2.new(0, 0, 0, 35),
				Size = UDim2.new(1, 0, 1, -35),
				BackgroundTransparency = 1
			}, {
				Create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder })
			})
			
			local function UpdateList()
				for _, v in ipairs(listFrame:GetChildren()) do
					if v:IsA("TextButton") then v:Destroy() end
				end
				
				for i, opt in ipairs(list) do
					local optBtn = Create("TextButton", {
						Parent = listFrame,
						Size = UDim2.new(1, 0, 0, 30),
						BackgroundColor3 = CONFIG.Theme.Surface,
						BorderSizePixel = 0,
						Text = opt,
						TextColor3 = opt == selected and CONFIG.Theme.Accent or CONFIG.Theme.Text,
						Font = Enum.Font.Gotham,
						TextSize = 13,
						AutoButtonColor = false,
						LayoutOrder = i
					})
					
					optBtn.MouseEnter:Connect(function()
						if opt ~= selected then Tween(optBtn, {BackgroundColor3 = CONFIG.Theme.SurfaceHover}, 0.15) end
					end)
					optBtn.MouseLeave:Connect(function()
						Tween(optBtn, {BackgroundColor3 = CONFIG.Theme.Surface}, 0.15)
					end)
					
					optBtn.MouseButton1Click:Connect(function()
						if not CrimsonUI.IsRunning then return end
						selected = opt
						selectedText.Text = selected
						pcall(callback, selected)
						
						expanded = false
						Tween(arrow, {Rotation = 0}, 0.2)
						Tween(dropFrame, {Size = UDim2.new(1, 0, 0, 35)}, 0.2)
						UpdateList()
					end)
				end
			end
			
			headerBtn.MouseButton1Click:Connect(function()
				if not CrimsonUI.IsRunning then return end
				expanded = not expanded
				Tween(arrow, {Rotation = expanded and 180 or 0}, 0.2)
				if expanded then
					UpdateList()
					Tween(dropFrame, {Size = UDim2.new(1, 0, 0, 35 + (#list * 30))}, 0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
				else
					Tween(dropFrame, {Size = UDim2.new(1, 0, 0, 35)}, 0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
				end
			end)
		end

		function tab:CreateLabel(text)
			Create("TextLabel", {
				Parent = tab.Container,
				Size = UDim2.new(1, 0, 0, 20),
				BackgroundTransparency = 1,
				Text = text,
				TextColor3 = CONFIG.Theme.TextMuted,
				Font = Enum.Font.GothamMedium,
				TextSize = 13,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextWrapped = true
			})
		end
		
		function tab:CreateInput(options)
			local inpName = options.Name or "Input"
			local placeholder = options.Placeholder or "Type here..."
			local callback = options.Callback or function() end
			
			local inputFrame = Create("Frame", {
				Parent = tab.Container,
				Size = UDim2.new(1, 0, 0, 50),
				BackgroundColor3 = CONFIG.Theme.Surface,
				BorderSizePixel = 0
			}, { 
				Create("UICorner", { CornerRadius = UDim.new(0, 8) }),
				CreateInnerShadow(nil, 8)
			})
			
			local iShadow = inputFrame:FindFirstChild("ShadowContainer")
			if iShadow then
				iShadow.Parent = inputFrame
				iShadow.ZIndex = 5
			end
			
			Create("TextLabel", {
				Parent = inputFrame,
				Position = UDim2.new(0, 10, 0, 5),
				Size = UDim2.new(1, -20, 0, 15),
				BackgroundTransparency = 1,
				Text = inpName,
				TextColor3 = CONFIG.Theme.TextMuted,
				Font = Enum.Font.GothamMedium,
				TextSize = 13,
				TextXAlignment = Enum.TextXAlignment.Left
			})
			
			local textBox = Create("TextBox", {
				Parent = inputFrame,
				Position = UDim2.new(0, 10, 0, 25),
				Size = UDim2.new(1, -20, 0, 20),
				BackgroundColor3 = CONFIG.Theme.Background,
				Text = "",
				PlaceholderText = placeholder,
				PlaceholderColor3 = CONFIG.Theme.TextDark,
				TextColor3 = CONFIG.Theme.Text,
				Font = Enum.Font.Gotham,
				TextSize = 13,
				TextXAlignment = Enum.TextXAlignment.Left,
				ClearTextOnFocus = false
			}, {
				Create("UICorner", { CornerRadius = UDim.new(0, 4) }),
				Create("UIPadding", { PaddingLeft = UDim.new(0, 6), PaddingRight = UDim.new(0, 6) })
			})
			
			textBox.FocusLost:Connect(function()
				if CrimsonUI.IsRunning then
					pcall(callback, textBox.Text)
				end
			end)
		end

		return tab
	end

	return window
end

return CrimsonUI
