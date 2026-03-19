--!strict
--[[ 
INSTALLATION:
local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/RealBatu20/AI-Scripts-2025/refs/heads/main/test_cuilib.lua"))()
]]
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")

local CrimsonUI = {
	Version = "2.0.0",
	Windows = {}
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
		Success = Color3.fromRGB(46, 204, 113),
		Warning = Color3.fromRGB(241, 196, 15),
		Error = Color3.fromRGB(231, 76, 60)
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
	Tooltip = {
		Delay = 2.0,
		Background = Color3.fromRGB(40, 40, 50),
		TextColor = Color3.fromRGB(255, 255, 255),
		CornerRadius = 6,
		Padding = 8,
		MaxWidth = 200
	}
}

-- Utility functions
local function Create(className: string, properties: {[string]: any}?, children: {Instance}?): Instance
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

local function Tween(obj: Instance, props: {[string]: any}, time: number?, style: Enum.EasingStyle?, direction: Enum.EasingDirection?): Tween
	time = time or CONFIG.Animation.Speed
	style = style or CONFIG.Animation.Easing
	direction = direction or CONFIG.Animation.Direction
	local tweenInfo = TweenInfo.new(time, style, direction)
	local tween = TweenService:Create(obj, tweenInfo, props)
	tween:Play()
	return tween
end

-- Tooltip System
local activeTooltip: Frame? = nil
local tooltipConnection: RBXScriptConnection? = nil

local function HideTooltip()
	if activeTooltip then
		Tween(activeTooltip, {Size = UDim2.new(0, activeTooltip.AbsoluteSize.X, 0, 0), Position = UDim2.new(activeTooltip.Position.X.Scale, activeTooltip.Position.X.Offset, activeTooltip.Position.Y.Scale, activeTooltip.Position.Y.Offset + 10)}, 0.15)
		task.delay(0.15, function()
			if activeTooltip then
				activeTooltip:Destroy()
				activeTooltip = nil
			end
		end)
	end
	if tooltipConnection then
		tooltipConnection:Disconnect()
		tooltipConnection = nil
	end
end

