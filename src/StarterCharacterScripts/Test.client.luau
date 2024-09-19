-- Framework --

local Framework = require(game.ReplicatedStorage.Framework)
local StateManager = Framework.StateManager.new()
local Util = Framework.Util

-- Player Variables --

local Player = Util.getPlayer(game.Players.LocalPlayer)
local Mouse = Player.Player:GetMouse()

-- Setup --


-- Variables --

local Count = 1

Mouse.Button1Down:Connect(function()
    if StateManager:GetState() == "Idle" then
        StateManager:EnterState("ExecutingMove")
        print("Executing Move!")
        task.wait(1)
        StateManager:EnterState("Idle")
    end
end)
