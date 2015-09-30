function OnAbilityPhaseStart(keys)
	local caster = keys.caster
	local target = keys.target_points[1]
end

function OnSpellStart(keys)
	-- Variables
	local caster = keys.caster
	local target = keys.target_points[1]
	local ability = keys.ability

	-- Unit
	local unit = CreateUnitByName("superhot_bullet", caster:GetAbsOrigin(), true, caster, caster, caster:GetTeamNumber())
	unit.direction = (target - caster:GetAbsOrigin()):Normalized()
	unit.direction.z = 0
	local velocityVec = unit.direction * 1800

	-- Physics
	unit:AddNewModifier(unit, nil, "modifier_invulnerable", {duration=-1})
	unit:SetAbsOrigin(unit:GetAbsOrigin() + (unit.direction * 40))
	Physics:Unit(unit)
	unit:AddPhysicsVelocity(velocityVec)
	unit:SetPhysicsFriction(0)
	unit:SetBounceMultiplier(0)
	unit:SetNavCollisionType(PHYSICS_NAV_BOUNCE)
	unit:Hibernate(false)
	unit:OnBounce(function(unit, normal)
		if unit.hasBeenDeleted == true then
			return false
		end
		unit:SetPhysicsVelocity(velocityVec)
		unit.hasBeenDeleted = true
		Timers:CreateTimer(0.05, function()
			unit.SuperhotDelete(unit)
		end)
	end)
	unit:OnPhysicsFrame(function(unit)
		if GameMode.GlobalSlow == true then
			unit:SetPhysicsVelocity(unit.direction * 20)
		else
			unit:SetPhysicsVelocity(unit.direction * 1800)
		end
	end)

	-- Collider
	unit.physCollider = unit:AddColliderFromProfile("delete")
	unit.physCollider.draw = {color = Vector(100,50,200), alpha = 0}
	unit.physCollider.radius = 10
	unit.physCollider.test = Dynamic_Wrap(GameMode, "HandleCollision")
	unit.physCollider.deleteSelf = false -- Handle deletion on our own so its less confusing
	unit.physCollider.removeCollider = false
	unit.owningEntity = caster

	-- Slow
	GameMode.EntitiesToBeSlowed[unit:entindex()] = unit
	if GameMode.GlobalSlow == true then 
		GameMode:SlowEntity(unit) 
	end

	-- Particle
	unit.bulletParticle = ParticleManager:CreateParticle("particles/clinkz_base_attack.vpcf", PATTACH_ABSORIGIN_FOLLOW, unit)
	ParticleManager:SetParticleControl(unit.bulletParticle, 0, Vector(unit:GetAbsOrigin().x, unit:GetAbsOrigin().y, unit:GetAbsOrigin().z))
	ParticleManager:SetParticleControl(unit.bulletParticle, 1, velocityVec)
	
	-- Values
	unit.isBullet = true
	unit.hasBeenDeleted = false

	-- Delete 
	unit.SuperhotDelete = function()
		table.remove(GameMode.EntitiesToBeSlowed, unit:entindex())
		Physics:RemoveCollider(unit.physCollider)
		ParticleManager:DestroyParticle(unit.bulletParticle, true)
		if IsValidEntity(unit) then
			unit:RemoveSelf()
		end
	end
end