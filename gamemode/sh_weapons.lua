GM.HandsWeapons = {
	"weapon_cc_hands",
}

function GM:PlayerSwitchWeapon(ply, old, new)
	if SERVER and new.Holsterable then

		ply:SetHolstered(true)

	end

	if not new.Holsterable then

		ply:SetHolstered(false)

	end

	self.BaseClass:PlayerSwitchWeapon(ply, old, new)
end

function GM:PlayerSwitchFlashlight(ply, enable)
	if not enable then
		return true
	end

	local item = ply:GetEquipment(EQUIPMENT_LIGHT)

	if not ply.NextFlashlight then
		ply.NextFlashlight = CurTime()
	end

	if item and CurTime() >= ply.NextFlashlight then
		ply.NextFlashlight = CurTime() + 0.2

		return item:Toggle(ply)
	end

	return false
end

if SERVER then
	function nToggleHolster(len, ply)
		local weapon = ply:GetActiveWeapon()

		if IsValid(weapon) then
			if weapon.Holsterable then
				ply:SetHolstered(not ply:Holstered())
			else
				ply:SetHolstered(false)
			end

			if weapon.ToggleHolster then
				weapon:ToggleHolster()
			end
		end
	end
	net.Receive("nToggleHolster", nToggleHolster)
end

function GM:IronsightsMul()
	return FrameTime() / 1.5
end

function GM:GetTraceDecal(tr)
	if tr.MatType == MAT_ALIENFLESH then return "Impact.AlientFlesh" end
	if tr.MatType == MAT_ANTLION then return "Impact.Antlion" end
	if tr.MatType == MAT_CONCRETE then return "Impact.Concrete" end
	if tr.MatType == MAT_METAL then return "Impact.Metal" end
	if tr.MatType == MAT_WOOD then return "Impact.Wood" end
	if tr.MatType == MAT_GLASS then return "Impact.Glass" end
	if tr.MatType == MAT_FLESH then return "Impact.Flesh" end
	if tr.MatType == MAT_BLOODYFLESH then return "Impact.BloodyFlesh" end

	return "Impact.Concrete"
end

function GM:GetImpactSound(tr)
	if tr.MatType == MAT_ALIENFLESH then return "Flesh.BulletImpact" end
	if tr.MatType == MAT_ANTLION then return "Flesh.BulletImpact" end
	if tr.MatType == MAT_CONCRETE then return "Concrete.BulletImpact" end
	if tr.MatType == MAT_METAL then return "SolidMetal.BulletImpact" end
	if tr.MatType == MAT_WOOD then return "Wood.BulletImpact" end
	if tr.MatType == MAT_GLASS then return "Glass.BulletImpact" end
	if tr.MatType == MAT_FLESH then return "Flesh.BulletImpact" end
	if tr.MatType == MAT_BLOODYFLESH then return "Flesh.BulletImpact" end
	if tr.MatType == MAT_DIRT then return "Dirt.BulletImpact" end
	if tr.MatType == MAT_GRATE then return "MetalGrate.BulletImpact" end
	if tr.MatType == MAT_TILE then return "Tile.BulletImpact" end
	if tr.MatType == MAT_COMPUTER then return "Computer.BulletImpact" end
	if tr.MatType == MAT_SAND then return "Sand.BulletImpact" end
	if tr.MatType == MAT_PLASTIC then return "Plastic_Box.BulletImpact" end

	return "Default.BulletImpact"
end
