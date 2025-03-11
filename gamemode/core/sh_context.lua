module("Context", package.seeall)

local PLAYER = FindMetaTable("Player")

if CLIENT then
	function Add(path, callback, section)
		assert(Cache, "Context.Add called outside of hook")

		section = section or CONTEXT_MISC

		if not Cache[section] then
			Cache[section] = {}
		end

		local cache = Cache[section]

		table.insert(cache, {
			Name = path,
			Callback = callback
		})
	end
end

function PLAYER:GetContextEntity()
	local tr = self:GetEyeTrace()
	local ent = tr.Entity
	local distance = tr.Fraction * 32768

	if not IsValid(ent) or distance > self:GetSightRange() then
		return
	end

	return ent, distance <= Config.Get("InteractRange"), distance
end

if CLIENT then
	function GM:BuildExternalContext(ent, canInteract, distance)
		if ent:IsPlayer() then
			-- Optional check for things like invisibility
			hook.Run("BuildPlayerContext", ent, canInteract, distance)
		else
			hook.Run("BuildEntityContext", ent, canInteract, distance)
		end
	end

	function GM:BuildPlayerContext(ply, canInteract, distance)
		Context.Add("Examine", function() ply:Examine() end, CONTEXT_ENTITY)
	end

	function GM:BuildEntityContext(ent, canInteract, distance)
		for _, entry in ipairs(ent:GetActionMenuData()) do
			Context.Add(entry.Name, entry.Callback, CONTEXT_ENTITY)
		end
	end

	function GM:BuildSelfContext()
		-- Doing it this way so that we always use the flag-defined order
		local slots = lp:RunCharFlag("EquipmentSlots")

		for _, slot in ipairs(slots) do
			local item = lp:GetEquipment(slot)

			if item then
				for _, entry in ipairs(item:GetActionMenuData("EquipmentContext")) do
					local name = item.Unique and string.format("%s\a%s", item:GetName(), item.ID) or item:GetName()

					Context.Add(string.format("Equipment/%s/%s", name, entry.Name), entry.Callback, CONTEXT_EQUIPMENT)
				end
			end
		end

		for _, item in pairs(lp:GetItems()) do
			for _, entry in ipairs(item:GetActionMenuData("InventoryContext")) do
				local name = item.Unique and string.format("%s\a%s", item:GetName(), item.ID) or item:GetName()

				Context.Add(string.format("Inventory/%s/%s", name, entry.Name), entry.Callback, CONTEXT_INVENTORY)
			end
		end
	end

	function GM:BuildAdminContext()
		for _, entry in ipairs(lp:GetActionMenuData("Admin")) do
			Context.Add(entry.Name, entry.Callback, CONTEXT_ADMIN)
		end
	end

	function GM:BuildContextMenu()
		local ent, canInteract, distance = lp:GetContextEntity()

		if IsValid(ent) then
			hook.Run("BuildExternalContext", ent, canInteract, distance)
		end

		hook.Run("BuildSelfContext")

		if lp:IsAdmin() then
			hook.Run("BuildAdminContext")
		end
	end

	function GM:OnContextMenuOpen()
		if false then
			self.BaseClass:OnContextMenuOpen(self)

			return
		end

		Cache = {}

		hook.Run("BuildContextMenu")

		local menuData = {}

		for _, section in SortedPairs(Cache) do
			for _, data in ipairs(section) do
				table.insert(menuData, data)
			end
		end

		Cache = nil

		if #menuData == 0 then
			return
		end

		self.ContextMenu = util.BuildMenu(menuData)

		self.ContextMenu:SetSkin("CombineControl")
		self.ContextMenu:Open(ScrW() * 0.5, ScrH() * 0.5)
	end

	function GM:OnContextMenuClose()
		if IsValid(self.ContextMenu) then
			self.ContextMenu:Remove()
			self.ContextMenu = nil
		end

		self.BaseClass.OnContextMenuClose(self)
	end
end
