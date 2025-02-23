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

local function loadImage(imageUrl, fileName, imageLabel)
    if not (isfolder and makefolder and writefile and getcustomasset and isfile) then
        imageLabel.Image = imageUrl
        return
    end
    if not isfolder("CachedImages") then
        makefolder("CachedImages")
    end
    local filePath = "CachedImages/" .. fileName .. ".jpg"
    if isfile(filePath) then
        imageLabel.Image = getcustomasset(filePath)
        return
    end
    local response
    local success, result = pcall(function()
        return httpRequestFunc({
            Url = imageUrl,
            Method = "GET",
            Headers = {["Content-Type"] = "application/octet-stream"}
        })
    end)
    if success then
        response = result
        local body = response.Body or response.body or ""
        pcall(function() writefile(filePath, body) end)
        imageLabel.Image = getcustomasset(filePath)
    else
        imageLabel.Image = imageUrl
    end
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MyAnimeListGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game:GetService("CoreGui")
if syn and syn.protect_gui then
    syn.protect_gui(ScreenGui)
end

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.Size = UDim2.new(0, 640, 0, 500)
MainFrame.BorderSizePixel = 0

local function updateGUISize()
    if UserInputService.TouchEnabled then
        MainFrame.Size = UDim2.new(0, 640, 0, 500)
    else
        MainFrame.Size = UDim2.new(0, 640, 0, 500)
    end
end
updateGUISize()
local originalSize = MainFrame.Size

local MainUICorner = Instance.new("UICorner", MainFrame)
MainUICorner.CornerRadius = UDim.new(0, 12)

local UIStroke = Instance.new("UIStroke", MainFrame)
UIStroke.Thickness = 2
UIStroke.Color = Color3.new(1, 0, 0)
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
TitleLabel.Position = UDim2.new(0, 16, 0, 8)
TitleLabel.Size = UDim2.new(1, -60, 0, 30)
TitleLabel.Text = "📺 MyAnimeList Gui"
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 24
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
CloseButton.TextSize = 18
CloseButton.TextColor3 = Color3.new(1, 1, 1)
local CloseUICorner = Instance.new("UICorner", CloseButton)
CloseUICorner.CornerRadius = UDim.new(0, 8)
CloseButton.MouseButton1Click:Connect(function()
	ScreenGui:Destroy()
end)

local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Name = "MinimizeButton"
MinimizeButton.Parent = MainFrame
MinimizeButton.BackgroundColor3 = Color3.fromRGB(70, 130, 180)
MinimizeButton.Size = UDim2.new(0, 30, 0, 30)
MinimizeButton.Position = UDim2.new(1, -70, 0, 5)
MinimizeButton.Text = "➖"
MinimizeButton.Font = Enum.Font.GothamBold
MinimizeButton.TextSize = 18
MinimizeButton.TextColor3 = Color3.new(1,1,1)
local MinimizeUICorner = Instance.new("UICorner", MinimizeButton)
MinimizeUICorner.CornerRadius = UDim.new(0, 8)

local isMinimized = false
MinimizeButton.MouseButton1Click:Connect(function()
    if not isMinimized then
        local tween = TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(MainFrame.Size.X.Scale, MainFrame.Size.X.Offset, 0, 50)})
        tween:Play()
        for _, child in ipairs(MainFrame:GetChildren()) do
            if child:IsA("GuiObject") and child.Name ~= "TitleLabel" and child.Name ~= "CloseButton" and child.Name ~= "MinimizeButton" and child.Name ~= "UIStroke" then
                child.Visible = false
            end
        end
        isMinimized = true
        MinimizeButton.Text = "➕"
    else
        local tween = TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = originalSize})
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

local TabsFrame = Instance.new("Frame")
TabsFrame.Name = "TabsFrame"
TabsFrame.Parent = MainFrame
TabsFrame.BackgroundTransparency = 1
TabsFrame.Position = UDim2.new(0, 16, 0, 48)
TabsFrame.Size = UDim2.new(1, -32, 0, 40)

