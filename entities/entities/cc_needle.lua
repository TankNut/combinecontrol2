AddCSLuaFile()

ENT.Base = "cc_base_ent"

ENT.RenderGroup = RENDERGROUP_BOTH

ENT.Model = Model("models/vuthakral/halo/weapons/w_needle.mdl")

function ENT:Initialize()
	self:SetModel(self.Model)
end

if CLIENT then
	local sprite = Material("sprites/light_glow02_add")
	local color = Color(220, 0, 255)

	function ENT:Draw()
		self:DrawModel()
	end

	function ENT:DrawTranslucent()
		local pos = self:GetPos()

		render.SetMaterial(sprite)

		render.DrawSprite(pos, 8, 8, color)
		render.DrawSprite(pos, 8, 8, color)
	end
else
	function ENT:Shatter()
		local parent = self:GetParent()

		if IsValid(parent) then
			parent.NeedleValue = parent.NeedleValue - self.Value
		end

		sound.Play("Needle.Shatter", self:GetPos())

		self:Remove()
	end

	function ENT:Think()
		if CurTime() - self:GetCreationTime() >= 4 then
			self:Shatter()
		end
	end

	function SuperCombine(source, target, pos)
		target:EmitSound("Needle.SuperCombine")

		util.BlastDamage(source, source:GetOwner(), pos, 30, 350)

		local ed = EffectData()

		ed:SetOrigin(pos)
		ed:SetStart(pos)

		util.Effect("drc_halo_ne_sc", ed)

		target.NeedleValue = 0

		for _, ent in ipairs(target:GetChildren()) do
			if ent:GetClass() == "cc_needle" then
				ent:Remove()
			end
		end
	end

	function AddNeedle(source, trace, value)
		local target = trace.Entity
		local pos = trace.HitPos

		value = value or 1

		if IsValid(target) then
			target.NeedleValue = target.NeedleValue or 0
			target.NeedleValue = target.NeedleValue + value

			if target.NeedleValue > 6 then
				SuperCombine(source, target, pos)

				return
			end
		end

		local ent = ents.Create("cc_needle")

		ent:SetPos(pos)
		ent:SetAngles(trace.Normal:Angle())

		ent.Value = value

		if IsValid(target) then
			ent:SetParent(target)
		end

		ent:Spawn()
		ent:Activate()
	end
end

sound.Add({
	name = "Needle.Shatter",
	channel = CHAN_AUTO,
	volume = 1,
	level = 56,
	pitch = {97.5, 102.5},
	sound = {
		")vuthakral/halo/weapons/Needler/expl1.wav",
		")vuthakral/halo/weapons/Needler/expl3.wav"
	}
})

sound.Add({
	name = "Needle.SuperCombine",
	channel = CHAN_AUTO,
	volume = 1,
	level = 90,
	pitch = {97.5, 102.5},
	sound = ")vuthakral/halo/weapons/Needler/supercombine.wav"
})
