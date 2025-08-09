--[[
    Fly Gui v7 (Revised 5)
    Created by: [FE SCRIPTER]
    Revisions:
    - Added a character death handler. Flight is now automatically disabled if the player dies while it's active.
    - Updated stopFlying() function to be safe to call on dead characters.
    - Corrected a minor typo in the UI drag logic for touch input.
    - Maintained all previous features.
]]

--// Services & Core Variables
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

--// Core Flight & State Variables
local flying = false
local flySpeed = 1
local bodyGyro, bodyVelocity
local flyUpActive, flyDownActive = false, false
local lastSpeedChangeTime = 0

--// Gui Creation
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FlyGui_V7_Container"
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.ResetOnSpawn = false

--// Tooltip (Parented to ScreenGui now)
local Tooltip = Instance.new("Frame")
Tooltip.Name = "Tooltip"
Tooltip.Size = UDim2.new(0, 0, 0, 25) -- Width is now fully automatic
Tooltip.AutomaticSize = Enum.AutomaticSize.X -- The frame resizes based on child content
Tooltip.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
Tooltip.BackgroundTransparency = 0.5
Tooltip.BorderColor3 = Color3.fromRGB(150, 150, 150)
Tooltip.Visible = false
Tooltip.ZIndex = 10
Tooltip.Parent = ScreenGui

local TooltipPadding = Instance.new("UIPadding")
TooltipPadding.PaddingLeft = UDim.new(0, 8)
TooltipPadding.PaddingRight = UDim.new(0, 8)
TooltipPadding.Parent = Tooltip

local TooltipCorner = Instance.new("UICorner")
TooltipCorner.CornerRadius = UDim.new(0, 6)
TooltipCorner.Parent = Tooltip

local TooltipLabel = Instance.new("TextLabel")
TooltipLabel.Name = "TooltipLabel"
TooltipLabel.Size = UDim2.new(0, 0, 1, 0) -- Set size to 0 on X axis
TooltipLabel.AutomaticSize = Enum.AutomaticSize.X -- Allow the label to expand horizontally to fit text
TooltipLabel.BackgroundTransparency = 1
TooltipLabel.Font = Enum.Font.Gotham
TooltipLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
TooltipLabel.TextSize = 14
TooltipLabel.Parent = Tooltip

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 220, 0, 180)
MainFrame.Position = UDim2.new(0.5, -110, 0.5, -90)
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BackgroundTransparency = 0.1
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 12)
Corner.Parent = MainFrame

local AspectRatio = Instance.new("UIAspectRatioConstraint")
AspectRatio.AspectRatio = 220 / 180
AspectRatio.Parent = MainFrame

local Stroke = Instance.new("UIStroke")
Stroke.Color = Color3.fromRGB(120, 120, 120)
Stroke.Transparency = 0.5
Stroke.Thickness = 1
Stroke.Parent = MainFrame

