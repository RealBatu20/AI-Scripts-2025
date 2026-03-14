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
		Border = Color3.fromRGB(50, 50, 65)
	},
	Animation = {
		Speed = 0.35,
		Easing = Enum.EasingStyle.Quart,
		Direction = Enum.EasingDirection.Out
	},
	Drag = {
		ClickThreshold = 5,
		MaxClickTime = 0.3
	},
	AspectRatios = {
		{ Name = "16:9", Ratio = 16/9, Desc = "Widescreen" },
		{ Name = "9:16", Ratio = 9/16, Desc = "Vertical" },
		{ Name = "1:1", Ratio = 1, Desc = "Square" },
		{ Name = "4:3", Ratio = 4/3, Desc = "Classic" },
		{ Name = "3:2", Ratio = 3/2, Desc = "Photography" }
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

-- Clean up existing instances if re-executed
if getgenv().CrimsonUI_Instance then
	pcall(function() 
		if getgenv().CrimsonUI_Cleanup then
			getgenv().CrimsonUI_Cleanup()
		end
		getgenv().CrimsonUI_Instance:Destroy() 
	end)
end

-- Cleanup function to stop all running processes
local function CleanupAll()
	CrimsonUI.IsRunning = false
	for _, conn in ipairs(CrimsonUI.ActiveConnections) do
		pcall(function() conn:Disconnect() end)
	end
	CrimsonUI.ActiveConnections = {}
	-- Turn off all active toggles
	for _, window in ipairs(CrimsonUI.Windows) do
		if window.ActiveToggles then
			for toggleName, toggleData in pairs(window.ActiveToggles) do
				if toggleData.State then
					pcall(function() toggleData.Callback(false) end)
				end
			end
		end
	end
	CrimsonUI.Windows = {}
end

getgenv().CrimsonUI_Cleanup = CleanupAll

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

-- 3D Tilt effect handler
local function Apply3DEffect(frame, intensity)
	intensity = intensity or 5
	local connection = frame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			local pos = input.Position
			local absPos = frame.AbsolutePosition
			local absSize = frame.AbsoluteSize
			local centerX = absPos.X + absSize.X / 2
			local centerY = absPos.Y + absSize.Y / 2
			
			local deltaX = (pos.X - centerX) / (absSize.X / 2)
			local deltaY = (pos.Y - centerY) / (absSize.Y / 2)
			
			Tween(frame, {
				Rotation = deltaY * intensity,
				Position = UDim2.new(
					frame.Position.X.Scale, 
					frame.Position.X.Offset + deltaX * 2,
					frame.Position.Y.Scale,
					frame.Position.Y.Offset + deltaY * 2
				)
			}, 0.1)
		end
	end)
	table.insert(CrimsonUI.ActiveConnections, connection)
	
	local leaveConn = frame.MouseLeave:Connect(function()
		Tween(frame, {Rotation = 0}, 0.3)
	end)
	table.insert(CrimsonUI.ActiveConnections, leaveConn)
end

