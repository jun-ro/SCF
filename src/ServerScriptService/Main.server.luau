local Framework = require(game.ReplicatedStorage.Framework)
local SNet = Framework.SNet.new()

SNet:Rollup({
    Framework.StateManager.Package()
})

SNet:Compose()

task.wait(5)

print(SNet:EmitClientCallback(game.Players:GetPlayers()[1], "StateManager", "TestClient"))