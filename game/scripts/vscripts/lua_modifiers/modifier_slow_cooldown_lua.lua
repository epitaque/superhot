modifier_slow_cooldown_lua = class({})
LinkLuaModifier( "modifier_slow_cooldown_lua", "lua_modifiers/modifier_slow_cooldown_lua", LUA_MODIFIER_MOTION_NONE )

function modifier_slow_lua:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE
	}
	return funcs
end

function modifier_slow_lua:GetModifierPercentageCooldown(params)
	return -0.95
end