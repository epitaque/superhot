modifier_timeslow_creep_lua = class({})
LinkLuaModifier( "modifier_timeslow_creep_lua", "lua_modifiers/modifier_timeslow_creep", LUA_MODIFIER_MOTION_NONE )

function modifier_timeslow_creep_lua:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_CASTTIME_PERCENTAGE,
		MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
	}
	return funcs
end

function modifier_timeslow_creep_lua:GetModifierMoveSpeedBonus_Percentage( params )
	return -0.95
end

function modifier_timeslow_creep_lua:GetModifierPercentageCasttime(params)
	return -0.95
end

function modifier_timeslow_creep_lua:GetModifierPercentageCooldown(params)
	return -0.95
end

function modifier_timeslow_creep_lua:GetTexture()
	return "faceless_void_backtrack"
end