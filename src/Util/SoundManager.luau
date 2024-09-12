local SoundManager = {}
SoundManager.__index = SoundManager

function SoundManager.new()
	local self = setmetatable({}, SoundManager)
	return self
end

function SoundManager:CreateBlank(id: string, destination: Part)
	local Sound = Instance.new('Sound', destination)
	Sound.SoundId = 'rbxassetid://'..id
	
	return Sound
end

return SoundManager
