--!strict
if not game:IsLoaded() then game.Loaded:Wait() end

local players = game:GetService("Players")
local marketplaceservice = game:GetService("MarketplaceService")
local httpservice = game:GetService("HttpService")
local localplayer = players.LocalPlayer

local disabledAnimations = {
  -- R15
  ["WalkAnim"] = true,
  ["JumpAnim"] = true,
  ["RunAnim"] = true,
  ["SwimAnim"] = true,
  ["IdleAnim"] = true,
  ["FallAnim"] = true,
  ["SwimIdleAnim"] = true,
  ["ClimbAnim"] = true,
  
  -- R6
  ["Walk"] = true,
  ["Jump"] = true,
  ["Run"] = true,
  ["Swim"] = true,
  ["Idle"] = true,
  ["Fall"] = true,
  ["SwimIdle"] = true,
  ["Climb"] = true,
  
  -- Others
  ["Walking"] = true,
  ["Jumping"] = true,
  ["Running"] = true,
  ["Swimming"] = true,
  ["Idling"] = true,
  ["Falling"] = true,
  ["SwimIdling"] = true,
  ["Climbing"] = true,
  
  ["WalkingAnim"] = true,
  ["JumpingAnim"] = true,
  ["RunningAnim"] = true,
  ["SwimmingAnim"] = true,
  ["IdlingAnim"] = true,
  ["FallingAnim"] = true,
  ["SwimIdlingAnim"] = true,
  ["ClimbingAnim"] = true,
}

local function clik()
  local s = Instance.new("Sound") 
  s.SoundId = "rbxassetid://87152549167464"
  s.Parent = game.Workspace
  s.Volume = 1.2
  s.TimePosition = 0.1
  s:Play()
  task.delay(1, function() s:Destroy() end)
end

local dw = {
  [16116270224] = true,
  [16552821455] = true,
  [18984416148] = true
}

local indw = dw[game.GameId] or false

local gameName = "Unknown"
local success, result = pcall(function()
  gameName = marketplaceservice:GetProductInfo(game.PlaceId).Name
end)
if not success then gameName = "Failed to fetch" end

local gui = Instance.new("ScreenGui")
gui.Name = "AnimationLogger"
gui.Parent = gethui and gethui() or game:GetService("CoreGui")
gui.ResetOnSpawn = false

local function repos(ui, w, h)
  local sw, sh = workspace.CurrentCamera.ViewportSize.X, workspace.CurrentCamera.ViewportSize.Y
  local cx, cy = (sw - w) / 2, (sh - h) / 2 - 56
  ui.Position = UDim2.new(0, cx, 0, cy)
end

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 400, 0, 250)
frame.Position = UDim2.new(0.35, 0, 0.3, 0)
repos(frame, 400, 250)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 0
frame.Parent = gui
frame.Active = true
frame.Draggable = true

local topbar = Instance.new("Frame")
topbar.Size = UDim2.new(0, 400, 0, 30)
topbar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
topbar.BorderSizePixel = 0
topbar.Parent = frame

local titlelabel = Instance.new("TextLabel")
titlelabel.Size = UDim2.new(0, 120, 1, 0)
titlelabel.Position = UDim2.new(0, 0, 0, 0)
titlelabel.BackgroundTransparency = 1
titlelabel.Text = " Animation Logger"
titlelabel.Font = Enum.Font.RobotoMono
titlelabel.TextXAlignment = Enum.TextXAlignment.Left
titlelabel.TextColor3 = Color3.new(1, 1, 1)
titlelabel.TextSize = 14
titlelabel.Parent = topbar

local searchbox = Instance.new("TextBox")
searchbox.Name = "SearchBox"
searchbox.Size = UDim2.new(0, 100, 0, 20)
searchbox.Position = UDim2.new(0, 125, 0, 5)
searchbox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
searchbox.TextColor3 = Color3.new(1, 1, 1)
searchbox.PlaceholderText = "Search..."
searchbox.Text = ""
searchbox.Font = Enum.Font.RobotoMono
searchbox.TextSize = 12
searchbox.ClearTextOnFocus = false
searchbox.BorderSizePixel = 0
searchbox.Parent = topbar

local searchstroke = Instance.new("UIStroke")
searchstroke.Color = Color3.fromRGB(80, 80, 80)
searchstroke.Thickness = 1
searchstroke.Parent = searchbox

