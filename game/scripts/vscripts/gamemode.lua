BAREBONES_DEBUG_SPEW = false 

if GameMode == nil then
	_G.GameMode = class({})
end

-- Barebones
require("libraries/timers")
require("libraries/physics")
require("libraries/projectiles")
--require("libraries/notifications")
require("libraries/animations")
require("internal/gamemode")
require("internal/events")
require("settings")
require("events")
require("libraries/attachments")

-- SUPERHOT--
require("superhot_util")
require("superhot_time")
require("superhot_commands")
require("superhot_level")
require("superhot_item_system")
require("ai/pistol_ai")

-- MODIFIERS --
require("lua_modifiers/modifier_timeslow_creep")
require("lua_modifiers/modifier_timeslow_player")
require("lua_modifiers/modifier_timespeed_player")
require("lua_modifiers/modifier_item_pistol")

function GameMode:OnFirstPlayerLoaded()
end

function GameMode:OnAllPlayersLoaded()
end

function GameMode:OnGameInProgress()
end

function GameMode:OnHeroInGame(hero)
	hero.item = CreateItem("item_pistol_lua", hero, hero)
	hero:AddItem(hero.item)

	-- Automatically pickup items
	GameMode:StartItemLoop(hero)

	-- Time
	GameRules:GetGameModeEntity():SetExecuteOrderFilter( Dynamic_Wrap( GameMode, "OnOrderIssued" ), self )
	local lastLoc = hero:GetAbsOrigin()
	Timers.CreateTimer(1, function()
		local heroLoc = hero:GetAbsOrigin()
		hero.superhotVelocity = (lastLoc - heroLoc) * 10
		lastLoc = heroLoc
		return 0.1
	end)

	-- Since hitboxes are messed up for the superhot model, I create a small dummy that follows the 
	-- player around, with the sole purpose of triggering triggers (which are essential to this gamemode)
	local unit = CreateUnitByName("superhot_follow_bot", Vector(0, 0, 0), false, nil, nil, DOTA_TEAM_NEUTRALS)
	unit:AddNewModifier(unit, nil, "modifier_invulnerable", {duration=-1})
	unit:AddNewModifier(unit, nil, "modifier_invisible", {duration=-1})
	unit:AddNewModifier(unit, nil, "modifier_phased", {duration=-1})
	unit.player = hero
	Timers:CreateTimer(0, function()
		unit:SetAbsOrigin(hero:GetAbsOrigin())
		unit:MoveToNPC(hero)
		return 0.5
	end)

	-- Physics
	Physics:Unit(hero)
	local collider = hero:AddColliderFromProfile("delete")
	collider.draw = {color = Vector(100,50,200), alpha = 0}
	collider.radius = 43
	collider.deleteSelf = false
	collider.removeCollider = false
	collider.test = Dynamic_Wrap(GameMode, "HandleCollision")
	
	-- Variables
	hero.isBot = false
	hero.collider = collider
	GameMode.PlayerHero = hero

	-- Delete
	hero.SuperhotDelete = function(hero)
		GameMode:RestartLevel()
	end
end

function GameMode:InitGameMode()
	GameMode = self
	GameMode:_InitGameMode()
	Convars:SetFloat("host_timescale", 1)

	GameMode.SlowPercent = 95

	GameMode.items = {"item_player_pistol_superhot"}

	GameMode.CurrentLevel = 0
	GameMode.CurrentWeapon = nil

	GameMode.PlayerIsInCastAnimation = false
	GameMode.GlobalSlow = true
	GameMode.EntitiesToBeSlowed = {}
	GameMode.LevelBotCount = {}
	GameMode.LevelEntities = {}

	for i = 1, 10 do
		GameMode.LevelEntities[i] = {}
	end

	GameRules:SetCustomGameSetupAutoLaunchDelay( 0 )
	GameMode.MostRecentTimer = nil
	GameMode.PlayerSpeed = 0

	
	GameMode:RegisterCommands()
end

