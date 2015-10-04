item_pistol_lua = class({})

function item_pistol_lua:GetIntrinsicModifierName()
	return "modifier_item_pistol_lua"
end

function item_pistol_lua:OnItemEquipped(item)
	print("OnItemEquipped")
	if IsServer() ~= true then
		return
	end
	self:GetParent().gunAttachment = Attachments:AttachProp(unit, "attach_attack2", "models/superhot/pistol.vmdl", 0.06)
end


function item_pistol_lua:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorPosition()
	caster:StartGesture(ACT_DOTA_CAST_ABILITY_1)


	DebugDrawSphere(target, Vector(255, 0, 0), 255, 20, false, 2.0)

	caster:StartGesture(ACT_DOTA_ATTACK)
	Timers:CreateTimer(0.2, function()
		self:FireWeapon(target)
	end)
end

--[[function item_pistol_lua:GetCastPoint()
	print("GetCastPoint has been run")
	if GameMode.GlobalSlow == true then
		return 10.0
	else
		return 0.5
	end
	return 0.15
end]]

function item_pistol_lua:FireWeapon(target)
	local caster = self:GetCaster()

	-- Gun Attachment Point
	local attachment = caster:ScriptLookupAttachment("attach_attack1")
	local attachorigin = caster:GetAttachmentOrigin(attachment)

	-- Knockback
	caster:SetPhysicsVelocity(-caster:GetForwardVector() * 100)

	-- Unit
	local unit = CreateUnitByName("superhot_bullet", caster:GetAbsOrigin(), true, caster, caster, caster:GetTeamNumber())
	unit.direction = (target - attachorigin):Normalized()
	unit.direction.z = 0
	local velocityVec = unit.direction * 1800

	-- Physics
	unit:AddNewModifier(unit, nil, "modifier_invulnerable", {duration=-1})
	unit:SetAbsOrigin(attachorigin)
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