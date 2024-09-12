local AttackModule = {}
AttackModule.__index = AttackModule

local RS = game:GetService("RunService")
local Debris = game:GetService("Debris")

local Types = require(script.Types)
local Util = require(script.Parent.Parent.Util.Global)
local AnimationHandler = require(script.Parent.Parent.Util.Animation).new()
local StateMachine = require(script.Parent.StateManagement).new()
local RelayModule = require(script.Parent.Parent.Util.RelayModule).new()
local SoundManager = require(script.Parent.Parent.Util.SoundManager).new()

function AttackModule.new()
	local self = setmetatable({}, AttackModule)

	self.Enums = {
		["M1"] = "M1",
		["Ability"] = "Ability",
		["Projectile"] = "Projectile",
		["Ragdoll"] = "Ragdoll",
		["DownSlam"] = "DownSlam",
		["Launcher"] = "Launcher",
	}

	if RS:IsClient() then
		self.Player = Util.getPlayer(game.Players.LocalPlayer)
		self.PlayerAnimator = AnimationHandler:CreateAnimator("Player")
		
		AnimationHandler:GetAnimator(self.Player.Player, "Player")
		
		self.PlayerAnimator.loadAll()
	end
	
	self.currentAnim = nil

	return self
end

-- Helper Functions --

local function createHitbox(cframe: CFrame, attackData: Types.AttackData)
	local HitboxPart = Instance.new('Part', workspace)
	HitboxPart.Name = "Hitbox"
	HitboxPart.CFrame = cframe + cframe.LookVector*2
	HitboxPart.Size = attackData.Hitbox
	HitboxPart.Color = Color3.fromRGB(255,0,0)
	HitboxPart.Transparency = 0.5
	HitboxPart.CanCollide = false
	HitboxPart.Anchored = true
	HitboxPart.Material = Enum.Material.Neon
	
	return HitboxPart
end

local function generateParams(character: Model)
	local params = OverlapParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = character:GetDescendants()
	
	return params
end

local function processHitbox(playerCFrame: CFrame, enemyModel: Model, attackData: Types.AttackData)
	local HRP: Part = enemyModel:WaitForChild('HumanoidRootPart')
	local Humanoid: Humanoid = enemyModel:FindFirstChildOfClass("Humanoid")
	local Animator: Animator = Humanoid:FindFirstChildOfClass('Animator')
	
	local State: StringValue = enemyModel:WaitForChild('State')
	
	if State.Value == "Blocking" then
		return
	end
	
	AnimationHandler:StopAllAnims(Animator)
	local sound = SoundManager:CreateBlank("9117969687", HRP)
	local stunAnim = AnimationHandler:CreateBlank(attackData.EnemyAnim, Animator)

	sound.Volume = 1.25
	stunAnim:Play()
	sound:Play()
	
	HRP:ApplyImpulse(playerCFrame.LookVector*250)
end

-- Methods --

function AttackModule:HandleBasic(attackData: Types.AttackData)
	
	local basicFunctions = {
		getCurrentAttack = function()
			return {Data = attackData, Animation = self.currentAnim}
		end,
		castHitbox = function(humanoidRootPart: Part)
			self:CastHitbox(humanoidRootPart, attackData)
		end,
		onEnd = nil,
		onHit = nil
	}

	
	self.PlayerAnimator.stopAllAnims()
	
	local stopConnection: RBXScriptConnection = nil
	local hitConnection: RBXScriptConnection = nil
	
	
	self.currentAnim = self.PlayerAnimator.getTrack(attackData.Animation)
	
	
	self.currentAnim:Play()
	StateMachine:EnterState(StateMachine.Enums.ExecutingMove)
	
	hitConnection = self.currentAnim.KeyframeReached:Connect(function(keyframeName: string)
		basicFunctions.onHit(keyframeName)
		hitConnection:Disconnect()
	end)
	
	stopConnection = self.currentAnim.Stopped:Connect(function() 
		StateMachine:EnterState(StateMachine.Enums.Idle)
		basicFunctions.onEnd()
		stopConnection:Disconnect()
	end)

	return basicFunctions
end

function AttackModule:GetCurrentAnim(): AnimationTrack
	if self.currentAnim ~= nil then
		return self.currentAnim
	end
end

function AttackModule:CastHitbox(HumanoidRootPart: Part, attackData: Types.AttackData)
	RelayModule:EmitRelay("AttackModule", "CastHitbox", HumanoidRootPart.CFrame, attackData)
end

function AttackModule:RelayCastHitbox()
	local function onCast(player: Player, hCFrame: CFrame, attackData: Types.AttackData)
		local hitbox = createHitbox(hCFrame, attackData)
		Debris:AddItem(hitbox, 0.2)
		
		local processedEnemies = {}

		local results = workspace:GetPartsInPart(hitbox, generateParams(player.Character))
		
		for _, parts: Part in pairs(results) do
			local character = parts:FindFirstAncestorOfClass("Model")
			
			if character and character:FindFirstChildOfClass("Humanoid") then
				
				if not processedEnemies[character.Name] then
					
					processHitbox(hCFrame, character, attackData)
					
					processedEnemies[character.Name] = true
				end
			end
		end
	end
	
	return onCast
end

function AttackModule:HandleAttack(attackData: Types.AttackData)
	local attackFunctions = {
		
	}
	
	if attackFunctions[attackData.AttackType] then
		attackFunctions[attackData.AttackType](attackData)
	end
end

return AttackModule
