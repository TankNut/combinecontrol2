-- You shouldn't touch these vars, they contain most of the source features doors have and are tracked/updated manually within the doors library itself
Doors.AddVar("Locked", {
	Mode = DOOR_MASTER,
	Saved = true,
	Get = function(self) return self:_DoorLocked() end,
	Set = function(self, val) self:Fire(val and "lock" or "unlock") end
})

Doors.AddVar("Usable", {
	Mode = DOOR_SEPARATE,
	NoProp = true,
	Saved = true,
	Get = function(self) return self:_DoorUsable() end,
	Set = function(self, val)
		val = tobool(val)

		if val then
			self:AddSpawnFlags(256)
		else
			self:RemoveSpawnFlags(256)
		end

		self:Set_DoorUsable(val)
	end
})

Doors.AddVar("Touchable", {
	Mode = DOOR_SEPARATE,
	NoProp = true,
	Saved = true,
	Get = function(self) return self:_DoorTouchable() end,
	Set = function(self, val)
		val = tobool(val)

		if val then
			self:AddSpawnFlags(1024)
		else
			self:RemoveSpawnFlags(1024)
		end

		self:Set_DoorTouchable(val)
	end
})

Doors.AddVar("Toggle", {
	Mode = DOOR_MASTER,
	NoProp = true,
	Saved = true,
	Get = function(self) return self:_DoorToggle() end,
	Set = function(self, val)
		val = tobool(val)

		if val then
			self:AddSpawnFlags(self:IsPropDoor() and 8192 or 32)
		else
			self:RemoveSpawnFlags(self:IsPropDoor() and 8192 or 32)
		end

		self:Set_DoorToggle(val)
	end
})

Doors.AddVar("AutoClose", {
	Mode = DOOR_BOTH,
	Saved = true,
	Get = function(self) return self:_DoorAutoClose() end,
	Set = function(self, val)
		if val == false then
			val = -1
		end

		self:SetKeyValue(self:IsPropDoor() and "returndelay" or "wait", val)
		self:Set_DoorAutoClose(val)
	end
})

Doors.AddVar("Speed", {
	Mode = DOOR_BOTH,
	Saved = true,
	Get = function(self) return self:_DoorSpeed() end,
	Set = function(self, val)
		self:SetKeyValue("speed", val)
		self:Set_DoorSpeed(val)
	end
})

Doors.AddVar("ForceClose", {
	Mode = DOOR_MASTER,
	NoProp = true,
	Saved = true,
	Get = function(self) return self:_DoorForceClose() end,
	Set = function(self, val)
		val = tobool(val)

		self:SetKeyValue("forceclosed", val and 1 or 0)
		self:Set_DoorForceClose(val)
	end
})

Doors.AddVar("Damage", {
	Mode = DOOR_BOTH,
	Saved = true,
	Get = function(self) return self:_DoorDamage() end,
	Set = function(self, val)
		self:SetKeyValue("dmg", val)
		self:Set_DoorDamage(val)
	end
})

Doors.AddVar("Group", {
	Mode = DOOR_BOTH,
	Saved = true,
	Get = function(self) return self:_DoorGroup() end,
	Set = function(self, val)
		self:Set_DoorGroup(string.Trim(val))
	end,
})

Doors.AddVar("Type", {
	Mode = DOOR_BOTH,
	Saved = true,
	Get = function(self) return self:_DoorType() end,
	Set = function(self, val)
		self:Set_DoorType(string.Trim(val))
	end,
})
