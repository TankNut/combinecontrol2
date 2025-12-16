local entityCategoryIcons = {
	["Spawnpoints"] = "icon16/status_online.png",
	["Utilities"] = "icon16/cog.png",
	["World Entities"] = "icon16/world.png"
}

function GM:PopulateCCEntities(content, tree, browseNode)
	local entities = tree:AddNode("Entities", "icon16/folder.png")
	entities:SetExpanded(true)

	local categories = {}
	local subCategories = {}

	for class, ent in pairs(scripted_ents.GetList()) do
		ent = ent.t

		if ent.CCMainCategory then
			if not categories[ent.CCMainCategory] then
				categories[ent.CCMainCategory] = {}
				subCategories[ent.CCMainCategory] = {}
			end

			if ent.CCSubCategory then
				local subs = subCategories[ent.CCMainCategory]

				if not subs[ent.CCSubCategory] then
					subs[ent.CCSubCategory] = {}
				end

				subs[ent.CCSubCategory][class] = ent
			else
				categories[ent.CCMainCategory][class] = ent
			end
		end
	end

	for category, classes in SortedPairs(categories) do
		local node = entities:AddNode(category, entityCategoryIcons[category] or "icon16/bricks.png")
		node:SetExpanded(true)

		node.DoPopulate = function(pnl)
			if pnl.EntityPanel then
				return
			end

			pnl.EntityPanel = content:Add("ContentContainer")
			pnl.EntityPanel:SetVisible(false)
			pnl.EntityPanel:SetTriggerSpawnlistChange(false)

			for class, ent in SortedPairsByMemberValue(classes, "PrintName") do
				spawnmenu.CreateContentIcon(ent.ScriptedEntityType or "entity", pnl.EntityPanel, {
					nicename	= ent.PrintName or ent.ClassName,
					spawnname	= class,
					material	= ent.IconOverride or ("entities/" .. class .. ".png"),
					admin		= ent.AdminOnly
				})
			end
		end

		node.DoClick = function(pnl)
			pnl:DoPopulate()

			content:SwitchPanel(pnl.EntityPanel)
		end

		for subCategory, filteredClasses in SortedPairs(subCategories[category]) do
			local subNode = node:AddNode(subCategory, entityCategoryIcons[subCategory] or "icon16/bricks.png")

			subNode.DoPopulate = function(pnl)
				if pnl.EntityPanel then
					return
				end

				pnl.EntityPanel = content:Add("ContentContainer")
				pnl.EntityPanel:SetVisible(false)
				pnl.EntityPanel:SetTriggerSpawnlistChange(false)

				for class, ent in SortedPairsByMemberValue(filteredClasses, "PrintName") do
					spawnmenu.CreateContentIcon(ent.ScriptedEntityType or "entity", pnl.EntityPanel, {
						nicename	= ent.PrintName or ent.ClassName,
						spawnname	= class,
						material	= ent.IconOverride or ("entities/" .. class .. ".png"),
						admin		= ent.AdminOnly
					})
				end
			end

			subNode.DoClick = function(pnl)
				pnl:DoPopulate()

				content:SwitchPanel(pnl.EntityPanel)
			end
		end
	end
end

local itemCategoryIcons = {
	["Container"] = "icon16/package.png",
	["Weapons"] = "icon16/gun.png"
}

function GM:PopulateCCItems(content, tree, browseNode)
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
		local node = items:AddNode(category, itemCategoryIcons[category] or "icon16/bricks.png")

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

			for _, item in SortedPairsByMemberValue(tab, "Name") do
				spawnmenu.CreateContentIcon("cc_item", pnl.ItemPanel, item)
			end
		end
	end

	items.DoClick = function(pnl)
		pnl:DoPopulate()

		content:SwitchPanel(pnl.ItemPanel)
	end
end

function GM:PopulateCCSpawnmenu(content, tree, browseNode)
	if not lp then
		return
	end

	self:PopulateCCEntities(content, tree, browseNode)

	if not lp:IsAdmin() then
		return
	end

	self:PopulateCCItems(content, tree, browseNode)
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
			func = function() RunConsoleCommand("rpa_item_create", class) end,
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
		RunConsoleCommand("rpa_item_create", item.ClassName)
		surface.PlaySound("ui/buttonclickrelease.wav")
	end

	icon.OpenMenu = function()
		local dmenu = DermaMenu()

		dmenu:AddOption("Copy Class to Clipboard", function()
			SetClipboardText(item.ClassName)
		end):SetIcon("icon16/page_copy.png")

		dmenu:AddOption("Spawn Temporary Item", function()
			RunConsoleCommand("rpa_item_create_temp", item.ClassName)
		end ):SetIcon("icon16/brick_add.png")

		dmenu:Open()
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

-- NPC weapon category
hook.Add("PopulateMenuBar", "cc2.SpawnMenu", function(_, menuBar)
	local npcMenu = menuBar:AddOrGetMenu("#menubar.npcs")
	local weaponMenu = npcMenu:AddSubMenu("CombineControl Weapons")
	weaponMenu:SetDeleteSelf(false)

	weaponMenu:AddCVar("#menubar.npcs.defaultweapon", "gmod_npcweapon", "")
	weaponMenu:AddCVar("#menubar.npcs.noweapon", "gmod_npcweapon", "none")
	weaponMenu:AddSpacer()

	local categories = {}

	for _, weapon in pairs(weapons.GetList()) do
		if weapon and weapon.Spawnable and weapons.IsBasedOn(weapon.ClassName, "weapon_cc_base_gun") then
			local category = weapon.NPCCategory or "Misc"

			categories[category] = categories[category] or {}

			table.insert(categories[category], {
				["class"] = weapon.ClassName,
				["title"] = weapon.PrintName or weapon.ClassName
			})
		end
	end

	for category, weaponList  in SortedPairs(categories) do
		local subMenu = weaponMenu:AddSubMenu(category)

		subMenu:SetDeleteSelf(false)

		for _, weapon in SortedPairsByMemberValue(weaponList, "title") do
			subMenu:AddCVar(weapon.title, "gmod_npcweapon", weapon.class)
		end
	end
end, POST_HOOK_RETURN)
