local BaseClass = inherit.Get("item", "base")

ITEM.Internal = true

ITEM.Category    = "Weapon"

ITEM.WeaponClass = "weapon_bugbait"

ItemDataFunc("WeaponState", {})

function ITEM:GetWeapon()
	if not self:IsEquipped() then
		return NULL
	end

	return self:GetPlayer():GetWeapon(self.WeaponClass)
end

if SERVER then
	function ITEM:OnEquipped(ply, slot)
		BaseClass.OnEquipped(self, ply, slot)

		ply:UpdateLoadout()
		self:LoadWeaponState()
	end

	function ITEM:OnUnequipped(ply)
		BaseClass.OnUnequipped(self, ply)

		self:SaveWeaponState()
		ply:UpdateLoadout()
	end

	function ITEM:LoadWeaponState()
		local weapon = self:GetWeapon()

		if not IsValid(weapon) or not weapon:IsType("weapon_cc_base") then
			return
		end

		weapon:SetItemID(self.ID)
		weapon:LoadState(self:GetWeaponState())
	end

	function ITEM:SaveWeaponState()
		local weapon = self:GetWeapon()

		if not IsValid(weapon) then
			return
		end

		if not weapon:IsType("weapon_cc_base") then
			self:SetData("WeaponState", {})

			return
		end

		self:SetData("WeaponState", weapon:SaveState())
	end

	function ITEM:OnPlayerDeath(ply)
		self:SaveWeaponState()
	end

	function ITEM:GetLoadout(ply, loadout, spawned)
		if self:IsEquipped() then
			table.insert(loadout, self.WeaponClass)
		end
	end

	function ITEM:PlayerSpawned(ply)
		if self:IsEquipped() then
			self:LoadWeaponState()
		end
	end
end