local clearsearchbtn = Instance.new("TextButton")
clearsearchbtn.Name = "ClearSearchButton"
clearsearchbtn.Size = UDim2.new(0, 20, 0, 20)
clearsearchbtn.Position = UDim2.new(0, 230, 0, 5)
clearsearchbtn.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
clearsearchbtn.Text = "×"
clearsearchbtn.TextColor3 = Color3.new(1, 1, 1)
clearsearchbtn.TextSize = 14
clearsearchbtn.Font = Enum.Font.RobotoMono
clearsearchbtn.BorderSizePixel = 0
clearsearchbtn.BackgroundTransparency = 0.3
clearsearchbtn.Parent = topbar

local function createbutton(name, position, size, color, text)
  local button = Instance.new("TextButton")
  button.Name = name
  button.Size = size
  button.Position = position
  button.BackgroundColor3 = color
  button.Text = text
  button.TextColor3 = Color3.new(1, 1, 1)
  button.TextSize = 16
  button.Font = Enum.Font.RobotoMono
  button.BorderSizePixel = 0
  button.BackgroundTransparency = 0.7
  button.Parent = topbar
  return button
end

local clearbutton = createbutton("ClearButton", UDim2.new(1, -116, 0, 5), UDim2.new(0, 60, 0, 20), Color3.fromRGB(200, 50, 50), "Clear")
local minimizebutton = createbutton("MinimizeButton", UDim2.new(1, -51, 0, 5), UDim2.new(0, 20, 0, 20), Color3.fromRGB(50, 50, 200), "–")
local xbutton = createbutton("CloseButton", UDim2.new(1, -25, 0, 5), UDim2.new(0, 20, 0, 20), Color3.fromRGB(200, 50, 50), "X")

local fakeframe = Instance.new("Frame")
fakeframe.Size = UDim2.new(1, 0, 1, -30)
fakeframe.Position = UDim2.new(0, 0, 0, 30)
fakeframe.BorderSizePixel = 0
fakeframe.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
fakeframe.Parent = frame

local scrollframe = Instance.new("ScrollingFrame")
scrollframe.Size = UDim2.new(1, 0, 0, 210)
scrollframe.Position = UDim2.new(0, 5, 0, 35)
scrollframe.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollframe.ScrollBarThickness = 5
scrollframe.BorderSizePixel = 0
scrollframe.BackgroundTransparency = 1
scrollframe.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
scrollframe.Parent = frame

local loglayout = Instance.new("UIListLayout")
loglayout.Padding = UDim.new(0, 5)
loglayout.Parent = scrollframe

local loggedanimations = {}
local animationentries = {}
local activetracks = {}

local function extractanimationid(fullid)
  return string.gsub(tostring(fullid or ""), "[^%d]", "")
end

local function getAnimationInfo(assetid)
  local success, result = pcall(function()
  	return marketplaceservice:GetProductInfo(assetid, Enum.InfoType.Asset)
  end)

  if success and result then
  	return {
  		Creator = result.Creator.Name,
  		Name = result.Name,
  		Status = result.IsPublicDomain and "Public" or "Private"
  	}
  end
  return { Creator = "Unknown", Name = "Unknown", Status = "Unknown" }
end

local function filterentries()
  local query = string.lower(searchbox.Text)
  for animid, data in pairs(animationentries) do
  	local entry = data.frame
  	local info = data.info
  	local source = data.source
  	local displayid = data.displayid
  	
  	local match = false
  	if query == "" then
  		match = true
  	else
  		if string.find(string.lower(info.Name), query, 1, true) then
  			match = true
  		elseif string.find(string.lower(displayid), query, 1, true) then
  			match = true
  		elseif string.find(string.lower(source), query, 1, true) then
  			match = true
  		elseif string.find(string.lower(info.Creator), query, 1, true) then
  			match = true
  		end
  	end
  	
  	entry.Visible = match
  end
  
  task.wait()
  local visiblecount = 0
  for _, child in ipairs(scrollframe:GetChildren()) do
  	if child:IsA("Frame") and child.Visible then
  		visiblecount = visiblecount + 1
  	end
  end
  scrollframe.CanvasSize = UDim2.new(0, 0, 0, loglayout.AbsoluteContentSize.Y)
end

