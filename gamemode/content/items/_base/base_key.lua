ITEM.Internal = true

ITEM.Rarity    = RARITY_COMMON
ITEM.Category  = "Key"

ITEM.Model     = Model("models/gibs/metal_gib4.mdl")

ITEM.Weight    = 0.1

ITEM.IconAngle = Angle(50, -35, -10)
ITEM.IconFOV   = 6

ITEM.KeyType   = KEY_BOTH
ITEM.KeyID     = ""

ItemDataFunc("KeyType")
ItemDataFunc("KeyID")

function ITEM:TryKey(keyType, id)
	local ourType = self:GetKeyType()

	if ourType != KEY_BOTH and ourType != keyType then
		return false
	end

	local key = "^" .. string.Replace(self:GetKeyID(), "*", ".*") .. "$"

	return tobool(string.find(id, key))
end
