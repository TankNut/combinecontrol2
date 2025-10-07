module("zone", package.seeall)

Shapes = Shapes or {}
Effects = Effects or {}

PlayerData = PlayerData or {}

function ActiveZone(ply, class)
	if not PlayerData[ply] then
		return
	end

	return PlayerData[ply][class]
end

if SERVER then
	function CreateShape(class, pos, ...)
		local ent = ents.Create(class)

		ent:SetPos(pos)

		ent:Spawn()
		ent:Activate()

		ent:Setup(...)

		return ent
	end

	function CreateEffect(class, pos)
		local ent = ents.Create(class)

		ent:SetPos(pos)

		ent:Spawn()
		ent:Activate()

		return ent
	end
end

hook.Add("Think", "cc2.Zones", function()
	for _, ply in player.Iterator() do
		if not PlayerData[ply] then
			PlayerData[ply] = {
				Stack = {},
				Active = {}
			}
		end

		local data = PlayerData[ply]
		local pos = ply:EyePos()

		if data.LastPos == pos then
			continue
		end

		data.LastPos = pos

		local stack = data.Stack
		local active = data.Active

		local entering = {}
		local exiting = {}

		local classes = {}

		-- Build entering table based on shapes
		for shape in pairs(Shapes) do
			if shape:Contains(ply) then
				for effect in pairs(shape.Effects) do
					if effect:AffectsPlayer(ply) then
						local class = effect:GetClass()

						entering[class] = entering[class] or {}
						entering[class][effect] = true

						classes[class] = true
					end
				end
			end
		end

		-- Build exiting table based on effects that are in the stack but not in the entering list
		for class, entities in pairs(stack) do
			for _, effect in ipairs(entities) do
				if not IsValid(effect) or not entering[class] or not entering[class][effect] then
					exiting[class] = exiting[class] or {}
					exiting[class][effect] = true
					classes[class] = true
				end
			end
		end

		-- Create a new stack
		for class in pairs(classes) do
			local lookup = {}
			local newStack = {}

			-- Add entries that are on the old stack and we're not leaving
			if stack[class] then
				for _, effect in ipairs(stack[class]) do
					if exiting[class] and exiting[class][effect] then
						continue
					end

					table.insert(newStack, effect)

					lookup[effect] = true
				end
			end

			-- Don't add duplicate effects
			if entering[class] then
				for effect in pairs(entering[class]) do
					if lookup[effect] then
						continue
					end

					table.insert(newStack, effect)
				end
			end

			table.sort(newStack, function(a, b)
				return a:GetZOrder() > b:GetZOrder()
			end)

			stack[class] = newStack
		end

		-- Call enter/exit hooks and set active stack entity
		for class, entities in pairs(stack) do
			local current = active[class]
			local target = entities[1]

			if current != target then
				if IsValid(current) then
					current:Exit(ply, target != nil)
				end

				if IsValid(target) then
					target:Enter(ply, current != nil)
				end

				active[class] = target
			end
		end

		data.LastPos = ply:GetPos()
	end

	for ply in pairs(PlayerData) do
		if not IsValid(ply) then
			PlayerData[ply] = nil
		end
	end
end)

if CLIENT then
	hook.Add("PostDrawTranslucentRenderables", "cc2.Zones", function(depth, skybox)
		if skybox then
			return
		end

		if not lp:EditMode() then
			return
		end

		for shape in pairs(Shapes) do
			shape:DrawShape()
		end
	end)
end
