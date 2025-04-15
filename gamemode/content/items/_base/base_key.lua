ITEM.Internal = true

ITEM.Category = "Key"

ITEM.Model = Model("models/gibs/metal_gib4.mdl")

ITEM.KeyType = KEY_BOTH
ITEM.KeyID   = ""

function ITEM:GetKeyType()
	return self:GetData("KeyType", self.KeyType)
end

function ITEM:GetKeyID()
	return self:GetData("KeyID", self.KeyID)
end

function ITEM:TryKey(keyType, id)
	local ourType = self:GetKeyType()

	if ourType != KEY_BOTH and ourType != keyType then
		return false
	end

	local key = "^" .. string.Replace(self:GetKeyID(), "*", ".*") .. "$"

	return tobool(string.find(id, key))
end
