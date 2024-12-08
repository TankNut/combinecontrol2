ITEM.Actions.Pickup = {
	ServerOnly = true,
	Validate = function(self, ply)
		return hook.Run("CanPickupItem", ply, self)
	end,
	Callback = function(self, ply)
		self:SetInventory(ply:GetInventory())
	end
}

ITEM.Actions.Drop = {
	Validate = function(self, ply)
		return hook.Run("CanDropItem", ply, self)
	end,
	Callback = function(self, ply)
		self:SetWorldItem(ply:EyePos(), ply:EyeAngles(), false)
	end
}

ITEM.Actions.Destroy = {
	Validate = function(self, ply)
		return hook.Run("CanDestroyItem", ply, self)
	end,
	Callback = function(self, ply)
		self:Delete()
	end
}

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

function ITEM:CanRunAction(ply, name, ...)
	local action = self:GetActions()[name]

	if not action then
		return false, string.format("No action with name '%s' exists!", name)
	end

	return self:ValidateAction(ply, action, ...)
end

function ITEM:ValidateAction(ply, action, ...)
	if action.Validate then
		return action.Validate(self, ply, ...)
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

function ITEM:HandleClientAction(ply, name, action, ...)
	assert(not action.ServerOnly, "Attempt to run SERVER only action on CLIENT")

	local ok, err = self:ValidateAction(ply, action, ...)

	if not ok then
		if err then
			SendLocalChat("ERROR", err)
		end

		return
	end

	if action.ClientOnly then
		action.Client(self, ply, ...)
	else
		netstream.Send("ItemAction", self.ID, name, action.Client and action.Client(self, ply, ...) or ...)
	end
end

function ITEM:HandleServerAction(ply, name, action, ...)
	assert(not action.ClientOnly, "Attempt to run CLIENT only action on SERVER")

	local ok, err = self:ValidateAction(ply, action, ...)

	if not ok then
		if err then
			ply:SendChat(nil, "ERROR", err)
		end

		return
	end

	action.Callback(self, ply, ...)
end

if SERVER then
	function ITEM:OnWorldUse(ply)
		self:RunAction(ply, "Pickup")
	end
end
