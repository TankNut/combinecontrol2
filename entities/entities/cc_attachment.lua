AddCSLuaFile()

ENT.Type = "anim"

if CLIENT then
	function ENT:Draw(flags)
		-- We're a honest to god entity, so our parent is too (nothing vgui related), so we do some extra checks to see if we should bother drawing
		if self:EntIndex() != -1 then
			local parent = self:GetParent()

			if parent:GetNoDraw() or not parent:Alive() then
				return
			end

			if parent == lp and not parent:ShouldDrawLocalPlayer() then
				return
			end
		end

		self:DrawModel(flags)
	end
end
