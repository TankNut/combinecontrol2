local BaseClass = inherit.Get("item", "base_stacking")

ITEM.Base = "base_stacking"
ITEM.Internal = true

ITEM.Category = "Thrown"

ITEM.WeaponClass = "weapon_bugbait"

function ITEM:GetWeapon()
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
			self:GiveWeapon()
		end
	end

	function ITEM:InventoryRemoved(inventory)
		BaseClass.InventoryRemoved(self, inventory)

		if inventory.StoreType == INV_PLAYER then
			self:TakeWeapon()
		end
	end

	function ITEM:GiveWeapon()
		local ply = self:GetParent()

		if ply:HasWeapon(self.WeaponClass) then
			return
		end

		ply:Give(self.WeaponClass):SetItemID(self.ID)
	end

	function ITEM:TakeWeapon()
		local weapon = self:GetWeapon()
		local ply = self:GetParent()

		if not IsValid(weapon) then
			return
		end

		if weapon == ply:GetActiveWeapon() then
			ply:SelectDefaultWeapon()
		end

		ply:StripWeapon(self.WeaponClass)
	end

	function ITEM:PlayerSpawned(ply)
		self:GiveWeapon()
	end
end
