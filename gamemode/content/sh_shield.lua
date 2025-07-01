module("shield", package.seeall)

function Get(ent)
	return ent:GetNWEntity("ShieldEntity")
end

if SERVER then
	function Enable(ent, class)
		SafeRemoveEntity(ent.ShieldEntity)

		local shield = ents.Create(class or "cc_shield")

		shield:SetParent(ent)
		shield:Spawn()
		shield:Activate()

		ent:SetNWEntity("ShieldEntity", shield)
	end

	function Disable(ent)
		SafeRemoveEntity(ent.ShieldEntity)
	end

	hook.Add("EntityTakeDamage", "shield", function(ent, dmg)
		if IsValid(ent.ShieldEntity) and ent.ShieldEntity:TakeShieldDamage(dmg) then
			return true
		end
	end)

	hook.Add("ScalePlayerDamage", "shield", function(ply, hitgroup, dmg)
		if IsValid(ply.ShieldEntity) and ply.ShieldEntity:TakeShieldDamage(dmg) then
			return true
		end
	end)
end

if CLIENT then
	matproxy.Add({
		name = "cc2_shield",
		init = function(self, mat, values) end,
		bind = function(self, mat, ent)
			mat:SetVector("$emissiveBlendTint", ent:GetShieldColor())
			mat:SetFloat("$emissiveBlendStrength", ent:GetShieldVisibility())
		end
	})
end
