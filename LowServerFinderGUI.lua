local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local requestFunc = nil
if syn and syn.request then
    requestFunc = syn.request
elseif http and http.request then
    requestFunc = http.request
elseif http_request then
    requestFunc = http_request
elseif fluxus and fluxus.request then
    requestFunc = fluxus.request
elseif request then
    requestFunc = request
else
    error("No supported HTTP request function found! 😢")
end

local gameName = "Unknown"
pcall(function()
    local info = MarketplaceService:GetProductInfo(game.PlaceId)
    gameName = info.Name or gameName
end)

local function MakeDraggable(guiObject)
    local dragging, dragInput, dragStart, startPos
    guiObject.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = guiObject.AbsolutePosition
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    guiObject.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            guiObject.Position = UDim2.new(0, startPos.X + delta.X, 0, startPos.Y + delta.Y)
        end
    end)
end

local LowServerFinder = Instance.new("ScreenGui")
LowServerFinder.Name = "LowServerFinder"
LowServerFinder.Parent = LocalPlayer:WaitForChild("PlayerGui")
LowServerFinder.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = LowServerFinder
MainFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.1267, 0, 0.1183, 0)
MainFrame.Size = UDim2.new(0, 700, 0, 400)

local UICorner_Main = Instance.new("UICorner")
UICorner_Main.CornerRadius = UDim.new(0, 12)
UICorner_Main.Parent = MainFrame

local MainFrameGradient = Instance.new("UIGradient")
MainFrameGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(60, 60, 60)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(30, 30, 30))
})
MainFrameGradient.Parent = MainFrame

local MainFrameStroke = Instance.new("UIStroke")
MainFrameStroke.Thickness = 2
MainFrameStroke.Color = Color3.fromRGB(100, 100, 100)
MainFrameStroke.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Parent = MainFrame
Title.BackgroundTransparency = 1
Title.BorderSizePixel = 0
Title.Position = UDim2.new(0.00857, 0, 0.015, 0)
Title.Size = UDim2.new(0, 574, 0, 30)
Title.Font = Enum.Font.GothamBold
Title.Text = "Server Finder 💻"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextScaled = true
Title.TextWrapped = true
Title.TextXAlignment = Enum.TextXAlignment.Left

local TitleGradient = Instance.new("UIGradient")
TitleGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 200, 200))
})
TitleGradient.Parent = Title

local ServerListFrame = Instance.new("ScrollingFrame")
ServerListFrame.Name = "ServerListFrame"
ServerListFrame.Parent = MainFrame
ServerListFrame.Active = true
ServerListFrame.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
ServerListFrame.BorderSizePixel = 0
ServerListFrame.Position = UDim2.new(0.00857, 0, 0.105, 0)
ServerListFrame.Size = UDim2.new(0, 688, 0, 352)
ServerListFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ServerListFrame.ScrollBarThickness = 4

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = ServerListFrame
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

local ServerFrameTemplate = Instance.new("Frame")
ServerFrameTemplate.Name = "ServerFrame"
ServerFrameTemplate.Parent = ServerListFrame
ServerFrameTemplate.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
ServerFrameTemplate.BorderSizePixel = 0
ServerFrameTemplate.Size = UDim2.new(0, 688, 0, 40)
ServerFrameTemplate.Visible = false

local UICorner_Server = Instance.new("UICorner")
UICorner_Server.CornerRadius = UDim.new(0, 8)
UICorner_Server.Parent = ServerFrameTemplate

local ServerInfo = Instance.new("TextLabel")
ServerInfo.Name = "ServerInfo"
ServerInfo.Parent = ServerFrameTemplate
ServerInfo.BackgroundTransparency = 1
ServerInfo.Position = UDim2.new(0.02, 0, 0, 0)
ServerInfo.Size = UDim2.new(0.75, 0, 1, 0)
ServerInfo.Font = Enum.Font.SourceSans
ServerInfo.Text = string.format("Server: %s | gameId: %s (ServerId: %s)\n👥 %d / %d", gameName, tostring(game.PlaceId), "N/A", 0, 0)
ServerInfo.TextColor3 = Color3.fromRGB(255, 255, 255)
ServerInfo.TextScaled = true
ServerInfo.TextWrapped = true
ServerInfo.TextXAlignment = Enum.TextXAlignment.Left

