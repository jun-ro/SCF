local Networking = {}
Networking.__index = Networking

local RS = game:GetService("RunService")

function Networking.new()
	local self = setmetatable({}, Networking)
	self.Connections = {}
	return self
end

function Networking:Setup(clientEventMap: ModuleScript, serverEventMap: ModuleScript)
	if RS:IsServer() then
		local EventMasterCache = Instance.new('Folder', game.ReplicatedStorage)
		EventMasterCache.Name = "ServerEvents"
		
		local ClientEMC = Instance.new('Folder', game.ReplicatedStorage)
		ClientEMC.Name = "ClientEvents"

		for _, moduleScripts: ModuleScript in pairs(require(serverEventMap)) do
			for name, functions in pairs(require(moduleScripts)) do

				local RemoteEvent = Instance.new('RemoteEvent', EventMasterCache)
				RemoteEvent.Name = name
				
				RemoteEvent.OnServerEvent:Connect(functions)
			end
		end
		
		for _, moduleScripts: ModuleScript in pairs(require(clientEventMap)) do
			for name, functions: (player: Player) -> () in pairs(require(moduleScripts)) do
				local RemoteEvent = Instance.new('RemoteEvent', ClientEMC)
				RemoteEvent.Name = name
			end
		end
	else
		for _, moduleScripts: ModuleScript in pairs(require(clientEventMap)) do
			for name, functions: () -> () in pairs(require(moduleScripts)) do
				local EventConnection = game.ReplicatedStorage:FindFirstChild("ClientEvents")
				if EventConnection[name] then
					EventConnection[name].OnClientEvent:Connect(functions)
				end
			end
		end
	end
end

function Networking:CreateEvent(nameOfEvent: string, func_: (player: Player) -> ()) 
	if RS:IsServer() then
		local EventMasterCache = game.ReplicatedStorage:FindFirstChild("ServerEvents")

		if not EventMasterCache then
			error("Master Cache was not found! Please run :Setup()")
			return
		end

		local RemoteEvent = Instance.new('RemoteEvent', EventMasterCache)
		RemoteEvent.Name = nameOfEvent
		RemoteEvent.OnServerEvent:Connect(func_)
	else
		error("Please run :CreateEvent() on the server only!")
	end
end

function Networking:FireServer(nameOfEvent: string, ...)
	if RS:IsClient() then
		local MasterCache = game.ReplicatedStorage:FindFirstChild("ServerEvents")
		
		if not MasterCache then
			error("Master Cache was not found! Please run :Setup()")
			return
		end
		
		local RemoteEvent: RemoteEvent = MasterCache:FindFirstChild(nameOfEvent)
		
		if RemoteEvent then
			RemoteEvent:FireServer(...)
		end
	end
end

function Networking:FireClient(nameOfEvent: string, player: Player, ...)
	if RS:IsServer() then
		local MasterCache = game.ReplicatedStorage:FindFirstChild("ClientEvents")

		if not MasterCache then
			error("Master Cache was not found! Please run :Setup()")
			return
		end

		local RemoteEvent: RemoteEvent = MasterCache:FindFirstChild(nameOfEvent)

		if RemoteEvent then
			RemoteEvent:FireClient(player, ...)
		end
	end
end

function Networking:FireAllClients(nameOfEvent: string, ...)
	if RS:IsServer() then
		local MasterCache = game.ReplicatedStorage:FindFirstChild("ClientEvents")

		if not MasterCache then
			error("Master Cache was not found! Please run :Setup()")
			return
		end

		local RemoteEvent: RemoteEvent = MasterCache:FindFirstChild(nameOfEvent)

		if RemoteEvent then
			RemoteEvent:FireAllClients(...)
		end
	end
end


return Networking
