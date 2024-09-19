local Animation = {}
Animation.__index = Animation

local ContentProvider = game:GetService("ContentProvider")
local RS = game:GetService("RunService")

local UtilLibrary = require(script.Parent.Util)

function Animation.new()
	local self = setmetatable({}, Animation)
	self.Animators = {}
	return self
end

function Animation:CacheAnimations(animationMap: ModuleScript)
	if RS:IsServer() then
		local MasterCache = Instance.new("Folder", game.ReplicatedStorage)
		MasterCache.Name = "Animations"

		for _, moduleScripts: ModuleScript in pairs(require(animationMap)) do
			for name, id in pairs(require(moduleScripts)) do
				local Animation = Instance.new("Animation", MasterCache)
				Animation.AnimationId = "rbxassetid://" .. id
				Animation.Name = name
			end
		end

		ContentProvider:PreloadAsync(MasterCache:GetChildren())
	end
end

function Animation:CreateAnimator(name: string, animator: Animator)
	self.Animators[name] = {
		AnimatorObject = nil,
		loadedAnims = {},
	}

	if animator ~= nil then
		self.Animators[name].AnimatorObject = animator
	end

	local animatorObject = {
		loadAll = function()
			local masterCache = game.ReplicatedStorage:WaitForChild("Animations")

			if not masterCache then
				error("Cache is not found, please run :CacheAnimations()")
				return
			end

			for _, animations: Animation in pairs(masterCache:GetChildren()) do
				self.Animators[name].loadedAnims[animations.Name] =
					self.Animators[name].AnimatorObject:LoadAnimation(animations)
			end
		end,
		getTrack = function(nameOfTrack: string): AnimationTrack
			if not self.Animators[name].loadedAnims[nameOfTrack] then
				error(`{nameOfTrack} does not exist within "LoadedAnimations"! Please run .loadAll()`)
				return
			end

			return self.Animators[name].loadedAnims[nameOfTrack]
		end,
		stopAllAnims = function()
			for _, animationTracks: AnimationTrack in
				pairs(self.Animators[name].AnimatorObject:GetPlayingAnimationTracks())
			do
				animationTracks:Stop()
			end
		end,
		setAnimator = function(animator: Animator)
			self.Animators[name].AnimatorObject = animator
		end,
	}

	return animatorObject
end

function Animation:CreateBlank(id: string, animator: Animator): AnimationTrack
	local Animation = Instance.new("Animation")
	Animation.AnimationId = "rbxassetid://" .. id

	return animator:LoadAnimation(Animation)
end

function Animation:StopAllAnims(animator: Animator)
	for _, animationTracks: AnimationTrack in pairs(animator:GetPlayingAnimationTracks()) do
		animationTracks:Stop()
	end
end

function Animation:GetAnimator(player: Player, animator: string)
	local PlayerVars = UtilLibrary.getPlayer(player)
	local Animator: Animator = PlayerVars.Humanoid:WaitForChild("Animator")

	if not Animator then
		error("Animator not found. Please create one!")
		return
	end

	self.Animators[animator].AnimatorObject = Animator

	return Animator
end

return Animation