local SearchTabButton = Instance.new("TextButton")
SearchTabButton.Name = "SearchTabButton"
SearchTabButton.Parent = TabsFrame
SearchTabButton.BackgroundColor3 = Color3.fromRGB(70, 130, 180)
SearchTabButton.Size = UDim2.new(0.5, -4, 1, 0)
SearchTabButton.Position = UDim2.new(0, 0, 0, 0)
SearchTabButton.Text = "🔍 Search Animes"
SearchTabButton.Font = Enum.Font.GothamBold
SearchTabButton.TextSize = 18
SearchTabButton.TextColor3 = Color3.new(1, 1, 1)
local STBCorner = Instance.new("UICorner", SearchTabButton)
STBCorner.CornerRadius = UDim.new(0, 8)

local UpcomingTabButton = Instance.new("TextButton")
UpcomingTabButton.Name = "UpcomingTabButton"
UpcomingTabButton.Parent = TabsFrame
UpcomingTabButton.BackgroundColor3 = Color3.fromRGB(70, 130, 180)
UpcomingTabButton.Size = UDim2.new(0.5, -4, 1, 0)
UpcomingTabButton.Position = UDim2.new(0.5, 4, 0, 0)
UpcomingTabButton.Text = "⏳ Upcoming Animes"
UpcomingTabButton.Font = Enum.Font.GothamBold
UpcomingTabButton.TextSize = 18
UpcomingTabButton.TextColor3 = Color3.new(1, 1, 1)
local UTBCorner = Instance.new("UICorner", UpcomingTabButton)
UTBCorner.CornerRadius = UDim.new(0, 8)

local SearchTab = Instance.new("Frame")
SearchTab.Name = "SearchTab"
SearchTab.Parent = MainFrame
SearchTab.BackgroundTransparency = 1
SearchTab.Position = UDim2.new(0, 16, 0, 96)
SearchTab.Size = UDim2.new(1, -32, 1, -112)

local UpcomingTab = Instance.new("Frame")
UpcomingTab.Name = "UpcomingTab"
UpcomingTab.Parent = MainFrame
UpcomingTab.BackgroundTransparency = 1
UpcomingTab.Position = UDim2.new(0, 16, 0, 96)
UpcomingTab.Size = UDim2.new(1, -32, 1, -112)
UpcomingTab.Visible = false

local SearchBox = Instance.new("TextBox")
SearchBox.Name = "SearchBox"
SearchBox.Parent = SearchTab
SearchBox.PlaceholderText = "Enter anime name..."
SearchBox.Text = ""
SearchBox.ClearTextOnFocus = false
SearchBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
SearchBox.TextColor3 = Color3.new(1, 1, 1)
SearchBox.Font = Enum.Font.Gotham
SearchBox.TextSize = 18
SearchBox.Size = UDim2.new(0, 300, 0, 30)
SearchBox.Position = UDim2.new(0, 0, 0, 0)
local SearchBoxUICorner = Instance.new("UICorner", SearchBox)
SearchBoxUICorner.CornerRadius = UDim.new(0, 8)

local SearchButton = Instance.new("TextButton")
SearchButton.Name = "SearchButton"
SearchButton.Parent = SearchTab
SearchButton.BackgroundColor3 = Color3.fromRGB(70, 130, 180)
SearchButton.Size = UDim2.new(0, 120, 0, 30)
SearchButton.Position = UDim2.new(0, 310, 0, 0)
SearchButton.Text = "Search 🔍"
SearchButton.Font = Enum.Font.GothamBold
SearchButton.TextSize = 18
SearchButton.TextColor3 = Color3.new(1, 1, 1)
local SearchButtonUICorner = Instance.new("UICorner", SearchButton)
SearchButtonUICorner.CornerRadius = UDim.new(0, 8)