searchbox:GetPropertyChangedSignal("Text"):Connect(filterentries)

clearsearchbtn.MouseButton1Click:Connect(function()
  clik()
  searchbox.Text = ""
  filterentries()
end)

local function createlogentry(animationname, animationid, source)
  local displayid = extractanimationid(animationid)
  local numericid = tonumber(displayid)

  if not numericid then return end

  local entryframe = Instance.new("Frame")
  entryframe.Size = UDim2.new(0, 390, 0, 130)
  entryframe.Position = UDim2.new(0, 10, 0, 10)
  entryframe.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
  entryframe.BorderSizePixel = 0
  entryframe.Parent = scrollframe

  local info = getAnimationInfo(numericid)
  
  if info.Creator == "Roblox" then
  	entryframe:Destroy()
  	loggedanimations[animationid] = nil
  	return
  end

  local track = nil
  
  animationentries[animationid] = {
  	frame = entryframe,
  	info = info,
  	source = source,
  	displayid = displayid,
  	track = track
  }

  local function createLabel(text, yPos, size, color)
  	local label = Instance.new("TextLabel")
  	label.Size = UDim2.new(1, -170, 0, 20)
  	label.Position = UDim2.new(0, 5, 0, yPos)
  	label.BackgroundTransparency = 1
  	label.Text = text
  	label.Font = Enum.Font.RobotoMono
  	label.TextColor3 = color or Color3.new(1, 1, 1)
  	label.TextSize = size
  	label.BorderSizePixel = 0
  	label.TextXAlignment = Enum.TextXAlignment.Left
  	label.Parent = entryframe
  	return label
  end

  createLabel("Game: " .. gameName, 5, 14, Color3.fromRGB(200, 200, 200))
  createLabel("ID: " .. displayid, 25, 16)
  createLabel("Creator: " .. info.Creator, 45, 14, Color3.fromRGB(200, 200, 200))
  createLabel("Status: " .. info.Status, 65, 14, Color3.fromRGB(200, 200, 200))
  createLabel("Source: " .. source, 85, 14, Color3.fromRGB(200, 200, 200))
  local animNameLabel = createLabel("Animation Name: " .. info.Name, 105, 14, Color3.fromRGB(200, 200, 200))

  local function createEntryButton(text, yPos, color, xOffset)
  	local button = Instance.new("TextButton")
  	button.Size = UDim2.new(0, 75, 0, 20)
  	button.Position = UDim2.new(1, -80 - (xOffset or 0), 0, yPos)
  	button.BackgroundColor3 = color
  	button.Text = text
  	button.Font = Enum.Font.RobotoMono
  	button.BorderSizePixel = 0
  	button.TextColor3 = Color3.new(1, 1, 1)
  	button.TextSize = 12
  	button.Parent = entryframe
  	return button
  end
  
  local copyidbutton = createEntryButton("Copy ID", 5, Color3.fromRGB(60, 60, 150), 80)
  local copynamebutton = createEntryButton("Copy Name", 30, Color3.fromRGB(60, 60, 150), 80)
  local copyurlbutton = createEntryButton("Copy Url", 55, Color3.fromRGB(60, 60, 150), 80)

  local playbutton = createEntryButton("Play", 5, Color3.fromRGB(60, 150, 60))
  local stopbutton = createEntryButton("Stop", 30, Color3.fromRGB(150, 60, 60))
  local removebutton = createEntryButton("Remove", 55, Color3.fromRGB(200, 80, 80))
  
  playbutton.MouseButton1Click:Connect(function()
  	clik()
  	if localplayer.Character then
  		local humanoid = localplayer.Character:FindFirstChildOfClass("Humanoid")
  		if humanoid then
  			if track then track:Stop() track = nil end

  			local animation = Instance.new("Animation")
  			animation.AnimationId = "rbxassetid://" .. numericid
  			track = humanoid:LoadAnimation(animation)
  			track:Play()
  			track:AdjustWeight(999)
  			
  			animationentries[animationid].track = track
  			activetracks[animationid] = track

  			playbutton.Text = "Playing"
  			task.delay(1, function() if playbutton then playbutton.Text = "Play" end end)
  		end
  	end
  end)

  stopbutton.MouseButton1Click:Connect(function()
  	clik()
  	if track then
  		track:Stop()
  		track = nil
  		animationentries[animationid].track = nil
  		activetracks[animationid] = nil
  		stopbutton.Text = "Stopped"
  		task.delay(1, function() if stopbutton then stopbutton.Text = "Stop" end end)
  	end
  end)

  local function copyToClipboard(textToCopy, button)
  	clik()
  	if setclipboard then
  		setclipboard(textToCopy)
  		local originalText = button.Text
  		button.Text = "Copied!"
  		task.wait(1)
  		button.Text = originalText
  	else
  		local originalText = button.Text
  		button.Text = "Error"
  		task.wait(1)
  		button.Text = originalText
  	end
  end
  
  copyidbutton.MouseButton1Click:Connect(function()
  	copyToClipboard(displayid, copyidbutton)
  end)

  copynamebutton.MouseButton1Click:Connect(function()
  	copyToClipboard(info.Name, copynamebutton)
  end)

  copyurlbutton.MouseButton1Click:Connect(function()
  	local url = "https://www.roblox.com/library/" .. displayid
  	copyToClipboard(url, copyurlbutton)
  end)

  removebutton.MouseButton1Click:Connect(function()
  	clik()
  	if track then
  		track:Stop()
  		track = nil
  	end
  	activetracks[animationid] = nil
  	loggedanimations[animationid] = nil
  	animationentries[animationid] = nil
  	entryframe:Destroy()
  	filterentries()
  end)

  return entryframe
