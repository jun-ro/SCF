local Framework = require(game.ReplicatedStorage.Framework)

local Util = Framework.Util
local AttackHandler = Framework.AttackHandler.new()

local Player = Util.getPlayer(game.Players.LocalPlayer)
local Mouse = Player.Player:GetMouse()


local moveData = {
	AttackType = AttackHandler.Enums.M1,
	Animation = "Staff1",
	EnemyAnim = "119097870904238",
	Damage = 5,
	Hitbox = Vector3.new(4,5,2),
	PushbackMagnitude = 5
}

Mouse.Button1Down:Connect(function() 
	local Attack = AttackHandler:HandleBasic(moveData)
	
	Attack.onHit = function()
		print("Hit keyframe reached!")
	end
	
	Attack.onEnd = function()
		print("Animation has ended!")
	end
end)
