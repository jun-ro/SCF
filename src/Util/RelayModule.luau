local RelayModule = {}
RelayModule.__index = RelayModule

local RelayEvent = script.RelayEvent

function RelayModule.new()
	local self = setmetatable({}, RelayModule)
	self.Relays = {}
	return self
end

function RelayModule:CreateRelay(hostName: string, eventName: string, callFunction: () -> ())
	if not self.Relays[hostName] then
		self.Relays[hostName] = {}
		self.Relays[hostName][eventName] = callFunction
	else
		self.Relays[hostName][eventName] = callFunction
	end
end

function RelayModule:EmitRelay(hostName: string, eventName: string, ...)
	RelayEvent:FireServer(hostName, eventName, ...)
end


function RelayModule:Compose()
	RelayEvent.OnServerEvent:Connect(function(player: Player, hostName: string, eventName: string, ...) 
		if self.Relays[hostName][eventName] then
			self.Relays[hostName][eventName](player, ...)
		end
	end)
end

return RelayModule
