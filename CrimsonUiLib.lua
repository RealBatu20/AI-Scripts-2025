--!strict
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")

local CrimsonUI = {
	Version = "2.0.0",
	Windows = {},
	ActiveToggles = {} -- Track active toggles for cleanup
}

-- Aspect Ratio Configuration
local ASPECT_RATIOS = {
	{ Name = "16:9", Ratio = 16/9, Label = "16:9" },
	{ Name = "9:16", Ratio = 9/16, Label = "9:16" },
	{ Name = "1:1", Ratio = 1/1, Label = "1:1" },
	{ Name = "4:3", Ratio = 4/3, Label = "4:3" },
	{ Name = "3:2", Ratio = 3/2, Label = "3:2" }
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
	-- Base height for minimized state (just header)
	HeaderHeight = 45,
	-- Default size reference (will scale based on screen)
	BaseWidth = 350
}

-- Utility to create instances cleanly
local function Create(className: string, properties: {[string]: any}?, children: {Instance}?): Instance
	local inst = Instance.new(className)
	for k, v in pairs(properties or {}) do
		if k ~= "Parent" then (inst :: any)[k] = v end
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
local function Tween(obj: Instance, props: {[string]: any}, time: number?, style: Enum.EasingStyle?, direction: Enum.EasingDirection?): Tween
	time = time or CONFIG.Animation.Speed
	style = style or CONFIG.Animation.Easing
	direction = direction or CONFIG.Animation.Direction
	local tweenInfo = TweenInfo.new(time, style, direction)
	local tween = TweenService:Create(obj, tweenInfo, props)
	tween:Play()
	return tween
end

-- Calculate size based on aspect ratio and screen constraints
local function CalculateSize(aspectRatio: number, screenSize: Vector2, isMinimized: boolean): (number, number)
	if isMinimized then
		-- When minimized, keep aspect ratio but collapse height to header only
		local width = math.min(CONFIG.BaseWidth, screenSize.X * 0.9)
		return width, CONFIG.HeaderHeight
	end
	
	local maxWidth = screenSize.X * 0.9
	local maxHeight = screenSize.Y * 0.9
	
	-- Start with base width and calculate height from aspect ratio
	local width = math.min(CONFIG.BaseWidth, maxWidth)
	local height = width / aspectRatio
	
	-- If height exceeds screen, scale down
	if height > maxHeight then
		height = maxHeight
		width = height * aspectRatio
	end
	
	-- Ensure minimum sizes
	width = math.max(width, 200)
	height = math.max(height, CONFIG.HeaderHeight + 100)
	
	return width, height
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

-- Connection storage for cleanup
local connections: {RBXScriptConnection} = {}
local heartbeatConnections: {RBXScriptConnection} = {}

local function addConnection(conn: RBXScriptConnection)
	table.insert(connections, conn)
	return conn
end

local function addHeartbeat(conn: RBXScriptConnection)
	table.insert(heartbeatConnections, conn)
	return conn
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

