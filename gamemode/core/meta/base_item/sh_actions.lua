ITEM.Actions = {}

function ITEM:GetActions()
	local cache = Item.ActionCache[self.ClassName]

	if cache then
		return cache
	end

	local actions = {}
	local class = inherit.Get("item", self.ClassName)

	while true do
		local actionTable = rawget(class, "Actions")

		if actionTable then
			for k, v in pairs(actionTable) do
				if not actions[k] then
					actions[k] = v

					v.ID = k

					if not v.Name then v.Name = k end
				end
			end
		end

		if class.ClassName == "base" then
			break
		end

		class = class.Base and inherit.Get("item", class.Base) or inherit.Get("item", "base")
	end

	Item.ActionCache[self.ClassName] = actions

	return actions
end

if CLIENT then
	-- Used for generating different listings based on what kind of UI is used, doesn't actually restrict anything
	function ITEM:GetAvailableActions(context)
		local actions = {}

		for name, action in pairs(self:GetActions()) do
			if action.ServerOnly then
				continue
			end

			local hidden = action.Hidden

			if hidden then
				if hidden == true then
					continue
				end

				if istable(hidden) and hidden[context] then
					continue
				end
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
		return false
	end

	if action.CanRun then
		local ok = action.CanRun(self, ply)

		if not ok then
			return false
		end
	end

	return true
end

function ITEM:RunAction(ply, name, ...)
	local feedback = function(err, ...)
		if not err then
			return
		end

		ply:SendChat("ERROR", string.format(err, ...))
	end

	local action = self:GetActions()[name]

	if not action then
		feedback("No action with id '%s' exists!", name)

		return
	end

	local args = {...}

	local function check()
		if action.CanRun then
			local ok, err = action.CanRun(self, ply)

			if not ok then
				feedback(err)

				return true
			end
		end

		-- We only validate on the client if we're never running server code (ClientOnly), or we're not bothering with action.Client (which might pass different values along)
		local shouldValidate = CLIENT and (action.ClientOnly or not action.Client) or SERVER

		if action.Validate and shouldValidate then
			local ok, err = action.Validate(self, ply, unpack(args))

			if not ok then
				feedback(err)

				return true
			end
		end
	end

	if check() then
		return
	end

	async.Start(function()
		if action.Progress then
			local data = action.Progress(self, ply, unpack(args))

			if data then
				data.Validate = data.Validate or {}

				table.insert(data.Validate, check)

				local val = progress.Start(ply, data)

				print(val, check())

				if val and val != 1 then
					return
				end
			end
		end

		if CLIENT then
			self:HandleClientAction(ply, name, action, unpack(args))
		else
			self:HandleServerAction(ply, name, action, unpack(args))
		end
	end)
end

if CLIENT then
	function ITEM:HandleClientAction(ply, name, action, ...)
		assert(not action.ServerOnly, "Attempt to run SERVER only action on CLIENT")

		if action.ClientOnly then
			local ok, err = action.Client(self, ply, ...)

			if not ok and err then
				lp:SendChat("ERROR", err)
			end
		else
			if action.Client then
				local args = {action.Client(self, ply, ...)}

				if not table.remove(args, 1) and args[1] then
					lp:SendChat("ERROR", args[1])

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
			ply:SendChat("ERROR", err)
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

		local action = item:GetActions()[name]

		if not action then
			return
		end

		if action.ServerOnly then
			ply:SendChat("ERROR", "You cannot run this command from your client!")

			return
		end

		item:RunAction(ply, name, ...)
	end)
end
