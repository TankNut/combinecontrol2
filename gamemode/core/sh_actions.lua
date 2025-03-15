module("Action", package.seeall)

List = List or {}
Cache = {}

local ENTITY = FindMetaTable("Entity")

--[[
	Action.Add("name", {
		Name = nil, -- Defaults to id, supports util.BuildMenu paths
		ClientOnly = false, -- If set, never sends anything to the server
		ServerOnly = false, -- If set, can only be ran from the server (client networks are ignored)
		Priority = 0, -- Determines sort order in GetActionMenuData, higher numbers appear first

		Admin = false, -- If set, only admins can run this action
		EditMode = false, -- If set, only admins in edit mode can run this action

		Self = false, -- If set, only lets players run this action on themselves
		Interaction = false, -- If set, requires player to be in interaction range (rather than sight range) before they can execute this action
		Context = nil, -- Used in GetActionMenuData to filter what actions to grab, doesn't actually prevent execution otherwise
		Filter = function(class) end, -- Static filter for entity types, used for optimization

		CanRun = function(self, ply) end, -- Additional check to see if this action can be run at all
		SubOptions = function(self, ply) end, -- Lets you return a table of additional options {Name = "Foo", Value = "Bar"} that will generate as sub options with value being fed into RunAction as extra arguments
		Progress = function(self, ply, ...) end, -- Lets you return progress bar data to automatically run one as part of the action
		Validate = function(self, ply, ...) end, -- Used for validating user input either fed into RunAction or returned through Client
		Client = function(self, ply, ...) end, -- Clientside code that is ran, return bool, value
		Callback = function(self, ply, ...) end -- Main serverside code
	})
]]

function Add(id, data)
	data.Name = data.Name or id
	data.ID = id

	List[id] = data
end

function ENTITY:GetActions()
	local ourClass = self:GetClass()
	local cache = Cache[ourClass]

	if cache then
		return cache
	end

	local actions = {}

	for k, action in pairs(List) do
		if action.Filter and not action.Filter(ourClass) then
			continue
		end

		if action.Self and ourClass != "player" then
			continue
		end

		actions[k] = action
	end

	if self.IsCCEntity then
		local class = scripted_ents.GetStored(ourClass).t

		while true do
			local actionTable = rawget(class, "Actions")

			if actionTable then
				for k, action in pairs(actionTable) do
					if not actions[k] then
						actions[k] = action

						action.ID = k

						if not action.Name then action.Name = k end
					end
				end
			end

			if class.ClassName == "cc_base_ent" then
				break
			end

			class = scripted_ents.GetStored(class.Base).t
		end
	end

	Cache[ourClass] = actions

	return actions
end

local function check(self, action, ply)
	if action.Admin and not ply:IsAdmin() then
		return false
	end

	if action.EditMode and not ply:EditMode() then
		return false
	end

	if action.Self then
		if ply != self then
			return false
		end
	else
		local ent, canInteract = ply:GetContextEntity()

		if ent != self or action.Interaction and not canInteract then
			return false
		end
	end

	if action.CanRun then
		local ok = action.CanRun(self, ply)

		if not ok then
			return false
		end
	end

	return true
end

if CLIENT then
	-- Used for generating different listings based on what kind of UI is used, doesn't actually restrict anything
	function ENTITY:GetActionMenuData(context)
		local actions = {}

		for name, action in pairs(self:GetActions()) do
			if action.ServerOnly then
				continue
			end

			if action.Hidden then
				continue
			end

			if action.Context != context then
				continue
			end

			if not check(self, action, lp) then
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
							if IsValid(self) then
								self:RunAction(lp, action.ID, sub.Value)
							end
						end
					})
				end
			else
				table.insert(menuData, {
					Name = action.Name,
					Callback = function()
						if IsValid(self) then
							self:RunAction(lp, action.ID)
						end
					end
				})
			end
		end

		return menuData
	end
end

function ENTITY:CanRunAction(ply, name)
	local action = self:GetActions()[name]

	if not action then
		return false
	end

	return check(self, action, ply)
end

function ENTITY:RunAction(ply, name, ...)
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

	local function validate()
		check(self, action, ply)

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

	if validate() then
		return
	end

	async.Start(function()
		if action.Progress then
			local data = action.Progress(self, ply, unpack(args))

			if data then
				data.Validate = data.Validate or {}

				table.insert(data.Validate, validate)

				local val = progress.Start(ply, data)

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
	function ENTITY:HandleClientAction(ply, name, action, ...)
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

				netstream.Send("EntityAction", self, name, unpack(args))
			else
				netstream.Send("EntityAction", self, name, ...)
			end
		end
	end
else
	function ENTITY:HandleServerAction(ply, name, action, ...)
		assert(not action.ClientOnly, "Attempt to run CLIENT only action on SERVER")

		local ok, err = action.Callback(self, ply, ...)

		if not ok and err then
			ply:SendChat("ERROR", err)
		end
	end

	netstream.Hook("EntityAction", function(ply, ent, name, ...)
		if not IsValid(ent) then
			return
		end

		local action = ent:GetActions()[name]

		if not action then
			return
		end

		if action.ServerOnly then
			ply:SendChat("ERROR", "You cannot run this command from your client!")

			return
		end

		ent:RunAction(ply, name, ...)
	end)
end
