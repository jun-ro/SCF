-- Services --

local Players = game:GetService("Players")

-- Framework --

local Framework = require(game.ReplicatedStorage.Framework)

local Server = Framework.Server.new()
local Animation = Framework.Animation.new()
local Relay = Framework.Relay.new()
local StateMachine = Framework.StateMachine.new()
local Networking = Framework.Networking.new()
local AttackModule = Framework.AttackHandler.new()

-- Networking --

local ClientEventMap = game.ReplicatedStorage.Client.Networking.EventMap
local ServerEventMap = game.ServerStorage.Server.Events.EventMap

Networking:Setup(ClientEventMap, ServerEventMap)

-- Animation --

Animation:CacheAnimations(game.ServerStorage.Server.Animations.AnimMap)

-- Relays --

Relay:CreateRelay("StateManagement", "ChangeState", StateMachine:RelayModule())
Relay:CreateRelay("AttackModule", "CastHitbox", AttackModule:RelayCastHitbox())
Relay:Compose()

-- Server Management --

Server:Compose(game.ServerStorage.Server.Functions.FunctionMap)

-- Player Events --

function onPlayerJoin(player: Player)
	
end

Players.PlayerAdded:Connect(onPlayerJoin)

for _, players: Players in pairs(Players:GetPlayers()) do
	task.spawn(function()
		onPlayerJoin(players)
	end)
end
