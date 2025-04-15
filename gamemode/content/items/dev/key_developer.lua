ITEM.Base = "base_key"

ITEM.Name = "Skeleton Key"
ITEM.Description = "A key that somehow fits every lock"

ITEM.Rarity = RARITY_DEVELOPER

function ITEM:TryKey(keyType, id)
	return true
end
