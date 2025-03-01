--// AntiAFK + AntiKick GUI (Larger & Toggle Button)
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")

--// GUI Creation
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game.CoreGui
ScreenGui.Name = "AntiAFKV3"

local Frame = Instance.new("Frame")
Frame.Parent = ScreenGui
Frame.Size = UDim2.new(0, 320, 0, 280) -- Increased Size
Frame.Position = UDim2.new(0.5, -160, 0.4, 0)
Frame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
Frame.BackgroundTransparency = 0.1
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true
Frame.ClipsDescendants = true
Frame.Visible = true -- Initially visible

--// UI Corner (Smooth Edge)
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = Frame

--// Neon Glow Effect
local UIStroke = Instance.new("UIStroke")
UIStroke.Parent = Frame
UIStroke.Thickness = 2.5
UIStroke.Color = Color3.fromRGB(0, 255, 150)
UIStroke.Transparency = 0.4

--// Gradient Animation
local Gradient = Instance.new("UIGradient")
Gradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 200, 255)), 
    ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 255, 150))
}
Gradient.Rotation = 90
Gradient.Parent = Frame

task.spawn(function()
    while true do
        local Tween = TweenService:Create(Gradient, TweenInfo.new(3, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut), {Rotation = Gradient.Rotation + 180})
        Tween:Play()
        Tween.Completed:Wait()
    end
end)

--// Title Label
local Title = Instance.new("TextLabel")
Title.Parent = Frame
Title.Size = UDim2.new(1, 0, 0, 28)
Title.BackgroundTransparency = 1
Title.Text = "🛡️ AntiAFK + AntiKick V3.2"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.TextColor3 = Color3.fromRGB(255, 255, 255)

--// Timer Label
local TimerLabel = Instance.new("TextLabel")
TimerLabel.Parent = Frame
TimerLabel.Size = UDim2.new(1, 0, 0, 22)
TimerLabel.Position = UDim2.new(0, 0, 0, 32)
TimerLabel.BackgroundTransparency = 1
TimerLabel.Text = "AFK Time: 0 seconds"
TimerLabel.Font = Enum.Font.Gotham
TimerLabel.TextSize = 12
TimerLabel.TextColor3 = Color3.fromRGB(200, 200, 200)

--// Scrolling Frame for Kick Logs
local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Parent = Frame
ScrollFrame.Size = UDim2.new(1, -10, 1, -85)
ScrollFrame.Position = UDim2.new(0, 5, 0, 58)
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollFrame.ScrollBarThickness = 3
ScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(0, 255, 150)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y

local ListLayout = Instance.new("UIListLayout")
ListLayout.Parent = ScrollFrame
ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
ListLayout.Padding = UDim.new(0, 3)

--// Clear Logs Button
local ClearLogsButton = Instance.new("TextButton")
ClearLogsButton.Parent = Frame
ClearLogsButton.Size = UDim2.new(1, -10, 0, 24)
ClearLogsButton.Position = UDim2.new(0, 5, 1, -28)
ClearLogsButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
ClearLogsButton.Text = "🗑️ Clear Logs"
ClearLogsButton.Font = Enum.Font.GothamBold
ClearLogsButton.TextSize = 13
ClearLogsButton.TextColor3 = Color3.fromRGB(255, 100, 100)

-- Smooth edges for Clear Button
local ButtonCorner = Instance.new("UICorner")
ButtonCorner.CornerRadius = UDim.new(0, 6)
ButtonCorner.Parent = ClearLogsButton

--// Toggle Visibility Button (Outside GUI)
local ToggleButton = Instance.new("TextButton")
ToggleButton.Parent = ScreenGui
ToggleButton.Size = UDim2.new(0, 140, 0, 30)
ToggleButton.Position = UDim2.new(0.5, -70, 0, -24)
ToggleButton.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
ToggleButton.Text = "👁️ Hide AntiAFK GUI"
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.TextSize = 12
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 6)
ToggleCorner.Parent = ToggleButton

--// Function to Toggle GUI
local isVisible = true
ToggleButton.MouseButton1Click:Connect(function()
    isVisible = not isVisible
    Frame.Visible = isVisible
    ToggleButton.Text = isVisible and "👁️ Hide AntiAFK GUI" or "👁️ Show AntiAFK GUI"
end)

--// Function to Format AFK Time
local function formatTime(seconds)
    local days = math.floor(seconds / 86400)
    seconds = seconds % 86400
    local hours = math.floor(seconds / 3600)
    seconds = seconds % 3600
    local minutes = math.floor(seconds / 60)
    local secs = seconds % 60
    
    local result = ""
    if days > 0 then result = result .. days .. " days, " end
    if hours > 0 then result = result .. hours .. " hours, " end
    if minutes > 0 then result = result .. minutes .. " minutes, " end
    result = result .. secs .. " seconds"
    
    return result
end

--// AntiAFK System
local afkTime = 0
local function preventAFK()
    game:GetService("Players").LocalPlayer.Idled:Connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())

        -- Log Kick Attempt
        local Log = Instance.new("TextLabel")
        Log.Parent = ScrollFrame
        Log.Size = UDim2.new(1, -5, 0, 20)
        Log.BackgroundTransparency = 1
        Log.Text = "❌ Kick prevented at " .. formatTime(afkTime)
        Log.Font = Enum.Font.Gotham
        Log.TextSize = 12
        Log.TextColor3 = Color3.fromRGB(255, 100, 100)
        Log.TextXAlignment = Enum.TextXAlignment.Left

        ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y + 5)
    end)
end

--// Clear Logs Function
ClearLogsButton.MouseButton1Click:Connect(function()
    for _, v in pairs(ScrollFrame:GetChildren()) do
        if v:IsA("TextLabel") then v:Destroy() end
    end
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
end)

--// AFK Timer System
task.spawn(function()
    preventAFK()
    while true do
        task.wait(1)
        afkTime = afkTime + 1
        TimerLabel.Text = "AFK Time: " .. formatTime(afkTime)
    end
end)
