local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Table to store copied tool information to avoid duplicates 🛡️
local copyDebounce = {}

-- Utility: Safe wait for child with timeout 🚀
local function safeWaitForChild(parent, childName, timeout)
    local child = parent:FindFirstChild(childName)
    local elapsed = 0
    while not child and elapsed < (timeout or 5) do
        task.wait(0.1)
        elapsed = elapsed + 0.1
        child = parent:FindFirstChild(childName)
    end
    return child
end

-- Advanced function to copy tools from a given player's backpack 📦➡️🎒
local function copyToolsFromPlayer(player)
    if player == LocalPlayer then return end
    local backpack = safeWaitForChild(player, "Backpack", 5)
    if not backpack then
        warn("Backpack not found for player:", player.Name)
        return
    end
    
    copyDebounce[player.UserId] = copyDebounce[player.UserId] or {}

    for _, tool in ipairs(backpack:GetChildren()) do
        if tool:IsA("Tool") then
            -- Skip if this tool was already copied or exists in local player's backpack
            if not copyDebounce[player.UserId][tool.Name] and not LocalPlayer:WaitForChild("Backpack"):FindFirstChild(tool.Name) then
                local success, toolClone = pcall(function() 
                    return tool:Clone() 
                end)
                if success and toolClone then
                    toolClone.Parent = LocalPlayer:WaitForChild("Backpack")
                    copyDebounce[player.UserId][toolClone.Name] = true
                    print(string.format("✅ Copied '%s' from %s", tool.Name, player.Name))
                else
                    warn("❌ Failed to clone tool:", tool.Name, "from", player.Name)
                end
            end
        end
    end
end

-- Copy tools from all current players 🎯
local function copyToolsFromAllPlayers()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            copyToolsFromPlayer(player)
        end
    end
end

-- Advanced logging: Print all usernames with IDs 🔥
local function printUsernames()
    for _, player in ipairs(Players:GetPlayers()) do
        print(string.format("👤 User: %s | ID: %d", player.Name, player.UserId))
    end
end

-- Monitor a player's Backpack for new tools in real-time 👀
local function monitorBackpack(player)
    local backpack = safeWaitForChild(player, "Backpack", 5)
    if backpack then
        backpack.ChildAdded:Connect(function(child)
            if child:IsA("Tool") then
                task.wait(0.1) -- tiny delay to ensure the tool is fully added ⚡
                copyToolsFromPlayer(player)
            end
        end)
    else
        warn("Unable to monitor Backpack for", player.Name)
    end
end

-- Connect to new players joining 🔗
Players.PlayerAdded:Connect(function(player)
    -- Monitor the Backpack as soon as it is available
    player:WaitForChild("Backpack", 5)
    monitorBackpack(player)
    
    player.CharacterAdded:Connect(function(character)
        task.wait(2) -- allow time for Backpack initialization ⏱️
        copyToolsFromPlayer(player)
    end)
end)

-- Initialize for existing players (excluding the local player) 🌐
for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        monitorBackpack(player)
    end
end

-- Initial copy and user logging 🏁
copyToolsFromAllPlayers()
printUsernames()
