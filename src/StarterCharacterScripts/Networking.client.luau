local Framework = require(game.ReplicatedStorage.Framework)
local SNet = Framework.SNet.new()

SNet:Rollup({
    Framework.StateManager.Package()
})

SNet:Compose()