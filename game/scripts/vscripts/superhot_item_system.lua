function GameMode:StartItemLoop(hero)
	Timers:CreateTimer(0.1, function()
		GameMode:FindAndPickupItems(hero)
		return 0.1
	end)
end

function GameMode:FindAndPickupItems(hero)
	local origin = hero:GetAbsOrigin()
	local ents = Entities:FindAllByClassnameWithin("dota_item_drop", origin, 90)
	--print("Item count: ", #ents)
	if ents[1] ~= nil then
		local item = ents[1]:GetContainedItem()
		if hero:GetItemInSlot(0) ~= nil then
			hero:GetItemInSlot(0):RemoveSelf()
		end

		hero:AddItem(item)
		ents[1]:RemoveSelf()
	end
end