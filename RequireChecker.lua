local ReplicatedStorage = game:GetService("ReplicatedStorage")

local executor = getgenv().identifyexecutor and getgenv().identifyexecutor() or "RobloxClientApp"

local function checkRequireSupport()
    local success, result = pcall(function()
        local reqTest = require(game:GetService("ReplicatedStorage")) -- Attempt to use require
    end)

    if success then
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Require Checker",
            Text = executor .. " supports 'require'",
            Duration = 5
        })
    else
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Require Checker",
            Text = executor .. " does not support 'require'",
            Duration = 5
        })
    end
end

checkRequireSupport()