local SearchAnimeList = Instance.new("ScrollingFrame")
SearchAnimeList.Name = "AnimeList"
SearchAnimeList.Parent = SearchTab
SearchAnimeList.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
SearchAnimeList.BorderSizePixel = 0
SearchAnimeList.Position = UDim2.new(0, 0, 0, 40)
SearchAnimeList.Size = UDim2.new(1, 0, 1, -40)
SearchAnimeList.CanvasSize = UDim2.new(0, 0, 0, 0)
SearchAnimeList.ScrollBarThickness = 4
local SearchAnimeListUICorner = Instance.new("UICorner", SearchAnimeList)
SearchAnimeListUICorner.CornerRadius = UDim.new(0, 8)

local SearchAnimeListLayout = Instance.new("UIListLayout", SearchAnimeList)
SearchAnimeListLayout.SortOrder = Enum.SortOrder.LayoutOrder
SearchAnimeListLayout.Padding = UDim.new(0, 8)
SearchAnimeListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	SearchAnimeList.CanvasSize = UDim2.new(0, 0, 0, SearchAnimeListLayout.AbsoluteContentSize.Y)
end)

local UpcomingAnimeList = Instance.new("ScrollingFrame")
UpcomingAnimeList.Name = "AnimeList"
UpcomingAnimeList.Parent = UpcomingTab
UpcomingAnimeList.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
UpcomingAnimeList.BorderSizePixel = 0
UpcomingAnimeList.Position = UDim2.new(0, 0, 0, 0)
UpcomingAnimeList.Size = UDim2.new(1, 0, 1, 0)
UpcomingAnimeList.CanvasSize = UDim2.new(0, 0, 0, 0)
UpcomingAnimeList.ScrollBarThickness = 4
local UpcomingAnimeListUICorner = Instance.new("UICorner", UpcomingAnimeList)
UpcomingAnimeListUICorner.CornerRadius = UDim.new(0, 8)

local UpcomingAnimeListLayout = Instance.new("UIListLayout", UpcomingAnimeList)
UpcomingAnimeListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UpcomingAnimeListLayout.Padding = UDim.new(0, 8)
UpcomingAnimeListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	UpcomingAnimeList.CanvasSize = UDim2.new(0, 0, 0, UpcomingAnimeListLayout.AbsoluteContentSize.Y)
end)

local function updateThumbnails(listFrame)
    for _, entry in ipairs(listFrame:GetChildren()) do
        if entry:IsA("Frame") and entry:FindFirstChild("Thumbnail") then
            spawn(function()
                local thumb = entry.Thumbnail
                local url = thumb:GetAttribute("ImageUrl")
                local fileName = thumb:GetAttribute("FileName")
                if url and fileName then
                    loadImage(url, fileName, thumb)
                end
            end)
        end
    end
end