function CrimsonUI:CreateWindow(options)
	options = options or {}
	local title = options.Title or "Crimson Window"
	local icon = options.Icon or "🎲"
	
	local window = {
		Tabs = {},
		CurrentTab = nil,
		IsMinimized = false,
		CurrentAspectIndex = 1, -- Default to 16:9
		AspectRatio = ASPECT_RATIOS[1].Ratio,
		Connections = {},
		ActiveToggles = {}, -- Instance-specific toggle tracking
		IsDestroyed = false
	}
	
	-- Get initial screen size
	local screenSize = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1920, 1080)
	local initialWidth, initialHeight = CalculateSize(window.AspectRatio, screenSize, false)
	
	-- Main Frame
	local mainFrame = Create("Frame", {
		Name = "MainFrame",
		Parent = screenGui,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(0, initialWidth, 0, 0), -- Start collapsed for intro
		BackgroundColor3 = CONFIG.Theme.Background,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		ZIndex = 1
	}, {
		Create("UICorner", { CornerRadius = UDim.new(0, 12) }),
		Create("UIStroke", { Color = CONFIG.Theme.Border, Thickness = 1.5 })
	})
	
	window.MainFrame = mainFrame
	
	-- Aspect Ratio Constraint for responsiveness
	local aspectConstraint = Create("UIAspectRatioConstraint", {
		Parent = mainFrame,
		AspectRatio = window.AspectRatio,
		AspectType = Enum.AspectType.FitWithinMaxSize,
		DominantAxis = Enum.DominantAxis.Width
	})
	window.AspectConstraint = aspectConstraint
	
	-- Header
	local header = Create("Frame", {
		Name = "Header",
		Parent = mainFrame,
		Size = UDim2.new(1, 0, 0, CONFIG.HeaderHeight),
		BackgroundColor3 = CONFIG.Theme.Surface,
		BorderSizePixel = 0,
		ZIndex = 2
	}, {
		Create("UICorner", { CornerRadius = UDim.new(0, 12) }),
		Create("Frame", { -- Fix bottom corners of header
			Name = "CornerFix",
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
	
	-- Controls container (Aspect Ratio, Minimize, Close)
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
	
	-- Aspect Ratio Button (cycles through ratios)
	local aspectBtn = Create("TextButton", {
		Name = "AspectRatio",
		Parent = controls,
		Size = UDim2.new(0, 45, 0, 26),
		BackgroundColor3 = CONFIG.Theme.Background,
		Text = ASPECT_RATIOS[1].Label,
		TextColor3 = CONFIG.Theme.Text,
		Font = Enum.Font.GothamBold,
		TextSize = 12,
		AutoButtonColor = false,
		LayoutOrder = 1,
		ZIndex = 4
	}, { 
		Create("UICorner", { CornerRadius = UDim.new(0, 6) }),
		Create("UIStroke", { Color = CONFIG.Theme.Border, Thickness = 1 })
	})
	
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
	
	local tabContainer = Create("Frame", {
		Name = "TabContainer",
		Parent = mainFrame,
		Size = UDim2.new(1, -20, 0, 30),
		Position = UDim2.new(0, 10, 0, CONFIG.HeaderHeight + 10),
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
		Size = UDim2.new(1, -20, 1, -(CONFIG.HeaderHeight + 50)),
		Position = UDim2.new(0, 10, 0, CONFIG.HeaderHeight + 40),
		BackgroundTransparency = 1,
		ZIndex = 2
	})
	
	-- Store references
	window.TabContainer = tabContainer
	window.ContentContainer = contentContainer
	
	-- Drag Logic
	local isDragging = false
	local dragStart, startPos
	local dragStartTime = 0
	local dragStartMousePos = Vector2.zero
	local hasDragged = false

	addConnection(header.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			-- Prevent dragging if clicking controls
			local mousePos = UserInputService:GetMouseLocation()
			local aspectAbs, aspectSize = aspectBtn.AbsolutePosition, aspectBtn.AbsoluteSize
			local minAbs, minSize = minimizeBtn.AbsolutePosition, minimizeBtn.AbsoluteSize
			local closeAbs, closeSize = closeBtn.AbsolutePosition, closeBtn.AbsoluteSize
			
			if (mousePos.X >= aspectAbs.X and mousePos.X <= aspectAbs.X + aspectSize.X and mousePos.Y >= aspectAbs.Y and mousePos.Y <= aspectAbs.Y + aspectSize.Y) or
			   (mousePos.X >= minAbs.X and mousePos.X <= minAbs.X + minSize.X and mousePos.Y >= minAbs.Y and mousePos.Y <= minAbs.Y + minSize.Y) or
			   (mousePos.X >= closeAbs.X and mousePos.X <= closeAbs.X + closeSize.X and mousePos.Y >= closeAbs.Y and mousePos.Y <= closeAbs.Y + closeSize.Y) then
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
	end))

	addConnection(UserInputService.InputChanged:Connect(function(input)
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

	addConnection(UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			if not isDragging then return end
			isDragging = false
			
			-- If minimized, clicking the header (without dragging) maximizes it
			if window.IsMinimized and not hasDragged and (tick() - dragStartTime) < CONFIG.Drag.MaxClickTime then
				window:Maximize()
			end
		end
	end))
	
	-- Button Hovers
	local function setupHover(btn: TextButton, normalColor: Color3, hoverColor: Color3)
		addConnection(btn.MouseEnter:Connect(function() 
			Tween(btn, {BackgroundColor3 = hoverColor}, 0.2) 
		end))
		addConnection(btn.MouseLeave:Connect(function() 
			Tween(btn, {BackgroundColor3 = normalColor}, 0.2) 
		end))
	end
	
	setupHover(aspectBtn, CONFIG.Theme.Background, CONFIG.Theme.SurfaceHover)
	setupHover(minimizeBtn, CONFIG.Theme.Minimize, CONFIG.Theme.Minimize:Lerp(Color3.new(1,1,1), 0.15))
	setupHover(closeBtn, CONFIG.Theme.Close, CONFIG.Theme.Close:Lerp(Color3.new(1,1,1), 0.15))
	
	-- Aspect Ratio Switching
	addConnection(aspectBtn.MouseButton1Click:Connect(function()
		if window.IsMinimized then return end -- Don't switch while minimized
		
		window.CurrentAspectIndex = (window.CurrentAspectIndex % #ASPECT_RATIOS) + 1
		local newAspect = ASPECT_RATIOS[window.CurrentAspectIndex]
		window.AspectRatio = newAspect.Ratio
		
		-- Update button text
		aspectBtn.Text = newAspect.Label
		
		-- Animate aspect ratio change
		local currentScreenSize = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1920, 1080)
		local newWidth, newHeight = CalculateSize(window.AspectRatio, currentScreenSize, false)
		
		-- Smooth transition
		Tween(aspectConstraint, {AspectRatio = window.AspectRatio}, 0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
		Tween(mainFrame, {
			Size = UDim2.new(0, newWidth, 0, newHeight)
		}, 0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
	end))
	
	-- Minimize/Maximize with smooth aspect-ratio-preserving animations
	function window:Minimize()
		if window.IsMinimized then return end
		window.IsMinimized = true
		minimizeBtn.Text = "+"
		tabContainer.Visible = false
		contentContainer.Visible = false
		
		-- Calculate minimized size (keep width, collapse to header height)
		local currentWidth = mainFrame.AbsoluteSize.X
		local minimizedHeight = CONFIG.HeaderHeight
		
		-- Animate up into title bar (scale Y to 0 from bottom, or move up while shrinking)
		-- We'll shrink height while maintaining position anchor
		Tween(mainFrame, {
			Size = UDim2.new(0, currentWidth, 0, minimizedHeight)
		}, CONFIG.Animation.Speed, Enum.EasingStyle.Back, Enum.EasingDirection.In)
		
		-- Hide content immediately for cleaner effect
		task.delay(CONFIG.Animation.Speed * 0.5, function()
			if window.IsDestroyed then return end
			header:FindFirstChild("CornerFix").Visible = true
		end)
	end
	
	function window:Maximize()
		if not window.IsMinimized then return end
		window.IsMinimized = false
		minimizeBtn.Text = "−"
		
		-- Calculate maximized size based on current aspect ratio
		local currentScreenSize = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1920, 1080)
		local newWidth, newHeight = CalculateSize(window.AspectRatio, currentScreenSize, false)
		
		-- Animate back to full size
		Tween(mainFrame, {
			Size = UDim2.new(0, newWidth, 0, newHeight)
		}, CONFIG.Animation.Speed, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
		
		task.delay(CONFIG.Animation.Speed * 0.3, function()
			if window.IsDestroyed then return end
			tabContainer.Visible = true
			contentContainer.Visible = true
		end)
	end
	
	addConnection(minimizeBtn.MouseButton1Click:Connect(function()
		if window.IsMinimized then 
			window:Maximize() 
		else 
			window:Minimize() 
		end
	end))
	
	-- Cleanup function - destroys GUI and stops all scripts
	function window:Destroy()
		if window.IsDestroyed then return end
		window.IsDestroyed = true
		
		-- Turn off all active toggles
		for toggleId, toggleData in pairs(window.ActiveToggles) do
			if toggleData.SetState then
				pcall(function() toggleData.SetState(false) end)
			end
		end
		
		-- Disconnect all connections
		for _, conn in ipairs(window.Connections or {}) do
			pcall(function() conn:Disconnect() end)
		end
		
		-- Animate out
		Tween(mainFrame, {
			Size = UDim2.new(0, 0, 0, 0),
			Position = UDim2.new(mainFrame.Position.X.Scale, mainFrame.Position.X.Offset, mainFrame.Position.Y.Scale, mainFrame.Position.Y.Offset + 50)
		}, 0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
		
		task.delay(0.3, function()
			if screenGui and screenGui.Parent then
				screenGui:Destroy()
			end
			-- Remove from global
			if getgenv().CrimsonUI_Instance == screenGui then
				getgenv().CrimsonUI_Instance = nil
			end
		end)
	end
	
	addConnection(closeBtn.MouseButton1Click:Connect(function()
		window:Destroy()
	end))
	
	-- Responsive handling - adjust size when screen changes
	addConnection(workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
		if window.IsDestroyed or window.IsMinimized then return end
		
		local newScreenSize = workspace.CurrentCamera.ViewportSize
		local newWidth, newHeight = CalculateSize(window.AspectRatio, newScreenSize, false)
		
		Tween(mainFrame, {
			Size = UDim2.new(0, newWidth, 0, newHeight)
		}, 0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
	end))
	
	-- Intro Animation
	Tween(mainFrame, {
		Size = UDim2.new(0, initialWidth, 0, initialHeight)
	}, 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

	-- API: Create Tab
	function window:CreateTab(tabName: string)
		local tab = { Elements = {}, Toggles = {} }
		
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
		
		addConnection(tabBtn.MouseButton1Click:Connect(SelectThisTab))
		
		-- Auto-select first tab
		if #tabContainer:GetChildren() == 2 then -- UIListLayout + 1st Button
			SelectThisTab()
		end

		-- API: Elements
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
			
			addConnection(btnFrame.MouseEnter:Connect(function()
				local brightenedStart = startColor:Lerp(Color3.new(1, 1, 1), 0.15)
				local brightenedEnd = endColor:Lerp(Color3.new(1, 1, 1), 0.15)
				Tween(gradient, {
					Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0, brightenedStart),
						ColorSequenceKeypoint.new(1, brightenedEnd)
					})
				}, 0.2)
			end))
			
			addConnection(btnFrame.MouseLeave:Connect(function()
				Tween(gradient, {Color = originalColor}, 0.2)
			end))
			
			addConnection(btnFrame.MouseButton1Click:Connect(function()
				Tween(btnFrame, {Size = UDim2.new(0.97, 0, 0, 46)}, 0.08, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
				task.delay(0.08, function()
					Tween(btnFrame, {Size = UDim2.new(1, 0, 0, 48)}, 0.12, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
				end)
				pcall(callback)
			end))
		end

		function tab:CreateToggle(options)
			local togName = options.Name or "Toggle"
			local default = options.Default or false
			local callback = options.Callback or function() end
			
			local toggleId = tostring(math.random(100000, 999999))
			local state = default
			
			local toggleFrame = Create("TextButton", {
				Name = togName,
				Parent = tab.Container,
				Size = UDim2.new(1, 0, 0, 35),
				BackgroundColor3 = CONFIG.Theme.Surface,
				Text = "",
				AutoButtonColor = false,
				LayoutOrder = #tab.Container:GetChildren()
			}, {
				Create("UICorner", { CornerRadius = UDim.new(0, 8) }),
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
			
			local function SetState(newState: boolean)
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
			tab.Toggles[toggleId] = window.ActiveToggles[toggleId]
			
			addConnection(toggleFrame.MouseButton1Click:Connect(function()
				SetState(not state)
			end))
			
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
				BorderSizePixel = 0,
				LayoutOrder = #tab.Container:GetChildren()
			}, { Create("UICorner", { CornerRadius = UDim.new(0, 8) }) })
			
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
				local percent = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
				val = math.floor(min + (max - min) * percent)
				valText.Text = tostring(val)
				Tween(fill, {Size = UDim2.new(percent, 0, 1, 0)}, 0.1)
				pcall(callback, val)
			end
			
			addConnection(track.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					dragging = true
					UpdateSlider(input)
				end
			end))
			
			addConnection(UserInputService.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					dragging = false
				end
			end))
			
			addConnection(UserInputService.InputChanged:Connect(function(input)
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
				Size = UDim2.new(1, 0, 0, 35),
				BackgroundColor3 = CONFIG.Theme.Surface,
				ClipsDescendants = true,
				LayoutOrder = #tab.Container:GetChildren()
			}, { Create("UICorner", { CornerRadius = UDim.new(0, 8) }) })
			
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
					
					addConnection(optBtn.MouseEnter:Connect(function()
						if opt ~= selected then Tween(optBtn, {BackgroundColor3 = CONFIG.Theme.SurfaceHover}, 0.15) end
					end))
					addConnection(optBtn.MouseLeave:Connect(function()
						Tween(optBtn, {BackgroundColor3 = CONFIG.Theme.Surface}, 0.15)
					end))
					
					addConnection(optBtn.MouseButton1Click:Connect(function()
						selected = opt
						selectedText.Text = selected
						pcall(callback, selected)
						
						expanded = false
						Tween(arrow, {Rotation = 0}, 0.2)
						Tween(dropFrame, {Size = UDim2.new(1, 0, 0, 35)}, 0.2)
						UpdateList()
					end))
				end
			end
			
			addConnection(headerBtn.MouseButton1Click:Connect(function()
				expanded = not expanded
				Tween(arrow, {Rotation = expanded and 180 or 0}, 0.2)
				if expanded then
					UpdateList()
					Tween(dropFrame, {Size = UDim2.new(1, 0, 0, 35 + (#list * 30))}, 0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
				else
					Tween(dropFrame, {Size = UDim2.new(1, 0, 0, 35)}, 0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
				end
			end))
		end

		function tab:CreateLabel(text: string)
			Create("TextLabel", {
				Parent = tab.Container,
				Size = UDim2.new(1, 0, 0, 20),
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
				Size = UDim2.new(1, 0, 0, 50),
				BackgroundColor3 = CONFIG.Theme.Surface,
				BorderSizePixel = 0,
				LayoutOrder = #tab.Container:GetChildren()
			}, { Create("UICorner", { CornerRadius = UDim.new(0, 8) }) })
			
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
			
			addConnection(textBox.FocusLost:Connect(function()
				pcall(callback, textBox.Text)
			end))
		end

		return tab
	end

	table.insert(self.Windows, window)
	return window
end

-- Global cleanup function
getgenv().CrimsonUI_Cleanup = function()
	for _, conn in ipairs(connections) do
		pcall(function() conn:Disconnect() end)
	end
	for _, conn in ipairs(heartbeatConnections) do
		pcall(function() conn:Disconnect() end)
	end
	connections = {}
	heartbeatConnections = {}
end

return CrimsonUI

--[[ INSTALLATION:
local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/RealBatu20/AI-Scripts-2025/refs/heads/main/CrimsonUiLib.lua"))()
]]
