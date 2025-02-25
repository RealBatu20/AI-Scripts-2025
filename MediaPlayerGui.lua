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

local function extractFileName(url)
    local parts = url:split("/")
    local filePart = parts[#parts] or "video.mp4"
    filePart = filePart:split("?")[1] or filePart
    return filePart
end

local function loadVideo(videoUrl, fileName, videoFrame, statusLabel)
    if not (isfolder and makefolder and writefile and getcustomasset and isfile) then
        videoFrame.Video = videoUrl
        statusLabel.Text = "Loaded (No local file functions) 😅"
        return
    end
    if not isfolder("MediaPlayer") then
        makefolder("MediaPlayer")
    end
    local filePath = "MediaPlayer/" .. fileName
    if isfile(filePath) then
        videoFrame.Video = getcustomasset(filePath)
        statusLabel.Text = "100% | " .. string.format("%.2f", #readfile(filePath)/(1024*1024)) .. "MB"
        return
    end
    statusLabel.Text = "Loading 0% | 0MB"
    local response
    local success, result = pcall(function()
        return httpRequestFunc({
            Url = videoUrl,
            Method = "GET",
            Headers = {["Content-Type"] = "application/octet-stream"}
        })
    end)
    if not success then
        statusLabel.Text = "Download failed! 😢"
        return
    end
    response = result
    local body = response.Body or response.body or ""
    pcall(function() writefile(filePath, body) end)
    local sizeMB = #body / (1024 * 1024)
    statusLabel.Text = "100% | " .. string.format("%.2f", sizeMB) .. "MB"
    videoFrame.Video = getcustomasset(filePath)
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MediaPlayerGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game:GetService("CoreGui")
if syn and syn.protect_gui then
    syn.protect_gui(ScreenGui)
end

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(25,25,25)
MainFrame.AnchorPoint = Vector2.new(0.5,0.5)
MainFrame.Position = UDim2.new(0.5,0,0.5,0)
-- Fixed size: 640x500 pixels
MainFrame.Size = UDim2.new(0,640,0,500)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true  -- Ensure draggability even when children are removed

local function updateGUISize()
    if UserInputService.TouchEnabled then
        MainFrame.Size = UDim2.new(0,640,0,500)
    else
        MainFrame.Size = UDim2.new(0,640,0,500)
    end
end
updateGUISize()
local originalSize = MainFrame.Size

local MainUICorner = Instance.new("UICorner", MainFrame)
MainUICorner.CornerRadius = UDim.new(0,12)

local UIStroke = Instance.new("UIStroke", MainFrame)
UIStroke.Thickness = 2
UIStroke.Color = Color3.new(1,0,0)
local function animateStroke()
    local tweenInfo = TweenInfo.new(2,Enum.EasingStyle.Linear,Enum.EasingDirection.InOut,-1,true)
    local tween = TweenService:Create(UIStroke,tweenInfo,{Color = Color3.new(0,1,0)})
    tween:Play()
end
animateStroke()

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "TitleLabel"
TitleLabel.Parent = MainFrame
TitleLabel.BackgroundTransparency = 1
TitleLabel.Position = UDim2.new(0,16,0,8)
TitleLabel.Size = UDim2.new(1,-100,0,30)
TitleLabel.Text = "🎬 Media Player Gui"
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 24
TitleLabel.TextColor3 = Color3.new(1,1,1)
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Parent = MainFrame
CloseButton.BackgroundColor3 = Color3.fromRGB(200,50,50)
CloseButton.Size = UDim2.new(0,30,0,30)
CloseButton.Position = UDim2.new(1,-35,0,5)
CloseButton.Text = "❌"
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextSize = 18
CloseButton.TextColor3 = Color3.new(1,1,1)
local CloseUICorner = Instance.new("UICorner", CloseButton)
CloseUICorner.CornerRadius = UDim.new(0,8)
CloseButton.MouseButton1Click:Connect(function()
    local tween = TweenService:Create(MainFrame, TweenInfo.new(0.3,Enum.EasingStyle.Quad,Enum.EasingDirection.Out), {Transparency = 1})
    tween:Play()
    tween.Completed:Connect(function()
        ScreenGui:Destroy()
    end)
end)

local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Name = "MinimizeButton"
MinimizeButton.Parent = MainFrame
MinimizeButton.BackgroundColor3 = Color3.fromRGB(70,130,180)
MinimizeButton.Size = UDim2.new(0,30,0,30)
MinimizeButton.Position = UDim2.new(1,-70,0,5)
MinimizeButton.Text = "➖"
MinimizeButton.Font = Enum.Font.GothamBold
MinimizeButton.TextSize = 18
MinimizeButton.TextColor3 = Color3.new(1,1,1)
local MinimizeUICorner = Instance.new("UICorner", MinimizeButton)
MinimizeUICorner.CornerRadius = UDim.new(0,8)
local isMinimized = false
MinimizeButton.MouseButton1Click:Connect(function()
    if not isMinimized then
        local tween = TweenService:Create(MainFrame, TweenInfo.new(0.3,Enum.EasingStyle.Quad,Enum.EasingDirection.Out), {Size = UDim2.new(originalSize.X.Scale, originalSize.X.Offset, 0, 50)})
        tween:Play()
        for _, child in ipairs(MainFrame:GetChildren()) do
            if child:IsA("GuiObject") and child.Name ~= "TitleLabel" and child.Name ~= "CloseButton" and child.Name ~= "MinimizeButton" and child.Name ~= "UIStroke" then
                child.Visible = false
            end
        end
        isMinimized = true
        MinimizeButton.Text = "➕"
    else
        local tween = TweenService:Create(MainFrame, TweenInfo.new(0.3,Enum.EasingStyle.Quad,Enum.EasingDirection.Out), {Size = originalSize})
        tween:Play()
        for _, child in ipairs(MainFrame:GetChildren()) do
            if child:IsA("GuiObject") and child.Name ~= "TitleLabel" and child.Name ~= "CloseButton" and child.Name ~= "MinimizeButton" and child.Name ~= "UIStroke" then
                child.Visible = true
            end
        end
        isMinimized = false
        MinimizeButton.Text = "➖"
    end
end)

local ContentFrame = Instance.new("ScrollingFrame")
ContentFrame.Name = "ContentFrame"
ContentFrame.Parent = MainFrame
ContentFrame.BackgroundTransparency = 1
ContentFrame.Position = UDim2.new(0,16,0,50)
ContentFrame.Size = UDim2.new(1,-32,1,-66)
ContentFrame.CanvasSize = UDim2.new(0,0,0,0)
ContentFrame.ScrollBarThickness = 4
local ContentUICorner = Instance.new("UICorner", ContentFrame)
ContentUICorner.CornerRadius = UDim.new(0,8)

local ContentLayout = Instance.new("UIListLayout", ContentFrame)
ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
ContentLayout.Padding = UDim.new(0,8)
ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    ContentFrame.CanvasSize = UDim2.new(0,0,0,ContentLayout.AbsoluteContentSize.Y)
end)

local PlayerContainer = Instance.new("Frame")
PlayerContainer.Name = "PlayerContainer"
PlayerContainer.Parent = ContentFrame
PlayerContainer.BackgroundTransparency = 1
PlayerContainer.Size = UDim2.new(1,0,0,300)

local PlaylistFrame = Instance.new("ScrollingFrame")
PlaylistFrame.Name = "PlaylistFrame"
PlaylistFrame.Parent = PlayerContainer
PlaylistFrame.BackgroundColor3 = Color3.fromRGB(40,40,40)
PlaylistFrame.BorderSizePixel = 0
PlaylistFrame.Position = UDim2.new(0,0,0,0)
PlaylistFrame.Size = UDim2.new(0.25, -4, 1, 0)
PlaylistFrame.CanvasSize = UDim2.new(0,0,0,0)
PlaylistFrame.ScrollBarThickness = 4
local PlaylistUICorner = Instance.new("UICorner", PlaylistFrame)
PlaylistUICorner.CornerRadius = UDim.new(0,8)
local PlaylistLayout = Instance.new("UIListLayout", PlaylistFrame)
PlaylistLayout.SortOrder = Enum.SortOrder.LayoutOrder
PlaylistLayout.Padding = UDim.new(0,4)
PlaylistLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    PlaylistFrame.CanvasSize = UDim2.new(0,0,0,PlaylistLayout.AbsoluteContentSize.Y)
end)

