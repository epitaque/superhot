function GameMode:OnOrderIssued(keys)
	local orderType = keys["order_type"]
	local unit = EntIndexToHScript(keys["units"]["0"])

	print("GameMode.GlobalSlow: ", GameMode.GlobalSlow)

	if unit:IsRealHero() then
		
		-- If a player has issued a move command...
		if orderType == DOTA_UNIT_ORDER_MOVE_TO_POSITION then
			-- If time is already slowed dont do anything
			if GameMode.GlobalSlow == true then
				print("GameMode.GlobalSlow: ", GameMode.GlobalSlow)

				-- Stop any current loops
				if GameMode.MostRecentTimer ~= nil then
					Timers:RemoveTimer(GameMode.MostRecentTimer)
				end

				-- Set up the Last Position and Last Forward Vector variables and speed up time
				local LastPosition
				local LastFwVec

				GameMode:SpeedTime()

				GameMode.MostRecentTimer = Timers:CreateTimer(0, function()
					if GameMode.PlayerIsInCastAnimation == true then
						return 0.01
					end
					if LastPosition == unit:GetAbsOrigin() and LastFwVec == unit:GetForwardVector() then
						print("Slowing time")
						GameMode:SlowTime()
						GameMode.MostRecentTimer = nil
						return nil
					else
						LastPosition = unit:GetAbsOrigin()
						LastFwVec = unit:GetForwardVector()
						return 0.01
					end
				end)
			end
		end
	end

	return true
end

function GameMode:SpeedTimeWhilePlayerIsInCastAnimation(time)
	GameMode.PlayerIsInCastAnimation = true
	GameMode:SpeedTime()
	Timers:CreateTimer(time, function()
		GameMode:SlowTime()
		GameMode.PlayerIsInCastAnimation = true
		return nil
	end)
end

function GameMode:SlowTime()
	print("Slowing time.")
	GameMode.GlobalSlow = true
	
	local entsToBeRemoved = {}

	for entityIndex, entity in pairs(GameMode.EntitiesToBeSlowed) do
		if IsValidEntity(entity) then
			GameMode:SlowEntity(entity)
		else
			table.insert(entsToBeRemoved, entityIndex)
		end
	end

	for k, v in pairs(entsToBeRemoved) do
		table.remove(GameMode.EntitiesToBeSlowed, entityIndex)
	end
end

function GameMode:SpeedTime()
	print("Speeding time.")
	GameMode.GlobalSlow = false

	local entsToBeRemoved = {}

	for entityIndex, entity in pairs(GameMode.EntitiesToBeSlowed) do
		if IsValidEntity(entity) then
			GameMode:UnslowEntity(entity)
		else
			table.insert(entsToBeRemoved, entityIndex)
		end					
	end

	for k, v in pairs(entsToBeRemoved) do
		table.remove(GameMode.EntitiesToBeSlowed, entityIndex)
	end
end

function GameMode:SlowEntity(entity)
	--print("Slowing entity: " .. entity:GetUnitName())
	if IsPhysicsUnit(entity) then
		--local dir = entity:GetPhysicsVelocity():Normalized()
		--entity:SetPhysicsVelocity(dir * 20)
	else
		entity:AddNewModifier(entity, nil, "modifier_slow_lua", {duration=-1})
	end
end

function GameMode:UnslowEntity(entity)
	--print("Unslowing entity: " .. entity:GetUnitName())
	if IsPhysicsUnit(entity) then
		--local dir = entity:GetPhysicsVelocity():Normalized()
		--entity:SetPhysicsVelocity(dir * 1800)
	else
		entity:RemoveModifierByName("modifier_slow_lua")
	end
end