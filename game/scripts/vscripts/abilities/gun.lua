require('libraries/timers')
require('libraries/projectiles')

function DelayedFire(keys)
	--print('[SuperHot] Firing gun.')
	local caster = keys.caster
	local target = keys.target_points[1]
	local delay = keys.delay

	if caster:IsHero() then delay = 0.35 end
	if delay == nil then delay = 0 end

	local direction = (target - caster:GetAbsOrigin()):Normalized()
	
	print("Firing gun. Delay: ", delay)

	local point_1 = caster:GetAbsOrigin()
	local point_2 = direction * keys.ProjectileDistance
	local point_final = direction * keys.ProjectileDistance
	local vInterval = (point_1 - point_2) / 40

	for i = 1, 40 do
		local checkPoint = point_1 - (i * vInterval)
		DebugDrawSphere(checkPoint, Vector(0, 0, 255), 255, 10, false, 1.0)
		if GridNav:IsBlocked(checkPoint) == true or GridNav:IsTraversable(checkPoint) ~= true then
			if i == 1 then
				point_final = point_1
			else
				point_final = point_1 - ( (i - 1) * vInterval)
			end
			break
		end
	end

	local distance = (point_final - point_1):Length2D()

	local info = 
	{
		Ability = keys.ability,
		EffectName = keys.EffectName,
		vSpawnOrigin = caster:GetAttachmentOrigin(DOTA_PROJECTILE_ATTACHMENT_ATTACK_1),
		fDistance = distance,
		fStartRadius = keys.ProjectileRadius,
		fEndRadius = keys.ProjectileRadius,
		Source = caster,
		bHasFrontalCone = false,
		bReplaceExisting = false,
		iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
		iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
		iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		fExpireTime = GameRules:GetGameTime() + 10.0,
		bDeleteOnHit = true,
		vVelocity = direction * keys.ProjectileSpeed,
		bProvidesVision = true,
		iVisionRadius = 50,
		iVisionTeamNumber = caster:GetTeamNumber()
	}

	Timers:CreateTimer(delay, function()
		ProjectileManager:CreateLinearProjectile(info)
		EmitSoundOn("Hero_Sniper.attack", caster)
	end)
end

function StartGesture(keys)
	local caster = keys.caster
	caster:StartGesture(ACT_DOTA_CAST_ABILITY_1)
end