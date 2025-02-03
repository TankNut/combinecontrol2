local meta = FindMetaTable("Entity")

function game.GetDoors()
	local tab = {}

	for _, v in ents.Iterator() do

		if v.IsDoor and v:IsDoor() then

			table.insert(tab, v)

		end

	end

	return tab
end

function meta:CopyBodygroups(ent)
	for i = 1, 8 do
		self:SetBodygroup(i, ent:GetBodygroup(i))
	end
end

function GM:EntityEmitSound(data)
	if not data then return end

	local ent = data.Entity

	if not IsValid(ent) then
		return
	end

	if ent.TerminatorAI and string.find(data.SoundName, "player/footsteps/") then
		local step = ent.Step

		if step != nil then
			ent:EmitSound(step and ent.Footsteps[1] or ent.Footsteps[2])
			ent.Step = not step
		else
			ent:EmitSound(ent.Footsteps[math.random(1, #ent.Footsteps)])
		end

		return false
	end
end
