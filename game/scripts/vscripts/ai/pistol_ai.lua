AI_THINK_INTERVAL = 0.5
AI_STATE_IDLE = 0
AI_STATE_AGGRESSIVE = 1
AI_STATE_RETURNING = 2

AI_SHOOT_COOLDOWN = 2

NeutralAI = {}
NeutralAI.__index = NeutralAI

function NeutralAI:Start( unit, params )
	print("Starting NeutralAI for "..unit:GetUnitName().." "..unit:GetEntityIndex())

	local ai = {}
	setmetatable( ai, NeutralAI )

	ai.unit = unit
	ai.stateThinks = { 
		[AI_STATE_IDLE] = 'IdleThink',
		[AI_STATE_AGGRESSIVE] = 'AggressiveThink',
		[AI_STATE_RETURNING] = 'ReturningThink'
	}

	unit.gun = unit:GetItemInSlot(0)
	unit.canShoot = true
	unit.state = AI_STATE_IDLE
	unit.spawnPos = params.spawnPos
	unit.aggroRange = params.aggroRange
	unit.leashRange = params.leashRange

	Timers:CreateTimer(function()
		return ai:GlobalThink()
	end)

	return ai
end

function NeutralAI:GlobalThink()
	local unit = self.unit

	if not IsValidEntity(unit) then
		self = nil
		return nil
	end

	if not unit:IsAlive() then
		return nil
	end

	Dynamic_Wrap(NeutralAI, self.stateThinks[ unit.state ])( self )

	return AI_THINK_INTERVAL
end

function NeutralAI:IdleThink()
	local unit = self.unit

	local units = FindUnitsInRadius(unit:GetTeam(), unit:GetAbsOrigin(), nil,
		unit.aggroRange, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, 
		FIND_ANY_ORDER, false )
	
	if #units > 0 then
		print("Number of units is greater than 1!")
		unit:MoveToNPC( units[1] ) 
		unit.aggroTarget = units[1]
		unit.state = AI_STATE_AGGRESSIVE 
		return true
	end
end

function NeutralAI:AggressiveThink()
	local unit = self.unit

	if ( unit.spawnPos - unit:GetAbsOrigin() ):Length() > unit.leashRange then
		unit:MoveToPosition( unit.spawnPos ) 
		unit.state = AI_STATE_RETURNING 
		return true 
	end

	if not unit.aggroTarget:IsAlive() then
		unit:MoveToPosition( unit.spawnPos ) 
		unit.state = AI_STATE_RETURNING 
		return true 
	end

	local point_1 = unit:GetAbsOrigin()
	local point_2 = unit.aggroTarget:GetAbsOrigin()

	local length = (point_1 - point_2):Length2D()
	local traveltime = length/800 -- in seconds
	local velocity = unit.aggroTarget.superhotVelocity
	local relative = velocity * (traveltime)
	point_2 = point_2 - relative
	DebugDrawSphere(point_2, Vector(0, 255, 0), 255, 10, false, 0.5)

	point_2 = GetNearestPointToWall(unit.aggroTarget:GetAbsOrigin(), point_2)

	if NeutralAI:CanTraverseProjectile(point_1, unit.aggroTarget:GetAbsOrigin()) and (point_1 - point_2):Length2D() < 1900 then
		if unit.canShoot then
			DebugDrawSphere(point_2, Vector(255, 255, 0), 255, 20, false, 0.5)
			unit.canShoot = false
			local newOrder = 
			{
		 		UnitIndex = unit:entindex(), 
		 		OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
		 		AbilityIndex = unit.itemEntity:entindex(), 
		 		Position = point_2
		 	}
	 	
			ExecuteOrderFromTable(newOrder)
			Timers:CreateTimer(4, function() unit.canShoot = true return end)
		end
	else
		unit:MoveToNPC(unit.aggroTarget) 
	end
end

function GetNearestPointToWall(point_1, point_2)
	local point_final = point_2
	local vInterval = (point_1 - point_2) / 40

	for i = 1, 40 do
		local checkPoint = point_1 - (i * vInterval)
		DebugDrawSphere(checkPoint, Vector(255, 0, 255), 255, 6, false, 0.5)
		if GridNav:IsBlocked(checkPoint) == true or GridNav:IsTraversable(checkPoint) ~= true then
			if i == 1 then
				point_final = point_1
			else
				point_final = checkPoint
			end
			break
		end
	end
	return point_final
end

function NeutralAI:CanTraverseProjectile(point_1, point_2)
	local vInterval = (point_1 - point_2) / 20

	for i = 1, 20 do
		local checkPoint = point_1 - (i * vInterval)
		DebugDrawSphere(checkPoint, Vector(255, 0, 0), 255, 10, false, 0.5)
		if GridNav:IsBlocked(checkPoint) == true or GridNav:IsTraversable(checkPoint) ~= true then
			return false
		end
	end
	return true
end

function NeutralAI:ReturningThink()
	local unit = self.unit

	if ( unit.spawnPos - unit:GetAbsOrigin() ):Length() < 10 then

		unit.state = AI_STATE_IDLE
		return true
	end
end