local function createAnimeEntry(data)
	-- Main container with automatic height adjustment
	local EntryFrame = Instance.new("Frame")
	EntryFrame.Name = "AnimeEntry"
	EntryFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	EntryFrame.Size = UDim2.new(1, 0, 0, 150)
	EntryFrame.BorderSizePixel = 0
	EntryFrame.AutomaticSize = Enum.AutomaticSize.Y
	local entryCorner = Instance.new("UICorner", EntryFrame)
	entryCorner.CornerRadius = UDim.new(0, 8)
	
	-- Thumbnail Image
	local Thumbnail = Instance.new("ImageLabel")
	Thumbnail.Name = "Thumbnail"
	Thumbnail.Parent = EntryFrame
	Thumbnail.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	Thumbnail.Size = UDim2.new(0, 100, 0, 130)
	Thumbnail.Position = UDim2.new(0, 10, 0, 10)
	Thumbnail.Image = data.images and data.images.jpg and data.images.jpg.image_url or ""
	Thumbnail:SetAttribute("ImageUrl", data.images and data.images.jpg and data.images.jpg.image_url or "")
	Thumbnail:SetAttribute("FileName", data.mal_id and tostring(data.mal_id) or "default")
	local thumbCorner = Instance.new("UICorner", Thumbnail)
	thumbCorner.CornerRadius = UDim.new(0, 8)
	
	-- Anime Title (Bold, smaller text, wrapped)
	local Title = Instance.new("TextLabel")
	Title.Name = "AnimeTitle"
	Title.Parent = EntryFrame
	Title.BackgroundTransparency = 1
	Title.Position = UDim2.new(0, 120, 0, 10)
	Title.Size = UDim2.new(1, -130, 0, 24)
	Title.Text = data.title or "N/A"
	Title.Font = Enum.Font.GothamBold
	Title.TextSize = 18
	Title.TextColor3 = Color3.new(1, 1, 1)
	Title.TextWrapped = true
	Title.TextXAlignment = Enum.TextXAlignment.Left

	-- Details Label
	local Details = Instance.new("TextLabel")
	Details.Name = "Details"
	Details.Parent = EntryFrame
	Details.BackgroundTransparency = 1
	Details.Position = UDim2.new(0, 120, 0, 40)
	Details.Size = UDim2.new(1, -130, 0, 80)
	local episodes = data.episodes or "N/A"
	local score = data.score or "0.00"
	local rank = data.rank or "N/A"
	local status = data.status or "N/A"
	local airing = (status == "Currently Airing") and "true" or "false"
	local aired_from = data.aired and data.aired.from or "null"
	local aired_to = data.aired and data.aired.to or "null"
	Details.Text = string.format("Episodes: %s\nRating: %s\nRanking: %s\nAiring: %s\nAired: %s to %s\nStatus: %s", 
		episodes, score, rank, airing, aired_from, aired_to, status)
	Details.Font = Enum.Font.Gotham
	Details.TextSize = 16
	Details.TextColor3 = Color3.new(1, 1, 1)
	Details.TextXAlignment = Enum.TextXAlignment.Left
	Details.TextYAlignment = Enum.TextYAlignment.Top
	
	-- Synopsis Dropdown (ScrollingFrame) - initially collapsed; positioned to avoid overlapping with Title and Details
	local SynopsisDropdown = Instance.new("ScrollingFrame")
	SynopsisDropdown.Name = "SynopsisDropdown"
	SynopsisDropdown.Parent = EntryFrame
	SynopsisDropdown.BackgroundTransparency = 1
	SynopsisDropdown.Position = UDim2.new(0, 10, 0, 170)
	SynopsisDropdown.Size = UDim2.new(1, -20, 0, 0)
	SynopsisDropdown.CanvasSize = UDim2.new(0, 0, 0, 0)
	SynopsisDropdown.ScrollBarThickness = 2
	SynopsisDropdown.Visible = true
	local synLayout = Instance.new("UIListLayout", SynopsisDropdown)
	synLayout.SortOrder = Enum.SortOrder.LayoutOrder
	synLayout.Padding = UDim.new(0, 4)
	synLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		SynopsisDropdown.CanvasSize = UDim2.new(0, 0, 0, synLayout.AbsoluteContentSize.Y)
	end)
	-- Synopsis Label inside dropdown (smaller text)
	local SynopsisLabel = Instance.new("TextLabel")
	SynopsisLabel.Name = "SynopsisLabel"
	SynopsisLabel.Parent = SynopsisDropdown
	SynopsisLabel.BackgroundTransparency = 1
	SynopsisLabel.Size = UDim2.new(1, 0, 0, 0)
	SynopsisLabel.Text = data.synopsis or "No synopsis available."
	SynopsisLabel.Font = Enum.Font.Gotham
	SynopsisLabel.TextSize = 14
	SynopsisLabel.TextColor3 = Color3.new(1, 1, 1)
	SynopsisLabel.TextWrapped = true
	SynopsisLabel.TextXAlignment = Enum.TextXAlignment.Left
	SynopsisLabel.TextYAlignment = Enum.TextYAlignment.Top
	SynopsisLabel.AutomaticSize = Enum.AutomaticSize.Y
	
	-- Synopsis Toggle State and Button (Dropdown Toggle with smooth transition)
	local expanded = false
	local SynopsisButton = Instance.new("TextButton")
	SynopsisButton.Name = "SynopsisButton"
	SynopsisButton.Parent = EntryFrame
	SynopsisButton.BackgroundColor3 = Color3.fromRGB(70, 130, 180)
	SynopsisButton.Size = UDim2.new(0, 100, 0, 30)
	-- Positioned to avoid overlapping with AnimeTitle and Details
	SynopsisButton.Position = UDim2.new(1, -110, 0, 130)
	SynopsisButton.Text = "Synopsis 📖"
	SynopsisButton.Font = Enum.Font.GothamBold
	SynopsisButton.TextSize = 16
	SynopsisButton.TextColor3 = Color3.new(1, 1, 1)
	local synBtnCorner = Instance.new("UICorner", SynopsisButton)
	synBtnCorner.CornerRadius = UDim.new(0, 8)
	SynopsisButton.MouseButton1Click:Connect(function()
		expanded = not expanded
		local targetHeight = expanded and 200 or 0
		local tween = TweenService:Create(SynopsisDropdown, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(1, -20, 0, targetHeight)})
		tween:Play()
	end)
	
	return EntryFrame
