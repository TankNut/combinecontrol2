local create = console.AddCommand("rpa_createitem", function(ply, item)
	if item == nil then
		return
	end

	Item.Create(item):SetWorldItem(Item.GetDropPosition(ply), Angle(0, ply:EyeAngles().y, 0))
end)

create:SetCategory("Item Commands")
create:SetDescription("Creates an item in front of you")
create:SetExecutionContext(console.Server)
create:SetAccess(console.IsAdmin)
create:SetNoConsole()

create:AddParameter(console.Item({
	Force = true
}))

local createTemp = console.AddCommand("rpa_createtempitem", function(ply, item)
	if item == nil then
		return
	end

	Item.CreateTemp(item):SetWorldItem(Item.GetDropPosition(ply), Angle(0, ply:EyeAngles().y, 0))
end)

createTemp:SetCategory("Item Commands")
createTemp:SetDescription("Creates a temporary item in front of you")
createTemp:SetExecutionContext(console.Server)
createTemp:SetAccess(console.IsAdmin)
createTemp:SetNoConsole()

createTemp:AddParameter(console.Item({
	Force = true
}))

local give = console.AddCommand("rpa_giveitem", function(ply, targets, item)
	if item == nil then
		return
	end

	for _, target in ipairs(targets) do
		target:GiveItem(item)
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

local giveTemp = console.AddCommand("rpa_givetempitem", function(ply, targets, item)
	if item == nil then
		return
	end

	for _, target in ipairs(targets) do
		target:GiveTempItem(item)
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
