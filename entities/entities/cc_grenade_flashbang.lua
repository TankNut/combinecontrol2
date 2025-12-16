AddCSLuaFile()

ENT.Base = "cc_base_grenade"

ENT.Model = Model("models/weapons/w_eq_flashbang.mdl")

ENT.FlashRadius = 1500
ENT.FlashSeverity = 1

-- Maximum effort

if SERVER then
	local damage = 4

	util.AddNetworkString("cc2_flashbang")

	-- Todo: Might want to make this a generic flash function?
	function ENT:Detonate()
		self:EmitSound("Flashbang.Explode")

		local origin = self:WorldSpaceCenter()
		local radius = self.FlashRadius
		local falloff = damage / radius

		for _, ply in player.Iterator() do
			local pos = ply:EyePos()
			local dist = pos:Distance(origin)

			if dist > radius then
				continue
			end

			local tr = util.TraceLine({
				start = origin,
				endpos = pos,
				mask = MASK_VISIBLE,
				filter = self,
				collisiongroup = COLLISION_GROUP_NONE
			})

			if tr.Fraction < 1 and tr.Entity != ply then
				continue
			end

			if hook.Run("CanBeFlashed", ply) == false then
				continue
			end

			local diff = origin - pos
			local severity = (damage - (diff):Length() * falloff) * self.FlashSeverity

			local dot = diff:GetNormalized():Dot(ply:GetAimVector())

			local fadeTime = 0
			local fadeHold = 0
			local alpha = 255

			if dot >= 0.5 then
				fadeTime = severity * 2.5
				fadeHold = severity * 1.25
			elseif dot >= -0.5 then
				fadeTime = severity * 1.75
				fadeHold = severity * 0.8
			else
				fadeTime = severity
				fadeHold = severity * 0.75
				alpha = 200
			end

			local curTime = CurTime()
			local tab = ply:GetTable()

			local oldUntil = tab.m_blindUntilTime or 0
			local data = {}

			tab.m_blindUntilTime = math.max(curTime + fadeHold + 0.5 * fadeTime)
			tab.m_blindStartTime = curTime

			fadeTime = fadeTime / 1.4

			if curTime > oldUntil then
				tab.m_flFlashDuration = fadeTime
				data.m_flFlashDuration = tab.m_flFlashDuration

				tab.m_flFlashMaxAlpha = alpha
				data.m_flFlashMaxAlpha = tab.m_flFlashMaxAlpha
			else
				local remaining = oldUntil + tab.m_flFlashDuration - curTime

				tab.m_flFlashDuration = math.max(remaining, fadeTime)
				data.m_flFlashDuration = tab.m_flFlashDuration

				tab.m_flFlashMaxAlpha = math.max(tab.m_flFlashMaxAlpha, alpha)
				data.m_flFlashMaxAlpha = tab.m_flFlashMaxAlpha
			end

			-- Doing this for maximum performance
			net.Start("cc2_flashbang")
				net.WriteUInt(self:EntIndex(), 16)
				net.WriteVector(origin)
				net.WriteTable(data)
			net.Send(ply)

			local dspRange = radius / 3

			if dist <= dspRange * dspRange then
				ply:SetDSP(35)
			end
		end

		self:Remove()
	end
else
	net.Receive("cc2_flashbang", function()
		local index = net.ReadUInt(16)
		local pos = net.ReadVector()

		local light = DynamicLight(index)

		light.pos = pos
		light.r = 255
		light.g = 255
		light.b = 255
		light.brightness = 2
		light.radius = 400
		light.decay = 768
		light.DieTime = CurTime() + 0.1

		local data = net.ReadTable()
		local tab = lp:GetTable()

		if not tab.flashbang or (tab.flashbang.m_flFlashDuration != data.m_flFlashDuration and data.m_flFlashDuration > 0) then
			data.m_flFlashAlpha = 1
			data.newTexture = true
		end

		data.m_flFlashbangTime = CurTime() + data.m_flFlashDuration

		tab.flashbang = data
	end)

	local rt = GetRenderTarget(string.format("cc2_flashbang_rt_%s_%s", ScrW(), ScrH()), ScrW(), ScrH())
	local mat = CreateMaterial("cc2_flashbang", "unlitgeneric", {
		["$basetexture"] = rt:GetName(),
		["$translucent"] = 1,
		["$additive"] = 1,
		["$vertexalpha"] = 1
	})

	hook.Add("OnScreenSizeChanged", "cc2_flashbang", function(_, _, w, h)
		rt = GetRenderTarget(string.format("cc2_flashbang_rt_%s_%s", w, h), w, h)
		mat:SetTexture("$basetexture", rt)
	end)

	local mat2 = Material("effects/flashbang_white")

	hook.Add("PostDrawHUD", "cc2_flashbang", function()
		if not lp then
			return
		end

		local data = lp.flashbang

		if not data then
			return
		end

		local curTime = CurTime()

		if data.m_flFlashbangTime < curTime then
			return
		end

		surface.SetMaterial(mat)

		if data.newTexture then
			data.newTexture = nil

			render.CopyTexture(render.GetScreenEffectTexture(0), rt)
		end

		if data.m_flFlashAlpha < data.m_flFlashMaxAlpha then
			data.m_flFlashAlpha = math.min(data.m_flFlashAlpha + 45, data.m_flFlashMaxAlpha)

			mat:SetFloat("$alpha", data.m_flFlashAlpha / 255)

			-- Overkill but it's how valve did it

			surface.SetDrawColor(data.m_flFlashAlpha, data.m_flFlashAlpha, data.m_flFlashAlpha)
			surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
			surface.SetDrawColor(255, 255, 255)
			surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
			surface.SetDrawColor(data.m_flFlashAlpha, data.m_flFlashAlpha, data.m_flFlashAlpha)
			surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
			surface.SetDrawColor(255, 255, 255)
			surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
		else
			local alpha = math.Clamp(data.m_flFlashMaxAlpha * (data.m_flFlashbangTime - curTime) / data.m_flFlashDuration, 0, data.m_flFlashMaxAlpha)

			mat:SetFloat("$alpha", alpha / 255)

			surface.SetDrawColor(alpha, alpha, alpha)
			surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
			surface.SetDrawColor(255, 255, 255)
			surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
			surface.SetDrawColor(alpha, alpha, alpha)
			surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
			surface.SetDrawColor(255, 255, 255)
			surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
		end

		surface.SetMaterial(mat2)

		local alpha = 255

		if data.m_flFlashAlpha < data.m_flFlashMaxAlpha then
			alpha = data.m_flFlashAlpha
		else
			local timeLeft = data.m_flFlashbangTime - curTime
			local alphaMult = 1

			if timeLeft > 3 then
				alphaMult = 1
			else
				alphaMult = timeLeft / 3

				alphaMult = alphaMult * alphaMult
			end

			alpha = math.Clamp(alphaMult * data.m_flFlashMaxAlpha, 0, data.m_flFlashMaxAlpha)
		end

		surface.SetDrawColor(alpha, alpha, alpha, alpha)
		surface.DrawRect(0, 0, ScrW(), ScrH())
	end)
end
