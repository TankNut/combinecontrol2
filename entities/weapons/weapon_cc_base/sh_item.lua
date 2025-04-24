AddCSLuaFile()

function SWEP:GetItem()
	local id = self:GetItemID()

	if id == 0 then
		return
	end

	return Item.Get(id)
end

if SERVER then
	function SWEP:QueueItemSave()
	end

	function SWEP:LoadState(data)
	end

	function SWEP:SaveState()
		return {}
	end
end
