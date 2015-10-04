modifier_timeslow_player_lua = class({})
LinkLuaModifier( "modifier_timeslow_player_lua", "lua_modifiers/modifier_timeslow_player", LUA_MODIFIER_MOTION_NONE )

function modifier_timeslow_player_lua:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE
	}

	return funcs
end

function modifier_timeslow_player_lua:OnCreated()
	if IsServer() ~= true or self:GetParent():GetItemInSlot(0) == nil then
		return
	end
	local remainingtime = GameMode.PlayerHero.item:GetCooldownTimeRemaining()
	self:GetParent():GetItemInSlot(0):EndCooldown()
	self:GetParent():GetItemInSlot(0):StartCooldown(remainingtime*5)
end

function modifier_timeslow_player_lua:GetModifierPercentageCooldown(keys)
	return 0
end

function modifier_timeslow_player_lua:GetTexture()
	return "faceless_void_chronosphere"
end