local VideoFrame = Instance.new("VideoFrame")
VideoFrame.Name = "VideoFrame"
VideoFrame.Parent = PlayerContainer
VideoFrame.BackgroundColor3 = Color3.fromRGB(0,0,0)
VideoFrame.Size = UDim2.new(0.75, -4, 1, 0)
VideoFrame.Position = UDim2.new(0.25, 4, 0, 0)
VideoFrame.Video = ""
VideoFrame.Looped = false

local ControlsFrame = Instance.new("Frame")
ControlsFrame.Name = "ControlsFrame"
ControlsFrame.Parent = ContentFrame
ControlsFrame.BackgroundTransparency = 1
ControlsFrame.Size = UDim2.new(1,0,0,40)

local PlayButton = Instance.new("TextButton")
PlayButton.Name = "PlayButton"
PlayButton.Parent = ControlsFrame
PlayButton.BackgroundColor3 = Color3.fromRGB(70,130,180)
PlayButton.Size = UDim2.new(0,100,0,30)
PlayButton.Position = UDim2.new(0,10,0,5)
PlayButton.Text = "Play ▶️"
PlayButton.Font = Enum.Font.GothamBold
PlayButton.TextSize = 18
PlayButton.TextColor3 = Color3.new(1,1,1)
local PlayButtonUICorner = Instance.new("UICorner", PlayButton)
PlayButtonUICorner.CornerRadius = UDim.new(0,8)

