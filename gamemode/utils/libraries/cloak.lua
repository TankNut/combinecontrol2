local PLAYER = FindMetaTable("Player")
local ENTITY = FindMetaTable("Entity")

local material = CreateMaterial("cloak", "vertexlitgeneric", {
	["$basetexture"] = "null",
	["$translucent"] = "1",
	["$cloakpassenabled"] = "1",
	["$refractamount"] = "0.1",
	["$cloakfactor"] = "0.9",
	["$nocull"] = "1"
})

function PLAYER:GetCloakFactor()
	local tab = ENTITY.GetTable(self)
	local frame = FrameNumber()

	if not tab.CloakFrame or tab.CloakFrame != frame then
		tab.CloakFactor = hook.Run("GetCloakFactor", self) or 0
		tab.CloakFrame = frame
	end

	return tab.CloakFactor
end

function PLAYER:IsCloaked()
	return self:GetCloakFactor() >= 0.3
end

local renderingCloak = false

hook.Add("PrePlayerDraw", "cc2.Cloak", function(ply)
	if ply:IsCloaked() and not renderingCloak then
		return true
	end
end)

local function updateShadow(ent, cloaked)
	if not IsValid(ent) then
		return
	end

	if cloaked and not ent:IsEffectActive(EF_NOSHADOW) then
		ent:AddEffects(EF_NOSHADOW)
	elseif not cloaked and ent:IsEffectActive(EF_NOSHADOW) then
		ent:RemoveEffects(EF_NOSHADOW)
	end
end

hook.Add("Think", "cc2.Cloak", function()
	for _, ply in player.Iterator() do
		local cloaked = ply:IsCloaked()

		updateShadow(ply, cloaked)
		updateShadow(ply:GetActiveWeapon(), cloaked)

		for _, child in ipairs(ply:GetChildren()) do
			if child:GetClass() != "cc_attachment" then
				continue
			end

			updateShadow(child, cloaked)
		end
	end
end)

local function drawPlayer(ply)
	ply:DrawModel()

	local weapon = ply:GetActiveWeapon()

	if IsValid(weapon) then
		weapon:DrawModel()
	end

	for _, child in ipairs(ply:GetChildren()) do
		if child:GetClass() == "cc_attachment" then
			child:DrawModel()
		end
	end
end

hook.Add("PostDrawTranslucentRenderables", "cc2.Cloak", function(depth, skybox)
	if skybox then return end

	renderingCloak = true

	render.UpdateFullScreenDepthTexture()

	for _, ply in player.Iterator() do
		if not ply:Alive() or ply:GetNoDraw() then
			continue
		end

		local factor = ply:GetCloakFactor()

		if factor == 0 or factor == 1 then
			continue
		end

		material:SetFloat("$cloakfactor", factor)

		drawPlayer(ply)

		render.MaterialOverride(material)
			drawPlayer(ply)
		render.MaterialOverride()
	end

	renderingCloak = false
end)
