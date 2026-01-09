FLAG.Name = "Hunter"
FLAG.Team = TEAM_COVENANT

FLAG.Health = 200
FLAG.Armor = 100

FLAG.Loadout = {"weapon_cc_hands", "weapon_cc_hunter"}

FLAG.EquipmentSlots = {
	"radio"
}

FLAG.Clothing = CLOTHING_NONE

FLAG.SlowWalkSpeed = 67
FLAG.WalkSpeed = 67
FLAG.RunSpeed = 200
FLAG.JumpPower = 210
FLAG.CrouchSpeed = 67

FLAG.SprintFiring = true

local model = Model("models/valk/haloreach/covenant/characters/hunter/hunter_player.mdl")

function FLAG:GetModelData(ply)
	return {_base = {
		Model = model,
		Skin = 1
	}}
end

function FLAG:PlayerTakeDamage(ply, dmg)
	local source = dmg:GetInflictor() or dmg:GetAttacker()

	if dmg:IsExplosionDamage() then
		dmg:ScaleDamage(0.5)
	end

	if IsValid(source) and not dmg:IsExplosionDamage() then
		local rel = source:GetPos() - ply:GetPos()
		local eye = ply:EyeAngles()

		local dx = rel:Dot(eye:Forward())
		local dy = rel:Dot(eye:Right())

		local ang = math.atan2(dx, dy) / math.pi

		if not math.InRange(ang, -0.8, -0.2) then
			return true
		end
	end
end
