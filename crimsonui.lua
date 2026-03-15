--!strict
-- INSTALLATION: local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/RealBatu20/AI-Scripts-2025/refs/heads/main/crimsonui.lua"))()

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local CrimsonUI = {
	Version = "1.0.0",
	Windows = {}
}

-- Theme configuration based on the reference
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
	pcall(function() getgenv().CrimsonUI_Instance:Destroy() end)
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
		ImageTransparency = 1, -- Start invisible for intro
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
		Size = UDim2.new(0, windowSize.X, 0, 0), -- Start collapsed
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

	UserInputService.InputChanged:Connect(function(input)
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

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			if not isDragging then return end
			isDragging = false
			
			-- If minimized, clicking the header (without dragging) maximizes it
			if window.IsMinimized and not hasDragged and (tick() - dragStartTime) < CONFIG.Drag.MaxClickTime then
				window:Maximize()
			end
		end
	end)
	
	-- Button Hovers
	local function setupHover(btn, normalColor, hoverColor)
		btn.MouseEnter:Connect(function() Tween(btn, {BackgroundColor3 = hoverColor}, 0.2) end)
		btn.MouseLeave:Connect(function() Tween(btn, {BackgroundColor3 = normalColor}, 0.2) end)
	end
	
	setupHover(minimizeBtn, CONFIG.Theme.Minimize, CONFIG.Theme.Minimize:Lerp(Color3.new(1,1,1), 0.15))
	setupHover(closeBtn, CONFIG.Theme.Close, CONFIG.Theme.Close:Lerp(Color3.new(1,1,1), 0.15))
	
	local originalSize = UDim2.new(0, windowSize.X, 0, windowSize.Y)
	local originalShadowSize = UDim2.new(0, windowSize.X + 20, 0, windowSize.Y + 20)
	local minSize = UDim2.new(0, windowSize.X, 0, 45)
	local minShadowSize = UDim2.new(0, windowSize.X + 20, 0, 45 + 20)

	function window:Minimize()
		window.IsMinimized = true
		minimizeBtn.Text = "+"
		tabContainer.Visible = false
		contentContainer.Visible = false
		Tween(mainFrame, {Size = minSize}, CONFIG.Animation.Speed, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
		Tween(shadow, {Size = minShadowSize}, CONFIG.Animation.Speed, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
	end
	
	function window:Maximize()
		window.IsMinimized = false
		minimizeBtn.Text = "−"
		Tween(mainFrame, {Size = originalSize}, CONFIG.Animation.Speed, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
		Tween(shadow, {Size = originalShadowSize}, CONFIG.Animation.Speed, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
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
		
		-- Auto-select first tab
		if #tabContainer:GetChildren() == 2 then -- UIListLayout + 1st Button
			SelectThisTab()
		end

		-- API: Elements
		function tab:CreateButton(options)
			local btnName = options.Name or "Button"
			local callback = options.Callback or function() end
			
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
			
			setupHover(btnFrame, CONFIG.Theme.Surface, CONFIG.Theme.SurfaceHover)
			
			btnFrame.MouseButton1Click:Connect(function()
				-- Click bounce
				Tween(btnFrame, {Size = UDim2.new(0.95, 0, 0, 38)}, 0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
				task.delay(0.1, function()
					Tween(btnFrame, {Size = UDim2.new(1, 0, 0, 40)}, 0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
				end)
				pcall(callback)
			end)
		end

		function tab:CreateToggle(options)
			local togName = options.Name or "Toggle"
			local default = options.Default or false
			local callback = options.Callback or function() end
			
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
			
			-- Initial fire
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
				Size = UDim2.new(1, 0, 0, 50),
				BackgroundColor3 = CONFIG.Theme.Surface,
				BorderSizePixel = 0
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
			
			track.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					dragging = true
					UpdateSlider(input)
				end
			end)
			
			UserInputService.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					dragging = false
				end
			end)
			
			UserInputService.InputChanged:Connect(function(input)
				if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
					UpdateSlider(input)
				end
			end)
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
						
						-- Close
						expanded = false
						Tween(arrow, {Rotation = 0}, 0.2)
						Tween(dropFrame, {Size = UDim2.new(1, 0, 0, 35)}, 0.2)
						UpdateList() -- refresh colors
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
			
			textBox.FocusLost:Connect(function()
				pcall(callback, textBox.Text)
			end)
		end

		return tab
	end

	return window
end

return CrimsonUI
