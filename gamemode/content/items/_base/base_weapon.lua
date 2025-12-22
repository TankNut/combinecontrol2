local BaseClass = inherit.Get("item", "base")

ITEM.Internal = true

ITEM.Category    = "Weapon"

ITEM.WeaponClass = "weapon_bugbait"

ItemDataFunc("WeaponState", {})

function ITEM:GetWeapon()
	local weapon = self:GetParent():GetWeapon(self.WeaponClass)

	if IsValid(weapon) and weapon:GetItemID() == self.ID then
		return weapon
	end

	return NULL
end

if SERVER then
	function ITEM:OnRemove()
		self:SaveWeaponState()

		BaseClass.OnRemove(self)
	end

	function ITEM:OnEquipped(ply, slot)
		BaseClass.OnEquipped(self, ply, slot)

		self:GiveWeapon()
	end

	function ITEM:OnUnequipped(ply)
		BaseClass.OnUnequipped(self, ply)

		self:TakeWeapon()
	end

	function ITEM:GiveWeapon()
		local ply = self:GetParent()

		if ply:HasWeapon(self.WeaponClass) then
			return
		end

		self:LoadWeaponState(ply:Give(self.WeaponClass))
	end

	function ITEM:TakeWeapon()
		local ply = self:GetParent()
		local weapon = self:GetWeapon()

		if not IsValid(weapon) then
			return
		end

		if weapon == ply:GetActiveWeapon() then
			ply:SelectDefaultWeapon()
		end

		self:SaveWeaponState()
		ply:StripWeapon(self.WeaponClass)
	end

	function ITEM:LoadWeaponState(weapon)
		if not weapon:IsType("weapon_cc_base") then
			return
		end

		weapon:SetItemID(self.ID)
		weapon:LoadItemState(self:GetWeaponState())
	end

	function ITEM:SaveWeaponState()
		local weapon = self:GetWeapon()

		if not IsValid(weapon) or not weapon:IsType("weapon_cc_base") then
			return
		end

		self:SetData("WeaponState", weapon:SaveItemState())
	end

	function ITEM:OnPlayerDeath(ply)
		self:SaveWeaponState()
	end

	function ITEM:PlayerSpawned(ply)
		if self:IsEquipped() then
			self:GiveWeapon(ply)
		end
	end
end
