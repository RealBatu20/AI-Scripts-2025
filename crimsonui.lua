--!strict
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")

local CrimsonUI = {
	Version = "2.0.0",
	Windows = {},
	ActiveConnections = {},
	ActiveToggles = {} -- Track active toggle states for cleanup
}

-- Aspect Ratio Presets
local ASPECT_RATIOS = {
	{ Name = "16:9", Ratio = 16/9, Desc = "Widescreen" },
	{ Name = "9:16", Ratio = 9/16, Desc = "Vertical" },
	{ Name = "1:1", Ratio = 1, Desc = "Square" },
	{ Name = "4:3", Ratio = 4/3, Desc = "Classic" },
	{ Name = "3:2", Ratio = 3/2, Desc = "Photography" }
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
	Effects3D = {
		ShadowOffset = 4,
		ShadowTransparency = 0.7,
		ShadowBlur = 0.05,
		Depth = 3
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

-- 3D Effect: Add depth shadow to UI elements
local function Add3DEffect(parent, depth)
	depth = depth or CONFIG.Effects3D.Depth
	
	-- Bottom-right shadow for depth
	local shadow = Create("Frame", {
		Name = "DepthShadow",
		Parent = parent,
		Size = UDim2.new(1, 0, 1, 0),
		Position = UDim2.new(0, depth, 0, depth),
		BackgroundColor3 = Color3.new(0, 0, 0),
		BackgroundTransparency = CONFIG.Effects3D.ShadowTransparency,
		BorderSizePixel = 0,
		ZIndex = parent.ZIndex - 1
	})
	
	-- Match corner radius if parent has UICorner
	local parentCorner = parent:FindFirstChildOfClass("UICorner")
	if parentCorner then
		Create("UICorner", {
			CornerRadius = parentCorner.CornerRadius,
			Parent = shadow
		})
	end
	
	-- Clip shadow to parent bounds if needed
	shadow.ClipsDescendants = false
	
	return shadow
end

-- 3D Button Effect with press animation
local function Add3DButtonEffect(button, depth)
	depth = depth or 4
	
	local shadow = Create("Frame", {
		Name = "ButtonDepth",
		Parent = button,
		Size = UDim2.new(1, 0, 1, 0),
		Position = UDim2.new(0, depth, 0, depth),
		BackgroundColor3 = Color3.new(0, 0, 0),
		BackgroundTransparency = 0.6,
		BorderSizePixel = 0,
		ZIndex = button.ZIndex - 1
	})
	
	local corner = button:FindFirstChildOfClass("UICorner")
	if corner then
		Create("UICorner", {
			CornerRadius = corner.CornerRadius,
			Parent = shadow
		})
	end
	
	-- Press effect
	button.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			Tween(button, {Position = UDim2.new(0, depth, 0, depth)}, 0.05)
			Tween(shadow, {Position = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 0.8}, 0.05)
		end
	end)
	
	button.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			Tween(button, {Position = UDim2.new(0, 0, 0, 0)}, 0.1, Enum.EasingStyle.Back)
			Tween(shadow, {Position = UDim2.new(0, depth, 0, depth), BackgroundTransparency = 0.6}, 0.1)
		end
	end)
	
	return shadow
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

-- Cleanup function for connections and toggles
local function Cleanup()
	-- Disconnect all active connections
	for _, conn in ipairs(CrimsonUI.ActiveConnections) do
		pcall(function() conn:Disconnect() end)
	end
	CrimsonUI.ActiveConnections = {}
	
	-- Turn off all active toggles
	for toggleKey, toggleData in pairs(CrimsonUI.ActiveToggles) do
		if toggleData.SetState then
			pcall(function() toggleData.SetState(false) end)
		end
	end
	CrimsonUI.ActiveToggles = {}
	
	-- Stop any running loops
	if getgenv().CrimsonUI_Running then
		getgenv().CrimsonUI_Running = false
	end
end

getgenv().CrimsonUI_Cleanup = Cleanup

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
getgenv().CrimsonUI_Running = true