end

local function loganimation(animationname, animationid, source)
  if not animationid or loggedanimations[animationid] or disabledAnimations[animationname] then 
  	return 
  end

  loggedanimations[animationid] = true
  
  task.spawn(function()
  	createlogentry(animationname, animationid, source)
  	filterentries()
  end)
end

local function trackanimationplaying(humanoid)
  if indw then return end

  local connection = humanoid.AnimationPlayed:Connect(function(animationtrack)
  	if not animationtrack or not animationtrack.Animation then return end
  	local anim = animationtrack.Animation
  	loganimation(anim.Name, anim.AnimationId, "Played Animation")
  end)

  return function()
  	if connection then connection:Disconnect() end
  end
end

local function setupcharacter(character)
  local humanoid = character:WaitForChild("Humanoid")

  local animateScript = character:FindFirstChild("Animate")
  if animateScript then
  	for _, child in ipairs(animateScript:GetChildren()) do
  		if child:IsA("StringValue") and child:FindFirstChildOfClass("Animation") then
  			local anim = child:FindFirstChildOfClass("Animation")
  			loganimation(anim.Name, anim.AnimationId, "Animate Script")
  		end
  	end
  end

  if indw then return end
  
  trackanimationplaying(humanoid)
end

local characterconnection

local function monitorcharacter()
  if characterconnection then characterconnection:Disconnect() end

  characterconnection = localplayer.CharacterAdded:Connect(setupcharacter)
  if localplayer.Character then setupcharacter(localplayer.Character) end
end

monitorcharacter()

clearbutton.MouseButton1Click:Connect(function()
  clik()
  for animid, track in pairs(activetracks) do
  	if track then
  		track:Stop()
  	end
  end
  activetracks = {}
  for _, child in ipairs(scrollframe:GetChildren()) do
  	if child:IsA("Frame") then child:Destroy() end
  end
  loggedanimations = {}
  animationentries = {}
  searchbox.Text = ""
  scrollframe.CanvasSize = UDim2.new(0, 0, 0, 0)
end)

xbutton.MouseButton1Click:Connect(function()
  clik()
  for animid, track in pairs(activetracks) do
  	if track then
  		track:Stop()
  	end
  end
  activetracks = {}
  gui:Destroy()
end)

local isminimized = false
local originalsize = frame.Size
minimizebutton.MouseButton1Click:Connect(function()
  clik()
  isminimized = not isminimized
  if isminimized then
  	minimizebutton.Text = "+"
  	frame.Size = UDim2.new(originalsize.X.Scale, originalsize.X.Offset, 0, 30)
  	scrollframe.Visible = false
  else
  	minimizebutton.Text = "–"
  	frame.Size = originalsize
  	scrollframe.Visible = true
  end
end)

loglayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
  if not isminimized then
  	scrollframe.CanvasSize = UDim2.new(0, 0, 0, loglayout.AbsoluteContentSize.Y)
  end
end)
