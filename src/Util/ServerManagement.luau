local ServerManagement = {}
ServerManagement.__index = ServerManagement

function ServerManagement.new()
	local self = setmetatable({}, ServerManagement)
	self.Functions = {}
	return self
end

function ServerManagement:Compose(functionMap: ModuleScript)
	for _, moduleScripts: ModuleScript in pairs(require(functionMap)) do
		for name, functions in pairs(require(moduleScripts)) do
			self.Functions[name] = functions
		end
	end
end

function ServerManagement:Execute(nameOfFunction: string, ...)
	if self.Functions[nameOfFunction] then
		self.Functions[nameOfFunction](...)
	end
end

return ServerManagement
