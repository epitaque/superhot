function StartLevel(keys)
	local activator = keys.activator
	local trigger = keys.caller
	local level = trigger:Attribute_GetIntValue("level", -1)
	local hero = activator.player

	GameMode:StartLevelForPlayer(level, hero, true)
end

function LevelTransition(keys)
	local activator = keys.activator
	local trigger = keys.caller
	local level = trigger:Attribute_GetIntValue("level", -1)
	local hero = activator.player

	GameMode:CloseLevelExit(level)
	GameMode:OpenLevelEntrance(level + 1)
end

function EntranceTransition(keys)
	local activator = keys.activator
	local trigger = keys.caller
	local level = trigger:Attribute_GetIntValue("level", -1)
	local hero = activator.player

	if GameMode.CurrentLevel ~= level then
		GameMode:CloseLevelEntrance(level)
		GameMode:StartLevelForPlayer(level, hero, false)
	end
end