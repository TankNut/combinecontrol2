local categoryIcons = {
	Container = "icon16/package.png",
	Weapons = "icon16/gun.png"
}

function GM:PopulateCCSpawnmenu(content, tree, browseNode)
	if not lp then
		return
	end

	local entities = tree:AddNode("Entities", "icon16/folder.png")
	entities:SetExpanded(true)

	if not lp:IsAdmin() then
		return
	end

	local items = tree:AddNode("Items", "icon16/folder.png")
	items:SetExpanded(true)

	local categories = {}
	local all = {}

	for i = 1, #Item.Rarities do
		all[i] = {}
	end

	for class, item in pairs(Item.Spawnable) do
		if not hook.Run("CanSpawnItem", lp, item) then
			continue
		end

		if not categories[item.Category] then
			local category = {}

			for i = 1, #Item.Rarities do
				category[i] = {}
			end

			categories[item.Category] = category
		end

		local category = categories[item.Category]

		if not category[item.Rarity] then
			category[item.Rarity] = {}
		end

		category[item.Rarity][class] = item
		all[item.Rarity][class] = item
	end

	for category, rarities in SortedPairs(categories) do
		local node = items:AddNode(category, categoryIcons[category] or "icon16/bricks.png")

		node.DoPopulate = function(pnl)
			if pnl.ItemPanel then
				return
			end

			pnl.ItemPanel = content:Add("ContentContainer")
			pnl.ItemPanel:SetVisible(false)
			pnl.ItemPanel:SetTriggerSpawnlistChange(false)

			for k, tab in SortedPairs(rarities) do
				if table.Count(tab) <= 0 then
					continue
				end

				local rarity = Item.Rarities[k]

				spawnmenu.CreateContentIcon("header", pnl.ItemPanel, {
					text = rarity.Name
				})

				for _, item in SortedPairs(tab) do
					spawnmenu.CreateContentIcon("cc_item", pnl.ItemPanel, item)
				end
			end
		end

		node.DoClick = function(pnl)
			pnl:DoPopulate()

			content:SwitchPanel(pnl.ItemPanel)
		end
	end

	items.DoPopulate = function(pnl)
		if pnl.ItemPanel then
			return
		end

		pnl.ItemPanel = content:Add("ContentContainer")
		pnl.ItemPanel:SetVisible(false)
		pnl.ItemPanel:SetTriggerSpawnlistChange(false)

		for k, tab in SortedPairs(all) do
			if table.Count(tab) <= 0 then
				continue
			end

			local rarity = Item.Rarities[k]

			spawnmenu.CreateContentIcon("header", pnl.ItemPanel, {
				text = rarity.Name
			})

			for _, item in SortedPairs(tab) do
				spawnmenu.CreateContentIcon("cc_item", pnl.ItemPanel, item)
			end
		end
	end

	items.DoClick = function(pnl)
		pnl:DoPopulate()

		content:SwitchPanel(pnl.ItemPanel)
	end
end

spawnmenu.AddCreationTab("CombineControl", function()
	local panel = vgui.Create("SpawnmenuContentPanel")

	panel:EnableSearch("combinecontrol", "PopulateCCSpawnmenu")
	panel:CallPopulateHook("PopulateCCSpawnmenu")

	return panel
end, "icon16/palette.png", 25)

search.AddProvider(function(str)
	local items = {}

	for class, item in SortedPairs(Item.Find(lp, str)) do
		table.insert(items, {
			text = class,
			func = function() RunConsoleCommand("rpa_createitem", class) end,
			icon = spawnmenu.CreateContentIcon("cc_item", nil, item),
			words = {class}
		})
	end

	return items
end, "combinecontrol")

spawnmenu.AddContentType("cc_item", function(container, item)
	local icon = vgui.Create("ContentIcon", container)

	icon:SetContentType("cc_item")
	icon:SetSpawnName(item.ClassName)
	icon:SetName(item.Name)
	icon:SetAdminOnly(item.Rarity == RARITY_DEVELOPER)
	icon:SetColor(Item.Rarities[item.Rarity].Color)

	icon.DoClick = function()
		RunConsoleCommand("rpa_createitem", item.ClassName)
		surface.PlaySound("ui/buttonclickrelease.wav")
	end

	if IsValid(container) then
		container:Add(icon)
	end

	return icon
end)

-- Tool disabling based off of CanUseTool status
local PANEL = vgui.GetControlTable("ToolPanel")

function PANEL:UpdateToolDisabledStatus()
	for cid, category in ipairs(self.List.pnlCanvas:GetChildren()) do
		for id, item in ipairs(category:GetChildren()) do
			if item == category.Header then
				continue
			end

			local enabled, err = hook.Run("CanUseTool", lp, item.Name)

			if enabled == item:IsEnabled() and (enabled or err == item:GetTooltip()) then
				continue
			end

			item:SetEnabled(enabled)

			if enabled then
				item:SetTooltip(nil)
			else
				item:SetTooltip(err)
			end
		end
	end
end
