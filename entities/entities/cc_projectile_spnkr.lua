AddCSLuaFile()
DEFINE_BASECLASS("cc_base_rocket")

ENT.Base = "cc_base_rocket"

ENT.Model = Model("models/vuthakral/halo/weapons/spnkr_rocket.mdl")

ENT.Velocity = 4000

ENT.Damage = 200
ENT.LoopSound = Sound("vuthakral/halo/weapons/spnkr/rocketloop.wav")

if SERVER then
	function ENT:Initialize()
		BaseClass.Initialize(self)

		local trail = ents.Create("env_rockettrail")

		trail:SetSaveValue("m_SpawnRate", 100)
		trail:SetSaveValue("m_ParticleLifetime", 0.5)

		trail:SetSaveValue("m_EndColor", Vector(0, 0, 0))
		trail:SetSaveValue("m_Opacity", 0.1)

		trail:SetSaveValue("m_StartSize", 8)
		trail:SetSaveValue("m_EndSize", 32)

		trail:SetSaveValue("m_SpawnRadius", 4)

		trail:SetSaveValue("m_MinSpeed", 2)
		trail:SetSaveValue("m_MaxSpeed", 16)

		trail:SetParent(self)

		trail:SetLocalPos(vector_origin)
		trail:SetLocalAngles(angle_zero)

		trail:Spawn()
		trail:Activate()
	end

	function ENT:OnHit(tr)
		self:SetImpact(tr.HitPos)

		local explo = ents.Create("env_explosion")
		explo:SetOwner(self:GetOwner())
		explo:SetPos(tr.HitPos)
		explo:SetKeyValue("spawnflags", 96)
		explo:SetKeyValue("iMagnitude", self.Damage)
		explo:Spawn()
		explo:Activate()
		explo:Fire("Explode")

		-- New way of doing distant sounds?
		local filter = RecipientFilter()
		filter:AddAllPlayers()

		self:EmitSound("Weapon_Spnkr.Explode", 140, 100, 1, CHAN_STATIC, 0, 0, filter)
		self:Remove()
	end
end

sound.Add({
	name = "Weapon_Spnkr.Explode",
	channel = CHAN_STATIC,
	volume = 1,
	level = 140,
	pitch = 100,
	sound = {
		")vuthakral/halo/weapons/spnkr/explode0.wav",
		")vuthakral/halo/weapons/spnkr/explode1.wav",
		")vuthakral/halo/weapons/spnkr/explode2.wav",
		")vuthakral/halo/weapons/spnkr/explode3.wav",
		")vuthakral/halo/weapons/spnkr/explode4.wav",
		")vuthakral/halo/weapons/spnkr/explode5.wav"
	}
})