function CrimsonUI:CreateWindow(options)
	options = options or {}
	local title = options.Title or "Crimson Window"
	local icon = options.Icon or "🎲"
	local baseSize = options.Size or Vector2.new(300, 380)
	local currentAspectIndex = 1 -- Default to 16:9
	
	local window = {
		Tabs = {},
		CurrentTab = nil,
		IsMinimized = false,
		ActiveToggles = {},
		BaseWidth = baseSize.X
	}
	table.insert(CrimsonUI.Windows, window)
	
	-- Calculate height based on aspect ratio
	local function GetSizeForAspect(index)
		local ratio = CONFIG.AspectRatios[index].Ratio
		local width = window.BaseWidth
		local height = width / ratio
		return Vector2.new(width, math.clamp(height, 200, 600))
	end
	
	local currentSize = GetSizeForAspect(currentAspectIndex)
	
	-- Shadow with improved smoothness
	local shadow = Create("ImageLabel", {
		Name = "Shadow",
		Parent = screenGui,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(0, currentSize.X + 30, 0, currentSize.Y + 30),
		BackgroundTransparency = 1,
		Image = "rbxassetid://1316045217",
		ImageColor3 = CONFIG.Theme.Shadow,
		ImageTransparency = 0.4,
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(10, 10, 118, 118),
		ZIndex = 0
	})
	
	-- Main Frame with 3D perspective
	local mainFrame = Create("Frame", {
		Name = "MainFrame",
		Parent = screenGui,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(0, currentSize.X, 0, 0), -- Start collapsed for intro
		BackgroundColor3 = CONFIG.Theme.Background,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		ZIndex = 1
	}, {
		Create("UICorner", { CornerRadius = UDim.new(0, 12) }),
		Create("UIStroke", { Color = CONFIG.Theme.Border, Thickness = 1.5 })
	})
	
	-- 3D Depth layers
	local depthFrame = Create("Frame", {
		Name = "DepthLayer",
		Parent = mainFrame,
		Size = UDim2.new(1, -20, 1, -20),
		Position = UDim2.new(0, 10, 0, 10),
		BackgroundTransparency = 1,
		ZIndex = 1
	})
	
	-- Header with 3D effect
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
	
	local controls = Create("Frame", {
		Name = "Controls",
		Parent = header,
		Size = UDim2.new(0, 140, 0, 30),
		Position = UDim2.new(1, -10, 0.5, 0),
		AnchorPoint = Vector2.new(1, 0.5),
		BackgroundTransparency = 1,
		ZIndex = 3
	}, {
		Create("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Right,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 6)
		})
	})
	
	-- Aspect Ratio Button (cycles through ratios)
	local aspectBtn = Create("TextButton", {
		Name = "AspectRatio",
		Parent = controls,
		Size = UDim2.new(0, 45, 0, 26),
		BackgroundColor3 = CONFIG.Theme.SurfaceHover,
		Text = CONFIG.AspectRatios[1].Name,
		TextColor3 = CONFIG.Theme.Text,
		Font = Enum.Font.GothamBold,
		TextSize = 11,
		AutoButtonColor = false,
		LayoutOrder = 1,
		ZIndex = 4
	}, { 
		Create("UICorner", { CornerRadius = UDim.new(0, 6) }),
		-- 3D highlight effect
		Create("Frame", {
			Name = "Highlight",
			Size = UDim2.new(1, 0, 0.5, 0),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 0.9,
			BorderSizePixel = 0
		}, { Create("UICorner", { CornerRadius = UDim.new(0, 6) }) })
	})
	
	local minimizeBtn = Create("TextButton", {
		Name = "Minimize",
		Parent = controls,
		Size = UDim2.new(0, 30, 0, 26),
		BackgroundColor3 = CONFIG.Theme.Minimize,
		Text = "−",
		TextColor3 = CONFIG.Theme.Text,
		Font = Enum.Font.GothamBold,
		TextSize = 18,
		AutoButtonColor = false,
		LayoutOrder = 2,
		ZIndex = 4
	}, { 
		Create("UICorner", { CornerRadius = UDim.new(0, 6) }),
		Create("Frame", {
			Name = "Highlight",
			Size = UDim2.new(1, 0, 0.5, 0),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 0.85,
			BorderSizePixel = 0
		}, { Create("UICorner", { CornerRadius = UDim.new(0, 6) }) })
	})
	
	local closeBtn = Create("TextButton", {
		Name = "Close",
		Parent = controls,
		Size = UDim2.new(0, 30, 0, 26),
		BackgroundColor3 = CONFIG.Theme.Close,
		Text = "×",
		TextColor3 = CONFIG.Theme.Text,
		Font = Enum.Font.GothamBold,
		TextSize = 16,
		AutoButtonColor = false,
		LayoutOrder = 3,
		ZIndex = 4
	}, { 
		Create("UICorner", { CornerRadius = UDim.new(0, 6) }),
		Create("Frame", {
			Name = "Highlight",
			Size = UDim2.new(1, 0, 0.5, 0),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 0.85,
			BorderSizePixel = 0
		}, { Create("UICorner", { CornerRadius = UDim.new(0, 6) }) })
	})
	
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
	
	-- Drag & Minimize Logic
	local isDragging = false
	local dragStart, startPos
	local dragStartTime = 0
	local dragStartMousePos = Vector2.zero
	local hasDragged = false

	header.InputBegan:Connect(function(input)
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

	local dragConn = UserInputService.InputChanged:Connect(function(input)
		if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local currentPos = Vector2.new(input.Position.X, input.Position.Y)
			local distanceMoved = (currentPos - dragStartMousePos).Magnitude
			
			if distanceMoved > CONFIG.Drag.ClickThreshold then
				hasDragged = true
				local delta = input.Position - dragStart
				local newX = startPos.X.Offset + delta.X
				local newY = startPos.Y.Offset + delta.Y
				mainFrame.Position = UDim2.new(startPos.X.Scale, newX, startPos.Y.Scale, newY)
				shadow.Position = mainFrame.Position
			end
		end
	end)
	table.insert(CrimsonUI.ActiveConnections, dragConn)

	local dragEndConn = UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			if not isDragging then return end
			isDragging = false
			
			if window.IsMinimized and not hasDragged and (tick() - dragStartTime) < CONFIG.Drag.MaxClickTime then
				window:Maximize()
			end
		end
	end)
	table.insert(CrimsonUI.ActiveConnections, dragEndConn)
	
	-- Button Hovers with 3D effect
	local function setupHover3D(btn, normalColor, hoverColor)
		local highlight = btn:FindFirstChild("Highlight")
		btn.MouseEnter:Connect(function() 
			Tween(btn, {BackgroundColor3 = hoverColor}, 0.2)
			if highlight then
				Tween(highlight, {BackgroundTransparency = 0.7}, 0.2)
			end
		end)
		btn.MouseLeave:Connect(function() 
			Tween(btn, {BackgroundColor3 = normalColor}, 0.2)
			if highlight then
				Tween(highlight, {BackgroundTransparency = 0.85}, 0.2)
			end
		end)
	end
	
	setupHover3D(aspectBtn, CONFIG.Theme.SurfaceHover, CONFIG.Theme.SurfaceHover:Lerp(Color3.new(1,1,1), 0.2))
	setupHover3D(minimizeBtn, CONFIG.Theme.Minimize, CONFIG.Theme.Minimize:Lerp(Color3.new(1,1,1), 0.15))
	setupHover3D(closeBtn, CONFIG.Theme.Close, CONFIG.Theme.Close:Lerp(Color3.new(1,1,1), 0.15))
	
	-- Aspect Ratio Changer
	local function CycleAspectRatio()
		currentAspectIndex = currentAspectIndex % #CONFIG.AspectRatios + 1
		local newSize = GetSizeForAspect(currentAspectIndex)
		
		aspectBtn.Text = CONFIG.AspectRatios[currentAspectIndex].Name
		
		-- Smooth transition to new aspect ratio
		Tween(mainFrame, {
			Size = UDim2.new(0, newSize.X, 0, window.IsMinimized and 45 or newSize.Y)
		}, 0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
		
		Tween(shadow, {
			Size = UDim2.new(0, newSize.X + 30, 0, (window.IsMinimized and 45 or newSize.Y) + 30)
		}, 0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
		
		-- Update stored sizes
		currentSize = newSize
	end
	
	aspectBtn.MouseButton1Click:Connect(CycleAspectRatio)
	
	-- Minimize/Maximize with upward animation into title bar
	local originalSize = UDim2.new(0, currentSize.X, 0, currentSize.Y)
	local minSize = UDim2.new(0, currentSize.X, 0, 45)
	local originalShadowSize = UDim2.new(0, currentSize.X + 30, 0, currentSize.Y + 30)
	local minShadowSize = UDim2.new(0, currentSize.X + 30, 0, 45 + 30)

	function window:Minimize()
		window.IsMinimized = true
		minimizeBtn.Text = "+"
		tabContainer.Visible = false
		contentContainer.Visible = false
		
		-- Calculate position to animate upward into title bar
		local currentPos = mainFrame.Position
		local headerHeight = 45
		local targetY = currentPos.Y.Offset - (currentSize.Y - headerHeight) / 2
		
		Tween(mainFrame, {
			Size = minSize,
			Position = UDim2.new(currentPos.X.Scale, currentPos.X.Offset, currentPos.Y.Scale, targetY)
		}, CONFIG.Animation.Speed, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
		
		Tween(shadow, {
			Size = minShadowSize,
			Position = UDim2.new(currentPos.X.Scale, currentPos.X.Offset, currentPos.Y.Scale, targetY)
		}, CONFIG.Animation.Speed, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
	end
	
	function window:Maximize()
		window.IsMinimized = false
		minimizeBtn.Text = "−"
		
		local currentPos = mainFrame.Position
		local targetY = currentPos.Y.Offset + (currentSize.Y - 45) / 2
		
		Tween(mainFrame, {
			Size = UDim2.new(0, currentSize.X, 0, currentSize.Y),
			Position = UDim2.new(currentPos.X.Scale, currentPos.X.Offset, currentPos.Y.Scale, targetY)
		}, CONFIG.Animation.Speed, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
		
		Tween(shadow, {
			Size = UDim2.new(0, currentSize.X + 30, 0, currentSize.Y + 30),
			Position = UDim2.new(currentPos.X.Scale, currentPos.X.Offset, currentPos.Y.Scale, targetY)
		}, CONFIG.Animation.Speed, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
		
		task.delay(0.1, function()
			tabContainer.Visible = true
			contentContainer.Visible = true
		end)
	end
	
	minimizeBtn.MouseButton1Click:Connect(function()
		if window.IsMinimized then window:Maximize() else window:Minimize() end
	end)
	
	closeBtn.MouseButton1Click:Connect(function()
		-- Cleanup before closing
		CleanupAll()
		
		-- Close animation
		Tween(mainFrame, {
			Size = UDim2.new(0, 0, 0, 0),
			Position = UDim2.new(mainFrame.Position.X.Scale, mainFrame.Position.X.Offset, mainFrame.Position.Y.Scale, mainFrame.Position.Y.Offset + 170),
			Rotation = -10
		}, 0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
		
		Tween(shadow, {Size = UDim2.new(0,0,0,0), ImageTransparency = 1}, 0.25)
		
		task.delay(0.3, function() 
			screenGui:Destroy()
		end)
	end)
	
	-- Intro Anim
	Tween(shadow, {Size = originalShadowSize, ImageTransparency = 0.4}, 0.5)
	Tween(mainFrame, {Size = originalSize}, 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	
	-- Apply 3D effects to interactive elements
	Apply3DEffect(mainFrame, 3)

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
			-- 3D highlight
			Create("Frame", {
				Name = "TabHighlight",
				Size = UDim2.new(1, 0, 0.5, 0),
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 0.9,
				BorderSizePixel = 0
			}, { Create("UICorner", { CornerRadius = UDim.new(0, 6) }) })
		})
		
		local scrollFrame = Create("ScrollingFrame", {
			Name = "Content_" .. tabName,
			Parent = contentContainer,
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			ScrollBarThickness = 3,
			ScrollBarImageColor3 = CONFIG.Theme.Accent,
			BorderSizePixel = 0,
			Visible = false,
			CanvasSize = UDim2.new(0, 0, 0, 0),
			AutomaticCanvasSize = Enum.AutomaticSize.Y
		}, {
			Create("UIListLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, 10)
			}),
			Create("UIPadding", {
				PaddingBottom = UDim.new(0, 5),
				PaddingRight = UDim.new(0, 4)
			})
		})
		
		tab.Container = scrollFrame
		
		local function SelectThisTab()
			if window.CurrentTab == tab then return end
			window.CurrentTab = tab
			
			for _, child in ipairs(tabContainer:GetChildren()) do
				if child:IsA("TextButton") then
					Tween(child, {BackgroundColor3 = CONFIG.Theme.Surface, TextColor3 = CONFIG.Theme.TextMuted}, 0.2)
					local hl = child:FindFirstChild("TabHighlight")
					if hl then Tween(hl, {BackgroundTransparency = 0.9}, 0.2) end
				end
			end
			for _, child in ipairs(contentContainer:GetChildren()) do
				if child:IsA("ScrollingFrame") then child.Visible = false end
			end
			
			Tween(tabBtn, {BackgroundColor3 = CONFIG.Theme.Accent, TextColor3 = CONFIG.Theme.Text}, 0.2)
			local hl = tabBtn:FindFirstChild("TabHighlight")
			if hl then Tween(hl, {BackgroundTransparency = 0.75}, 0.2) end
			
			scrollFrame.Visible = true
			-- 3D pop effect on content
			scrollFrame.Position = UDim2.new(0, 20, 0, 0)
			Tween(scrollFrame, {Position = UDim2.new(0, 0, 0, 0)}, 0.3, Enum.EasingStyle.Back)
		end
		
		tabBtn.MouseButton1Click:Connect(SelectThisTab)
		Apply3DEffect(tabBtn, 2)
		
		if #tabContainer:GetChildren() == 2 then
			SelectThisTab()
		end

		-- API: Elements with 3D effects
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
				ClipsDescendants = true,
				LayoutOrder = #tab.Container:GetChildren()
			}, {
				Create("UICorner", { CornerRadius = UDim.new(0, 10) }),
				Create("UIGradient", {
					Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0, startColor),
						ColorSequenceKeypoint.new(1, endColor)
					}),
					Rotation = 0
				}),
				Create("Frame", {
					Name = "Shine",
					Size = UDim2.new(1, 0, 0.5, 0),
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					BackgroundTransparency = 0.85,
					BorderSizePixel = 0
				}, { Create("UICorner", { CornerRadius = UDim.new(0, 10) }) }),
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
			
			local gradient = btnFrame:FindFirstChildOfClass("UIGradient")
			local originalColor = gradient.Color
			local shine = btnFrame:FindFirstChild("Shine")
			
			btnFrame.MouseEnter:Connect(function()
				local brightenedStart = startColor:Lerp(Color3.new(1, 1, 1), 0.15)
				local brightenedEnd = endColor:Lerp(Color3.new(1, 1, 1), 0.15)
				Tween(gradient, {
					Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0, brightenedStart),
						ColorSequenceKeypoint.new(1, brightenedEnd)
					})
				}, 0.2)
				if shine then Tween(shine, {BackgroundTransparency = 0.7}, 0.2) end
				Tween(btnFrame, {Position = UDim2.new(0, 2, 0, btnFrame.Position.Y.Offset)}, 0.1)
			end)
			
			btnFrame.MouseLeave:Connect(function()
				Tween(gradient, {Color = originalColor}, 0.2)
				if shine then Tween(shine, {BackgroundTransparency = 0.85}, 0.2) end
				Tween(btnFrame, {Position = UDim2.new(0, 0, 0, btnFrame.Position.Y.Offset)}, 0.1)
			end)
			
			btnFrame.MouseButton1Click:Connect(function()
				Tween(btnFrame, {Size = UDim2.new(0.97, 0, 0, 46)}, 0.08, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
				task.delay(0.08, function()
					Tween(btnFrame, {Size = UDim2.new(1, 0, 0, 48)}, 0.12, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
				end)
				pcall(callback)
			end)
			
			Apply3DEffect(btnFrame, 4)
		end

		function tab:CreateToggle(options)
			local togName = options.Name or "Toggle"
			local default = options.Default or false
			local callback = options.Callback or function() end
			
			local state = default
			local toggleId = togName .. "_" .. tostring(math.random(1000, 9999))
			
			-- Store in window's active toggles registry
			window.ActiveToggles[toggleId] = { State = state, Callback = callback }
			
			local toggleFrame = Create("TextButton", {
				Name = togName,
				Parent = tab.Container,
				Size = UDim2.new(1, 0, 0, 40),
				BackgroundColor3 = CONFIG.Theme.Surface,
				Text = "",
				AutoButtonColor = false,
				LayoutOrder = #tab.Container:GetChildren()
			}, {
				Create("UICorner", { CornerRadius = UDim.new(0, 8) }),
				Create("Frame", {
					Name = "Highlight",
					Size = UDim2.new(1, 0, 0.5, 0),
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					BackgroundTransparency = 0.92,
					BorderSizePixel = 0
				}, { Create("UICorner", { CornerRadius = UDim.new(0, 8) }) }),
				Create("TextLabel", {
					Position = UDim2.new(0, 12, 0, 0),
					Size = UDim2.new(1, -70, 1, 0),
					BackgroundTransparency = 1,
					Text = togName,
					TextColor3 = state and CONFIG.Theme.Text or CONFIG.Theme.TextMuted,
					Font = Enum.Font.GothamMedium,
					TextSize = 14,
					TextXAlignment = Enum.TextXAlignment.Left
				})
			})
			
			local titleText = toggleFrame:FindFirstChildOfClass("TextLabel")
			local highlight = toggleFrame:FindFirstChild("Highlight")
			
			local switchBg = Create("Frame", {
				Parent = toggleFrame,
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, -12, 0.5, 0),
				Size = UDim2.new(0, 44, 0, 22),
				BackgroundColor3 = state and CONFIG.Theme.Accent or CONFIG.Theme.Background
			}, { 
				Create("UICorner", { CornerRadius = UDim.new(1, 0) }),
				Create("UIStroke", { Color = state and CONFIG.Theme.AccentHover or CONFIG.Theme.Border, Thickness = 2 })
			})
			
			local switchKnob = Create("Frame", {
				Parent = switchBg,
				AnchorPoint = Vector2.new(0, 0.5),
				Position = UDim2.new(0, state and 24 or 2, 0.5, 0),
				Size = UDim2.new(0, 16, 0, 16),
				BackgroundColor3 = Color3.new(1, 1, 1)
			}, { Create("UICorner", { CornerRadius = UDim.new(1, 0) }) })
			
			-- 3D shadow for knob
			Create("Frame", {
				Parent = switchKnob,
				Position = UDim2.new(0, 2, 0, 2),
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundColor3 = Color3.fromRGB(0, 0, 0),
				BackgroundTransparency = 0.6,
				ZIndex = -1
			}, { Create("UICorner", { CornerRadius = UDim.new(1, 0) }) })
			
			local function UpdateToggle()
				if not CrimsonUI.IsRunning then return end
				
				Tween(switchBg, {BackgroundColor3 = state and CONFIG.Theme.Accent or CONFIG.Theme.Background}, 0.2)
				Tween(switchKnob, {Position = UDim2.new(0, state and 24 or 2, 0.5, 0)}, 0.2, Enum.EasingStyle.Back)
				Tween(titleText, {TextColor3 = state and CONFIG.Theme.Text or CONFIG.Theme.TextMuted}, 0.2)
				
				if highlight then
					Tween(highlight, {BackgroundTransparency = state and 0.8 or 0.92}, 0.2)
				end
				
				window.ActiveToggles[toggleId].State = state
				pcall(callback, state)
			end
			
			toggleFrame.MouseButton1Click:Connect(function()
				state = not state
				UpdateToggle()
			end)
			
			toggleFrame.MouseEnter:Connect(function()
				Tween(toggleFrame, {BackgroundColor3 = CONFIG.Theme.SurfaceHover}, 0.2)
			end)
			toggleFrame.MouseLeave:Connect(function()
				Tween(toggleFrame, {BackgroundColor3 = CONFIG.Theme.Surface}, 0.2)
			end)
			
			Apply3DEffect(toggleFrame, 2)
			
			if state then UpdateToggle() end
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
				Size = UDim2.new(1, 0, 0, 55),
				BackgroundColor3 = CONFIG.Theme.Surface,
				BorderSizePixel = 0,
				LayoutOrder = #tab.Container:GetChildren()
			}, {
				Create("UICorner", { CornerRadius = UDim.new(0, 8) }),
				Create("Frame", {
					Name = "Highlight",
					Size = UDim2.new(1, 0, 0.5, 0),
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					BackgroundTransparency = 0.92,
					BorderSizePixel = 0
				}, { Create("UICorner", { CornerRadius = UDim.new(0, 8) }) })
			})
			
			local titleText = Create("TextLabel", {
				Parent = sliderFrame,
				Position = UDim2.new(0, 12, 0, 8),
				Size = UDim2.new(0.6, 0, 0, 16),
				BackgroundTransparency = 1,
				Text = slName,
				TextColor3 = CONFIG.Theme.TextMuted,
				Font = Enum.Font.GothamMedium,
				TextSize = 13,
				TextXAlignment = Enum.TextXAlignment.Left
			})
			
			local valText = Create("TextLabel", {
				Parent = sliderFrame,
				Position = UDim2.new(0.6, 0, 0, 8),
				Size = UDim2.new(0.4, -12, 0, 16),
				BackgroundTransparency = 1,
				Text = tostring(val),
				TextColor3 = CONFIG.Theme.Accent,
				Font = Enum.Font.GothamBold,
				TextSize = 13,
				TextXAlignment = Enum.TextXAlignment.Right
			})
			
			local track = Create("TextButton", {
				Parent = sliderFrame,
				Position = UDim2.new(0, 12, 0, 32),
				Size = UDim2.new(1, -24, 0, 8),
				BackgroundColor3 = CONFIG.Theme.Background,
				Text = "",
				AutoButtonColor = false
			}, { 
				Create("UICorner", { CornerRadius = UDim.new(1, 0) }),
				Create("UIStroke", { Color = CONFIG.Theme.Border, Thickness = 1 })
			})
			
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
				Size = UDim2.new(0, 14, 0, 14),
				BackgroundColor3 = Color3.new(1, 1, 1)
			}, { 
				Create("UICorner", { CornerRadius = UDim.new(1, 0) }),
				Create("UIStroke", { Color = CONFIG.Theme.Accent, Thickness = 2 }),
				-- 3D shadow
				Create("Frame", {
					Position = UDim2.new(0, 2, 0, 2),
					Size = UDim2.new(1, 0, 1, 0),
					BackgroundColor3 = Color3.fromRGB(0, 0, 0),
					BackgroundTransparency = 0.5,
					ZIndex = -1
				}, { Create("UICorner", { CornerRadius = UDim.new(1, 0) }) })
			})
			
			local dragging = false
			
			local function UpdateSlider(input)
				if not CrimsonUI.IsRunning then return end
				local percent = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
				val = math.floor(min + (max - min) * percent)
				valText.Text = tostring(val)
				Tween(fill, {Size = UDim2.new(percent, 0, 1, 0)}, 0.1)
				pcall(callback, val)
			end
			
			track.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					dragging = true
					UpdateSlider(input)
				end
			end)
			
			local slideEndConn = UserInputService.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					dragging = false
				end
			end)
			table.insert(CrimsonUI.ActiveConnections, slideEndConn)
			
			local slideChangeConn = UserInputService.InputChanged:Connect(function(input)
				if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
					UpdateSlider(input)
				end
			end)
			table.insert(CrimsonUI.ActiveConnections, slideChangeConn)
			
			Apply3DEffect(sliderFrame, 2)
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
				Size = UDim2.new(1, 0, 0, 40),
				BackgroundColor3 = CONFIG.Theme.Surface,
				ClipsDescendants = true,
				LayoutOrder = #tab.Container:GetChildren()
			}, {
				Create("UICorner", { CornerRadius = UDim.new(0, 8) }),
				Create("Frame", {
					Name = "Highlight",
					Size = UDim2.new(1, 0, 0.5, 0),
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					BackgroundTransparency = 0.92,
					BorderSizePixel = 0
				}, { Create("UICorner", { CornerRadius = UDim.new(0, 8) }) })
			})
			
			local headerBtn = Create("TextButton", {
				Parent = dropFrame,
				Size = UDim2.new(1, 0, 0, 40),
				BackgroundTransparency = 1,
				Text = ""
			})
			
			Create("TextLabel", {
				Parent = headerBtn,
				Position = UDim2.new(0, 12, 0, 0),
				Size = UDim2.new(0.4, 0, 1, 0),
				BackgroundTransparency = 1,
				Text = dropName,
				TextColor3 = CONFIG.Theme.TextMuted,
				Font = Enum.Font.GothamMedium,
				TextSize = 14,
				TextXAlignment = Enum.TextXAlignment.Left
			})
			
			local selectedText = Create("TextLabel", {
				Parent = headerBtn,
				Position = UDim2.new(0.4, 0, 0, 0),
				Size = UDim2.new(0.6, -35, 1, 0),
				BackgroundTransparency = 1,
				Text = selected,
				TextColor3 = CONFIG.Theme.Accent,
				Font = Enum.Font.GothamBold,
				TextSize = 13,
				TextXAlignment = Enum.TextXAlignment.Right
			})
			
			local arrow = Create("TextLabel", {
				Parent = headerBtn,
				Position = UDim2.new(1, -30, 0, 0),
				Size = UDim2.new(0, 20, 1, 0),
				BackgroundTransparency = 1,
				Text = "▼",
				TextColor3 = CONFIG.Theme.TextDark,
				Font = Enum.Font.GothamBold,
				TextSize = 12
			})
			
			local listFrame = Create("Frame", {
				Parent = dropFrame,
				Position = UDim2.new(0, 0, 0, 40),
				Size = UDim2.new(1, 0, 1, -40),
				BackgroundTransparency = 1
			}, {
				Create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 2) })
			})
			
			local function UpdateList()
				for _, v in ipairs(listFrame:GetChildren()) do
					if v:IsA("TextButton") then v:Destroy() end
				end
				
				for i, opt in ipairs(list) do
					local optBtn = Create("TextButton", {
						Parent = listFrame,
						Size = UDim2.new(1, 0, 0, 32),
						BackgroundColor3 = CONFIG.Theme.Surface,
						BorderSizePixel = 0,
						Text = opt,
						TextColor3 = opt == selected and CONFIG.Theme.Accent or CONFIG.Theme.Text,
						Font = Enum.Font.Gotham,
						TextSize = 13,
						AutoButtonColor = false,
						LayoutOrder = i
					}, {
						Create("UICorner", { CornerRadius = UDim.new(0, 6) })
					})
					
					optBtn.MouseEnter:Connect(function()
						if opt ~= selected then 
							Tween(optBtn, {BackgroundColor3 = CONFIG.Theme.SurfaceHover}, 0.15)
							Tween(optBtn, {Position = UDim2.new(0, 4, 0, optBtn.Position.Y.Offset)}, 0.1)
						end
					end)
					optBtn.MouseLeave:Connect(function()
						Tween(optBtn, {BackgroundColor3 = CONFIG.Theme.Surface}, 0.15)
						Tween(optBtn, {Position = UDim2.new(0, 0, 0, optBtn.Position.Y.Offset)}, 0.1)
					end)
					
					optBtn.MouseButton1Click:Connect(function()
						selected = opt
						selectedText.Text = selected
						pcall(callback, selected)
						
						expanded = false
						Tween(arrow, {Rotation = 0}, 0.2)
						Tween(dropFrame, {Size = UDim2.new(1, 0, 0, 40)}, 0.2)
						UpdateList()
					end)
					
					Apply3DEffect(optBtn, 1)
				end
			end
			
			headerBtn.MouseButton1Click:Connect(function()
				expanded = not expanded
				Tween(arrow, {Rotation = expanded and 180 or 0}, 0.2)
				if expanded then
					UpdateList()
					Tween(dropFrame, {Size = UDim2.new(1, 0, 0, 40 + (#list * 34))}, 0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
				else
					Tween(dropFrame, {Size = UDim2.new(1, 0, 0, 40)}, 0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
				end
			end)
			
			Apply3DEffect(dropFrame, 2)
		end

		function tab:CreateLabel(text)
			Create("TextLabel", {
				Parent = tab.Container,
				Size = UDim2.new(1, 0, 0, 22),
				BackgroundTransparency = 1,
				Text = text,
				TextColor3 = CONFIG.Theme.TextMuted,
				Font = Enum.Font.GothamMedium,
				TextSize = 13,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextWrapped = true,
				LayoutOrder = #tab.Container:GetChildren()
			})
		end
		
		function tab:CreateInput(options)
			local inpName = options.Name or "Input"
			local placeholder = options.Placeholder or "Type here..."
			local callback = options.Callback or function() end
			
			local inputFrame = Create("Frame", {
				Parent = tab.Container,
				Size = UDim2.new(1, 0, 0, 55),
				BackgroundColor3 = CONFIG.Theme.Surface,
				BorderSizePixel = 0,
				LayoutOrder = #tab.Container:GetChildren()
			}, {
				Create("UICorner", { CornerRadius = UDim.new(0, 8) }),
				Create("Frame", {
					Name = "Highlight",
					Size = UDim2.new(1, 0, 0.5, 0),
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					BackgroundTransparency = 0.92,
					BorderSizePixel = 0
				}, { Create("UICorner", { CornerRadius = UDim.new(0, 8) }) })
			})
			
			Create("TextLabel", {
				Parent = inputFrame,
				Position = UDim2.new(0, 12, 0, 6),
				Size = UDim2.new(1, -24, 0, 16),
				BackgroundTransparency = 1,
				Text = inpName,
				TextColor3 = CONFIG.Theme.TextMuted,
				Font = Enum.Font.GothamMedium,
				TextSize = 13,
				TextXAlignment = Enum.TextXAlignment.Left
			})
			
			local textBox = Create("TextBox", {
				Parent = inputFrame,
				Position = UDim2.new(0, 12, 0, 26),
				Size = UDim2.new(1, -24, 0, 22),
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
				Create("UICorner", { CornerRadius = UDim.new(0, 6) }),
				Create("UIPadding", { PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8) }),
				Create("UIStroke", { Color = CONFIG.Theme.Border, Thickness = 1 })
			})
			
			textBox.FocusLost:Connect(function()
				pcall(callback, textBox.Text)
			end)
			
			textBox.Focused:Connect(function()
				Tween(textBox, {BackgroundColor3 = CONFIG.Theme.SurfaceHover}, 0.2)
				Tween(textBox:FindFirstChildOfClass("UIStroke"), {Color = CONFIG.Theme.Accent}, 0.2)
			end)
			
			textBox.FocusLost:Connect(function()
				Tween(textBox, {BackgroundColor3 = CONFIG.Theme.Background}, 0.2)
				Tween(textBox:FindFirstChildOfClass("UIStroke"), {Color = CONFIG.Theme.Border}, 0.2)
			end)
			
			Apply3DEffect(inputFrame, 2)
		end

		return tab
	end

	return window
end

return CrimsonUI

-- INSTALLATION: local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/RealBatu20/AI-Scripts-2025/refs/heads/main/crimsonui.lua"))()
