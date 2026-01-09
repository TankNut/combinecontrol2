AddCSLuaFile()
DEFINE_BASECLASS("cc_base_projectile")

ENT.Base = "cc_base_projectile"

ENT.Model = Model("models/weapons/w_missile_launch.mdl")

ENT.Velocity = 4000
ENT.Gravity = 0.3

function ENT:Initialize()
	BaseClass.Initialize(self)

	if SERVER then
		local trail = ents.Create("env_rockettrail")

		trail:SetSaveValue("m_SpawnRate", 100)
		trail:SetSaveValue("m_ParticleLifetime", 0.5)

		trail:SetSaveValue("m_Opacity", 0)

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
end