--// Title Bar
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 30)
TitleBar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
TitleBar.BackgroundTransparency = 0.3
TitleBar.Parent = MainFrame

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "TitleLabel"
TitleLabel.Size = UDim2.new(1, -60, 1, 0)
TitleLabel.Position = UDim2.new(0, 0, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Font = Enum.Font.GothamSemibold
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.Text = "Fly Gui v7"
TitleLabel.TextSize = 16
TitleLabel.TextXAlignment = Enum.TextXAlignment.Center
TitleLabel.Parent = TitleBar

--// Tooltip Function
local function showTooltip(button, text)
    button.MouseEnter:Connect(function()
        TooltipLabel.Text = text
        task.wait() -- Wait for AutomaticSize to update the frame
        
        local mainPos = MainFrame.AbsolutePosition
        local mainSize = MainFrame.AbsoluteSize
        local tipSize = Tooltip.AbsoluteSize
        
        local xPos = mainPos.X + (mainSize.X / 2) - (tipSize.X / 2)
        local yPos = mainPos.Y + mainSize.Y + 5 -- 5px gap below the frame
        
        Tooltip.Position = UDim2.fromOffset(xPos, yPos)
        Tooltip.Visible = true
    end)
    button.MouseLeave:Connect(function()
        Tooltip.Visible = false
    end)
end

--// Buttons
local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Size = UDim2.new(0, 30, 1, 0)
CloseButton.Position = UDim2.new(1, -30, 0, 0)
CloseButton.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
CloseButton.BackgroundTransparency = 1
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.Text = "X"
CloseButton.TextSize = 16
CloseButton.Parent = TitleBar
showTooltip(CloseButton, "Close GUI")

local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Name = "MinimizeButton"
MinimizeButton.Size = UDim2.new(0, 30, 1, 0)
MinimizeButton.Position = UDim2.new(1, -60, 0, 0)
MinimizeButton.BackgroundTransparency = 1
MinimizeButton.Font = Enum.Font.GothamBold
MinimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeButton.Text = "—"
MinimizeButton.TextSize = 16
MinimizeButton.Parent = TitleBar
showTooltip(MinimizeButton, "Minimize")

--// Content
local ContentFrame = Instance.new("Frame")
ContentFrame.Name = "ContentFrame"
ContentFrame.Size = UDim2.new(1, 0, 1, -30)
ContentFrame.Position = UDim2.new(0, 0, 0, 30)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainFrame

local Padding = Instance.new("UIPadding")
Padding.PaddingTop = UDim.new(0, 10)
Padding.PaddingBottom = UDim.new(0, 10)
Padding.PaddingLeft = UDim.new(0, 10)
Padding.PaddingRight = UDim.new(0, 10)
Padding.Parent = ContentFrame

local ListLayout = Instance.new("UIListLayout")
ListLayout.FillDirection = Enum.FillDirection.Vertical
ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
ListLayout.Padding = UDim.new(0, 8)
ListLayout.Parent = ContentFrame

local function createButton(name, text, order, parent, tooltipText)
    local button = Instance.new("TextButton")
    button.Name = name
    button.Size = UDim2.new(1, 0, 0, 35)
    button.LayoutOrder = order
    button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    button.Font = Enum.Font.GothamSemibold
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Text = text
    button.TextSize = 15
    button.Parent = parent

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = button
    
    showTooltip(button, tooltipText)
    return button
end

local function createRowFrame(order, parent)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 35)
    frame.BackgroundTransparency = 1
    frame.LayoutOrder = order
    frame.Parent = parent

    local layout = Instance.new("UIGridLayout")
    layout.CellPadding = UDim2.new(0, 8, 0, 0)
    layout.CellSize = UDim2.new(0.5, -4, 1, 0)
    layout.Parent = frame
    
    return frame
end

-- Row 1: Fly Toggle & Speed Display
local StatusFrame = Instance.new("Frame")
StatusFrame.Size = UDim2.new(1, 0, 0, 35)
StatusFrame.LayoutOrder = 1
StatusFrame.BackgroundTransparency = 1
StatusFrame.Parent = ContentFrame

local StatusLayout = Instance.new("UIGridLayout")
StatusLayout.CellPadding = UDim2.new(0, 8, 0, 0)
StatusLayout.CellSize = UDim2.new(0.5, -4, 1, 0)
StatusLayout.Parent = StatusFrame

local FlyToggleButton = createButton("FlyToggle", "Fly: Off", 1, StatusFrame, "Toggle Flight On/Off")
FlyToggleButton.Size = UDim2.new(0.5, -4, 1, 0)

local SpeedLabel = Instance.new("TextLabel")
SpeedLabel.Name = "SpeedLabel"
SpeedLabel.Size = UDim2.new(0.5, -4, 1, 0)
SpeedLabel.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
SpeedLabel.Font = Enum.Font.GothamSemibold
SpeedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedLabel.Text = "Speed: "..tostring(flySpeed)
SpeedLabel.TextSize = 15
SpeedLabel.Parent = StatusFrame

local labelCorner = Instance.new("UICorner")
labelCorner.CornerRadius = UDim.new(0, 6)
labelCorner.Parent = SpeedLabel

-- Row 2: Speed Controls
local SpeedControlFrame = createRowFrame(2, ContentFrame)
local SpeedIncreaseButton = createButton("SpeedIncrease", "Speed +", 1, SpeedControlFrame, "Increase Speed ( I )")
local SpeedDecreaseButton = createButton("SpeedDecrease", "Speed -", 2, SpeedControlFrame, "Decrease Speed ( O )")

-- Row 3: Vertical Controls
local VerticalControlFrame = createRowFrame(3, ContentFrame)
local FlyUpButton = createButton("FlyUp", "Up", 1, VerticalControlFrame, "Fly Up ( E )")
local FlyDownButton = createButton("FlyDown", "Down", 2, VerticalControlFrame, "Fly Down ( Q )")

ScreenGui.Parent = CoreGui

--// Functions

local function updateSpeedLabel()
    SpeedLabel.Text = "Speed: "..tostring(flySpeed)
end

local function stopFlying()
    if bodyGyro then bodyGyro:Destroy() end
    if bodyVelocity then bodyVelocity:Destroy() end
    bodyGyro, bodyVelocity = nil, nil
    flying = false
    FlyToggleButton.Text = "Fly: Off"
    FlyToggleButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    
    local Character = LocalPlayer.Character
    local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
    if Humanoid and Humanoid.Health > 0 then
        Humanoid:ChangeState(Enum.HumanoidStateType.Running)
    end
