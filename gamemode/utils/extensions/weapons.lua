local WEAPON = FindMetaTable("Weapon")

function weapons.IsType(name, base)
	return name == base or weapons.IsBasedOn(name, base)
end

if not WEAPON._GetPrintName then
	WEAPON._GetPrintName = WEAPON.GetPrintName
end

function WEAPON:GetPrintName()
	if self.OverridePrintName then
		return self:OverridePrintName()
	end

	return self:_GetPrintName()
end
