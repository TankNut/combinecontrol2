module("Action", package.seeall)

List = List or {}

function Add(id, data)
	data.Name = data.Name or id
	data.ID = id

	List[id] = data
end

local PLAYER = FindMetaTable("Player")

function PLAYER:CanRunAction(name)
	local action = List[name]

	if not action then
		return false
	end

	if action.CanRun then
		local ok = action.CanRun(self)

		if not ok then
			return false
		end
	end

	return true
end

function PLAYER:RunAction(name, ...)
	local feedback = function(err, ...)
		if not err then
			return
		end

		self:SendChat("ERROR", string.format(err, ...))
	end

	local action = List[name]

	if not action then
		feedback("No action with id '%s' exists!", name)

		return
	end

	local args = {...}

	local function check()
		if action.CanRun then
			local ok, err = action.CanRun(self)

			if not ok then
				feedback(err)

				return true
			end
		end

		-- We only validate on the client if we're never running server code (ClientOnly), or we're not bothering with action.Client (which might pass different values along)
		local shouldValidate = CLIENT and (action.ClientOnly or not action.Client) or SERVER

		if action.Validate and shouldValidate then
			local ok, err = action.Validate(self, unpack(args))

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
			local data = action.Progress(self, unpack(args))

			if data then
				data.Validate = data.Validate or {}

				table.insert(data.Validate, check)

				local val = progress.Start(self, data)

				if val and val != 1 then
					return
				end
			end
		end

		if CLIENT then
			self:HandleClientAction(name, action, unpack(args))
		else
			self:HandleServerAction(name, action, unpack(args))
		end
	end)
end

if CLIENT then
	function PLAYER:GetActionMenuData(context)
		local actions = {}

		for name, action in pairs(List) do
			if action.ServerOnly then
				continue
			end

			if action.Hidden then
				continue
			end

			if action.Context != context then
				continue
			end

			if action.CanRun and not action.CanRun(self) then
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

		local menuData = {}

		for _, action in ipairs(actions) do
			local options = action.SubOptions

			if isfunction(options) then
				options = action.SubOptions(self)
			end

			if options then
				if #options == 0 then
					continue
				end

				for _, sub in ipairs(options) do
					table.insert(menuData, {
						Name = string.format("%s/%s", action.Name, sub.Name),
						Callback = function()
							self:RunAction(action.ID, sub.Value)
						end
					})
				end
			else
				table.insert(menuData, {
					Name = action.Name,
					Callback = function()
						self:RunAction(action.ID)
					end
				})
			end
		end

		return menuData
	end

	function PLAYER:HandleClientAction(name, action, ...)
		assert(not action.ServerOnly, "Attempt to run SERVER only action on CLIENT")

		if action.ClientOnly then
			local ok, err = action.Client(self, ...)

			if not ok and err then
				self:SendChat("ERROR", err)
			end
		else
			if action.Client then
				local args = {action.Client(self, ...)}

				if not table.remove(args, 1) and args[1] then
					self:SendChat("ERROR", args[1])

					return
				end

				netstream.Send("PlayerAction", name, unpack(args))
			else
				netstream.Send("PlayerAction", name, ...)
			end
		end
	end
else
	function PLAYER:HandleServerAction(name, action, ...)
		assert(not action.ClientOnly, "Attempt to run CLIENT only action on SERVER")

		local ok, err = action.Callback(self, ...)

		if not ok and err then
			self:SendChat("ERROR", err)
		end
	end

	netstream.Hook("PlayerAction", function(ply, id, name, ...)
		local action = List[name]

		if not action then
			return
		end

		if action.ServerOnly then
			ply:SendChat("ERROR", "You cannot run this command from your client!")

			return
		end

		ply:RunAction(name, ...)
	end)
end
