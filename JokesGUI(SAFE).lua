local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local function getHttpRequest()
    if syn and syn.request then
        return syn.request
    elseif http and http.request then
        return http.request
    elseif http_request then
        return http_request
    elseif fluxus and fluxus.request then
        return fluxus.request
    elseif request then
        return request
    else
        error("No supported HTTP request method available! 😤")
    end
end
local httpRequestFunc = getHttpRequest()

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "JokesGui2"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game:GetService("CoreGui")
if syn and syn.protect_gui then
    syn.protect_gui(ScreenGui)
end

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.Size = UDim2.new(0, 360, 0, 230)
MainFrame.BorderSizePixel = 0

local UICorner = Instance.new("UICorner", MainFrame)
UICorner.CornerRadius = UDim.new(0, 12)

local UIStroke = Instance.new("UIStroke", MainFrame)
UIStroke.Thickness = 2
UIStroke.Color = Color3.new(1, 0, 0)  -- Start with red

local function animateStroke()
    local tweenInfo = TweenInfo.new(2, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1, true)
    local tween = TweenService:Create(UIStroke, tweenInfo, {Color = Color3.new(0, 1, 0)})
    tween:Play()
end
animateStroke()

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "TitleLabel"
TitleLabel.Parent = MainFrame
TitleLabel.BackgroundTransparency = 1
TitleLabel.Position = UDim2.new(0, 8, 0, 8)
TitleLabel.Size = UDim2.new(1, -50, 0, 24)
TitleLabel.Text = "😂 Jokes Gui (SAFE)"
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 20
TitleLabel.TextColor3 = Color3.new(1, 1, 1)
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Parent = MainFrame
CloseButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -35, 0, 5)
CloseButton.Text = "❌"
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextColor3 = Color3.new(1, 1, 1)
CloseButton.TextSize = 18
local CloseUICorner = Instance.new("UICorner", CloseButton)
CloseUICorner.CornerRadius = UDim.new(0, 8)

CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

local FromInput = Instance.new("TextBox")
FromInput.Name = "FromInput"
FromInput.Parent = MainFrame
FromInput.PlaceholderText = "From: 0"
FromInput.Text = ""
FromInput.ClearTextOnFocus = false
FromInput.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
FromInput.TextColor3 = Color3.new(1, 1, 1)
FromInput.Font = Enum.Font.Gotham
FromInput.TextSize = 16
FromInput.Size = UDim2.new(0, 160, 0, 30)
FromInput.Position = UDim2.new(0, 8, 0, 40)
local FromUICorner = Instance.new("UICorner", FromInput)
FromUICorner.CornerRadius = UDim.new(0, 8)

local ToInput = Instance.new("TextBox")
ToInput.Name = "ToInput"
ToInput.Parent = MainFrame
ToInput.PlaceholderText = "To: 1367"
ToInput.Text = ""
ToInput.ClearTextOnFocus = false
ToInput.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
ToInput.TextColor3 = Color3.new(1, 1, 1)
ToInput.Font = Enum.Font.Gotham
ToInput.TextSize = 16
ToInput.Size = UDim2.new(0, 160, 0, 30)
ToInput.Position = UDim2.new(0, 188, 0, 40)
local ToUICorner = Instance.new("UICorner", ToInput)
ToUICorner.CornerRadius = UDim.new(0, 8)

local SearchButton = Instance.new("TextButton")
SearchButton.Name = "SearchButton"
SearchButton.Parent = MainFrame
SearchButton.BackgroundColor3 = Color3.fromRGB(70, 130, 180)
SearchButton.Size = UDim2.new(0, 344, 0, 30)
SearchButton.Position = UDim2.new(0, 8, 0, 80)
SearchButton.Text = "🔍 Get Joke"
SearchButton.Font = Enum.Font.GothamBold
SearchButton.TextColor3 = Color3.new(1, 1, 1)
SearchButton.TextSize = 18
local SearchButtonUICorner = Instance.new("UICorner", SearchButton)
SearchButtonUICorner.CornerRadius = UDim.new(0, 8)

local JokeFrame = Instance.new("ScrollingFrame")
JokeFrame.Name = "JokeFrame"
JokeFrame.Parent = MainFrame
JokeFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
JokeFrame.BorderSizePixel = 0
JokeFrame.Position = UDim2.new(0, 4, 0, 120)
JokeFrame.Size = UDim2.new(0, 352, 0, 90)
JokeFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
JokeFrame.ScrollBarThickness = 2
local JokeFrameUICorner = Instance.new("UICorner", JokeFrame)
JokeFrameUICorner.CornerRadius = UDim.new(0, 8)

local JokeUIListLayout = Instance.new("UIListLayout", JokeFrame)
JokeUIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
JokeUIListLayout.Padding = UDim.new(0, 8)
JokeUIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    JokeFrame.CanvasSize = UDim2.new(0, 0, 0, JokeUIListLayout.AbsoluteContentSize.Y)
end)

local function clearJokeDisplay()
    for _, child in ipairs(JokeFrame:GetChildren()) do
        if child:IsA("TextLabel") then
            child:Destroy()
        end
    end
end

local function displayJoke(text)
    clearJokeDisplay()
    local lines = string.split(text, "\n")
    for i, line in ipairs(lines) do
        local lineLabel = Instance.new("TextLabel")
        lineLabel.Name = "Line_" .. i
        lineLabel.Parent = JokeFrame
        lineLabel.BackgroundTransparency = 1
        lineLabel.Text = line
        lineLabel.TextColor3 = Color3.new(1, 1, 1)
        lineLabel.Font = Enum.Font.Gotham
        lineLabel.TextSize = 16
        lineLabel.TextWrapped = true
        lineLabel.Size = UDim2.new(0, 352, 0, 45)
    end
end

local function fetchJoke()
    local lowerBound = tonumber(FromInput.Text) or 0
    local upperBound = tonumber(ToInput.Text) or 1367

    local url = "https://v2.jokeapi.dev/joke/Programming,Miscellaneous,Pun,Spooky,Christmas?blacklistFlags=nsfw,sexist,explicit"
    
    local response
    local success, result = pcall(function()
        return httpRequestFunc({
            Url = url,
            Method = "GET",
            Headers = {["Content-Type"] = "application/json"}
        })
    end)
    
    if not success then
        displayJoke("Request failed! 😢")
        return
    end

    response = result
    local body = response.Body or response.body
    local data
    pcall(function() data = HttpService:JSONDecode(body) end)
    
    if not data or data.error then
        displayJoke("No joke found! 😔")
        return
    end
    
    if data.id < lowerBound or data.id > upperBound then
        displayJoke("Joke ID " .. data.id .. " not in range " .. lowerBound .. " to " .. upperBound .. " 😕")
        return
    end

    if data.type == "single" then
        displayJoke(data.joke)
    elseif data.type == "twopart" then
        displayJoke(data.setup .. "\n" .. data.delivery)
    else
        displayJoke("Unknown joke type! 🤔")
    end
end

SearchButton.MouseButton1Click:Connect(function()
    fetchJoke()
end)

local dragging, dragInput, dragStart, startPos
local function update(input)
    local delta = input.Position - dragStart
    MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

MainFrame.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        dragInput = input
        update(dragInput)
    end
end)
