ITEM.Actions = {}

function ITEM:GetActions()
	local cache = Item.ActionCache[self.ClassName]

	if cache then
		return cache
	end

	local actions = {}
	local class = baseclass.Get(self.ThisClass)

	while true do
		local actionTable = rawget(class, "Actions")

		if actionTable then
			for k, v in pairs(actionTable) do
				if not actions[k] then
					actions[k] = v

					v.ID = k

					if not v.Name then
						v.Name = k
					end
				end
			end
		end

		if class.ClassName == "base" then
			break
		end

		class = class.Base and baseclass.Get("item_" .. class.Base) or Item.List.base
	end

	Item.ActionCache[self.ClassName] = actions

	return actions
end

if CLIENT then
	-- Used for generating different listings based on what kind of UI is used, doesn't actually restrict anything
	function ITEM:GetAvailableActions()
		local actions = {}

		for name, action in pairs(self:GetActions()) do
			if action.ServerOnly then
				continue
			end

			if action.Hidden then
				continue
			end

			if action.CanRun and not action.CanRun(self, lp) then
				continue
			end

			table.insert(actions, action)
		end

		table.sort(actions, function(a, b)
			local aPriority = a.Priority or 0
			local bPriority = b.Priority or 0

			if aPriority != bPriority then
				return aPriority > bPriority
			end

			return a.Name < b.Name
		end)

		return actions
	end
end

function ITEM:CanRunAction(ply, name)
	local action = self:GetActions()[name]

	if not action then
		return false, string.format("No action with name '%s' exists!", name)
	end

	if action.CanRun then
		return action.CanRun(self, ply)
	end

	return true
end

function ITEM:RunAction(ply, name, ...)
	local action = self:GetActions()[name]

	if not action then
		return
	end

	local func = CLIENT and self.HandleClientAction or self.HandleServerAction

	async.Start(func, self, ply, name, action, ...)
end

if CLIENT then
	function ITEM:HandleClientAction(ply, name, action, ...)
		assert(not action.ServerOnly, "Attempt to run SERVER only action on CLIENT")

		if action.ClientOnly then
			local ok, err = action.Client(self, ply, ...)

			if not ok and err then
				SendLocalChat("ERROR", err)
			end
		else
			if action.Client then
				local args = {action.Client(self, ply, ...)}

				if not table.remove(args, 1) and args[1] then
					SendLocalChat("ERROR", args[1])

					return
				end

				netstream.Send("ItemAction", self.ID, name, unpack(args))
			else
				netstream.Send("ItemAction", self.ID, name, ...)
			end
		end
	end
else
	function ITEM:HandleServerAction(ply, name, action, ...)
		assert(not action.ClientOnly, "Attempt to run CLIENT only action on SERVER")

		local ok, err = action.Callback(self, ply, ...)

		if not ok and err then
			ply:SendChat(nil, "ERROR", err)
		end
	end

	function ITEM:OnWorldUse(ply)
		self:RunAction(ply, "Pickup")
	end

	netstream.Hook("ItemAction", function(ply, id, name, ...)
		local item = Item.Get(id)

		if not item then
			return
		end

		if not item:CanRunAction(ply, name) then
			return
		end

		local action = item:GetActions()[name]

		if action.ServerOnly then
			return
		end

		item:HandleServerAction(ply, name, action, ...)
	end)
end
