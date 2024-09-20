local Framework = require(game.ReplicatedStorage.Framework)
local SNet = Framework.SNet.new()

SNet:Rollup({
	require(game.ReplicatedStorage.TestModule).Package(),
})

SNet:Compose()

-- Wait a bit --
-- You don't have to compose and roll up every time you want to start using SNet.

task.wait(2)

print(SNet:EmitCallback("TestModule","TestEvent"))

-- Should print out: This WILL return something AND run something on the Server.