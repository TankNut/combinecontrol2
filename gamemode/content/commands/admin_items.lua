local create = console.AddCommand("rpa_item_create", function(ply, item)
	if item == nil then
		return
	end

	item = Item.Create(item)
	item:SetWorldItem(Item.GetDropPosition(ply), Angle(0, ply:EyeAngles().y, 0))

	Log.Write("admin_item_create", ply, item)
end)

create:SetCategory("Item Commands")
create:SetDescription("Creates an item in front of you")
create:SetExecutionContext(console.Server)
create:SetAccess(console.IsAdmin)
create:SetNoConsole()

create:AddParameter(console.Item({
	Force = true
}))

local createTemp = console.AddCommand("rpa_item_create_temp", function(ply, item)
	if item == nil then
		return
	end

	item = Item.CreateTemp(item)
	item:SetWorldItem(Item.GetDropPosition(ply), Angle(0, ply:EyeAngles().y, 0))

	Log.Write("admin_item_create", ply, item)
end)

createTemp:SetCategory("Item Commands")
createTemp:SetDescription("Creates a temporary item in front of you")
createTemp:SetExecutionContext(console.Server)
createTemp:SetAccess(console.IsAdmin)
createTemp:SetNoConsole()

createTemp:AddParameter(console.Item({
	Force = true
}))

local give = console.AddCommand("rpa_item_give", function(ply, targets, item)
	if item == nil then
		return
	end

	for _, target in ipairs(targets) do
		if not target:HasCharacter() then
			continue
		end

		Log.Write("admin_item_give", ply, target:GiveItem(item), target)
	end
end)

give:SetCategory("Item Commands")
give:SetDescription("Gives an item to a player")
give:SetExecutionContext(console.Server)
give:SetAccess(console.IsAdmin)

give:AddParameter(console.Player())
give:AddParameter(console.Item({
	Force = true
}))

local giveTemp = console.AddCommand("rpa_item_give_temp", function(ply, targets, item)
	if item == nil then
		return
	end

	for _, target in ipairs(targets) do
		if not target:HasCharacter() then
			continue
		end

		Log.Write("admin_item_give", ply, target:GiveTempItem(item), target)
	end
end)

giveTemp:SetCategory("Item Commands")
giveTemp:SetDescription("Gives a temporary item to a player")
giveTemp:SetExecutionContext(console.Server)
giveTemp:SetAccess(console.IsAdmin)

giveTemp:AddParameter(console.Player())
giveTemp:AddParameter(console.Item({
	Force = true
}))

local clearStashes = console.AddCommand("rpa_stash_clear", function(ply)
	Log.Write("admin_stash_clear", ply)

	GAMEMODE:SetStashVersion(GAMEMODE:StashVersion() + 1)

	Chat.Send("NOTICE", console.FormatMessage("%s has cleared everyone's stashes.", ply))

	for _, target in player.Iterator() do
		if target:HasStash() then
			local data = target:GetStashData()
			data[game.GetMapOverride()] = nil

			target:SetStashData(data)
		end
	end
end)

clearStashes:SetCategory("Item Commands")
clearStashes:SetDescription("Clears everyone's stashes from the map")
clearStashes:SetExecutionContext(console.Server)
clearStashes:SetAccess(console.IsAdmin)
