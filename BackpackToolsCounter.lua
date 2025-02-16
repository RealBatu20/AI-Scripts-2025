local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
local UIS = game:GetService("UserInputService")

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.Name = "BackpackToolCounter"
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.Size = UDim2.new(0, 400, 0, 500)
MainFrame.Position = UDim2.new(0.5, -200, 0.5, -250)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BackgroundTransparency = 0.2
MainFrame.BorderSizePixel = 0
MainFrame.Active = true

local Stroke = Instance.new("UIStroke", MainFrame)
Stroke.Thickness = 3
Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
Stroke.Color = Color3.fromRGB(255, 0, 0)

local UICorner = Instance.new("UICorner", MainFrame)
UICorner.CornerRadius = UDim.new(0, 10)

local Title = Instance.new("TextLabel")
Title.Parent = MainFrame
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundTransparency = 1
Title.Text = "🎒 Backpack Tool Counter"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 20
Title.TextColor3 = Color3.fromRGB(255, 255, 255)

local SearchBox = Instance.new("TextBox")
SearchBox.Parent = MainFrame
SearchBox.Size = UDim2.new(1, -20, 0, 40)
SearchBox.Position = UDim2.new(0, 10, 0, 50)
SearchBox.PlaceholderText = "🔎 Enter Username or DisplayName"
SearchBox.Text = ""
SearchBox.Font = Enum.Font.Gotham
SearchBox.TextSize = 16
SearchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
SearchBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
SearchBox.ClearTextOnFocus = false

local UICorner2 = Instance.new("UICorner", SearchBox)
UICorner2.CornerRadius = UDim.new(0, 6)

local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Parent = MainFrame
ScrollFrame.Size = UDim2.new(1, -20, 1, -120)
ScrollFrame.Position = UDim2.new(0, 10, 0, 100)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
ScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 255)

local UIListLayout = Instance.new("UIListLayout", ScrollFrame)
UIListLayout.Padding = UDim.new(0, 5)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

local CloseButton = Instance.new("TextButton")
CloseButton.Parent = MainFrame
CloseButton.Size = UDim2.new(0, 40, 0, 40)
CloseButton.Position = UDim2.new(1, -50, 0, 10)
CloseButton.Text = "❌"
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextSize = 18
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)

local UICorner3 = Instance.new("UICorner", CloseButton)
UICorner3.CornerRadius = UDim.new(1, 0)

local function UpdateBackpackList()
    for _, child in pairs(ScrollFrame:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end

    local searchText = SearchBox.Text:lower()
    local foundPlayer = nil

    for _, player in pairs(Players:GetPlayers()) do
        if player.Name:lower():find(searchText) or player.DisplayName:lower():find(searchText) then
            foundPlayer = player
            break
        end
    end

    if foundPlayer then
        local backpack = foundPlayer:FindFirstChildOfClass("Backpack")
        if backpack then
            for _, tool in pairs(backpack:GetChildren()) do
                if tool:IsA("Tool") then
                    local ToolFrame = Instance.new("Frame")
                    ToolFrame.Parent = ScrollFrame
                    ToolFrame.Size = UDim2.new(1, -20, 0, 50)
                    ToolFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)

                    local ToolLabel = Instance.new("TextLabel")
                    ToolLabel.Parent = ToolFrame
                    ToolLabel.Size = UDim2.new(0.7, 0, 1, 0)
                    ToolLabel.Text = "🔧 " .. tool.Name
                    ToolLabel.Font = Enum.Font.Gotham
                    ToolLabel.TextSize = 16
                    ToolLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                    ToolLabel.BackgroundTransparency = 1

                    local GetButton = Instance.new("TextButton")
                    GetButton.Parent = ToolFrame
                    GetButton.Size = UDim2.new(0.3, 0, 1, 0)
                    GetButton.Position = UDim2.new(0.7, 0, 0, 0)
                    GetButton.Text = "🎁 Get"
                    GetButton.Font = Enum.Font.GothamBold
                    GetButton.TextSize = 16
                    GetButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
                    GetButton.TextColor3 = Color3.fromRGB(255, 255, 255)

                    GetButton.MouseButton1Click:Connect(function()
                        tool.Parent = LocalPlayer.Backpack
                    end)
                end
            end
        end
    end
end

SearchBox:GetPropertyChangedSignal("Text"):Connect(UpdateBackpackList)

local Dragging, DragStart, StartPos
local function Update(input)
    local delta = input.Position - DragStart
    MainFrame.Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + delta.X, StartPos.Y.Scale, StartPos.Y.Offset + delta.Y)
end

MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        Dragging = true
        DragStart = input.Position
        StartPos = MainFrame.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                Dragging = false
            end
        end)
    end
end)

UIS.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement and Dragging then
        Update(input)
    end
end)

CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)
