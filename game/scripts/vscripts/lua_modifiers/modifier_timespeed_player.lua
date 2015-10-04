modifier_timespeed_player_lua = class({})
LinkLuaModifier( "modifier_timespeed_player_lua", "lua_modifiers/modifier_timespeed_player", LUA_MODIFIER_MOTION_NONE )

function modifier_timespeed_player_lua:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE
	}

	return funcs
end

function modifier_timespeed_player_lua:OnCreated()
	if IsServer() ~= true or self:GetParent():GetItemInSlot(0) == nil then
		return
	end
	local remainingtime = GameMode.PlayerHero.item:GetCooldownTimeRemaining()
	self:GetParent():GetItemInSlot(0):EndCooldown()
	self:GetParent():GetItemInSlot(0):StartCooldown(remainingtime*0.20)
end

function modifier_timespeed_player_lua:GetModifierPercentageCooldown(keys)
	return 80
end

function modifier_timespeed_player_lua:GetTexture()
	return "faceless_void_timewalk"
end