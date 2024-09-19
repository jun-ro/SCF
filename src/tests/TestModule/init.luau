local TestModule = {}
TestModule.__index = TestModule

function TestModule.new()
	local self = setmetatable({}, TestModule)
	return self
end

function TestModule.Package()
	return require(script.EmittableFunctions)
end

return TestModule
