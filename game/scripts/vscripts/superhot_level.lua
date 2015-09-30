function GameMode:RestartLevel(hero)
	if not hero then
		hero = PlayerResource:GetSelectedHeroEntity(0)
	end

	GameMode:EndLevel(GameMode.CurrentLevel)
	hero:AddNewModifier(hero, nil, "modifier_stunned", {duration=1})
	Timers:CreateTimer(1, function()
		GameMode:StartLevelForPlayer(GameMode.CurrentLevel, hero, true)
	end)
end

function GameMode:InitializeLevel(level)
	print("Initializing Level ", level)

	local level = tonumber(level)
	GameMode.LevelBotCount[level] = 0
	local spawnPoints = Entities:FindAllByName("superhot_bot")

	--DeepPrintTable(spawnPoints)

	for _, spawnPoint in pairs(spawnPoints) do
		local levelValue = spawnPoint:Attribute_GetIntValue("level", -1)
		local gunValue = spawnPoint:Attribute_GetIntValue("gun", -1)

		-- If it the right level and it is an info target, spawn the bot	
		if levelValue == level and spawnPoint:GetClassname() == "info_target" then

			-- Have a different unit spawning method for each type of gun
			if gunValue == 1 then
				local unit = GameMode:SpawnBot(gunValue, levelValue, spawnPoint)
			end
		end
	end
end

function GameMode:EndLevel(level)
	local level = tonumber(level)
	if not GameMode.LevelEntities[level] then
		return
	end

	for _, entity in pairs(GameMode.LevelEntities[level]) do
		if IsValidEntity(entity) then
			entity:RemoveSelf()
		end
	end
	GameMode.LevelEntities[level] = {}
end

function GameMode:StartLevelForPlayer(level, hero, teleportplayer)
	print("[SuperHot] Starting level " .. tostring(level) .. "...")
	GameMode.CurrentLevel = tonumber(level)

	-- Remove all entities associated with the level
	GameMode:EndLevel(level)
	
	-- Close the exit of the level
	GameMode:CloseLevelExit(level)

	-- Make time slow and stop the player so the player has time to react
	ExecuteOrderFromTable({ UnitIndex = hero:entindex(), OrderType = DOTA_UNIT_ORDER_HOLD_POSITION })
	GameMode:SlowTime()
	
	-- Teleport the player to the level
	if teleportplayer == true then
		hero:SetAbsOrigin(Entities:FindAllByName("superhot_spawn_level_" .. tostring(level))[1]:GetAbsOrigin())
	end

	-- Initialize the level
	GameMode:InitializeLevel(level)
end

function GameMode:OpenLevelExit(level)
	local obstructionEntities = Entities:FindAllByName("superhot_obstruction_exit_level_" .. level)
	local obstructionMeshes = Entities:FindAllByName("superhot_obstruction_exit_mesh_level_" .. level)

	for _, obstructionEntity in pairs(obstructionEntities) do
		obstructionEntity:SetEnabled(false, false)
	end

	for _, obstructionMesh in pairs(obstructionMeshes) do
		obstructionMesh:AddEffects(EF_NODRAW)
	end
end

function GameMode:CloseLevelExit(level)
	local obstructionEntities = Entities:FindAllByName("superhot_obstruction_exit_level_" .. level)
	local obstructionMeshes = Entities:FindAllByName("superhot_obstruction_exit_mesh_level_" .. level)


	for _, obstructionEntity in pairs(obstructionEntities) do
		obstructionEntity:SetEnabled(true, true)
	end

	for _, obstructionMesh in pairs(obstructionMeshes) do
		obstructionMesh:RemoveEffects(EF_NODRAW)
	end
end

function GameMode:OpenLevelEntrance(level)
	local obstructionEntities = Entities:FindAllByName("superhot_obstruction_entrance_level_" .. level)
	local obstructionMeshes = Entities:FindAllByName("superhot_obstruction_entrance_mesh_level_" .. level)

	for _, obstructionEntity in pairs(obstructionEntities) do
		obstructionEntity:SetEnabled(false, false)
	end

	for _, obstructionMesh in pairs(obstructionMeshes) do
		obstructionMesh:AddEffects(EF_NODRAW)
	end
end

function GameMode:CloseLevelEntrance(level)
	local obstructionEntities = Entities:FindAllByName("superhot_obstruction_entrance_level_" .. level)
	local obstructionMeshes = Entities:FindAllByName("superhot_obstruction_entrance_mesh_level_" .. level)


	for _, obstructionEntity in pairs(obstructionEntities) do
		obstructionEntity:SetEnabled(true, true)
	end

	for _, obstructionMesh in pairs(obstructionMeshes) do
		obstructionMesh:RemoveEffects(EF_NODRAW)
	end
end