function CrimsonUI:CreateWindow(options)
	options = options or {}
	local title = options.Title or "Crimson Window"
	local icon = options.Icon or "🎲"
	local baseSize = options.Size or Vector2.new(300, 380)
	
	local window = {
		Tabs = {},
		CurrentTab = nil,
		IsMinimized = false,
		CurrentAspectIndex = 1,
		BaseSize = baseSize
	}
	
	-- Calculate size based on aspect ratio
	local function GetSizeForAspect(aspectIndex)
		local ratio = ASPECT_RATIOS[aspectIndex].Ratio
		local width = math.sqrt(baseSize.X * baseSize.Y * ratio)
		local height = width / ratio
		return Vector2.new(math.clamp(width, 250, 600), math.clamp(height, 200, 600))
	end
	
	local currentSize = GetSizeForAspect(1)
	
	-- Main Frame (No shadow)
	local mainFrame = Create("Frame", {
		Name = "MainFrame",
		Parent = screenGui,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(0, currentSize.X, 0, 0), -- Start collapsed
		BackgroundColor3 = CONFIG.Theme.Background,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		ZIndex = 1
	}, {
		Create("UICorner", { CornerRadius = UDim.new(0, 12) }),
		Create("UIStroke", { Color = CONFIG.Theme.Border, Thickness = 1.5 })
	})
	
	-- Add 3D effect to main frame
	Add3DEffect(mainFrame, 6)
	
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
		Create("Frame", { -- Fix bottom corners of header
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
			Padding = UDim.new(0, 8)
		})
	})
	
	-- Aspect Ratio Button (cycles through presets)
	local aspectBtn = Create("TextButton", {
		Name = "AspectRatio",
		Parent = controls,
		Size = UDim2.new(0, 45, 0, 30),
		BackgroundColor3 = CONFIG.Theme.SurfaceHover,
		Text = ASPECT_RATIOS[1].Name,
		TextColor3 = CONFIG.Theme.Text,
		Font = Enum.Font.GothamBold,
		TextSize = 12,
		AutoButtonColor = false,
		LayoutOrder = 1,
		ZIndex = 4
	}, { Create("UICorner", { CornerRadius = UDim.new(0, 6) }) })
	
	-- Add 3D effect to aspect button
	Add3DButtonEffect(aspectBtn, 3)
	
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
		LayoutOrder = 2,
		ZIndex = 4
	}, { Create("UICorner", { CornerRadius = UDim.new(0, 8) }) })
	
	Add3DButtonEffect(minimizeBtn, 3)
	
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
		LayoutOrder = 3,
		ZIndex = 4
	}, { Create("UICorner", { CornerRadius = UDim.new(0, 8) }) })
	
	Add3DButtonEffect(closeBtn, 3)
	
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
			-- Prevent dragging if clicking controls
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

	table.insert(CrimsonUI.ActiveConnections, UserInputService.InputChanged:Connect(function(input)
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
	end))

	table.insert(CrimsonUI.ActiveConnections, UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			if not isDragging then return end
			isDragging = false
			
			-- If minimized, clicking the header (without dragging) maximizes it
			if window.IsMinimized and not hasDragged and (tick() - dragStartTime) < CONFIG.Drag.MaxClickTime then
				window:Maximize()
			end
		end
	end))
	
	-- Aspect Ratio Changer
	aspectBtn.MouseButton1Click:Connect(function()
		window.CurrentAspectIndex = (window.CurrentAspectIndex % #ASPECT_RATIOS) + 1
		local aspect = ASPECT_RATIOS[window.CurrentAspectIndex]
		aspectBtn.Text = aspect.Name
		
		-- Smooth transition to new aspect ratio
		local newSize = GetSizeForAspect(window.CurrentAspectIndex)
		currentSize = newSize
		
		if not window.IsMinimized then
			Tween(mainFrame, {Size = UDim2.new(0, newSize.X, 0, newSize.Y)}, 0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
		else
			-- Update minimized size reference
			originalSize = UDim2.new(0, newSize.X, 0, newSize.Y)
			minShadowSize = UDim2.new(0, newSize.X + 20, 0, 45 + 20)
		end
	end)
	
	-- Button Hovers
	local function setupHover(btn, normalColor, hoverColor)
		btn.MouseEnter:Connect(function() Tween(btn, {BackgroundColor3 = hoverColor}, 0.2) end)
		btn.MouseLeave:Connect(function() Tween(btn, {BackgroundColor3 = normalColor}, 0.2) end)
	end
	
	setupHover(minimizeBtn, CONFIG.Theme.Minimize, CONFIG.Theme.Minimize:Lerp(Color3.new(1,1,1), 0.15))
	setupHover(closeBtn, CONFIG.Theme.Close, CONFIG.Theme.Close:Lerp(Color3.new(1,1,1), 0.15))
	setupHover(aspectBtn, CONFIG.Theme.SurfaceHover, CONFIG.Theme.SurfaceHover:Lerp(Color3.new(1,1,1), 0.1))
	
	local originalSize = UDim2.new(0, currentSize.X, 0, currentSize.Y)
	local minSize = UDim2.new(0, currentSize.X, 0, 45)

	function window:Minimize()
		window.IsMinimized = true
		minimizeBtn.Text = "+"
		tabContainer.Visible = false
		contentContainer.Visible = false
		
		-- Animation: Collapse upward into title bar
		local targetHeight = 45
		local currentHeight = mainFrame.AbsoluteSize.Y
		
		-- Calculate position shift to make it look like it's collapsing into the header
		local posTween = Tween(mainFrame, {
			Position = UDim2.new(
				mainFrame.Position.X.Scale, 
				mainFrame.Position.X.Offset, 
				mainFrame.Position.Y.Scale, 
				mainFrame.Position.Y.Offset - (currentHeight - targetHeight) / 2
			)
		}, CONFIG.Animation.Speed, Enum.EasingStyle.Back, Enum.EasingDirection.In)
		
		local sizeTween = Tween(mainFrame, {Size = minSize}, CONFIG.Animation.Speed, Enum.EasingStyle.Back, Enum.EasingDirection.In)
	end
	
	function window:Maximize()
		window.IsMinimized = false
		minimizeBtn.Text = "−"
		
		-- Animation: Expand downward from title bar
		Tween(mainFrame, {Size = originalSize}, CONFIG.Animation.Speed, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
		Tween(mainFrame, {
			Position = UDim2.new(0.5, 0, 0.5, 0)
		}, CONFIG.Animation.Speed, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
		
		task.delay(0.15, function()
			tabContainer.Visible = true
			contentContainer.Visible = true
		end)
	end
	
	minimizeBtn.MouseButton1Click:Connect(function()
		if window.IsMinimized then window:Maximize() else window:Minimize() end
	end)
	
	closeBtn.MouseButton1Click:Connect(function()
		-- Cleanup before closing
		Cleanup()
		
		-- Close animation: shrink and fade upward
		Tween(mainFrame, {
			Size = UDim2.new(0, 0, 0, 0),
			Position = UDim2.new(mainFrame.Position.X.Scale, mainFrame.Position.X.Offset, mainFrame.Position.Y.Scale, mainFrame.Position.Y.Offset - 100)
		}, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In)
		
		task.delay(0.35, function() 
			screenGui:Destroy() 
			getgenv().CrimsonUI_Instance = nil
			getgenv().CrimsonUI_Cleanup = nil
		end)
	end)
	
	-- Intro Anim
	Tween(mainFrame, {Size = originalSize}, 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

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
			Create("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10) })
		})
		
		-- Add 3D effect to tab button
		Add3DButtonEffect(tabBtn, 2)
		
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
				end
			end
			for _, child in ipairs(contentContainer:GetChildren()) do
				if child:IsA("ScrollingFrame") then child.Visible = false end
			end
			
			Tween(tabBtn, {BackgroundColor3 = CONFIG.Theme.Accent, TextColor3 = CONFIG.Theme.Text}, 0.2)
			scrollFrame.Visible = true
		end
		
		tabBtn.MouseButton1Click:Connect(SelectThisTab)
		
		-- Auto-select first tab
		if #tabContainer:GetChildren() == 2 then -- UIListLayout + 1st Button
			SelectThisTab()
		end

		-- API: Elements with 3D effects
		function tab:CreateButton(options)
			local btnName = options.Name or "Button"
			local callback = options.Callback or function() end
			
			-- Generate random vibrant gradient colors
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
				ZIndex = 5
			}, {
				Create("UICorner", { CornerRadius = UDim.new(0, 10) }),
				Create("UIGradient", {
					Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0, startColor),
						ColorSequenceKeypoint.new(1, endColor)
					}),
					Rotation = 0
				}),
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
					TextYAlignment = Enum.TextYAlignment.Center,
					ZIndex = 6
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
					TextYAlignment = Enum.TextYAlignment.Center,
					ZIndex = 6
				})
			})
			
			-- Add 3D depth effect
			Add3DButtonEffect(btnFrame, 4)
			
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
				pcall(callback)
			end)
		end

		function tab:CreateToggle(options)
			local togName = options.Name or "Toggle"
			local default = options.Default or false
			local callback = options.Callback or function() end
			
			local state = default
			local toggleKey = tostring(math.random(100000, 999999))
			
			local toggleFrame = Create("TextButton", {
				Name = togName,
				Parent = tab.Container,
				Size = UDim2.new(1, 0, 0, 40),
				BackgroundColor3 = CONFIG.Theme.Surface,
				Text = "",
				AutoButtonColor = false,
				ZIndex = 5
			}, {
				Create("UICorner", { CornerRadius = UDim.new(0, 8) }),
				Create("TextLabel", {
					Position = UDim2.new(0, 12, 0, 0),
					Size = UDim2.new(1, -70, 1, 0),
					BackgroundTransparency = 1,
					Text = togName,
					TextColor3 = state and CONFIG.Theme.Text or CONFIG.Theme.TextMuted,
					Font = Enum.Font.GothamMedium,
					TextSize = 14,
					TextXAlignment = Enum.TextXAlignment.Left,
					ZIndex = 6
				})
			})
			
			-- Add 3D effect
			Add3DButtonEffect(toggleFrame, 3)
			
			local titleText = toggleFrame:FindFirstChildOfClass("TextLabel")
			
			-- 3D Switch background
			local switchBg = Create("Frame", {
				Parent = toggleFrame,
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, -12, 0.5, 0),
				Size = UDim2.new(0, 44, 0, 22),
				BackgroundColor3 = state and CONFIG.Theme.Accent or CONFIG.Theme.Background,
				ZIndex = 6
			}, { 
				Create("UICorner", { CornerRadius = UDim.new(1, 0) }),
				-- 3D depth for switch
				Create("Frame", {
					Name = "SwitchDepth",
					Size = UDim2.new(1, 0, 1, 0),
					Position = UDim2.new(0, 2, 0, 2),
					BackgroundColor3 = Color3.new(0, 0, 0),
					BackgroundTransparency = 0.7,
					ZIndex = 5
				}, { Create("UICorner", { CornerRadius = UDim.new(1, 0) }) })
			})
			
			-- 3D Knob with shadow
			local knob = Create("Frame", {
				Parent = switchBg,
				AnchorPoint = Vector2.new(0, 0.5),
				Position = UDim2.new(0, state and 24 or 3, 0.5, 0),
				Size = UDim2.new(0, 16, 0, 16),
				BackgroundColor3 = Color3.new(1, 1, 1),
				ZIndex = 7
			}, { 
				Create("UICorner", { CornerRadius = UDim.new(1, 0) }),
				-- Knob shadow for 3D effect
				Create("Frame", {
					Name = "KnobShadow",
					Size = UDim2.new(1, 0, 1, 0),
					Position = UDim2.new(0, 1, 0, 1),
					BackgroundColor3 = Color3.new(0, 0, 0),
					BackgroundTransparency = 0.5,
					ZIndex = 6
				}, { Create("UICorner", { CornerRadius = UDim.new(1, 0) }) })
			})
			
			local function UpdateToggle()
				Tween(switchBg, {BackgroundColor3 = state and CONFIG.Theme.Accent or CONFIG.Theme.Background}, 0.25, Enum.EasingStyle.Quart)
				Tween(knob, {Position = UDim2.new(0, state and 24 or 3, 0.5, 0)}, 0.25, Enum.EasingStyle.Back)
				Tween(titleText, {TextColor3 = state and CONFIG.Theme.Text or CONFIG.Theme.TextMuted}, 0.2)
				pcall(callback, state)
			end
			
			-- Register for cleanup
			CrimsonUI.ActiveToggles[toggleKey] = {
				SetState = function(newState)
					state = newState
					UpdateToggle()
				end,
				GetState = function() return state end
			}
			
			toggleFrame.MouseButton1Click:Connect(function()
				state = not state
				UpdateToggle()
			end)
			
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
				ZIndex = 5
			}, { 
				Create("UICorner", { CornerRadius = UDim.new(0, 8) }),
				-- 3D depth
				Create("Frame", {
					Name = "SliderDepth",
					Size = UDim2.new(1, 0, 1, 0),
					Position = UDim2.new(0, 3, 0, 3),
					BackgroundColor3 = Color3.new(0, 0, 0),
					BackgroundTransparency = 0.6,
					ZIndex = 4
				}, { Create("UICorner", { CornerRadius = UDim.new(0, 8) }) })
			})
			
			local titleText = Create("TextLabel", {
				Parent = sliderFrame,
				Position = UDim2.new(0, 12, 0, 8),
				Size = UDim2.new(0.7, 0, 0, 15),
				BackgroundTransparency = 1,
				Text = slName,
				TextColor3 = CONFIG.Theme.TextMuted,
				Font = Enum.Font.GothamMedium,
				TextSize = 13,
				TextXAlignment = Enum.TextXAlignment.Left,
				ZIndex = 6
			})
			
			local valText = Create("TextLabel", {
				Parent = sliderFrame,
				Position = UDim2.new(0.7, -10, 0, 8),
				Size = UDim2.new(0.3, 0, 0, 15),
				BackgroundTransparency = 1,
				Text = tostring(val),
				TextColor3 = CONFIG.Theme.Text,
				Font = Enum.Font.GothamBold,
				TextSize = 13,
				TextXAlignment = Enum.TextXAlignment.Right,
				ZIndex = 6
			})
			
			-- 3D Track
			local track = Create("TextButton", {
				Parent = sliderFrame,
				Position = UDim2.new(0, 12, 0, 35),
				Size = UDim2.new(1, -24, 0, 8),
				BackgroundColor3 = CONFIG.Theme.Background,
				Text = "",
				AutoButtonColor = false,
				ZIndex = 6
			}, { 
				Create("UICorner", { CornerRadius = UDim.new(1, 0) }),
				-- Track depth
				Create("Frame", {
					Name = "TrackDepth",
					Size = UDim2.new(1, 0, 1, 0),
					Position = UDim2.new(0, 1, 0, 1),
					BackgroundColor3 = Color3.new(0, 0, 0),
					BackgroundTransparency = 0.5,
					ZIndex = 5
				}, { Create("UICorner", { CornerRadius = UDim.new(1, 0) }) })
			})
			
			local fill = Create("Frame", {
				Parent = track,
				Size = UDim2.new((val - min)/(max - min), 0, 1, 0),
				BackgroundColor3 = CONFIG.Theme.Accent,
				BorderSizePixel = 0,
				ZIndex = 7
			}, { Create("UICorner", { CornerRadius = UDim.new(1, 0) }) })
			
			-- 3D Knob with elevated effect
			local knob = Create("Frame", {
				Parent = fill,
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.new(1, 0, 0.5, 0),
				Size = UDim2.new(0, 16, 0, 16),
				BackgroundColor3 = Color3.new(1, 1, 1),
				ZIndex = 8
			}, { 
				Create("UICorner", { CornerRadius = UDim.new(1, 0) }),
				-- Knob shadow/depth
				Create("Frame", {
					Name = "KnobDepth",
					Size = UDim2.new(1, 0, 1, 0),
					Position = UDim2.new(0, 2, 0, 2),
					BackgroundColor3 = Color3.new(0, 0, 0),
					BackgroundTransparency = 0.4,
					ZIndex = 7
				}, { Create("UICorner", { CornerRadius = UDim.new(1, 0) }) })
			})
			
			local dragging = false
			
			local function UpdateSlider(input)
				local percent = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
				val = math.floor(min + (max - min) * percent)
				valText.Text = tostring(val)
				Tween(fill, {Size = UDim2.new(percent, 0, 1, 0)}, 0.05)
				pcall(callback, val)
			end
			
			track.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					dragging = true
					UpdateSlider(input)
					-- Press effect on knob
					Tween(knob, {Size = UDim2.new(0, 14, 0, 14)}, 0.1)
				end
			end)
			
			table.insert(CrimsonUI.ActiveConnections, UserInputService.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					dragging = false
					Tween(knob, {Size = UDim2.new(0, 16, 0, 16)}, 0.1)
				end
			end))
			
			table.insert(CrimsonUI.ActiveConnections, UserInputService.InputChanged:Connect(function(input)
				if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
					UpdateSlider(input)
				end
			end))
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
				ZIndex = 10
			}, { 
				Create("UICorner", { CornerRadius = UDim.new(0, 8) }),
				-- 3D depth
				Create("Frame", {
					Name = "DropdownDepth",
					Size = UDim2.new(1, 0, 1, 0),
					Position = UDim2.new(0, 3, 0, 3),
					BackgroundColor3 = Color3.new(0, 0, 0),
					BackgroundTransparency = 0.6,
					ZIndex = 9
				}, { Create("UICorner", { CornerRadius = UDim.new(0, 8) }) })
			})
			
			local headerBtn = Create("TextButton", {
				Parent = dropFrame,
				Size = UDim2.new(1, 0, 0, 40),
				BackgroundTransparency = 1,
				Text = "",
				ZIndex = 11
			})
			
			Create("TextLabel", {
				Parent = headerBtn,
				Position = UDim2.new(0, 12, 0, 0),
				Size = UDim2.new(0.5, 0, 1, 0),
				BackgroundTransparency = 1,
				Text = dropName,
				TextColor3 = CONFIG.Theme.TextMuted,
				Font = Enum.Font.GothamMedium,
				TextSize = 14,
				TextXAlignment = Enum.TextXAlignment.Left,
				ZIndex = 12
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
				TextXAlignment = Enum.TextXAlignment.Right,
				ZIndex = 12
			})
			
			local arrow = Create("TextLabel", {
				Parent = headerBtn,
				Position = UDim2.new(1, -28, 0, 0),
				Size = UDim2.new(0, 20, 1, 0),
				BackgroundTransparency = 1,
				Text = "▼",
				TextColor3 = CONFIG.Theme.TextDark,
				Font = Enum.Font.GothamBold,
				TextSize = 12,
				ZIndex = 12
			})
			
			local listFrame = Create("Frame", {
				Parent = dropFrame,
				Position = UDim2.new(0, 0, 0, 40),
				Size = UDim2.new(1, 0, 1, -40),
				BackgroundTransparency = 1,
				ZIndex = 11
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
						Size = UDim2.new(1, 0, 0, 32),
						BackgroundColor3 = CONFIG.Theme.Surface,
						BorderSizePixel = 0,
						Text = opt,
						TextColor3 = opt == selected and CONFIG.Theme.Accent or CONFIG.Theme.Text,
						Font = Enum.Font.Gotham,
						TextSize = 13,
						AutoButtonColor = false,
						LayoutOrder = i,
						ZIndex = 12
					})
					
					optBtn.MouseEnter:Connect(function()
						if opt ~= selected then Tween(optBtn, {BackgroundColor3 = CONFIG.Theme.SurfaceHover}, 0.15) end
					end)
					optBtn.MouseLeave:Connect(function()
						Tween(optBtn, {BackgroundColor3 = CONFIG.Theme.Surface}, 0.15)
					end)
					
					optBtn.MouseButton1Click:Connect(function()
						selected = opt
						selectedText.Text = selected
						pcall(callback, selected)
						
						expanded = false
						Tween(arrow, {Rotation = 0}, 0.2)
						Tween(dropFrame, {Size = UDim2.new(1, 0, 0, 40)}, 0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
						UpdateList()
					end)
				end
			end
			
			headerBtn.MouseButton1Click:Connect(function()
				expanded = not expanded
				Tween(arrow, {Rotation = expanded and 180 or 0}, 0.2)
				if expanded then
					UpdateList()
					Tween(dropFrame, {Size = UDim2.new(1, 0, 0, 40 + (#list * 32))}, 0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
				else
					Tween(dropFrame, {Size = UDim2.new(1, 0, 0, 40)}, 0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
				end
			end)
		end

		function tab:CreateLabel(text)
			local label = Create("TextLabel", {
				Parent = tab.Container,
				Size = UDim2.new(1, 0, 0, 22),
				BackgroundTransparency = 1,
				Text = text,
				TextColor3 = CONFIG.Theme.TextMuted,
				Font = Enum.Font.GothamMedium,
				TextSize = 13,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextWrapped = true,
				ZIndex = 5
			})
			
			-- Subtle 3D text shadow effect
			Create("TextLabel", {
				Parent = label,
				Size = UDim2.new(1, 0, 1, 0),
				Position = UDim2.new(0, 1, 0, 1),
				BackgroundTransparency = 1,
				Text = text,
				TextColor3 = Color3.new(0, 0, 0),
				TextTransparency = 0.8,
				Font = Enum.Font.GothamMedium,
				TextSize = 13,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextWrapped = true,
				ZIndex = 4
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
				ZIndex = 5
			}, { 
				Create("UICorner", { CornerRadius = UDim.new(0, 8) }),
				-- 3D depth
				Create("Frame", {
					Name = "InputDepth",
					Size = UDim2.new(1, 0, 1, 0),
					Position = UDim2.new(0, 3, 0, 3),
					BackgroundColor3 = Color3.new(0, 0, 0),
					BackgroundTransparency = 0.6,
					ZIndex = 4
				}, { Create("UICorner", { CornerRadius = UDim.new(0, 8) }) })
			})
			
			Create("TextLabel", {
				Parent = inputFrame,
				Position = UDim2.new(0, 12, 0, 8),
				Size = UDim2.new(1, -20, 0, 15),
				BackgroundTransparency = 1,
				Text = inpName,
				TextColor3 = CONFIG.Theme.TextMuted,
				Font = Enum.Font.GothamMedium,
				TextSize = 13,
				TextXAlignment = Enum.TextXAlignment.Left,
				ZIndex = 6
			})
			
			-- 3D TextBox with inner shadow effect
			local textBox = Create("TextBox", {
				Parent = inputFrame,
				Position = UDim2.new(0, 12, 0, 28),
				Size = UDim2.new(1, -24, 0, 22),
				BackgroundColor3 = CONFIG.Theme.Background,
				Text = "",
				PlaceholderText = placeholder,
				PlaceholderColor3 = CONFIG.Theme.TextDark,
				TextColor3 = CONFIG.Theme.Text,
				Font = Enum.Font.Gotham,
				TextSize = 13,
				TextXAlignment = Enum.TextXAlignment.Left,
				ClearTextOnFocus = false,
				ZIndex = 6
			}, {
				Create("UICorner", { CornerRadius = UDim.new(0, 4) }),
				Create("UIPadding", { PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8) }),
				-- Inner shadow for depth
				Create("Frame", {
					Name = "InnerShadow",
					Size = UDim2.new(1, 0, 1, 0),
					BackgroundTransparency = 1,
					ZIndex = 5
				}, {
					Create("UICorner", { CornerRadius = UDim.new(0, 4) }),
					Create("UIStroke", { Color = Color3.new(0, 0, 0), Thickness = 1, Transparency = 0.7 })
				})
			})
			
			textBox.FocusLost:Connect(function()
				pcall(callback, textBox.Text)
			end)
		end

		return tab
	end

	return window
end

return CrimsonUI

-- INSTALLATION: local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/RealBatu20/AI-Scripts-2025/refs/heads/main/crimsonui.lua"))()
