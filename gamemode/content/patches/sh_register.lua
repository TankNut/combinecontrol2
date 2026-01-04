local blockedEntities = {
	"^drc_ammo",
	"^drc_att",
	"^drc_plate",
	"^drc_station",
	"^ma2_battlesuit_",
	"^ma2_mech_",
	"^ma2_salvage_"
}

local blockedWeapons = {
	"^drc_"
}

local function filterEntity(ent, class)
	for _, block in ipairs(blockedEntities) do
		if string.find(class, block) then
			return false
		end
	end
end

local function filterWeapon(swep, class)
	for _, block in ipairs(blockedWeapons) do
		if string.find(class, block) then
			return false
		end
	end
end

hook.Add("PreRegisterSENT", "cc2.GoAway", filterEntity)
hook.Add("PreRegisterSWEP", "cc2.GoAway", filterWeapon)
