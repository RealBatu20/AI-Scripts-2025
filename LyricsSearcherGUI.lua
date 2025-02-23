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
ScreenGui.Name = "LyricsSearcherGui"
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
MainFrame.Size = UDim2.new(0, 300, 0, 370)
MainFrame.BorderSizePixel = 0

local UICorner = Instance.new("UICorner", MainFrame)
UICorner.CornerRadius = UDim.new(0, 12)

local UIStroke = Instance.new("UIStroke", MainFrame)
UIStroke.Thickness = 2
UIStroke.Color = Color3.new(1, 0, 0)  -- Starting with red

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
TitleLabel.Position = UDim2.new(0, 20, 0, 5)
TitleLabel.Size = UDim2.new(1, -40, 0, 30)
TitleLabel.Text = "🎵 Lyrics Searcher"
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 20
TitleLabel.TextColor3 = Color3.new(1,1,1)
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

local HideButton = Instance.new("TextButton")
HideButton.Name = "HideButton"
HideButton.Parent = MainFrame
HideButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
HideButton.Size = UDim2.new(0, 30, 0, 30)
HideButton.Position = UDim2.new(1, -70, 0, 5)
HideButton.Text = "🔽"
HideButton.Font = Enum.Font.GothamBold
HideButton.TextColor3 = Color3.new(1, 1, 1)
HideButton.TextSize = 18
local HideButtonUICorner = Instance.new("UICorner", HideButton)
HideButtonUICorner.CornerRadius = UDim.new(0, 8)

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
local CloseButtonUICorner = Instance.new("UICorner", CloseButton)
CloseButtonUICorner.CornerRadius = UDim.new(0, 8)

CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
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

local ArtistInput = Instance.new("TextBox")
ArtistInput.Name = "ArtistInput"
ArtistInput.Parent = MainFrame
ArtistInput.PlaceholderText = "🎵 Artist"
ArtistInput.ClearTextOnFocus = false
ArtistInput.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
ArtistInput.TextColor3 = Color3.new(1, 1, 1)
ArtistInput.Font = Enum.Font.Gotham
ArtistInput.TextSize = 16
ArtistInput.Text = ""
ArtistInput.Position = UDim2.new(0, 20, 0, 40)
ArtistInput.Size = UDim2.new(1, -40, 0, 40)
local ArtistUICorner = Instance.new("UICorner", ArtistInput)
ArtistUICorner.CornerRadius = UDim.new(0, 8)

local TitleInput = Instance.new("TextBox")
TitleInput.Name = "TitleInput"
TitleInput.Parent = MainFrame
TitleInput.PlaceholderText = "🎤 Title"
TitleInput.ClearTextOnFocus = false
TitleInput.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
TitleInput.TextColor3 = Color3.new(1, 1, 1)
TitleInput.Font = Enum.Font.Gotham
TitleInput.TextSize = 16
TitleInput.Text = ""
TitleInput.Position = UDim2.new(0, 20, 0, 85)
TitleInput.Size = UDim2.new(1, -40, 0, 40)
local TitleUICorner = Instance.new("UICorner", TitleInput)
TitleUICorner.CornerRadius = UDim.new(0, 8)

local SearchButton = Instance.new("TextButton")
SearchButton.Name = "SearchButton"
SearchButton.Parent = MainFrame
SearchButton.BackgroundColor3 = Color3.fromRGB(70, 130, 180)
SearchButton.Size = UDim2.new(1, -40, 0, 40)
SearchButton.Position = UDim2.new(0, 20, 0, 130)
SearchButton.Text = "🔍 Search Lyrics"
SearchButton.Font = Enum.Font.GothamBold
SearchButton.TextColor3 = Color3.new(1, 1, 1)
SearchButton.TextSize = 18
local SearchButtonUICorner = Instance.new("UICorner", SearchButton)
SearchButtonUICorner.CornerRadius = UDim.new(0, 8)

local SaveLyricsButton = Instance.new("TextButton")
SaveLyricsButton.Name = "SaveLyricsButton"
SaveLyricsButton.Parent = MainFrame
SaveLyricsButton.BackgroundColor3 = Color3.fromRGB(34, 139, 34)
SaveLyricsButton.Size = UDim2.new(1, -40, 0, 40)
SaveLyricsButton.Position = UDim2.new(0, 20, 0, 175)
SaveLyricsButton.Text = "💾 Save Lyrics"
SaveLyricsButton.Font = Enum.Font.GothamBold
SaveLyricsButton.TextColor3 = Color3.new(1, 1, 1)
SaveLyricsButton.TextSize = 18
local SaveLyricsButtonUICorner = Instance.new("UICorner", SaveLyricsButton)
SaveLyricsButtonUICorner.CornerRadius = UDim.new(0, 8)

