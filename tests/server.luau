local Framework = require(game.ReplicatedStorage.Framework)
local SNet = Framework.SNet.new()

SNet:Rollup({
	require(game.ReplicatedStorage.TestModule).Package(),
})

SNet:Compose()
