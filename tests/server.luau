local Framework = require(game.ReplicatedStorage.Framework)
local Players = game:GetService("Players")
local SNet = Framework.SNet.new()

SNet:Rollup({
	require(game.ReplicatedStorage.TestModule).Package(),
})

SNet:Compose()

task.wait(2)

print(SNet:EmitClientCallback(Players:GetPlayers()[1], "TestModule", "TestCallback"))
