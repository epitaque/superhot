function GameMode:RegisterCommands()
	Convars:RegisterCommand("start_level", Dynamic_Wrap(GameMode, "CMDStartLevel"), "Starts level for given player", FCVAR_CHEAT)
	Convars:RegisterCommand("end_level", Dynamic_Wrap(GameMode, "CMDEndLevel"), "Ends the level", FCVAR_CHEAT)
	Convars:RegisterCommand("open_exit", Dynamic_Wrap(GameMode, "CMDOpenExit"), "Opens the exit of a level", FCVAR_CHEAT)
	Convars:RegisterCommand("register_new_command", Dynamic_Wrap(GameMode, "CMDRegisterCommand"), "Used to register a new command without restarting the gamemode", FCVAR_CHEAT)

end

function GameMode:CMDRegisterCommand()

end

function GameMode:CMDStartLevel(level)
	local player = Convars:GetCommandClient()
	local playerID = player:GetPlayerID()
	local hero = PlayerResource:GetSelectedHeroEntity(playerID)

	GameMode:StartLevelForPlayer(level, hero)
end

function GameMode:CMDEndLevel(level)
	GameMode:EndLevel(level)
end

function GameMode:CMDOpenExit(level)
	GameMode:OpenLevelExit(level)
end