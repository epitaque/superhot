modifier_slow_lua = class({})
LinkLuaModifier( "modifier_slow_lua", "lua_modifiers/modifier_slow_lua", LUA_MODIFIER_MOTION_NONE )

function modifier_slow_lua:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_CASTTIME_PERCENTAGE,
		MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
	}
	return funcs
end

function modifier_slow_lua:GetModifierMoveSpeedBonus_Percentage( params )
	return -0.95
end

function modifier_slow_lua:GetModifierPercentageCasttime(params)
	return -0.95
end

function modifier_slow_lua:GetModifierPercentageCooldown(params)
	return -0.95
end