

function Punch(keys)
	local caster = keys.caster
	local target = keys.target_points[1]

	caster:StartGesture(ACT_DOTA_CAST_ABILITY_2)
	local fwvec = (target - caster:GetAbsOrigin()):Normalized() * 120
	
	DebugDrawSphere(fwvec + caster:GetAbsOrigin(), Vector(0, 255, 0), 255, 40, false, 0.5)

	Timers:CreateTimer(0.3, function()
		local units = FindUnitsInRadius(caster:GetTeamNumber(), fwvec + caster:GetAbsOrigin(), nil, 50, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false)

		local firstunit

		for k, v in pairs(units) do
			print("Found unit.")
			firstunit = v
			break
		end

		local damageTable = {
			victim = firstunit,
			attacker = caster,
			damage = 400,
			damage_type = DAMAGE_TYPE_PURE,
		}
		
		--print("unit:FirstMoveChild()", unit:FirstMoveChild())

		if firstunit ~= nil then 
			ApplyDamage(damageTable)
			local i = 0

		end


	end)
end