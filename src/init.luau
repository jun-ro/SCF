local Framework = {
	["Networking"] = require(script.Util.Networking),
	["Animation"] = require(script.Util.Animation),
	["Relay"] = require(script.Util.RelayModule),
	["Util"] = require(script.Util.Global),
	["StateMachine"] = require(script.Combat.StateManagement),
	["AttackHandler"] = require(script.Combat.AttackModule),
	["Server"] = require(script.Util.ServerManagement),
	["SoundManager"] = require(script.Util.SoundManager)
}


return Framework
