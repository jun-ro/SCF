local StateManagement = {}
StateManagement.__index = StateManagement 

local RS = game:GetService("RunService")
local Util = require(script.Parent.Parent.Util.Global)
local Relay = require(script.Parent.Parent.Util.RelayModule).new()

function StateManagement.new()
	local self = setmetatable({}, StateManagement) 
	
	if RS:IsClient() then
		self.States = {}

		self.Character = Util.getPlayer(game.Players.LocalPlayer).Character
		self.currentState = self.Character:WaitForChild('State')
		
		self.Enums = {
			["Idle"] = "Idle",
			["ExecutingMove"] = "ExecutingMove",
			["Stunned"] = "Stunned",
			["Slammed"] = "Slammed",
			["Ragdolled"] = "Ragdolled"
		}

		for name: string, stringPart: string in pairs(self.Enums) do
			self.States[name] = {
				initFunction = function()

				end,
			}
		end
	end
	
	return self
end

function StateManagement:AttachInitFunction(nameOfState: string, func: (previousState: string) -> ())
	if self.States[nameOfState] then
		self.States[nameOfState].initFunction = func
	end
end

function StateManagement:OnUpdate()
	local prevState = self.currentState.Value
	
	self.currentState.Changed:Connect(function(value: string)
		if self.States[value] then
			self.States[value].initFunction(prevState)
		end
		prevState = value
	end)
end

function StateManagement:EnterState(newState: string)
	Relay:EmitRelay("StateManagement", "ChangeState", newState)
end

function StateManagement:GetState()
	return self.currentState.Value
end

function StateManagement:RelayModule()
	return function(player: Player, newState: string)
		local Character = player.Character or player.CharacterAdded:Wait()
		local State: StringValue = Character:WaitForChild('State')
		State.Value = newState
	end
end

return StateManagement