local function ShowTooltip(parentElement: GuiObject, text: string, screenGui: ScreenGui)
	if not text or text == "" then return end
	if activeTooltip then HideTooltip() end
	
	activeTooltip = Create("Frame", {
		Name = "Tooltip",
		Parent = screenGui,
		BackgroundColor3 = CONFIG.Tooltip.Background,
		BorderSizePixel = 0,
		ZIndex = 1000,
		Size = UDim2.new(0, 0, 0, 0),
		Position = UDim2.new(0, 0, 0, 0)
	}, {
		Create("UICorner", { CornerRadius = UDim.new(0, CONFIG.Tooltip.CornerRadius) }),
		Create("UIStroke", { Color = CONFIG.Theme.Border, Thickness = 1 }),
		Create("UIPadding", { 
			PaddingLeft = UDim.new(0, CONFIG.Tooltip.Padding), 
			PaddingRight = UDim.new(0, CONFIG.Tooltip.Padding),
			PaddingTop = UDim.new(0, CONFIG.Tooltip.Padding),
			PaddingBottom = UDim.new(0, CONFIG.Tooltip.Padding)
		})
	})
	
	local label = Create("TextLabel", {
		Parent = activeTooltip,
		BackgroundTransparency = 1,
		Text = text,
		TextColor3 = CONFIG.Tooltip.TextColor,
		Font = Enum.Font.GothamMedium,
		TextSize = 12,
		TextWrapped = true,
		AutomaticSize = Enum.AutomaticSize.XY,
		Size = UDim2.new(0, 0, 0, 0),
		MaxSize = Vector2.new(CONFIG.Tooltip.MaxWidth, math.huge)
	})
	
	task.defer(function()
		if not activeTooltip then return end
		
		local absPos = parentElement.AbsolutePosition
		local absSize = parentElement.AbsoluteSize
		local tooltipSize = activeTooltip.AbsoluteSize
		
		local targetX = absPos.X + (absSize.X / 2) - (tooltipSize.X / 2)
		local targetY = absPos.Y - tooltipSize.Y - 8
		
		local screenSize = workspace.CurrentCamera.ViewportSize
		targetX = math.clamp(targetX, 10, screenSize.X - tooltipSize.X - 10)
		targetY = math.max(targetY, 10)
		
		activeTooltip.Position = UDim2.new(0, targetX, 0, targetY + 10)
		activeTooltip.Size = UDim2.new(0, tooltipSize.X, 0, 0)
		
		Tween(activeTooltip, {
			Size = UDim2.new(0, tooltipSize.X, 0, tooltipSize.Y),
			Position = UDim2.new(0, targetX, 0, targetY)
		}, 0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	end)
	
	tooltipConnection = RunService.Heartbeat:Connect(function()
		if not activeTooltip or not parentElement or not parentElement.Parent then
			HideTooltip()
			return
		end
		
		local mousePos = UserInputService:GetMouseLocation()
		local absPos = parentElement.AbsolutePosition
		local absSize = parentElement.AbsoluteSize
		
		if mousePos.X < absPos.X or mousePos.X > absPos.X + absSize.X or
		   mousePos.Y < absPos.Y or mousePos.Y > absPos.Y + absSize.Y then
			HideTooltip()
		end
	end)
end

local function SetupTooltip(element: GuiObject, text: string?, screenGui: ScreenGui)
	if not text or text == "" then return end
	
	local hoverStartTime = 0
	local isHovering = false
	local checkConnection: RBXScriptConnection? = nil
	
	element.MouseEnter:Connect(function()
		isHovering = true
		hoverStartTime = tick()
		
		checkConnection = RunService.Heartbeat:Connect(function()
			if not isHovering then
				checkConnection:Disconnect()
				return
			end
			
			if tick() - hoverStartTime >= CONFIG.Tooltip.Delay then
				checkConnection:Disconnect()
				if isHovering then
					ShowTooltip(element, text, screenGui)
				end
			end
		end)
	end)
	
	element.MouseLeave:Connect(function()
		isHovering = false
		if checkConnection then
			checkConnection:Disconnect()
		end
		HideTooltip()
	end)
end

-- Clean up existing instances
if getgenv().CrimsonUI_Instance then
	pcall(function() getgenv().CrimsonUI_Instance:Destroy() end)
end

-- GetHui stealth parenting - uses hidden UI service if available
local function GetHiddenParent(): Instance
	-- Try GetHui first (most exploits support this)
	if gethui then
		return gethui()
	end
	
	-- Fallback to CoreGui with pcall
	local success, result = pcall(function()
		return CoreGui
	end)
	
	if success then
		return result
	end
	
	-- Final fallback to PlayerGui
	return Players.LocalPlayer:WaitForChild("PlayerGui")
end

local hiddenParent = GetHiddenParent()

local screenGui = Create("ScreenGui", {
	Name = "CrimsonUI_" .. tostring(math.random(1000, 9999)),
	ResetOnSpawn = false,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	DisplayOrder = 100,
	IgnoreGuiInset = true,
	Parent = hiddenParent
})

getgenv().CrimsonUI_Instance = screenGui

function CrimsonUI:CreateWindow(options: {Title: string?, Icon: string?, Size: Vector2?})
	options = options or {}
	local title = options.Title or "Crimson Window"
	local icon = options.Icon or "🎲"
	local windowSize = options.Size or Vector2.new(300, 380)
	
	local window = {
		Tabs = {},
		CurrentTab = nil,
		IsMinimized = false
	}
	
	-- Shadow
	local shadow = Create("ImageLabel", {
		Name = "Shadow",
		Parent = screenGui,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(0, windowSize.X + 20, 0, windowSize.Y + 20),
		BackgroundTransparency = 1,
		Image = "rbxassetid://1316045217",
		ImageColor3 = CONFIG.Theme.Shadow,
		ImageTransparency = 1,
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(10, 10, 118, 118),
		ZIndex = 0
	})
	
	-- Main Frame
	local mainFrame = Create("Frame", {
		Name = "MainFrame",
		Parent = screenGui,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(0, windowSize.X, 0, 0),
		BackgroundColor3 = CONFIG.Theme.Background,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		ZIndex = 1
	}, {
		Create("UICorner", { CornerRadius = UDim.new(0, 12) }),
		Create("UIStroke", { Color = CONFIG.Theme.Border, Thickness = 1.5 })
	})
	
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
			Size = UDim2.new(1, -120, 1, 0),
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
		Size = UDim2.new(0, 80, 0, 30),
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
	}, { Create("UICorner", { CornerRadius = UDim.new(0, 8) }) })
	
	local closeBtn = Create("TextButton", {
		Name = "Close",
		Parent = controls,
		Size = UDim2.new(0, 30, 0, 30),
		BackgroundColor3 = CONFIG.Theme.Close,
		Text = "x",
		TextColor3 = CONFIG.Theme.Text,
		Font = Enum.Font.GothamBold,
		TextSize = 16,
		AutoButtonColor = false,
		LayoutOrder = 2,
		ZIndex = 4
	}, { Create("UICorner", { CornerRadius = UDim.new(0, 8) }) })
	
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
	local dragStart: Vector3?, startPos: UDim2?
	local dragStartTime = 0
	local dragStartMousePos = Vector2.zero
	local hasDragged = false

	header.InputBegan:Connect(function(input: InputObject)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			local mousePos = UserInputService:GetMouseLocation()
			local minAbs, minSize = minimizeBtn.AbsolutePosition, minimizeBtn.AbsoluteSize
			local closeAbs, closeSize = closeBtn.AbsolutePosition, closeBtn.AbsoluteSize
			
			if (mousePos.X >= minAbs.X and mousePos.X <= minAbs.X + minSize.X and mousePos.Y >= minAbs.Y and mousePos.Y <= minAbs.Y + minSize.Y) or
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
	end)

	UserInputService.InputChanged:Connect(function(input: InputObject)
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

	UserInputService.InputEnded:Connect(function(input: InputObject)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			if not isDragging then return end
			isDragging = false
			
			if window.IsMinimized and not hasDragged and (tick() - dragStartTime) < CONFIG.Drag.MaxClickTime then
				window:Maximize()
			end
		end
	end)
	
	-- Button Hovers & Tooltips
	local function setupHover(btn: TextButton, normalColor: Color3, hoverColor: Color3, tooltipText: string?)
		btn.MouseEnter:Connect(function() Tween(btn, {BackgroundColor3 = hoverColor}, 0.2) end)
		btn.MouseLeave:Connect(function() Tween(btn, {BackgroundColor3 = normalColor}, 0.2) end)
		
		if tooltipText then
			SetupTooltip(btn, tooltipText, screenGui)
		end
	end
	
	setupHover(minimizeBtn, CONFIG.Theme.Minimize, CONFIG.Theme.Minimize:Lerp(Color3.new(1,1,1), 0.15), "Minimize window")
	setupHover(closeBtn, CONFIG.Theme.Close, CONFIG.Theme.Close:Lerp(Color3.new(1,1,1), 0.15), "Close window")
	
	local originalSize = UDim2.new(0, windowSize.X, 0, windowSize.Y)
	local originalShadowSize = UDim2.new(0, windowSize.X + 20, 0, windowSize.Y + 20)
	local originalPosition = mainFrame.Position
	local minSize = UDim2.new(0, windowSize.X, 0, 45)
	local minShadowSize = UDim2.new(0, windowSize.X + 20, 0, 45 + 20)

	function window:Minimize()
		window.IsMinimized = true
		minimizeBtn.Text = "+"
		tabContainer.Visible = false
		contentContainer.Visible = false
		
		originalPosition = mainFrame.Position
		local currentPos = mainFrame.Position
		local collapseOffset = (windowSize.Y - 45) / 2
		
		Tween(mainFrame, {
			Size = minSize,
			Position = UDim2.new(currentPos.X.Scale, currentPos.X.Offset, currentPos.Y.Scale, currentPos.Y.Offset - collapseOffset)
		}, CONFIG.Animation.Speed, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
		
		Tween(shadow, {
			Size = minShadowSize,
			Position = UDim2.new(currentPos.X.Scale, currentPos.X.Offset, currentPos.Y.Scale, currentPos.Y.Offset - collapseOffset)
		}, CONFIG.Animation.Speed, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
	end
	
	function window:Maximize()
		window.IsMinimized = false
		minimizeBtn.Text = "−"
		
		local currentPos = mainFrame.Position
		local expandOffset = (windowSize.Y - 45) / 2
		
		Tween(mainFrame, {
			Size = originalSize,
			Position = UDim2.new(currentPos.X.Scale, currentPos.X.Offset, currentPos.Y.Scale, currentPos.Y.Offset + expandOffset)
		}, CONFIG.Animation.Speed, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
		
		Tween(shadow, {
			Size = originalShadowSize,
			Position = UDim2.new(currentPos.X.Scale, currentPos.X.Offset, currentPos.Y.Scale, currentPos.Y.Offset + expandOffset)
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
		Tween(mainFrame, {
			Size = UDim2.new(0, 0, 0, 0),
			Position = UDim2.new(mainFrame.Position.X.Scale, mainFrame.Position.X.Offset, mainFrame.Position.Y.Scale, mainFrame.Position.Y.Offset + 170)
		}, 0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
		Tween(shadow, {Size = UDim2.new(0,0,0,0), ImageTransparency = 1}, 0.25)
		task.delay(0.3, function() screenGui:Destroy() end)
	end)
	
	-- Intro Anim
	Tween(shadow, {Size = originalShadowSize, ImageTransparency = 0.6}, 0.5)
	Tween(mainFrame, {Size = originalSize}, 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

	-- API: Create Tab
	function window:CreateTab(tabName: string)
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
		
		SetupTooltip(tabBtn, "Switch to " .. tabName .. " tab", screenGui)
		
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
		
		tabBtn.MouseButton1Click:Connect(SelectThisTab)
		
		if #tabContainer:GetChildren() == 2 then
			SelectThisTab()
		end

		-- ==================== ELEMENT CREATION API ====================

		-- CreateButton: Standard action button
		function tab:CreateButton(options: {Name: string?, Callback: (() -> ())?, Tooltip: string?})
			local btnName = options.Name or "Button"
			local callback = options.Callback or function() end
			local tooltipText = options.Tooltip or options.Description
			
			local btnFrame = Create("TextButton", {
				Name = btnName,
				Parent = tab.Container,
				Size = UDim2.new(1, 0, 0, 40),
				BackgroundColor3 = CONFIG.Theme.Surface,
				Text = "",
				AutoButtonColor = false,
				ClipsDescendants = true
			}, {
				Create("UICorner", { CornerRadius = UDim.new(0, 8) }),
				Create("UIStroke", { Color = CONFIG.Theme.Border, Thickness = 1 }),
				Create("TextLabel", {
					Size = UDim2.new(1, 0, 1, 0),
					BackgroundTransparency = 1,
					Text = btnName,
					TextColor3 = CONFIG.Theme.Text,
					Font = Enum.Font.GothamBold,
					TextSize = 14
				})
			})
			
			setupHover(btnFrame, CONFIG.Theme.Surface, CONFIG.Theme.SurfaceHover, tooltipText)
			
			btnFrame.MouseButton1Click:Connect(function()
				Tween(btnFrame, {Size = UDim2.new(0.95, 0, 0, 38)}, 0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
				task.delay(0.1, function()
					Tween(btnFrame, {Size = UDim2.new(1, 0, 0, 40)}, 0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
				end)
				pcall(callback)
			end)
		end

		-- CreateToggle: Switch toggle with animation
		function tab:CreateToggle(options: {Name: string?, Default: boolean?, Callback: ((boolean) -> ())?, Tooltip: string?})
			local togName = options.Name or "Toggle"
			local default = options.Default or false
			local callback = options.Callback or function() end
			local tooltipText = options.Tooltip or options.Description
			
			local state = default
			
			local toggleFrame = Create("TextButton", {
				Name = togName,
				Parent = tab.Container,
				Size = UDim2.new(1, 0, 0, 35),
				BackgroundColor3 = CONFIG.Theme.Surface,
				Text = "",
				AutoButtonColor = false
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
			
			if tooltipText then
				SetupTooltip(toggleFrame, tooltipText, screenGui)
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
			
			local function UpdateToggle()
				Tween(switchBg, {BackgroundColor3 = state and CONFIG.Theme.Accent or CONFIG.Theme.Background}, 0.2)
				Tween(switchKnob, {Position = UDim2.new(0, state and 20 or 2, 0.5, 0)}, 0.2, Enum.EasingStyle.Back)
				Tween(titleText, {TextColor3 = state and CONFIG.Theme.Text or CONFIG.Theme.TextMuted}, 0.2)
				pcall(callback, state)
			end
			
			toggleFrame.MouseButton1Click:Connect(function()
				state = not state
				UpdateToggle()
			end)
			
			if state then UpdateToggle() end
			
			-- Return API for external control
			return {
				GetState = function() return state end,
				SetState = function(newState: boolean)
					state = newState
					UpdateToggle()
				end,
				Destroy = function() toggleFrame:Destroy() end
			}
		end

		-- CreateCheckbox: Classic checkbox with checkmark animation
		function tab:CreateCheckbox(options: {Name: string?, Default: boolean?, Callback: ((boolean) -> ())?, Tooltip: string?})
			local chkName = options.Name or "Checkbox"
			local default = options.Default or false
			local callback = options.Callback or function() end
			local tooltipText = options.Tooltip or options.Description
			
			local state = default
			
			local checkboxFrame = Create("TextButton", {
				Name = chkName,
				Parent = tab.Container,
				Size = UDim2.new(1, 0, 0, 35),
				BackgroundColor3 = CONFIG.Theme.Surface,
				Text = "",
				AutoButtonColor = false
			}, {
				Create("UICorner", { CornerRadius = UDim.new(0, 8) }),
				Create("TextLabel", {
					Position = UDim2.new(0, 40, 0, 0),
					Size = UDim2.new(1, -50, 1, 0),
					BackgroundTransparency = 1,
					Text = chkName,
					TextColor3 = CONFIG.Theme.TextMuted,
					Font = Enum.Font.GothamMedium,
					TextSize = 14,
					TextXAlignment = Enum.TextXAlignment.Left
				})
			})
			
			if tooltipText then
				SetupTooltip(checkboxFrame, tooltipText, screenGui)
			end
			
			local titleText = checkboxFrame:FindFirstChildOfClass("TextLabel")
			
			-- Checkbox box
			local box = Create("Frame", {
				Parent = checkboxFrame,
				Position = UDim2.new(0, 10, 0.5, 0),
				AnchorPoint = Vector2.new(0, 0.5),
				Size = UDim2.new(0, 18, 0, 18),
				BackgroundColor3 = state and CONFIG.Theme.Accent or CONFIG.Theme.Background,
				BorderSizePixel = 0
			}, {
				Create("UICorner", { CornerRadius = UDim.new(0, 4) }),
				Create("UIStroke", { 
					Color = state and CONFIG.Theme.Accent or CONFIG.Theme.Border, 
					Thickness = 2 
				})
			})
			
			-- Checkmark
			local checkmark = Create("TextLabel", {
				Parent = box,
				Size = UDim2.new(1, 0, 1, 0),
				BackgroundTransparency = 1,
				Text = "✓",
				TextColor3 = Color3.new(1, 1, 1),
				Font = Enum.Font.GothamBold,
				TextSize = 14,
				TextTransparency = state and 0 or 1
			})
			
			local function UpdateCheckbox()
				Tween(box, {BackgroundColor3 = state and CONFIG.Theme.Accent or CONFIG.Theme.Background}, 0.2)
				Tween(box:FindFirstChildOfClass("UIStroke"), {Color = state and CONFIG.Theme.Accent or CONFIG.Theme.Border}, 0.2)
				Tween(checkmark, {TextTransparency = state and 0 or 1}, 0.2)
				Tween(titleText, {TextColor3 = state and CONFIG.Theme.Text or CONFIG.Theme.TextMuted}, 0.2)
				pcall(callback, state)
			end
			
			checkboxFrame.MouseButton1Click:Connect(function()
				state = not state
				UpdateCheckbox()
			end)
			
			if state then UpdateCheckbox() end
			
			return {
				GetState = function() return state end,
				SetState = function(newState: boolean)
					state = newState
					UpdateCheckbox()
				end,
				Destroy = function() checkboxFrame:Destroy() end
			}
		end

		-- CreateSearchbox: Search input with live filtering
		function tab:CreateSearchbox(options: {Name: string?, Placeholder: string?, Callback: ((string) -> ())?, Tooltip: string?})
			local searchName = options.Name or "Search"
			local placeholder = options.Placeholder or "Search..."
			local callback = options.Callback or function() end
			local tooltipText = options.Tooltip or options.Description
			
			local searchFrame = Create("Frame", {
				Name = searchName,
				Parent = tab.Container,
				Size = UDim2.new(1, 0, 0, 50),
				BackgroundColor3 = CONFIG.Theme.Surface,
				BorderSizePixel = 0
			}, {
				Create("UICorner", { CornerRadius = UDim.new(0, 8) })
			})
			
			if tooltipText then
				SetupTooltip(searchFrame, tooltipText, screenGui)
			end
			
			Create("TextLabel", {
				Parent = searchFrame,
				Position = UDim2.new(0, 10, 0, 5),
				Size = UDim2.new(1, -20, 0, 15),
				BackgroundTransparency = 1,
				Text = searchName,
				TextColor3 = CONFIG.Theme.TextMuted,
				Font = Enum.Font.GothamMedium,
				TextSize = 13,
				TextXAlignment = Enum.TextXAlignment.Left
			})
			
			-- Search icon
			local searchIcon = Create("TextLabel", {
				Parent = searchFrame,
				Position = UDim2.new(0, 10, 0, 25),
				Size = UDim2.new(0, 20, 0, 20),
				BackgroundTransparency = 1,
				Text = "🔍",
				TextSize = 12,
				Font = Enum.Font.GothamBold
			})
			
			local textBox = Create("TextBox", {
				Parent = searchFrame,
				Position = UDim2.new(0, 35, 0, 25),
				Size = UDim2.new(1, -45, 0, 20),
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
			
			-- Live search with debounce
			local debounceTimer: thread? = nil
			textBox:GetPropertyChangedSignal("Text"):Connect(function()
				if debounceTimer then
					task.cancel(debounceTimer)
				end
				debounceTimer = task.delay(0.3, function()
					pcall(callback, textBox.Text)
				end)
			end)
			
			return {
				GetText = function() return textBox.Text end,
				SetText = function(text: string)
					textBox.Text = text
					pcall(callback, text)
				end,
				Clear = function()
					textBox.Text = ""
					pcall(callback, "")
				end,
				Focus = function() textBox:CaptureFocus() end,
				Destroy = function() searchFrame:Destroy() end
			}
		end

		-- CreateSearchButton: Search input with submit button
		function tab:CreateSearchButton(options: {Name: string?, Placeholder: string?, ButtonText: string?, Callback: ((string) -> ())?, Tooltip: string?})
			local searchName = options.Name or "Search"
			local placeholder = options.Placeholder or "Type to search..."
			local btnText = options.ButtonText or "Search"
			local callback = options.Callback or function() end
			local tooltipText = options.Tooltip or options.Description
			
			local container = Create("Frame", {
				Name = searchName,
				Parent = tab.Container,
				Size = UDim2.new(1, 0, 0, 75),
				BackgroundColor3 = CONFIG.Theme.Surface,
				BorderSizePixel = 0
			}, {
				Create("UICorner", { CornerRadius = UDim.new(0, 8) })
			})
			
			if tooltipText then
				SetupTooltip(container, tooltipText, screenGui)
			end
			
			Create("TextLabel", {
				Parent = container,
				Position = UDim2.new(0, 10, 0, 5),
				Size = UDim2.new(1, -20, 0, 15),
				BackgroundTransparency = 1,
				Text = searchName,
				TextColor3 = CONFIG.Theme.TextMuted,
				Font = Enum.Font.GothamMedium,
				TextSize = 13,
				TextXAlignment = Enum.TextXAlignment.Left
			})
			
			local textBox = Create("TextBox", {
				Parent = container,
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
			
			local searchBtn = Create("TextButton", {
				Parent = container,
				Position = UDim2.new(0, 10, 0, 50),
				Size = UDim2.new(1, -20, 0, 20),
				BackgroundColor3 = CONFIG.Theme.Accent,
				Text = btnText,
				TextColor3 = CONFIG.Theme.Text,
				Font = Enum.Font.GothamBold,
				TextSize = 12,
				AutoButtonColor = false
			}, {
				Create("UICorner", { CornerRadius = UDim.new(0, 4) })
			})
			
			setupHover(searchBtn, CONFIG.Theme.Accent, CONFIG.Theme.AccentHover)
			
			local function Submit()
				Tween(searchBtn, {Size = UDim2.new(0.95, 0, 0, 20)}, 0.1)
				task.delay(0.1, function()
					Tween(searchBtn, {Size = UDim2.new(1, -20, 0, 20)}, 0.1)
				end)
				pcall(callback, textBox.Text)
			end
			
			searchBtn.MouseButton1Click:Connect(Submit)
			textBox.FocusLost:Connect(function(enterPressed: boolean)
				if enterPressed then
					Submit()
				end
			end)
			
			return {
				GetText = function() return textBox.Text end,
				SetText = function(text: string) textBox.Text = text end,
				Submit = Submit,
				Clear = function() textBox.Text = "" end,
				Destroy = function() container:Destroy() end
			}
		end

		-- CreateSlider: Numeric slider with value display
		function tab:CreateSlider(options: {Name: string?, Min: number?, Max: number?, Default: number?, Increment: number?, Callback: ((number) -> ())?, Tooltip: string?})
			local slName = options.Name or "Slider"
			local min = options.Min or 0
			local max = options.Max or 100
			local default = options.Default or min
			local increment = options.Increment or 1
			local callback = options.Callback or function() end
			local tooltipText = options.Tooltip or options.Description
			
			-- Clamp default
			default = math.clamp(default, min, max)
			local val = default
			
			local sliderFrame = Create("Frame", {
				Name = slName,
				Parent = tab.Container,
				Size = UDim2.new(1, 0, 0, 50),
				BackgroundColor3 = CONFIG.Theme.Surface,
				BorderSizePixel = 0
			}, { Create("UICorner", { CornerRadius = UDim.new(0, 8) }) })
			
			if tooltipText then
				SetupTooltip(sliderFrame, tooltipText, screenGui)
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
				BackgroundColor3 = Color3.new(1, 1, 1),
				ZIndex = 10
			}, { Create("UICorner", { CornerRadius = UDim.new(1, 0) }) })
			
			SetupTooltip(knob, "Value: " .. tostring(val), screenGui)
			
			local dragging = false
			
			local function UpdateSlider(input: InputObject)
				local percent = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
				local rawVal = min + (max - min) * percent
				val = math.floor(rawVal / increment + 0.5) * increment
				val = math.clamp(val, min, max)
				
				valText.Text = tostring(val)
				Tween(fill, {Size = UDim2.new((val - min)/(max - min), 0, 1, 0)}, 0.1)
				
				if activeTooltip and activeTooltip.Parent then
					local tooltipLabel = activeTooltip:FindFirstChildOfClass("TextLabel")
					if tooltipLabel then
						tooltipLabel.Text = "Value: " .. tostring(val)
					end
				end
				
				pcall(callback, val)
			end
			
			track.InputBegan:Connect(function(input: InputObject)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					dragging = true
					UpdateSlider(input)
				end
			end)
			
			UserInputService.InputEnded:Connect(function(input: InputObject)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					dragging = false
				end
			end)
			
			UserInputService.InputChanged:Connect(function(input: InputObject)
				if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
					UpdateSlider(input)
				end
			end)
			
			return {
				GetValue = function() return val end,
				SetValue = function(newVal: number)
					val = math.clamp(newVal, min, max)
					valText.Text = tostring(val)
					Tween(fill, {Size = UDim2.new((val - min)/(max - min), 0, 1, 0)}, 0.2)
					pcall(callback, val)
				end,
				Destroy = function() sliderFrame:Destroy() end
			}
		end

		-- CreateSliderKnob: Draggable knob-only slider (compact)
		function tab:CreateSliderKnob(options: {Name: string?, Min: number?, Max: number?, Default: number?, Size: number?, Callback: ((number) -> ())?, Tooltip: string?})
			local knobName = options.Name or "Knob"
			local min = options.Min or 0
			local max = options.Max or 100
			local default = options.Default or min
			local size = options.Size or 80
			local callback = options.Callback or function() end
			local tooltipText = options.Tooltip or options.Description
			
			default = math.clamp(default, min, max)
			local val = default
			
			local container = Create("Frame", {
				Name = knobName,
				Parent = tab.Container,
				Size = UDim2.new(1, 0, 0, 40),
				BackgroundColor3 = CONFIG.Theme.Surface,
				BorderSizePixel = 0
			}, {
				Create("UICorner", { CornerRadius = UDim.new(0, 8) })
			})
			
			if tooltipText then
				SetupTooltip(container, tooltipText, screenGui)
			end
			
			Create("TextLabel", {
				Parent = container,
				Position = UDim2.new(0, 10, 0, 0),
				Size = UDim2.new(0.5, 0, 1, 0),
				BackgroundTransparency = 1,
				Text = knobName,
				TextColor3 = CONFIG.Theme.TextMuted,
				Font = Enum.Font.GothamMedium,
				TextSize = 14,
				TextXAlignment = Enum.TextXAlignment.Left
			})
			
			local valLabel = Create("TextLabel", {
				Parent = container,
				Position = UDim2.new(0.5, 0, 0, 0),
				Size = UDim2.new(0.5, -10, 1, 0),
				BackgroundTransparency = 1,
				Text = tostring(val),
				TextColor3 = CONFIG.Theme.Text,
				Font = Enum.Font.GothamBold,
				TextSize = 14,
				TextXAlignment = Enum.TextXAlignment.Right
			})
			
			-- Knob track
			local track = Create("Frame", {
				Parent = container,
				Position = UDim2.new(0.5, -size/2, 0.5, 0),
				AnchorPoint = Vector2.new(0, 0.5),
				Size = UDim2.new(0, size, 0, 4),
				BackgroundColor3 = CONFIG.Theme.Background,
				BorderSizePixel = 0
			}, {
				Create("UICorner", { CornerRadius = UDim.new(1, 0) })
			})
			
			-- Draggable knob
			local knob = Create("TextButton", {
				Parent = track,
				Position = UDim2.new((val - min)/(max - min), -8, 0.5, 0),
				AnchorPoint = Vector2.new(0, 0.5),
				Size = UDim2.new(0, 16, 0, 16),
				BackgroundColor3 = CONFIG.Theme.Accent,
				Text = "",
				AutoButtonColor = false,
				ZIndex = 5
			}, {
				Create("UICorner", { CornerRadius = UDim.new(1, 0) }),
				Create("UIStroke", { Color = CONFIG.Theme.Text, Thickness = 2 })
			})
			
			local dragging = false
			
			local function UpdateKnob(input: InputObject)
				local trackAbs = track.AbsolutePosition.X
				local trackSize = track.AbsoluteSize.X
				local relativeX = math.clamp(input.Position.X - trackAbs, 0, trackSize)
				local percent = relativeX / trackSize
				val = math.floor(min + (max - min) * percent)
				
				knob.Position = UDim2.new(percent, -8, 0.5, 0)
				valLabel.Text = tostring(val)
				pcall(callback, val)
			end
			
			knob.InputBegan:Connect(function(input: InputObject)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					dragging = true
					Tween(knob, {Size = UDim2.new(0, 20, 0, 20)}, 0.1)
				end
			end)
			
			UserInputService.InputEnded:Connect(function(input: InputObject)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					if dragging then
						dragging = false
						Tween(knob, {Size = UDim2.new(0, 16, 0, 16)}, 0.1)
					end
				end
			end)
			
			UserInputService.InputChanged:Connect(function(input: InputObject)
				if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
					UpdateKnob(input)
				end
			end)
			
			return {
				GetValue = function() return val end,
				SetValue = function(newVal: number)
					val = math.clamp(newVal, min, max)
					local percent = (val - min) / (max - min)
					knob.Position = UDim2.new(percent, -8, 0.5, 0)
					valLabel.Text = tostring(val)
					pcall(callback, val)
				end,
				Destroy = function() container:Destroy() end
			}
		end

		-- CreateDropdown: Selection dropdown
		function tab:CreateDropdown(options: {Name: string?, Options: {string}?, Default: string?, Callback: ((string) -> ())?, Tooltip: string?})
			local dropName = options.Name or "Dropdown"
			local list = options.Options or {}
			local default = options.Default
			local callback = options.Callback or function() end
			local tooltipText = options.Tooltip or options.Description
			
			local selected = default or "Select..."
			local expanded = false
			
			local dropFrame = Create("Frame", {
				Name = dropName,
				Parent = tab.Container,
				Size = UDim2.new(1, 0, 0, 35),
				BackgroundColor3 = CONFIG.Theme.Surface,
				ClipsDescendants = true
			}, { Create("UICorner", { CornerRadius = UDim.new(0, 8) }) })
			
			if tooltipText then
				SetupTooltip(dropFrame, tooltipText, screenGui)
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
				expanded = not expanded
				Tween(arrow, {Rotation = expanded and 180 or 0}, 0.2)
				if expanded then
					UpdateList()
					Tween(dropFrame, {Size = UDim2.new(1, 0, 0, 35 + (#list * 30))}, 0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
				else
					Tween(dropFrame, {Size = UDim2.new(1, 0, 0, 35)}, 0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
				end
			end)
			
			return {
				GetSelected = function() return selected end,
				SetOptions = function(newOptions: {string})
					list = newOptions
					if expanded then UpdateList() end
				end,
				Destroy = function() dropFrame:Destroy() end
			}
		end

		-- CreateLabel: Static text label
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
				TextWrapped = true
			})
		end
		
		-- CreateInput: Text input field
		function tab:CreateInput(options: {Name: string?, Placeholder: string?, Callback: ((string) -> ())?, Tooltip: string?})
			local inpName = options.Name or "Input"
			local placeholder = options.Placeholder or "Type here..."
			local callback = options.Callback or function() end
			local tooltipText = options.Tooltip or options.Description
			
			local inputFrame = Create("Frame", {
				Parent = tab.Container,
				Size = UDim2.new(1, 0, 0, 50),
				BackgroundColor3 = CONFIG.Theme.Surface,
				BorderSizePixel = 0
			}, { Create("UICorner", { CornerRadius = UDim.new(0, 8) }) })
			
			if tooltipText then
				SetupTooltip(inputFrame, tooltipText, screenGui)
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
				pcall(callback, textBox.Text)
			end)
			
			return {
				GetText = function() return textBox.Text end,
				SetText = function(text: string) textBox.Text = text end,
				Destroy = function() inputFrame:Destroy() end
			}
		end

		return tab
	end

	return window
end

return CrimsonUI
