local SNet = {}
SNet.__index = SNet

-- Dependencies --

local RunService = game:GetService("RunService")

-- Events --

local CallbackRelay = script.CallbackRelay
local EventRelay = script.EventRelay

-- Init --

function SNet.new()
	local self = setmetatable({}, SNet)

	self.UNetEvents = {}

	if _G.UNetEvents then
		self.UNetEvents = _G.UNetEvents
	else
		_G.UNetEvents = self.UNetEvents
	end

	if not _G.UNetEvents.Default then
		_G.UNetEvents.Default = require(script.Default)
	end

	return self
end

function SNet:CreateEvent(hostName: string, eventName: string, func_: () -> ())
	-- Ensure UNetEvents exists and is initialized properly
	if not self.UNetEvents[hostName] then
		self.UNetEvents[hostName] =
			{ Server = { Events = {}, Callbacks = {} }, Client = { Events = {}, Callbacks = {} } }
	end

	-- Assign the event function

	if RunService:IsClient() then
		self.UNetEvents[hostName].Client.Events[eventName] = func_
	else
		self.UNetEvents[hostName].Server.Events[eventName] = func_
	end

	_G.UNetEvents = self.UNetEvents
end

function SNet:CreateCallback(hostName: string, callbackName: string, func_: () -> ())
	-- Ensure UNetEvents exists and is initialized properly
	if not self.UNetEvents[hostName] then
		self.UNetEvents[hostName] =
			{ Server = { Events = {}, Callbacks = {} }, Client = { Events = {}, Callbacks = {} } }
	end

	-- Assign the callback function

	if RunService:IsClient() then
		self.UNetEvents[hostName].Client.Callbacks[callbackName] = func_
	else
		self.UNetEvents[hostName].Server.Callbacks[callbackName] = func_
	end

	_G.UNetEvents = self.UNetEvents
end

function SNet:Rollup(listOfFunctions: {})
	local success, err = pcall(function()
		for _, relayData: {Server: {}, Client: {}, Name: string} in pairs(listOfFunctions) do

			if RunService:IsServer() then	
				if relayData.Server ~= nil then
					for name: string, funcs_: () -> () in  pairs(relayData.Server.Events) do
						self:CreateEvent(relayData.Name, name, funcs_)
					end		

					for name: string, funcs_: () -> () in  pairs(relayData.Server.Callbacks) do
						self:CreateCallback(relayData.Name, name, funcs_)
					end		
				end	
			else
				
				if relayData.Client ~= nil then
					for name: string, funcs_: () -> () in  pairs(relayData.Client.Events) do
						self:CreateEvent(relayData.Name, name, funcs_)
					end		

					for name: string, funcs_: () -> () in  pairs(relayData.Client.Callbacks) do
						self:CreateCallback(relayData.Name, name, funcs_)
					end			
				end
			end
		end
	end)

	-- Check if pcall was successful
	if not success then
		error("Error in UNet:Rollup: " .. err)
	else
		print(`[UNet] Rollup Complete!`)
	end
end

function SNet:EmitCallback(hostName: string, callbackName: string, ...)
	return CallbackRelay:InvokeServer(hostName, callbackName, ...)
end

function SNet:EmitEvent(hostName: string, eventName: string, ...)
	EventRelay:FireServer(hostName, eventName, ...)
end

function SNet:EmitClientEvent(player: Player, hostName: string, eventName: string, ...)
	EventRelay:FireClient(player, hostName, eventName, ...)
end

function SNet:EmitClientCallback(player: Player, hostName: string, eventName: string, ...)
	return CallbackRelay:InvokeClient(player, hostName, eventName, ...)
end

function SNet:EmitAllClientEvent(hostName: string, eventName: string, ...)
	return CallbackRelay:FireAllClients(hostName, eventName, ...)
end

function SNet:Compose()
	if RunService:IsServer() then
		EventRelay.OnServerEvent:Connect(function(player: Player, hostName: string, eventName: string, ...)
			if self.UNetEvents[hostName].Server.Events[eventName] then
				self.UNetEvents[hostName].Server.Events[eventName](player, ...)
			else
				error(`\n[SNet] "{eventName}" was not found within {hostName}'s Events!`)
			end
		end)

		CallbackRelay.OnServerInvoke = function(player: Player, hostName: string, callbackEvent: string, ...)
			if not self.UNetEvents[hostName].Server.Callbacks[callbackEvent] then
				error(`\n[SNet] "{callbackEvent}" was not found within {hostName}'s Events!`)
				return false
			end

			return self.UNetEvents[hostName].Server.Callbacks[callbackEvent](player, ...)
		end
	else
		EventRelay.OnClientEvent:Connect(function(hostName: string, eventName: string, ...)
			if self.UNetEvents[hostName].Client.Events[eventName] then
				self.UNetEvents[hostName].Client.Events[eventName](...)
			else
				error(`\n[SNet] "{eventName}" was not found within {hostName}'s Events!`)
			end
		end)

		CallbackRelay.OnClientInvoke = function(hostName: string, callbackEvent: string, ...)
			if not self.UNetEvents[hostName].Client.Callbacks[callbackEvent] then
				error(`\n[SNet] "{callbackEvent}" was not found within {hostName}'s Events!`)
				return false
			end

			return self.UNetEvents[hostName].Client.Callbacks[callbackEvent](...)
		end
	end
end

function SNet:GetEvents()
	return self:EmitCallback("Default", "GetEvents")
end

return SNet