local PauseButton = Instance.new("TextButton")
PauseButton.Name = "PauseButton"
PauseButton.Parent = ControlsFrame
PauseButton.BackgroundColor3 = Color3.fromRGB(70,130,180)
PauseButton.Size = UDim2.new(0,100,0,30)
PauseButton.Position = UDim2.new(0,120,0,5)
PauseButton.Text = "Pause ⏸️"
PauseButton.Font = Enum.Font.GothamBold
PauseButton.TextSize = 18
PauseButton.TextColor3 = Color3.new(1,1,1)
local PauseButtonUICorner = Instance.new("UICorner", PauseButton)
PauseButtonUICorner.CornerRadius = UDim.new(0,8)

local StopButton = Instance.new("TextButton")
StopButton.Name = "StopButton"
StopButton.Parent = ControlsFrame
StopButton.BackgroundColor3 = Color3.fromRGB(70,130,180)
StopButton.Size = UDim2.new(0,100,0,30)
StopButton.Position = UDim2.new(0,230,0,5)
StopButton.Text = "Stop ⏹️"
StopButton.Font = Enum.Font.GothamBold
StopButton.TextSize = 18
StopButton.TextColor3 = Color3.new(1,1,1)
local StopButtonUICorner = Instance.new("UICorner", StopButton)
StopButtonUICorner.CornerRadius = UDim.new(0,8)

local VideoUrlBox = Instance.new("TextBox")
VideoUrlBox.Name = "VideoUrlBox"
VideoUrlBox.Parent = ContentFrame
VideoUrlBox.PlaceholderText = "Paste video URL here..."
VideoUrlBox.Text = ""
VideoUrlBox.ClearTextOnFocus = false
VideoUrlBox.BackgroundColor3 = Color3.fromRGB(50,50,50)
VideoUrlBox.TextColor3 = Color3.new(1,1,1)
VideoUrlBox.Font = Enum.Font.Gotham
VideoUrlBox.TextSize = 18
VideoUrlBox.Size = UDim2.new(1,0,0,30)
VideoUrlBox.TextXAlignment = Enum.TextXAlignment.Left
local UrlBoxUICorner = Instance.new("UICorner", VideoUrlBox)
UrlBoxUICorner.CornerRadius = UDim.new(0,8)

local LoadButton = Instance.new("TextButton")
LoadButton.Name = "LoadButton"
LoadButton.Parent = ContentFrame
LoadButton.BackgroundColor3 = Color3.fromRGB(70,130,180)
LoadButton.Size = UDim2.new(0,120,0,30)
LoadButton.Text = "Load Video 🎥"
LoadButton.Font = Enum.Font.GothamBold
LoadButton.TextSize = 18
LoadButton.TextColor3 = Color3.new(1,1,1)
local LoadButtonUICorner = Instance.new("UICorner", LoadButton)
LoadButtonUICorner.CornerRadius = UDim.new(0,8)