local LyricsFrame = Instance.new("ScrollingFrame")
LyricsFrame.Name = "LyricsFrame"
LyricsFrame.Parent = MainFrame
LyricsFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
LyricsFrame.BorderSizePixel = 0
LyricsFrame.Position = UDim2.new(0, 20, 0, 220)
LyricsFrame.Size = UDim2.new(1, -40, 0, 120)
LyricsFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
LyricsFrame.ScrollBarThickness = 8

local LyricsUICorner = Instance.new("UICorner", LyricsFrame)
LyricsUICorner.CornerRadius = UDim.new(0, 8)

local LyricsUIListLayout = Instance.new("UIListLayout", LyricsFrame)
LyricsUIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
LyricsUIListLayout.Padding = UDim.new(0, 8)

LyricsUIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    LyricsFrame.CanvasSize = UDim2.new(0, 0, 0, LyricsUIListLayout.AbsoluteContentSize.Y)
end)

local LocationLabel = Instance.new("TextLabel")
LocationLabel.Name = "LocationLabel"
LocationLabel.Parent = MainFrame
LocationLabel.BackgroundTransparency = 1
LocationLabel.Position = UDim2.new(0, 20, 0, 345)
LocationLabel.Size = UDim2.new(1, -40, 0, 20)
LocationLabel.Text = "Saved at: N/A"
LocationLabel.Font = Enum.Font.Gotham
LocationLabel.TextSize = 14
LocationLabel.TextColor3 = Color3.new(1, 1, 1)
LocationLabel.TextXAlignment = Enum.TextXAlignment.Left

local lastLyrics = ""

local function displayLyrics(text)
    lastLyrics = text
    for _, child in pairs(LyricsFrame:GetChildren()) do
        if child:IsA("TextLabel") then
            child:Destroy()
        end
    end
    local lines = string.split(text, "\n")
    for i, line in ipairs(lines) do
        local lineLabel = Instance.new("TextLabel")
        lineLabel.Name = "Line_" .. i
        lineLabel.Parent = LyricsFrame
        lineLabel.BackgroundTransparency = 1
        lineLabel.Text = line
        lineLabel.TextColor3 = Color3.new(1, 1, 1)
        lineLabel.Font = Enum.Font.Gotham
        lineLabel.TextSize = 16
        lineLabel.TextWrapped = true
        lineLabel.Size = UDim2.new(1, 0, 0, 20)
    end
end

local function searchLyrics()
    local artist = ArtistInput.Text
    local title = TitleInput.Text
    if artist == "" or title == "" then
        displayLyrics("Please enter both artist and title! 🚫")
        return
    end

    local urlArtist = HttpService:UrlEncode(artist)
    local urlTitle = HttpService:UrlEncode(title)
    local url = "https://api.lyrics.ovh/v1/" .. urlArtist .. "/" .. urlTitle

    local response
    local success, result = pcall(function()
        return httpRequestFunc({
            Url = url,
            Method = "GET",
            Headers = {["Content-Type"] = "application/json"}
        })
    end)
    if not success then
        displayLyrics("Request failed! 😢")
        return
    end
    response = result
    local body = response.Body or response.body
    local data
    pcall(function() data = HttpService:JSONDecode(body) end)
    if data and data.lyrics then
        displayLyrics(data.lyrics)
    else
        displayLyrics("Lyrics not found! 😔")
    end
end

SearchButton.MouseButton1Click:Connect(function()
    searchLyrics()
end)

local function saveLyrics()
    local artist = ArtistInput.Text
    local title = TitleInput.Text
    if artist == "" or title == "" or lastLyrics == "" then
        displayLyrics("No lyrics available to save! 🚫")
        return
    end

    if not isfolder or not makefolder or not writefile then
        displayLyrics("Local file functions unavailable! 😤")
        return
    end

    if not isfolder("SavedLyrics") then
        makefolder("SavedLyrics")
    end

    local fileName = "SavedLyrics/" .. artist .. " - " .. title .. ".txt"
    pcall(function()
        writefile(fileName, lastLyrics)
    end)
    LocationLabel.Text = "Saved at: " .. fileName
end

SaveLyricsButton.MouseButton1Click:Connect(function()
    saveLyrics()
end)

local isExpanded = true
local collapsedSize = UDim2.new(0, 300, 0, 40)
local expandedSize = UDim2.new(0, 300, 0, 370)
local toggleElements = {
    ArtistInput,
    TitleInput,
    SearchButton,
    SaveLyricsButton,
    LyricsFrame,
    LocationLabel
}

HideButton.MouseButton1Click:Connect(function()
    isExpanded = not isExpanded
    if isExpanded then
        -- Expand GUI
        local tween = TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = expandedSize})
        tween:Play()
        for _, element in ipairs(toggleElements) do
            element.Visible = true
        end
        HideButton.Text = "🔽"
    else
        -- Collapse GUI
        local tween = TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = collapsedSize})
        tween:Play()
        for _, element in ipairs(toggleElements) do
            element.Visible = false
        end
        HideButton.Text = "🔼"
    end
end)
