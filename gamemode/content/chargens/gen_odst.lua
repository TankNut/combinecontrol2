GENERATOR.Base = "marine"
GENERATOR.Name = "UNSC/ODST"

function GENERATOR:PostCreateCharacter(ply)
	ply:GiveItem("undersuit_odst"):SetEquipmentSlot("unsc_undersuit")

	local armor = ply:GiveItem("armor_odst")
	armor:SetData("Cuffs", true)
	armor:SetData("ChestPacks", 4)
	armor:SetData("Legs", 1)
	armor:SetEquipmentSlot("unsc_armor")

	local helmet = ply:GiveItem("helmet_odst")
	helmet:SetData("Balaclava", true)
	helmet:SetEquipmentSlot("unsc_headwear")
end
