Config.Fallback("CorpseFade", 30)

local function fade(ent)
	timer.Simple(Config.Get("CorpseFade"), function()
		if not IsValid(ent) then
			return
		end

		if CLIENT then
			ent:SetSaveValue("m_bFadingOut", true)
		else
			ent:Fire("FadeAndRemove")
		end
	end)
end

if CLIENT then
	hook.Add("CreateClientsideRagdoll", "corpsefade", function(ent, ragdoll)
		fade(ragdoll)
	end)
else
	hook.Add("CreateEntityRagdoll", "corpsefade", function(ent, ragdoll)
		fade(ragdoll)
	end)
end
