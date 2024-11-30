local meta = FindMetaTable("Player")

-- This might change later but for now I'm just stuffing all the generic 'recalculate this' functions into one file to ease my suffering

function meta:UpdateArmor()
	local armor = self:RunCharFlag("Armor")

	-- Todo: Item armor, no reason to bother implementing it now when items are being replaced

	-- Internally rescales current armor because of the armor plugin
	self:SetMaxArmor(armor)
end

function meta:UpdateVisibleName()
	local name

	if #self:CharacterNameOverride() > 0 then
		name = self:CharacterNameOverride()
	end

	self:SetVisibleRPName(name or self:RunCharFlag("VisibleRPName"))
end

function meta:UpdateMovementSpeed()
	local slow, walk, run, jump, crouch = self:RunCharFlag("GetSpeeds")

	self:SetSlowWalkSpeed(slow)
	self:SetWalkSpeed(walk)
	self:SetRunSpeed(run)
	self:SetJumpPower(jump)
	self:SetCrouchedWalkSpeed(crouch / walk)
end

function meta:UpdateLoadout()
	local current = self:GetActiveWeapon()
	local loadout = hook.Run("GetPlayerLoadout", self)
	local flag = self:RunCharFlag("Loadout")

	table.Add(loadout, flag)

	-- Inventory weapons

	local lookup = table.Lookup(loadout)

	for _, v in ipairs(self:GetWeapons()) do
		if not lookup[v:GetClass()] then
			v:Remove()
		end
	end

	for k in pairs(lookup) do
		if not self:HasWeapon(k) then
			self:Give(k)
		end
	end

	if not IsValid(current) and #loadout > 0 then
		netstream.Send(self, "SelectWeapon", flag[1] or loadout[1])
	end
end