end

local function startFlying()
    local Character = LocalPlayer.Character
    local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
    local RootPart = Humanoid and Humanoid.RootPart
    if not (Character and Humanoid and RootPart) then return end
    
    stopFlying()
    
    Humanoid:ChangeState(Enum.HumanoidStateType.Physics)
    
    bodyGyro = Instance.new("BodyGyro")
    bodyGyro.P = 500000
    bodyGyro.D = 1500
    bodyGyro.MaxTorque = Vector3.new(bodyGyro.P, bodyGyro.P, bodyGyro.P)
    bodyGyro.CFrame = RootPart.CFrame
    bodyGyro.Parent = RootPart

    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.Velocity = Vector3.new(0, 0, 0)
    bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bodyVelocity.P = 10000
    bodyVelocity.Parent = RootPart

    flying = true
    FlyToggleButton.Text = "Fly: On"
    FlyToggleButton.BackgroundColor3 = Color3.fromRGB(76, 175, 80)
end

RunService.Heartbeat:Connect(function()
    if not flying then return end
    
    local Character = LocalPlayer.Character
    local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
    local RootPart = Humanoid and Humanoid.RootPart
    
    if not (Character and Humanoid and RootPart and bodyGyro and bodyVelocity) then
        stopFlying()
        return
    end

    bodyGyro.CFrame = workspace.CurrentCamera.CFrame
    
    local moveDirection = Vector3.new(
        (UserInputService:IsKeyDown(Enum.KeyCode.D) and 1 or 0) - (UserInputService:IsKeyDown(Enum.KeyCode.A) and 1 or 0),
        ((UserInputService:IsKeyDown(Enum.KeyCode.E) or flyUpActive) and 1 or 0) - ((UserInputService:IsKeyDown(Enum.KeyCode.Q) or flyDownActive) and 1 or 0),
        (UserInputService:IsKeyDown(Enum.KeyCode.S) and 1 or 0) - (UserInputService:IsKeyDown(Enum.KeyCode.W) and 1 or 0)
    )
    
    if moveDirection.Magnitude > 0 then
        bodyVelocity.Velocity = workspace.CurrentCamera.CFrame:VectorToWorldSpace(moveDirection.Unit) * flySpeed
    else
        bodyVelocity.Velocity = Vector3.new(0, 0, 0)
    end
end)

--// Character Death Handler
local function onCharacterAdded(character)
    local humanoid = character:WaitForChild("Humanoid")
    humanoid.Died:Connect(function()
        if flying then
            stopFlying()
        end
    end)
end

if LocalPlayer.Character then
    onCharacterAdded(LocalPlayer.Character)
end
LocalPlayer.CharacterAdded:Connect(onCharacterAdded)

--// GUI Interactions
CloseButton.MouseButton1Click:Connect(function()
    stopFlying()
    ScreenGui:Destroy()
end)

local isMinimized = false
local originalSize = MainFrame.Size
local originalAspectRatio = AspectRatio.AspectRatio
MinimizeButton.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    ContentFrame.Visible = not isMinimized
    Tooltip.Visible = false

    if isMinimized then
        AspectRatio.AspectRatio = 220 / 30
        MainFrame:TweenSize(UDim2.new(0, 220, 0, 30), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
    else
        AspectRatio.AspectRatio = originalAspectRatio
        MainFrame:TweenSize(originalSize, Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
    end
end)

-- Draggable Logic
local dragging, dragStart, startPos
TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        Tooltip.Visible = false
    end
end)
TitleBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Button Connections
FlyToggleButton.MouseButton1Click:Connect(function()
    if flying then stopFlying() else startFlying() end
end)

SpeedIncreaseButton.MouseButton1Click:Connect(function()
    if os.clock() - lastSpeedChangeTime < 0.05 then return end
    lastSpeedChangeTime = os.clock()
    flySpeed = flySpeed + 1
    updateSpeedLabel()
end)

SpeedDecreaseButton.MouseButton1Click:Connect(function()
    if os.clock() - lastSpeedChangeTime < 0.05 then return end
    lastSpeedChangeTime = os.clock()
    flySpeed = math.max(1, flySpeed - 1)
    updateSpeedLabel()
end)

-- Mobile/Button Press Handlers
FlyUpButton.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then flyUpActive = true end end)
FlyUpButton.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then flyUpActive = false end end)
FlyDownButton.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then flyDownActive = true end end)
FlyDownButton.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then flyDownActive = false end end)
