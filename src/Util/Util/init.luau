local Global = {}

function Global.getPlayer(player: Player)
	local Character: Model = player.Character or player.CharacterAdded:Wait()
	local Humanoid: Humanoid = Character:WaitForChild("Humanoid")
	local HRP: Part = Character:WaitForChild("HumanoidRootPart")

	return { Player = player, Character = Character, Humanoid = Humanoid, HumanoidRootPart = HRP }
end


return Global
