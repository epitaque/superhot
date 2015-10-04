--require("libraries/attachments")

modifier_item_pistol_lua = class({})
LinkLuaModifier( "modifier_item_pistol_lua", "lua_modifiers/modifier_item_pistol", LUA_MODIFIER_MOTION_NONE )

function modifier_item_pistol_lua:OnCreated()
	if IsServer() ~= true then
		return
	end

	if IsValidEntity(self:GetParent().gunAttachment) then
		self:GetParent().gunAttachment:RemoveSelf()
	end

	self:GetParent().gunAttachment = Attachments:AttachProp(self:GetParent(), "attach_attack2", "models/superhot/pistol.vmdl", 0.06)
end

function modifier_item_pistol_lua:OnDestroy()
	print("Removing gun")

	if IsServer() ~= true then
		return
	end

	if IsValidEntity(self:GetParent().gunAttachment) then
		self:GetParent().gunAttachment:RemoveSelf()
	end
end