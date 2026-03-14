-- local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/RealBatu20/AI-Scripts-2025/refs/heads/main/CrimsonUiLib.lua"))()

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local IsMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

-- ========== UTILITIES ==========
local Util = {}

function Util.Create(className, props, children)
    local obj = Instance.new(className)
    for k, v in pairs(props or {}) do
        if k ~= "Parent" then obj[k] = v end
    end
    for _, child in ipairs(children or {}) do
        child.Parent = obj
    end
    if props and props.Parent then obj.Parent = props.Parent end
    return obj
end

function Util.Tween(obj, duration, props, easing, direction)
    easing = easing or Enum.EasingStyle.Quint
    direction = direction or Enum.EasingDirection.Out
    local tween = TweenService:Create(obj, TweenInfo.new(duration, easing, direction), props)
    tween:Play()
    return tween
end

function Util.GetTextSize(text, fontSize, font, maxWidth)
    local params = Instance.new("GetTextBoundsParams")
    params.Text = text
    params.Size = fontSize
    params.Font = font
    params.Width = maxWidth or 1000
    local success, result = pcall(function() return TextService:GetTextBoundsAsync(params) end)
    return success and result or Vector2.new(#text * fontSize * 0.5, fontSize)
end

function Util.Round(num, decimals)
    local mult = 10^(decimals or 0)
    return math.floor(num * mult + 0.5) / mult
end

function Util.Lerp(a, b, t) return a + (b - a) * t end
function Util.LerpColor(c1, c2, t)
    return Color3.new(Util.Lerp(c1.R, c2.R, t), Util.Lerp(c1.G, c2.G, t), Util.Lerp(c1.B, c2.B, t))
end

function Util.Clamp(v, min, max) return math.max(min, math.min(max, v)) end

function Util.IsBright(color)
    return 0.299 * color.R + 0.587 * color.G + 0.114 * color.B > 0.6
end

function Util.Contrast(color)
    return Util.IsBright(color) and Color3.fromRGB(20,20,30) or Color3.new(1,1,1)
end

-- ========== THEMES ==========
local Themes = {
    Dark = {
        Name = "Dark",
        Background = Color3.fromRGB(20,20,28),
        Surface = Color3.fromRGB(30,30,40),
        Accent = Color3.fromRGB(88,101,242),
        Text = Color3.new(1,1,1),
        TextMuted = Color3.fromRGB(180,180,190),
        Close = Color3.fromRGB(237,66,69),
        Minimize = Color3.fromRGB(88,101,242),
        Shadow = Color3.fromRGB(0,0,0),
        Card = Color3.fromRGB(35,35,45),
        CardHover = Color3.fromRGB(45,45,55),
        ToggleOn = Color3.fromRGB(88,101,242),
        ToggleOff = Color3.fromRGB(70,70,80),
        Slider = Color3.fromRGB(70,70,80),
        SliderFill = Color3.fromRGB(88,101,242),
        Input = Color3.fromRGB(40,40,50),
        InputBorder = Color3.fromRGB(70,70,85),
    },
    Light = {
        Name = "Light",
        Background = Color3.fromRGB(240,240,250),
        Surface = Color3.fromRGB(230,230,240),
        Accent = Color3.fromRGB(88,101,242),
        Text = Color3.fromRGB(20,20,30),
        TextMuted = Color3.fromRGB(100,100,110),
        Close = Color3.fromRGB(237,66,69),
        Minimize = Color3.fromRGB(88,101,242),
        Shadow = Color3.fromRGB(0,0,0),
        Card = Color3.fromRGB(255,255,255),
        CardHover = Color3.fromRGB(245,245,255),
        ToggleOn = Color3.fromRGB(88,101,242),
        ToggleOff = Color3.fromRGB(200,200,210),
        Slider = Color3.fromRGB(200,200,210),
        SliderFill = Color3.fromRGB(88,101,242),
        Input = Color3.fromRGB(255,255,255),
        InputBorder = Color3.fromRGB(200,200,210),
    }
}
local CurrentTheme = Themes.Dark
local CustomTheme = nil  -- store user‑edited theme

-- ========== MAIN LIBRARY ==========
local UI = {}
UI.Themes = Themes
UI.CurrentTheme = CurrentTheme
UI.Windows = {}
UI.Flags = {}
UI.Connections = {}
UI.ToggleKey = Enum.KeyCode.RightShift
UI.UnloadKey = Enum.KeyCode.End

-- File functions (if executor supports)
local function hasFile() return pcall(function() return writefile and readfile and isfile and makefolder end) end
local ThemeFile = "crimson_theme.json"

function UI:SaveCustomTheme(theme)
    if not hasFile() then return false end
    local data = {}
    for k, v in pairs(theme) do
        if typeof(v) == "Color3" then
            data[k] = {R=v.R, G=v.G, B=v.B}
        elseif type(v) == "string" or type(v) == "number" or type(v) == "boolean" then
            data[k] = v
        end
    end
    local json = HttpService:JSONEncode(data)
    pcall(function() writefile(ThemeFile, json) end)
    return true
end

function UI:LoadCustomTheme()
    if not hasFile() or not isfile(ThemeFile) then return false end
    local json = readfile(ThemeFile)
    local data = HttpService:JSONDecode(json)
    local theme = {}
    for k, v in pairs(data) do
        if type(v) == "table" and v.R then
            theme[k] = Color3.new(v.R, v.G, v.B)
        else
            theme[k] = v
        end
    end
    CustomTheme = theme
    return theme
end

function UI:SetTheme(name)
    if Themes[name] then
        CurrentTheme = Themes[name]
        CustomTheme = nil
    elseif name == "Custom" and CustomTheme then
        CurrentTheme = CustomTheme
    end
    self:_refreshAllWindows()
end

function UI:ToggleTheme()
    self:SetTheme(CurrentTheme.Name == "Dark" and "Light" or "Dark")
end

function UI:_refreshAllWindows()
    for _, win in ipairs(self.Windows) do
        if win and win.Refresh then win:Refresh() end
    end
end

-- ========== WINDOW CREATION ==========
function UI.New(config)
    config = config or {}
    local title = config.Title or "UI"
    local size = config.Size or UDim2.new(0, 400, 0, 500)
    local themeName = config.Theme or "Dark"
    local currentTheme = Themes[themeName] or Themes.Dark
    if config.CustomTheme then currentTheme = config.CustomTheme end

    -- GUI Hierarchy
    local screenGui = Util.Create("ScreenGui", {
        Name = "Crimson_" .. title:gsub("%s+",""),
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = 100,
        IgnoreGuiInset = true,
        Parent = (function()
            local success = pcall(function() return CoreGui end)
            return success and CoreGui or LocalPlayer:WaitForChild("PlayerGui")
        end)()
    })

    -- Shadow
    local shadow = Util.Create("ImageLabel", {
        Name = "Shadow",
        AnchorPoint = Vector2.new(0.5,0.5),
        Position = UDim2.new(0.5,0,0.5,0),
        Size = UDim2.new(0, size.X.Offset+20, 0, size.Y.Offset+20),
        BackgroundTransparency = 1,
        Image = "rbxassetid://1316045217",
        ImageColor3 = currentTheme.Shadow,
        ImageTransparency = 0.6,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(10,10,118,118),
        ZIndex = 0,
        Parent = screenGui
    })

    -- Main frame
    local main = Util.Create("Frame", {
        Name = "Main",
        AnchorPoint = Vector2.new(0.5,0.5),
        Position = UDim2.new(0.5,0,0.5,0),
        Size = UDim2.new(0,0,0,0), -- start small for intro
        BackgroundColor3 = currentTheme.Background,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        ZIndex = 1,
        Parent = screenGui
    }, {
        Util.Create("UICorner", {CornerRadius = UDim.new(0,12)}),
        Util.Create("UIStroke", {Color = currentTheme.Surface, Thickness = 1.5})
    })

    -- Header
    local header = Util.Create("Frame", {
        Name = "Header",
        Size = UDim2.new(1,0,0,45),
        BackgroundColor3 = currentTheme.Surface,
        BorderSizePixel = 0,
        ZIndex = 2,
        Parent = main
    }, {
        Util.Create("UICorner", {CornerRadius = UDim.new(0,12)}),
        Util.Create("Frame", {  -- cover the bottom corners
            Name = "Cover",
            Position = UDim2.new(0,0,0.5,0),
            Size = UDim2.new(1,0,0.5,0),
            BackgroundColor3 = currentTheme.Surface,
            BorderSizePixel = 0,
            ZIndex = 2
        })
    })

    -- Drag handle
    local dragHandle = Util.Create("Frame", {
        Name = "Drag",
        Size = UDim2.new(1,-100,1,0),
        BackgroundTransparency = 1,
        Active = true,
        ZIndex = 3,
        Parent = header
    })

    -- Title icon + text
    Util.Create("TextLabel", {
        Name = "Icon",
        Size = UDim2.new(0,30,0,30),
        Position = UDim2.new(0,12,0.5,0),
        AnchorPoint = Vector2.new(0,0.5),
        BackgroundTransparency = 1,
        Text = "⚡",
        TextSize = 20,
        Font = Enum.Font.GothamBold,
        TextColor3 = currentTheme.Text,
        ZIndex = 3,
        Parent = header
    })
    local titleLabel = Util.Create("TextLabel", {
        Name = "Title",
        Size = UDim2.new(1,-130,1,0),
        Position = UDim2.new(0,45,0,0),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = currentTheme.Text,
        Font = Enum.Font.GothamBold,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 3,
        Parent = header
    })

    -- Header controls (theme toggle, search, minimize, close)
    local controls = Util.Create("Frame", {
        Name = "Controls",
        Size = UDim2.new(0,160,0,30),
        Position = UDim2.new(1,-20,0.5,0),
        AnchorPoint = Vector2.new(1,0.5),
        BackgroundTransparency = 1,
        ZIndex = 3,
        Parent = header
    })
    local controlsLayout = Util.Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0,6),
        Parent = controls
    })

    -- Light/Dark toggle
    local themeToggle = Util.Create("TextButton", {
        Name = "ThemeToggle",
        Size = UDim2.new(0,30,0,30),
        BackgroundColor3 = currentTheme.Accent,
        Text = CurrentTheme.Name == "Dark" and "☀️" or "🌙",
        TextColor3 = Util.Contrast(currentTheme.Accent),
        Font = Enum.Font.GothamBold,
        TextSize = 18,
        AutoButtonColor = false,
        LayoutOrder = 1,
        ZIndex = 4,
        Parent = controls
    }, {Util.Create("UICorner", {CornerRadius = UDim.new(0,8)})})

    -- Search button
    local searchBtn = Util.Create("TextButton", {
        Name = "Search",
        Size = UDim2.new(0,30,0,30),
        BackgroundColor3 = currentTheme.Surface,
        Text = "🔍",
        TextColor3 = currentTheme.TextMuted,
        Font = Enum.Font.GothamBold,
        TextSize = 16,
        AutoButtonColor = false,
        LayoutOrder = 2,
        ZIndex = 4,
        Parent = controls
    }, {Util.Create("UICorner", {CornerRadius = UDim.new(0,8)})})

    -- Minimize
    local minBtn = Util.Create("TextButton", {
        Name = "Minimize",
        Size = UDim2.new(0,30,0,30),
        BackgroundColor3 = currentTheme.Minimize,
        Text = "−",
        TextColor3 = currentTheme.Text,
        Font = Enum.Font.GothamBold,
        TextSize = 20,
        AutoButtonColor = false,
        LayoutOrder = 3,
        ZIndex = 4,
        Parent = controls
    }, {Util.Create("UICorner", {CornerRadius = UDim.new(0,8)})})

    -- Close
    local closeBtn = Util.Create("TextButton", {
        Name = "Close",
        Size = UDim2.new(0,30,0,30),
        BackgroundColor3 = currentTheme.Close,
        Text = "x",
        TextColor3 = currentTheme.Text,
        Font = Enum.Font.GothamBold,
        TextSize = 16,
        AutoButtonColor = false,
        LayoutOrder = 4,
        ZIndex = 4,
        Parent = controls
    }, {Util.Create("UICorner", {CornerRadius = UDim.new(0,8)})})

    -- Content area
    local content = Util.Create("Frame", {
        Name = "Content",
        Size = UDim2.new(1,-20,1,-65),
        Position = UDim2.new(0,10,0,55),
        BackgroundTransparency = 1,
        ZIndex = 1,
        Parent = main
    })

    -- Search overlay (hidden initially)
    local searchOverlay = Util.Create("Frame", {
        Name = "SearchOverlay",
        BackgroundColor3 = currentTheme.Background,
        Position = UDim2.new(0,0,0,0),
        Size = UDim2.new(1,0,1,0),
        Visible = false,
        ZIndex = 20,
        Parent = main
    }, {Util.Create("UICorner", {CornerRadius = UDim.new(0,12)})})

    local searchTopbar = Util.Create("Frame", {
        Name = "Topbar",
        BackgroundColor3 = currentTheme.Surface,
        Size = UDim2.new(1,0,0,45),
        ZIndex = 21,
        Parent = searchOverlay
    }, {Util.Create("UICorner", {CornerRadius = UDim.new(0,12)})})

    local searchInput = Util.Create("TextBox", {
        Name = "Input",
        Size = UDim2.new(1,-120,0,30),
        Position = UDim2.new(0,12,0.5,0),
        AnchorPoint = Vector2.new(0,0.5),
        BackgroundColor3 = currentTheme.Input,
        Text = "",
        PlaceholderText = "Search...",
        PlaceholderColor3 = currentTheme.TextMuted,
        TextColor3 = currentTheme.Text,
        Font = Enum.Font.Gotham,
        TextSize = 14,
        ClearTextOnFocus = false,
        ZIndex = 22,
        Parent = searchTopbar
    }, {
        Util.Create("UICorner", {CornerRadius = UDim.new(0,8)}),
        Util.Create("UIStroke", {Color = currentTheme.InputBorder, Thickness = 1})
    })

    local searchClose = Util.Create("TextButton", {
        Name = "Close",
        Size = UDim2.new(0,80,0,30),
        Position = UDim2.new(1,-92,0.5,0),
        AnchorPoint = Vector2.new(1,0.5),
        BackgroundColor3 = currentTheme.Close,
        Text = "Close",
        TextColor3 = Util.Contrast(currentTheme.Close),
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        AutoButtonColor = false,
        ZIndex = 22,
        Parent = searchTopbar
    }, {Util.Create("UICorner", {CornerRadius = UDim.new(0,8)})})

    local searchResults = Util.Create("ScrollingFrame", {
        Name = "Results",
        BackgroundTransparency = 1,
        Size = UDim2.new(1,-20,1,-55),
        Position = UDim2.new(0,10,0,50),
        CanvasSize = UDim2.new(0,0,0,0),
        ScrollBarThickness = 4,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ZIndex = 21,
        Parent = searchOverlay
    }, {
        Util.Create("UIListLayout", {Padding = UDim.new(0,6), SortOrder = Enum.SortOrder.LayoutOrder}),
        Util.Create("UIPadding", {PaddingTop = UDim.new(0,4), PaddingBottom = UDim.new(0,8)})
    })

    -- Tab container (for multiple tabs, but we'll keep simple)
    local tabContainer = Util.Create("Frame", {
        Name = "Tabs",
        BackgroundTransparency = 1,
        Size = UDim2.new(1,0,1,0),
        Parent = content
    })

    -- We'll store elements per tab
    local tabs = {}
    local currentTab = nil

    -- Window object
    local window = {
        Gui = screenGui,
        Main = main,
        Header = header,
        Content = content,
        TabContainer = tabContainer,
        Tabs = tabs,
        CurrentTheme = currentTheme,
        Title = title,
        Size = size,
        Minimized = false,
        SearchOpen = false,
        SearchOverlay = searchOverlay,
        SearchInput = searchInput,
        SearchResults = searchResults,
        _elements = {},  -- for search indexing
    }

    -- Responsive constraints
    Util.Create("UISizeConstraint", {MaxSize = Vector2.new(500, 800), Parent = main})

    -- ========== DRAG ==========
    local dragging, dragStart, startPos = false, nil, nil
    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = main.Position
            screenGui.DisplayOrder = screenGui.DisplayOrder + 1
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            shadow.Position = main.Position
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    -- ========== MINIMIZE / CLOSE ==========
    local originalSize = size
    local minimizedSize = UDim2.new(0, size.X.Offset, 0, 45)
    local originalShadowSize = UDim2.new(0, size.X.Offset+20, 0, size.Y.Offset+20)
    local minimizedShadowSize = UDim2.new(0, size.X.Offset+20, 0, 45+20)

    function window:Minimize()
        if self.Minimized then return end
        self.Minimized = true
        minBtn.Text = "+"
        -- Hide content
        for _, child in ipairs(content:GetDescendants()) do
            if child:IsA("GuiObject") then
                Util.Tween(child, 0.2, {BackgroundTransparency = 1, TextTransparency = 1})
            end
        end
        Util.Tween(main, 0.3, {Size = minimizedSize})
        Util.Tween(shadow, 0.3, {Size = minimizedShadowSize})
        content.Visible = false
    end

    function window:Maximize()
        if not self.Minimized then return end
        self.Minimized = false
        minBtn.Text = "−"
        content.Visible = true
        Util.Tween(main, 0.4, {Size = originalSize}, Enum.EasingStyle.Back)
        Util.Tween(shadow, 0.4, {Size = originalShadowSize}, Enum.EasingStyle.Back)
        for _, child in ipairs(content:GetDescendants()) do
            if child:IsA("GuiObject") then
                child.BackgroundTransparency = 0
                child.TextTransparency = 0
            end
        end
    end

    minBtn.MouseButton1Click:Connect(function()
        if window.Minimized then window:Maximize() else window:Minimize() end
    end)

    closeBtn.MouseButton1Click:Connect(function()
        -- Outro animation
        Util.Tween(main, 0.25, {
            Size = UDim2.new(0,0,0,0),
            Position = UDim2.new(main.Position.X.Scale, main.Position.X.Offset, main.Position.Y.Scale, main.Position.Y.Offset + (window.Minimized and 20 or 170))
        }, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
        Util.Tween(shadow, 0.25, {Size = UDim2.new(0,0,0,0), ImageTransparency = 1})
        for _, obj in ipairs({header, titleLabel, minBtn, closeBtn, themeToggle, searchBtn}) do
            Util.Tween(obj, 0.2, {BackgroundTransparency = 1, TextTransparency = 1})
        end
        task.delay(0.3, function() screenGui:Destroy() end)
    end)

    -- ========== THEME TOGGLE ==========
    themeToggle.MouseButton1Click:Connect(function()
        UI:ToggleTheme()
        window:Refresh()
    end)

    -- ========== SEARCH ==========
    searchBtn.MouseButton1Click:Connect(function()
        window.SearchOpen = true
        searchOverlay.Visible = true
        searchInput:CaptureFocus()
        window:_performSearch("")
    end)

    searchClose.MouseButton1Click:Connect(function()
        window.SearchOpen = false
        searchOverlay.Visible = false
        searchInput:ReleaseFocus()
    end)

    searchInput:GetPropertyChangedSignal("Text"):Connect(function()
        window:_performSearch(searchInput.Text)
    end)

    function window:_performSearch(query)
        -- Clear previous results
        for _, child in ipairs(searchResults:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end
        query = query:lower()
        local found = 0
        for _, elem in ipairs(self._elements) do
            if elem.Name and elem.Name:lower():find(query) or elem.Type and elem.Type:lower():find(query) then
                found = found + 1
                local btn = Util.Create("TextButton", {
                    Size = UDim2.new(1,0,0,36),
                    BackgroundColor3 = CurrentTheme.Card,
                    Text = "",
                    AutoButtonColor = false,
                    LayoutOrder = found,
                    Parent = searchResults
                }, {
                    Util.Create("UICorner", {CornerRadius = UDim.new(0,8)}),
                    Util.Create("TextLabel", {
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0,12,0,0),
                        Size = UDim2.new(1,-24,1,0),
                        Font = Enum.Font.GothamMedium,
                        Text = elem.Name .. "  [" .. elem.Type .. "]",
                        TextColor3 = CurrentTheme.Text,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        ZIndex = 22
                    })
                })
                btn.MouseButton1Click:Connect(function()
                    -- Focus the element? For now just close search
                    window.SearchOpen = false
                    searchOverlay.Visible = false
                end)
            end
        end
        if found == 0 then
            Util.Create("TextLabel", {
                Size = UDim2.new(1,0,0,36),
                BackgroundTransparency = 1,
                Font = Enum.Font.Gotham,
                Text = "No results",
                TextColor3 = CurrentTheme.TextMuted,
                Parent = searchResults
            })
        end
    end

    -- ========== INTRO ANIMATION ==========
    main.Size = UDim2.new(0,0,0,0)
    shadow.ImageTransparency = 1
    Util.Tween(shadow, 0.5, {ImageTransparency = 0.6, Size = originalShadowSize})
    Util.Tween(main, 0.5, {Size = originalSize}, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

    -- ========== TAB CREATION ==========
    function window:Tab(name)
        local tabFrame = Util.Create("ScrollingFrame", {
            Name = name,
            BackgroundTransparency = 1,
            Size = UDim2.new(1,0,1,0),
            Visible = false,
            CanvasSize = UDim2.new(0,0,0,0),
            ScrollBarThickness = 4,
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Parent = self.TabContainer
        }, {
            Util.Create("UIListLayout", {Padding = UDim.new(0,8), SortOrder = Enum.SortOrder.LayoutOrder}),
            Util.Create("UIPadding", {PaddingLeft = UDim.new(0,6), PaddingRight = UDim.new(0,6), PaddingTop = UDim.new(0,8)})
        })

        local tabObj = {
            Frame = tabFrame,
            Name = name,
            Window = self,
            _elements = {}
        }

        table.insert(self.Tabs, tabObj)
        if #self.Tabs == 1 then
            currentTab = tabObj
            tabFrame.Visible = true
        end

        -- ========== ELEMENT CREATORS ==========
        function tabObj:Section(title)
            local section = Util.Create("TextLabel", {
                Size = UDim2.new(1,0,0,20),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamBold,
                Text = title:upper(),
                TextColor3 = CurrentTheme.Accent,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = self.Frame
            })
            table.insert(self._elements, {Type="Section", Name=title, Object=section})
            return section
        end

        function tabObj:Button(config)
            local name = config.Name or "Button"
            local callback = config.Callback or function() end
            local btn = Util.Create("TextButton", {
                Size = UDim2.new(1,0,0,45),
                BackgroundColor3 = CurrentTheme.Card,
                Text = "",
                AutoButtonColor = false,
                Parent = self.Frame
            }, {
                Util.Create("UICorner", {CornerRadius = UDim.new(0,10)}),
                Util.Create("UIGradient", {  -- subtle gradient
                    Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.new(1,1,1)), ColorSequenceKeypoint.new(1, Color3.fromRGB(230,230,240))}),
                    Rotation = 90
                }),
                Util.Create("TextLabel", {
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0,12,0,0),
                    Size = UDim2.new(1,-24,1,0),
                    Font = Enum.Font.GothamBold,
                    Text = name,
                    TextColor3 = CurrentTheme.Text,
                    TextSize = 15,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 2
                })
            })

            btn.MouseEnter:Connect(function()
                Util.Tween(btn, 0.2, {BackgroundColor3 = CurrentTheme.CardHover})
            end)
            btn.MouseLeave:Connect(function()
                Util.Tween(btn, 0.2, {BackgroundColor3 = CurrentTheme.Card})
            end)
            btn.MouseButton1Click:Connect(function()
                Util.Tween(btn, 0.1, {Size = UDim2.new(0.98,0,0,43), Position = UDim2.new(0.01,0,0, btn.Position.Y.Offset+1)})
                task.delay(0.1, function()
                    Util.Tween(btn, 0.1, {Size = UDim2.new(1,0,0,45), Position = UDim2.new(0,0,0, btn.Position.Y.Offset-1)})
                end)
                callback()
            end)

            table.insert(self._elements, {Type="Button", Name=name, Object=btn})
            return btn
        end

        function tabObj:Toggle(config)
            local name = config.Name or "Toggle"
            local flag = config.Flag
            local default = config.Default or false
            local callback = config.Callback or function() end

            local state = default
            if flag then UI.Flags[flag] = state end

            local frame = Util.Create("Frame", {
                Size = UDim2.new(1,0,0,40),
                BackgroundColor3 = CurrentTheme.Card,
                Parent = self.Frame
            }, {
                Util.Create("UICorner", {CornerRadius = UDim.new(0,8)}),
                Util.Create("TextLabel", {
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0,12,0,0),
                    Size = UDim2.new(1,-70,1,0),
                    Font = Enum.Font.GothamMedium,
                    Text = name,
                    TextColor3 = CurrentTheme.Text,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
            })

            local toggleBg = Util.Create("Frame", {
                BackgroundColor3 = state and CurrentTheme.ToggleOn or CurrentTheme.ToggleOff,
                Position = UDim2.new(1,-50,0.5,-10),
                Size = UDim2.new(0,44,0,20),
                Parent = frame
            }, {
                Util.Create("UICorner", {CornerRadius = UDim.new(1,0)})
            })
            local knob = Util.Create("Frame", {
                BackgroundColor3 = Color3.new(1,1,1),
                Position = state and UDim2.new(1,-22,0.5,-8) or UDim2.new(0,2,0.5,-8),
                Size = UDim2.new(0,16,0,16),
                Parent = toggleBg
            }, {Util.Create("UICorner", {CornerRadius = UDim.new(1,0)})})

            local function setState(new)
                state = new
                if flag then UI.Flags[flag] = state end
                Util.Tween(toggleBg, 0.25, {BackgroundColor3 = state and CurrentTheme.ToggleOn or CurrentTheme.ToggleOff})
                Util.Tween(knob, 0.25, {Position = state and UDim2.new(1,-22,0.5,-8) or UDim2.new(0,2,0.5,-8)})
                callback(state)
            end

            local btn = Util.Create("TextButton", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1,0,1,0),
                Text = "",
                Parent = frame
            })
            btn.MouseButton1Click:Connect(function() setState(not state) end)

            frame.MouseEnter:Connect(function()
                Util.Tween(frame, 0.15, {BackgroundColor3 = CurrentTheme.CardHover})
            end)
            frame.MouseLeave:Connect(function()
                Util.Tween(frame, 0.15, {BackgroundColor3 = CurrentTheme.Card})
            end)

            table.insert(self._elements, {Type="Toggle", Name=name, Object=frame, Set=setState})
            return {Set = setState, Get = function() return state end}
        end

        function tabObj:Slider(config)
            local name = config.Name or "Slider"
            local min = config.Min or 0
            local max = config.Max or 100
            local default = config.Default or min
            local suffix = config.Suffix or ""
            local flag = config.Flag
            local callback = config.Callback or function() end

            local value = Util.Clamp(default, min, max)
            if flag then UI.Flags[flag] = value end

            local frame = Util.Create("Frame", {
                Size = UDim2.new(1,0,0,50),
                BackgroundColor3 = CurrentTheme.Card,
                Parent = self.Frame
            }, {
                Util.Create("UICorner", {CornerRadius = UDim.new(0,8)}),
                Util.Create("TextLabel", {
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0,12,0,8),
                    Size = UDim2.new(1,-100,0,18),
                    Font = Enum.Font.GothamMedium,
                    Text = name,
                    TextColor3 = CurrentTheme.Text,
                    TextXAlignment = Enum.TextXAlignment.Left
                }),
                Util.Create("TextLabel", {
                    Name = "ValueLabel",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(1,-80,0,8),
                    Size = UDim2.new(0,50,0,18),
                    Font = Enum.Font.GothamMedium,
                    Text = tostring(value) .. suffix,
                    TextColor3 = CurrentTheme.Accent,
                    TextXAlignment = Enum.TextXAlignment.Right
                })
            })

            local track = Util.Create("Frame", {
                BackgroundColor3 = CurrentTheme.Slider,
                Position = UDim2.new(0,12,1,-25),
                Size = UDim2.new(1,-24,0,6),
                Parent = frame
            }, {Util.Create("UICorner", {CornerRadius = UDim.new(1,0)})})

            local fill = Util.Create("Frame", {
                BackgroundColor3 = CurrentTheme.SliderFill,
                Size = UDim2.new((value-min)/(max-min),0,1,0),
                Parent = track
            }, {Util.Create("UICorner", {CornerRadius = UDim.new(1,0)})})

            local knob = Util.Create("Frame", {
                BackgroundColor3 = Color3.new(1,1,1),
                Position = UDim2.new((value-min)/(max-min), -8, 0.5, -8),
                Size = UDim2.new(0,16,0,16),
                ZIndex = 5,
                Parent = track
            }, {Util.Create("UICorner", {CornerRadius = UDim.new(1,0)})})

            -- Tooltip
            local tooltip = Util.Create("Frame", {
                BackgroundColor3 = CurrentTheme.Surface,
                Position = UDim2.new(0.5,0,0,-26),
                AnchorPoint = Vector2.new(0.5,1),
                Size = UDim2.new(0,40,0,20),
                Visible = false,
                ZIndex = 10,
                Parent = knob
            }, {
                Util.Create("UICorner", {CornerRadius = UDim.new(0,4)}),
                Util.Create("TextLabel", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1,0,1,0),
                    Font = Enum.Font.GothamMedium,
                    Text = tostring(value) .. suffix,
                    TextColor3 = CurrentTheme.Text,
                    TextSize = 11
                })
            })
            knob.MouseEnter:Connect(function() tooltip.Visible = true end)
            knob.MouseLeave:Connect(function() tooltip.Visible = false end)

            local dragging = false
            local function update(val)
                value = Util.Clamp(val, min, max)
                local percent = (value-min)/(max-min)
                fill.Size = UDim2.new(percent,0,1,0)
                knob.Position = UDim2.new(percent, -8, 0.5, -8)
                tooltip.TextLabel.Text = tostring(value) .. suffix
                frame.ValueLabel.Text = tostring(value) .. suffix
                if flag then UI.Flags[flag] = value end
                callback(value)
            end

            track.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                    local rel = (input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X
                    update(min + rel * (max-min))
                end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    local rel = (input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X
                    update(min + rel * (max-min))
                end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = false
                end
            end)

            table.insert(self._elements, {Type="Slider", Name=name, Object=frame})
            return {Set = update, Get = function() return value end}
        end

                -- ========== ADDITIONAL ELEMENTS ==========

        function tabObj:Dropdown(config)
            local name = config.Name or "Dropdown"
            local options = config.Options or {}
            local default = config.Default or options[1]
            local flag = config.Flag
            local callback = config.Callback or function() end
            local multi = config.Multi or false

            local selected = multi and {} or default
            if multi and type(default) == "table" then
                for _, v in ipairs(default) do selected[v] = true end
            end
            if flag then UI.Flags[flag] = selected end

            local expanded = false
            local frame = Util.Create("Frame", {
                Size = UDim2.new(1,0,0,40),
                BackgroundColor3 = CurrentTheme.Card,
                ClipsDescendants = true,
                Parent = self.Frame
            }, {
                Util.Create("UICorner", {CornerRadius = UDim.new(0,8)}),
                Util.Create("TextLabel", {
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0,12,0,0),
                    Size = UDim2.new(1,-70,1,0),
                    Font = Enum.Font.GothamMedium,
                    Text = name,
                    TextColor3 = CurrentTheme.Text,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
            })

            local function getDisplay()
                if multi then
                    local items = {}
                    for k, v in pairs(selected) do if v then table.insert(items, k) end end
                    if #items == 0 then return "None" end
                    if #items > 2 then return #items .. " selected" end
                    return table.concat(items, ", ")
                else
                    return tostring(selected)
                end
            end

            local valueLabel = Util.Create("TextLabel", {
                BackgroundTransparency = 1,
                Position = UDim2.new(1,-50,0,0),
                Size = UDim2.new(0,40,1,0),
                Font = Enum.Font.Gotham,
                Text = getDisplay(),
                TextColor3 = CurrentTheme.Accent,
                TextSize = 13,
                TextTruncate = Enum.TextTruncate.AtEnd,
                Parent = frame
            })

            local arrow = Util.Create("TextLabel", {
                BackgroundTransparency = 1,
                Position = UDim2.new(1,-30,0,0),
                Size = UDim2.new(0,20,1,0),
                Font = Enum.Font.GothamBold,
                Text = "▼",
                TextColor3 = CurrentTheme.TextMuted,
                TextSize = 10,
                Parent = frame
            })

            local optionsHeight = #options * 32 + 8
            local optionsList = Util.Create("ScrollingFrame", {
                BackgroundTransparency = 1,
                Position = UDim2.new(0,8,0,40),
                Size = UDim2.new(1,-16,0,0),
                CanvasSize = UDim2.new(0,0,0,optionsHeight-8),
                ScrollBarThickness = 4,
                Visible = false,
                Parent = frame
            }, {
                Util.Create("UIListLayout", {Padding = UDim.new(0,4), SortOrder = Enum.SortOrder.LayoutOrder}),
                Util.Create("UIPadding", {PaddingTop = UDim.new(0,4)})
            })

            local optionButtons = {}
            local function rebuildOptions()
                for _, btn in ipairs(optionButtons) do btn:Destroy() end
                optionButtons = {}
                for _, opt in ipairs(options) do
                    local isSelected = multi and selected[opt] or selected == opt
                    local btn = Util.Create("TextButton", {
                        Size = UDim2.new(1,0,0,28),
                        BackgroundColor3 = isSelected and CurrentTheme.Accent or CurrentTheme.Input,
                        Text = "",
                        AutoButtonColor = false,
                        Parent = optionsList
                    }, {
                        Util.Create("UICorner", {CornerRadius = UDim.new(0,6)}),
                        Util.Create("TextLabel", {
                            BackgroundTransparency = 1,
                            Position = UDim2.new(0,8,0,0),
                            Size = UDim2.new(1,-16,1,0),
                            Font = Enum.Font.Gotham,
                            Text = opt,
                            TextColor3 = isSelected and Util.Contrast(CurrentTheme.Accent) or CurrentTheme.Text,
                            TextXAlignment = Enum.TextXAlignment.Left,
                            TextSize = 13
                        })
                    })
                    btn.MouseButton1Click:Connect(function()
                        if multi then
                            selected[opt] = not selected[opt]
                        else
                            selected = opt
                        end
                        valueLabel.Text = getDisplay()
                        if flag then UI.Flags[flag] = selected end
                        callback(selected)
                        rebuildOptions()
                        if not multi then
                            toggleExpand()
                        end
                    end)
                    table.insert(optionButtons, btn)
                end
            end
            rebuildOptions()

            local function toggleExpand()
                expanded = not expanded
                local targetHeight = expanded and (40 + optionsHeight) or 40
                Util.Tween(frame, 0.25, {Size = UDim2.new(1,0,0,targetHeight)})
                Util.Tween(arrow, 0.25, {Rotation = expanded and 180 or 0})
                if expanded then
                    optionsList.Visible = true
                else
                    task.delay(0.25, function() if not expanded then optionsList.Visible = false end end)
                end
            end

            local hitbox = Util.Create("TextButton", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1,0,1,0),
                Text = "",
                Parent = frame
            })
            hitbox.MouseButton1Click:Connect(toggleExpand)

            frame.MouseEnter:Connect(function()
                Util.Tween(frame, 0.15, {BackgroundColor3 = CurrentTheme.CardHover})
            end)
            frame.MouseLeave:Connect(function()
                Util.Tween(frame, 0.15, {BackgroundColor3 = CurrentTheme.Card})
            end)

            table.insert(self._elements, {Type="Dropdown", Name=name, Object=frame})
            return {
                Set = function(_, val)
                    if multi and type(val) == "table" then
                        selected = {}
                        for _, v in ipairs(val) do selected[v] = true end
                    else
                        selected = val
                    end
                    valueLabel.Text = getDisplay()
                    rebuildOptions()
                end,
                Get = function() return selected end
            }
        end

        function tabObj:Input(config)
            local name = config.Name or "Input"
            local default = config.Default or ""
            local placeholder = config.Placeholder or "Enter text..."
            local numeric = config.Numeric or false
            local flag = config.Flag
            local callback = config.Callback or function() end

            local value = default
            if flag then UI.Flags[flag] = value end

            local frame = Util.Create("Frame", {
                Size = UDim2.new(1,0,0,60),
                BackgroundColor3 = CurrentTheme.Card,
                Parent = self.Frame
            }, {
                Util.Create("UICorner", {CornerRadius = UDim.new(0,8)}),
                Util.Create("TextLabel", {
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0,12,0,8),
                    Size = UDim2.new(1,-24,0,18),
                    Font = Enum.Font.GothamMedium,
                    Text = name,
                    TextColor3 = CurrentTheme.Text,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
            })

            local box = Util.Create("TextBox", {
                BackgroundColor3 = CurrentTheme.Input,
                Position = UDim2.new(0,12,1,-30),
                Size = UDim2.new(1,-24,0,24),
                Font = Enum.Font.Gotham,
                Text = tostring(value),
                PlaceholderText = placeholder,
                PlaceholderColor3 = CurrentTheme.TextMuted,
                TextColor3 = CurrentTheme.Text,
                TextSize = 14,
                ClearTextOnFocus = false,
                Parent = frame
            }, {
                Util.Create("UICorner", {CornerRadius = UDim.new(0,6)}),
                Util.Create("UIStroke", {Color = CurrentTheme.InputBorder, Thickness = 1})
            })

            box.Focused:Connect(function()
                Util.Tween(box.UIStroke, 0.2, {Color = CurrentTheme.Accent})
            end)
            box.FocusLost:Connect(function(enterPressed)
                Util.Tween(box.UIStroke, 0.2, {Color = CurrentTheme.InputBorder})
                local newValue = box.Text
                if numeric then
                    newValue = tonumber(newValue) or value
                    box.Text = tostring(newValue)
                end
                value = newValue
                if flag then UI.Flags[flag] = value end
                callback(value)
            end)

            frame.MouseEnter:Connect(function()
                Util.Tween(frame, 0.15, {BackgroundColor3 = CurrentTheme.CardHover})
            end)
            frame.MouseLeave:Connect(function()
                Util.Tween(frame, 0.15, {BackgroundColor3 = CurrentTheme.Card})
            end)

            table.insert(self._elements, {Type="Input", Name=name, Object=frame})
            return {
                Set = function(_, val)
                    value = val
                    box.Text = tostring(val)
                end,
                Get = function() return value end
            }
        end

        function tabObj:Keybind(config)
            local name = config.Name or "Keybind"
            local default = config.Default or Enum.KeyCode.Unknown
            local flag = config.Flag
            local callback = config.Callback or function() end
            local changedCallback = config.ChangedCallback or function() end

            local currentKey = default
            local listening = false
            if flag then UI.Flags[flag] = currentKey end

            local function keyName(key)
                if key == Enum.KeyCode.Unknown then return "None" end
                return tostring(key):gsub("Enum.KeyCode.", "")
            end

            local frame = Util.Create("Frame", {
                Size = UDim2.new(1,0,0,40),
                BackgroundColor3 = CurrentTheme.Card,
                Parent = self.Frame
            }, {
                Util.Create("UICorner", {CornerRadius = UDim.new(0,8)}),
                Util.Create("TextLabel", {
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0,12,0,0),
                    Size = UDim2.new(1,-100,1,0),
                    Font = Enum.Font.GothamMedium,
                    Text = name,
                    TextColor3 = CurrentTheme.Text,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
            })

            local keyBtn = Util.Create("TextButton", {
                BackgroundColor3 = CurrentTheme.Input,
                Position = UDim2.new(1,-90,0.5,-15),
                Size = UDim2.new(0,80,0,30),
                Font = Enum.Font.Code,
                Text = keyName(currentKey),
                TextColor3 = CurrentTheme.Text,
                TextSize = 12,
                AutoButtonColor = false,
                Parent = frame
            }, {
                Util.Create("UICorner", {CornerRadius = UDim.new(0,6)})
            })

            local function setListening(state)
                listening = state
                if listening then
                    keyBtn.Text = "..."
                    Util.Tween(keyBtn, 0.2, {BackgroundColor3 = CurrentTheme.Accent, TextColor3 = Util.Contrast(CurrentTheme.Accent)})
                else
                    keyBtn.Text = keyName(currentKey)
                    Util.Tween(keyBtn, 0.2, {BackgroundColor3 = CurrentTheme.Input, TextColor3 = CurrentTheme.Text})
                end
            end

            keyBtn.MouseButton1Click:Connect(function()
                setListening(not listening)
            end)

            local conn
            conn = UserInputService.InputBegan:Connect(function(input, processed)
                if not listening then
                    if not processed and currentKey ~= Enum.KeyCode.Unknown and input.KeyCode == currentKey then
                        callback(currentKey)
                    end
                    return
                end
                if input.UserInputType == Enum.UserInputType.Keyboard then
                    if input.KeyCode == Enum.KeyCode.Escape then
                        setListening(false)
                    elseif input.KeyCode == Enum.KeyCode.Backspace then
                        currentKey = Enum.KeyCode.Unknown
                        setListening(false)
                        changedCallback(currentKey)
                        if flag then UI.Flags[flag] = currentKey end
                    else
                        currentKey = input.KeyCode
                        setListening(false)
                        changedCallback(currentKey)
                        if flag then UI.Flags[flag] = currentKey end
                    end
                end
            end)
            table.insert(UI.Connections, conn)

            frame.MouseEnter:Connect(function()
                Util.Tween(frame, 0.15, {BackgroundColor3 = CurrentTheme.CardHover})
            end)
            frame.MouseLeave:Connect(function()
                Util.Tween(frame, 0.15, {BackgroundColor3 = CurrentTheme.Card})
            end)

            table.insert(self._elements, {Type="Keybind", Name=name, Object=frame})
            return {
                Set = function(_, key) currentKey = key; keyBtn.Text = keyName(key) end,
                Get = function() return currentKey end
            }
        end

        function tabObj:ColorPicker(config)
            local name = config.Name or "Color"
            local default = config.Default or Color3.new(1,1,1)
            local flag = config.Flag
            local callback = config.Callback or function() end

            local color = default
            if flag then UI.Flags[flag] = color end

            local expanded = false
            local frame = Util.Create("Frame", {
                Size = UDim2.new(1,0,0,40),
                BackgroundColor3 = CurrentTheme.Card,
                ClipsDescendants = true,
                Parent = self.Frame
            }, {
                Util.Create("UICorner", {CornerRadius = UDim.new(0,8)}),
                Util.Create("TextLabel", {
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0,12,0,0),
                    Size = UDim2.new(1,-70,1,0),
                    Font = Enum.Font.GothamMedium,
                    Text = name,
                    TextColor3 = CurrentTheme.Text,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
            })

            local preview = Util.Create("Frame", {
                BackgroundColor3 = color,
                Position = UDim2.new(1,-50,0.5,-10),
                Size = UDim2.new(0,40,0,20),
                Parent = frame
            }, {
                Util.Create("UICorner", {CornerRadius = UDim.new(0,6)}),
                Util.Create("UIStroke", {Color = CurrentTheme.CardBorder, Thickness = 1})
            })

            local arrow = Util.Create("TextLabel", {
                BackgroundTransparency = 1,
                Position = UDim2.new(1,-30,0,0),
                Size = UDim2.new(0,20,1,0),
                Font = Enum.Font.GothamBold,
                Text = "▼",
                TextColor3 = CurrentTheme.TextMuted,
                TextSize = 10,
                Parent = frame
            })

            local pickerHeight = 140
            local picker = Util.Create("Frame", {
                BackgroundColor3 = CurrentTheme.Surface,
                Position = UDim2.new(0,8,0,40),
                Size = UDim2.new(1,-16,0,0),
                Visible = false,
                Parent = frame
            }, {
                Util.Create("UICorner", {CornerRadius = UDim.new(0,8)})
            })

            -- Simple HSV square (you can expand with a full color picker)
            local hue = Color3.toHSV(color)
            local satVal = Util.Create("ImageLabel", {
                BackgroundColor3 = Color3.fromHSV(hue,1,1),
                Position = UDim2.new(0,8,0,8),
                Size = UDim2.new(1,-60,1,-16),
                Image = "rbxassetid://4155801252",
                Parent = picker
            }, {Util.Create("UICorner", {CornerRadius = UDim.new(0,6)})})

            local hueBar = Util.Create("ImageLabel", {
                BackgroundColor3 = Color3.new(1,1,1),
                Position = UDim2.new(1,-44,0,8),
                Size = UDim2.new(0,24,1,-16),
                Image = "rbxassetid://4155801635",
                Parent = picker
            }, {Util.Create("UICorner", {CornerRadius = UDim.new(0,4)})})

            -- (Actual picker logic omitted for brevity – can be added later)
            -- For now just a placeholder that updates on click

            local function toggleExpand()
                expanded = not expanded
                local targetHeight = expanded and (40 + pickerHeight) or 40
                Util.Tween(frame, 0.25, {Size = UDim2.new(1,0,0,targetHeight)})
                Util.Tween(arrow, 0.25, {Rotation = expanded and 180 or 0})
                if expanded then
                    picker.Visible = true
                else
                    task.delay(0.25, function() if not expanded then picker.Visible = false end end)
                end
            end

            local hitbox = Util.Create("TextButton", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1,0,1,0),
                Text = "",
                Parent = frame
            })
            hitbox.MouseButton1Click:Connect(toggleExpand)

            frame.MouseEnter:Connect(function()
                Util.Tween(frame, 0.15, {BackgroundColor3 = CurrentTheme.CardHover})
            end)
            frame.MouseLeave:Connect(function()
                Util.Tween(frame, 0.15, {BackgroundColor3 = CurrentTheme.Card})
            end)

            table.insert(self._elements, {Type="ColorPicker", Name=name, Object=frame})
            return {
                Set = function(_, col) color = col; preview.BackgroundColor3 = col end,
                Get = function() return color end
            }
        end

        function tabObj:Divider()
            return Util.Create("Frame", {
                Size = UDim2.new(1,0,0,1),
                BackgroundColor3 = CurrentTheme.TextMuted,
                BackgroundTransparency = 0.7,
                BorderSizePixel = 0,
                Parent = self.Frame
            })
        end

        function tabObj:Label(text)
            return Util.Create("TextLabel", {
                Size = UDim2.new(1,0,0,20),
                BackgroundTransparency = 1,
                Font = Enum.Font.Gotham,
                Text = text,
                TextColor3 = CurrentTheme.TextMuted,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = self.Frame
            })
        end

        function tabObj:Paragraph(title, content)
            local height = Util.GetTextSize(content, 13, Enum.Font.Gotham, 300).Y + 30
            local frame = Util.Create("Frame", {
                Size = UDim2.new(1,0,0,height),
                BackgroundTransparency = 1,
                Parent = self.Frame
            })
            Util.Create("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1,0,0,18),
                Font = Enum.Font.GothamBold,
                Text = title,
                TextColor3 = CurrentTheme.Text,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = frame
            })
            Util.Create("TextLabel", {
                BackgroundTransparency = 1,
                Position = UDim2.new(0,0,0,20),
                Size = UDim2.new(1,0,0,height-20),
                Font = Enum.Font.Gotham,
                Text = content,
                TextColor3 = CurrentTheme.TextMuted,
                TextSize = 13,
                TextWrapped = true,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextYAlignment = Enum.TextYAlignment.Top,
                Parent = frame
            })
            table.insert(self._elements, {Type="Paragraph", Name=title, Object=frame})
            return frame
        end

        return tabObj
    end

    -- ========== REFRESH (theme update) ==========
    function window:Refresh()
        local theme = UI.CurrentTheme
        main.BackgroundColor3 = theme.Background
        main:FindFirstChildOfClass("UIStroke").Color = theme.Surface
        header.BackgroundColor3 = theme.Surface
        header.Cover.BackgroundColor3 = theme.Surface
        titleLabel.TextColor3 = theme.Text
        minBtn.BackgroundColor3 = theme.Minimize
        closeBtn.BackgroundColor3 = theme.Close
        themeToggle.BackgroundColor3 = theme.Accent
        themeToggle.Text = theme.Name == "Dark" and "☀️" or "🌙"
        themeToggle.TextColor3 = Util.Contrast(theme.Accent)
        shadow.ImageColor3 = theme.Shadow

        -- Recursively update elements (simplified; you may want to iterate all children)
        -- In a real library you'd store references to elements and update their colors.
        -- For brevity, we just set the most important ones.
    end

    table.insert(UI.Windows, window)
    return window
end

-- ========== KEYBINDS ==========
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == UI.ToggleKey then
        for _, win in ipairs(UI.Windows) do
            if win and win.Main then
                if win.Main.Visible then
                    win.Main.Visible = false
                    win.Shadow.Visible = false
                else
                    win.Main.Visible = true
                    win.Shadow.Visible = true
                end
            end
        end
    elseif input.KeyCode == UI.UnloadKey then
        for _, win in ipairs(UI.Windows) do
            if win and win.Gui then win.Gui:Destroy() end
        end
        UI.Windows = {}
    end
end)

-- ========== RETURN LIBRARY ==========
return UI
