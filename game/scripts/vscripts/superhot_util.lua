require("libraries/timers")
require("ai/pistol_ai")


function CalcDistBetweenVec2s(vec1x, vec1y, vec2x, vec2y)
	local xf = (vec1x - vec2x) * (vec1x - vec2x)
	local yf = (vec1y - vec2y) * (vec1x - vec2y)
	return math.sqrt(xf + yf)
end


function GameMode:HandleCollision(collider, collided)
	local collider_1, collider_2
	if collided.isBullet == true then
		collider_1 = collided
		collider_2 = collider
	end
	if collider.isBullet == true then
		collider_1 = collider
		collider_2 = collided
	end
	if not collider_1 then
		return
	end
	if not IsValidEntity(collider_1.owningEntity) then
		return
	end
	if collider_1.owningEntity.isBot == true and collider_2:IsRealHero() == true then
		collider_1:SuperhotDelete(collider_1)
		collider_2:SuperhotDelete(collider_2)
	end
	if collider_1.owningEntity:IsRealHero() == true and collider_2.isBot == true then
		collider_1:SuperhotDelete(collider_1)
		collider_2:SuperhotDelete(collider_2)	
	end
	return false
end

function GameMode:SpawnBot(gunValue, levelValue, spawnPoint)
	print("Spawning a bot", gunnumber)

	local unit
	if gunValue == 1 then
		GameMode.LevelBotCount[levelValue] = GameMode.LevelBotCount[levelValue] + 1
	
		unit = CreateUnitByName("superhot_bot", spawnPoint:GetAbsOrigin(), true, nil, nil, DOTA_TEAM_BADGUYS)

		-- Create the units' gun
		local item = CreateItem("item_player_pistol_superhot",nil,nil)
		unit:AddItem(item)
		unit.item = "item_player_pistol_superhot"
		unit:SetRenderColor(255, 50, 50)
		unit.itemEntity = item

		-- Set the level of the unit
		unit.level = levelValue

		-- Start the AI
		NeutralAI:Start(unit, {spawnPos=spawnPoint:GetAbsOrigin(), aggroRange=600, leashRange=2000})

		-- Attach the physical model of the gun
		unit.gunAttachment = Attachments:AttachProp(unit, "attach_attack2", "models/superhot/pistol.vmdl", 0.06)
		unit.isBot = true

		-- Add a collider for this unit. Make it so the collider doesn't do anything; we only want the bullets handling collisions
		Physics:Unit(unit)
		local collider = unit:AddColliderFromProfile("delete")
		collider.draw = {color = Vector(100,50,200), alpha = 0}
		collider.radius = 43
		collider.deleteSelf = false
		collider.removeCollider = false
		collider.test = Dynamic_Wrap(GameMode, "HandleCollision")

		-- Insert all the entities created by this bot into the levels' entity list
		unit.TableIndex_unit = table.insert(GameMode.LevelEntities[levelValue], unit)
		unit.TableIndex_gunAttachment = table.insert(GameMode.LevelEntities[levelValue], unit.gunAttachment)

		-- Delete function
		unit.SuperhotDelete = function(unit)
			Physics:RemoveCollider(collider)
			table.remove(GameMode.EntitiesToBeSlowed, unit:entindex())
			table.remove(GameMode.LevelEntities[unit.level], unit.TableIndex_unit)
			table.remove(GameMode.LevelEntities[unit.level], unit.TableIndex_gunAttachment)
			if IsValidEntity(unit) then
				unit:ForceKill(false)
				unit:RemoveSelf()
			end
		end
	end
	return unit
end

function GameMode:OnBotKilled(unit, killer)
	print("[SuperHot] A bot was killed!")
	local level = tonumber(unit.level)
	local itemName = unit.item

	GameMode.LevelBotCount[level] = GameMode.LevelBotCount[level] - 1

	-- Make the bot go flying
	local direction = (killer:GetAbsOrigin() - unit:GetAbsOrigin() ):Normalized()

	local i = 0
	Timers:CreateTimer(0, function()
		if not IsValidEntity(unit) then return nil end
		unit:SetAbsOrigin( (direction / (i + 1) ) + unit:GetAbsOrigin() )
		i = i + 1
		if i <= 80 then return 0.05 end
	end)

	-- Delete the bots' item model
	unit.gunAttachment:RemoveSelf()

	-- Launch the bots item
	local item = CreateItem(unit.item, nil, nil)
	local container = CreateItemOnPositionForLaunch(unit:GetAbsOrigin(), item)
	container:SetRenderColor(255, 100, 100)
	item:LaunchLoot(false, 200, 0.9, unit:GetAbsOrigin() + RandomVector(200))

	-- Add the launched item to the levels' entity list
	table.insert(GameMode.LevelEntities[level], item)
	table.insert(GameMode.LevelEntities[level], container)

	-- If it is the last bot, end the current level
	if GameMode.LevelBotCount[level] == 0 then
		print("[SuperHot] That bot was the last bot, ending level ", level)
		GameMode:EndLevel(level)
		GameMode:OpenLevelExit(level)
	end
end

function GameMode:SpawnItems(items)
	for itemIndex, itemName in pairs(items) do
		local entityArray = Entities:FindAllByName(itemName)
		for entityIndex, entity in pairs(entityArray) do
			if entity:GetClassname() == "info_target" then
				print("Spawning item at ", entity:GetAbsOrigin())
				local item = CreateItem(itemName,nil,nil)
				CreateItemOnPositionForLaunch(entity:GetAbsOrigin(), item)
			end
		end
	end
end