end

local function performSearch(query)
	local url = "https://api.jikan.moe/v4/anime?q=" .. HttpService:UrlEncode(query)
	local response
	local success, result = pcall(function()
		return httpRequestFunc({
			Url = url,
			Method = "GET",
			Headers = {["Content-Type"] = "application/json"}
		})
	end)
	if not success then
		warn("Search request failed! 😢")
		return
	end
	response = result
	local body = response.Body or response.body
	local data
	pcall(function() data = HttpService:JSONDecode(body) end)
	if not data or not data.data then
		warn("No search results found! 😔")
		return
	end
	
	for _, child in ipairs(SearchAnimeList:GetChildren()) do
		if child:IsA("Frame") then child:Destroy() end
	end
	
	for i, anime in ipairs(data.data) do
		local entry = createAnimeEntry(anime)
		entry.Parent = SearchAnimeList
	end
	
	-- After the anime list is loaded, fast load all thumbnail images concurrently
	updateThumbnails(SearchAnimeList)
end

local function loadUpcoming()
	local url = "https://api.jikan.moe/v4/seasons/upcoming"
	local response
	local success, result = pcall(function()
		return httpRequestFunc({
			Url = url,
			Method = "GET",
			Headers = {["Content-Type"] = "application/json"}
		})
	end)
	if not success then
		warn("Upcoming request failed! 😢")
		return
	end
	response = result
	local body = response.Body or response.body
	local data
	pcall(function() data = HttpService:JSONDecode(body) end)
	if not data or not data.data then
		warn("No upcoming results found! 😔")
		return
	end
	
	for _, child in ipairs(UpcomingAnimeList:GetChildren()) do
		if child:IsA("Frame") then child:Destroy() end
	end
	
	for i, anime in ipairs(data.data) do
		local entry = createAnimeEntry(anime)
		entry.Parent = UpcomingAnimeList
	end
	
	-- After the list is loaded, fast load thumbnail images concurrently
	updateThumbnails(UpcomingAnimeList)
end

SearchButton.MouseButton1Click:Connect(function()
	performSearch(SearchBox.Text)
end)
SearchBox.FocusLost:Connect(function(enterPressed)
	if enterPressed then
		performSearch(SearchBox.Text)
	end
end)

SearchTabButton.MouseButton1Click:Connect(function()
	SearchTab.Visible = true
	UpcomingTab.Visible = false
	SearchTabButton.BackgroundColor3 = Color3.fromRGB(70, 130, 180)
	UpcomingTabButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
end)
UpcomingTabButton.MouseButton1Click:Connect(function()
	SearchTab.Visible = false
	UpcomingTab.Visible = true
	UpcomingTabButton.BackgroundColor3 = Color3.fromRGB(70, 130, 180)
	SearchTabButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	loadUpcoming()
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
