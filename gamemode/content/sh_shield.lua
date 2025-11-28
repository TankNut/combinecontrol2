module("shield", package.seeall)

function Get(ent)
	return ent:GetNWEntity("ShieldEntity")
end

if SERVER then
	function Enable(ent, class)
		local existing = Get(ent)

		if IsValid(existing) and math.IsNearlyEqual(existing:GetCreationTime(), CurTime(), 0.1) then
			return
		end

		SafeRemoveEntity(Get(ent))

		local shield = ents.Create(class or "cc_shield")

		shield:SetParent(ent)
		shield:Spawn()
		shield:Activate()

		ent:SetNWEntity("ShieldEntity", shield)
	end

	function Disable(ent)
		SafeRemoveEntity(Get(ent))
	end

	hook.Add("EntityTakeDamage", "cc2.Shield", function(ent, dmg)
		local shield = Get(ent)

		if IsValid(shield) and shield:TakeShieldDamage(dmg) then
			return true
		end
	end)

	hook.Add("ScalePlayerDamage", "cc2.Shield", function(ply, hitgroup, dmg)
		local shield = Get(ply)

		if IsValid(shield) and shield:TakeShieldDamage(dmg) then
			return true
		end
	end)
end

if CLIENT then
	EntityCache.Add("shields", function(ent) return ent:IsType("cc_shield") end)

	hook.Add("PostDrawTranslucentRenderables", "cc2.Shield", function(depth, skybox)
		if skybox then
			return
		end

		for shield in EntityCache.Iterator("shields") do
			if shield:IsDormant() then
				continue
			end

			shield:Draw()
		end
	end)

	matproxy.Add({
		name = "cc2_shield",
		init = function(self, mat, values) end,
		bind = function(self, mat, ent)
			mat:SetVector("$emissiveBlendTint", ent:GetShieldColor())
			mat:SetFloat("$emissiveBlendStrength", ent:GetShieldVisibility())
		end
	})
end
