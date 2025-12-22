local BaseClass = inherit.Get("item", "base_stacking")

ITEM.Base = "base_stacking"
ITEM.Internal = true

ITEM.Category = "Throwable"

ITEM.WeaponClass = "weapon_bugbait"

function ITEM:GetWeapon()
	if not self:IsEquipped() then
		return NULL
	end

	local weapon = self:GetParent():GetWeapon(self.WeaponClass)

	if IsValid(weapon) and weapon:GetItemID() == self.ID then
		return weapon
	end

	return NULL
end

if SERVER then
	function ITEM:InventoryAdded(inventory)
		BaseClass.InventoryAdded(self, inventory)

		if inventory.StoreType == INV_PLAYER then
			self:GiveWeapon(self:GetParent())
		end
	end

	function ITEM:InventoryRemoved(inventory)
		BaseClass.InventoryRemoved(self, inventory)

		if inventory.StoreType == INV_PLAYER then
			self:TakeWeapon(self:GetParent())
		end
	end

	function ITEM:GiveWeapon(ply)
		if ply:HasWeapon(self.WeaponClass) then
			return
		end

		ply:Give(self.WeaponClass):SetItemID(self.ID)
	end

	function ITEM:TakeWeapon(ply)
		local weapon = self:GetWeapon()

		if not IsValid(weapon) then
			return
		end

		if weapon == ply:GetActiveWeapon() then
			self:SelectDefaultWeapon()
		end

		ply:StripWeapon(self.WeaponClass)
	end

	function ITEM:PlayerSpawned(ply)
		self:GiveWeapon(ply)
	end
end