local Join = Instance.new("TextButton")
Join.Name = "Join"
Join.Parent = ServerFrameTemplate
Join.BackgroundColor3 = Color3.fromRGB(85, 85, 255)
Join.BorderSizePixel = 0
Join.Position = UDim2.new(0.83, 0, 0, 0)
Join.Size = UDim2.new(0, 114, 0, 40)
Join.Font = Enum.Font.SourceSans
Join.Text = "Join 🚀"
Join.TextColor3 = Color3.fromRGB(255, 255, 255)
Join.TextScaled = true
Join.TextWrapped = true

local Close = Instance.new("TextButton")
Close.Name = "Close"
Close.Parent = MainFrame
Close.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
Close.BorderSizePixel = 0
Close.Position = UDim2.new(0.91286, 0, 0, 0)
Close.Size = UDim2.new(0, 55, 0, 36)
Close.Font = Enum.Font.SourceSans
Close.Text = "x"
Close.TextColor3 = Color3.fromRGB(255, 255, 255)
Close.TextScaled = true
Close.TextWrapped = true

local UICorner_Close = Instance.new("UICorner")
UICorner_Close.CornerRadius = UDim.new(0, 8)
UICorner_Close.Parent = Close

local HideShow = Instance.new("TextButton")
HideShow.Name = "HideShow"
HideShow.Parent = LowServerFinder
HideShow.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
HideShow.BorderSizePixel = 0
HideShow.Position = UDim2.new(-0.001, 0, 0.46565, 0)
HideShow.Size = UDim2.new(0, 55, 0, 36)
HideShow.Font = Enum.Font.SourceSans
HideShow.Text = "Hide"
HideShow.TextColor3 = Color3.fromRGB(255, 255, 255)
HideShow.TextScaled = true
HideShow.TextWrapped = true

local UICorner_HideShow = Instance.new("UICorner")
UICorner_HideShow.CornerRadius = UDim.new(0, 8)
UICorner_HideShow.Parent = HideShow

local HideShowGradient = Instance.new("UIGradient")
HideShowGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 220, 0)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 180, 0))
})
HideShowGradient.Parent = HideShow

local isHidden = false
HideShow.MouseButton1Click:Connect(function()
    if not isHidden then
        local tweenOut = TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 1})
        tweenOut:Play()
        tweenOut.Completed:Connect(function()
            MainFrame.Visible = false
            HideShow.Text = "Show"
            isHidden = true
        end)
    else
        MainFrame.Visible = true
        local tweenIn = TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 0})
        tweenIn:Play()
        HideShow.Text = "Hide"
        isHidden = false
    end
end)

Close.MouseButton1Click:Connect(function()
    local tweenClose = TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {BackgroundTransparency = 1})
    tweenClose:Play()
    tweenClose.Completed:Connect(function()
        LowServerFinder:Destroy()
    end)
end)

UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    ServerListFrame.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y)
end)

local function createServerEntry(serverData)
    local clone = ServerFrameTemplate:Clone()
    clone.Name = "ServerFrameClone"
    clone.Visible = true
    clone.Parent = ServerListFrame

    local serverInfoLabel = clone:FindFirstChild("ServerInfo")
    serverInfoLabel.Text = string.format("Server: %s | gameId: %s (ServerId: %s)\n👥 %d / %d", 
        gameName, tostring(game.PlaceId), tostring(serverData.id), serverData.playing, serverData.maxPlayers)

    local joinButton = clone:FindFirstChild("Join")
    joinButton.MouseButton1Click:Connect(function()
        TeleportService:TeleportToPlaceInstance(game.PlaceId, serverData.id, LocalPlayer)
    end)
end

local function fetchServers(cursor)
    local url = string.format("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100", game.PlaceId)
    if cursor then
        url = url .. "&cursor=" .. cursor
    end
    local response = requestFunc({
        Url = url,
        Method = "GET"
    })
    if response and response.Body then
        return HttpService:JSONDecode(response.Body)
    end
end

spawn(function()
    local servers = {}
    local cursor = nil
    repeat
        local data = fetchServers(cursor)
        if data and data.data then
            for _, server in ipairs(data.data) do
                table.insert(servers, server)
            end
            cursor = data.nextPageCursor
        else
            break
        end
    until not cursor

    table.sort(servers, function(a, b)
        return a.playing < b.playing
    end)

    for _, server in ipairs(servers) do
        if server.playing < server.maxPlayers then
            createServerEntry(server)
        end
    end
end)

MakeDraggable(MainFrame)
MakeDraggable(HideShow)