local StatusFrame = Instance.new("Frame")
StatusFrame.Name = "StatusFrame"
StatusFrame.Parent = MainFrame
StatusFrame.BackgroundTransparency = 1
StatusFrame.AnchorPoint = Vector2.new(0.5,1)
StatusFrame.Position = UDim2.new(0.5,0,1,-10)
StatusFrame.Size = UDim2.new(0.8,0,0,20)

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Name = "StatusLabel"
StatusLabel.Parent = StatusFrame
StatusLabel.Size = UDim2.new(1,0,1,0)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Loading: 0% | 0MB"
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextSize = 16
StatusLabel.TextColor3 = Color3.new(1,1,1)
StatusLabel.TextXAlignment = Enum.TextXAlignment.Center
StatusLabel.TextYAlignment = Enum.TextYAlignment.Center

LoadButton.MouseButton1Click:Connect(function()
    local url = VideoUrlBox.Text
    if url == "" then return end
    local fileName = extractFileName(url)
    loadVideo(url, fileName, VideoFrame, StatusLabel)
    -- Refresh PlaylistFrame: Remove buttons for non-existing files and add new ones.
    if isfolder and listfiles then
        for _, child in ipairs(PlaylistFrame:GetChildren()) do
            if child:IsA("TextButton") then
                if not isfile("MediaPlayer/" .. child.Text) then
                    child:Destroy()
                end
            end
        end
        local exists = false
        for _, btn in ipairs(PlaylistFrame:GetChildren()) do
            if btn:IsA("TextButton") and btn.Text == fileName then
                exists = true
                break
            end
        end
        if not exists then
            local pButton = Instance.new("TextButton")
            pButton.Parent = PlaylistFrame
            pButton.Size = UDim2.new(1,0,0,30)
            pButton.Text = fileName
            pButton.Font = Enum.Font.GothamBold
            pButton.TextSize = 16
            pButton.BackgroundColor3 = Color3.fromRGB(70,130,180)
            pButton.TextColor3 = Color3.new(1,1,1)
            local pCorner = Instance.new("UICorner", pButton)
            pCorner.CornerRadius = UDim.new(0,8)
            pButton.MouseButton1Click:Connect(function()
                local filePath = "MediaPlayer/" .. fileName
                if isfile(filePath) then
                    VideoFrame.Video = getcustomasset(filePath)
                    StatusLabel.Text = "Loaded: " .. fileName
                else
                    pButton:Destroy()
                end
            end)
        end
    end
end)

PlayButton.MouseButton1Click:Connect(function()
    VideoFrame:Play()
end)

PauseButton.MouseButton1Click:Connect(function()
    VideoFrame:Pause()
end)

StopButton.MouseButton1Click:Connect(function()
    VideoFrame.TimePosition = 0
    VideoFrame:Pause()
end)

local function loadPlaylist()
    if isfolder and listfiles then
        for _, child in ipairs(PlaylistFrame:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end
        local files = listfiles("MediaPlayer")
        for _, file in ipairs(files) do
            if file:match("%.mp4$") and isfile(file) then
                local fileName = file:match("([^/\\]+)$")
                local pButton = Instance.new("TextButton")
                pButton.Parent = PlaylistFrame
                pButton.Size = UDim2.new(1,0,0,30)
                pButton.Text = fileName
                pButton.Font = Enum.Font.GothamBold
                pButton.TextSize = 16
                pButton.BackgroundColor3 = Color3.fromRGB(70,130,180)
                pButton.TextColor3 = Color3.new(1,1,1)
                local pCorner = Instance.new("UICorner", pButton)
                pCorner.CornerRadius = UDim.new(0,8)
                pButton.MouseButton1Click:Connect(function()
                    VideoFrame.Video = getcustomasset(file)
                    StatusLabel.Text = "Loaded: " .. fileName
                end)
            end
        end
    end
end
loadPlaylist()

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
