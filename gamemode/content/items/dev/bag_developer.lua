ITEM.Base = "base_container"

ITEM.Name = "Bag of Holding"
ITEM.Description = "This bag has an interior space considerably larger than it's outside dimensions"

ITEM.Rarity = RARITY_DEVELOPER

ITEM.Model = Model("models/props_junk/garbage_bag001a.mdl")
ITEM.Color = Color(95, 63, 127)

ITEM.BaseWeight = 5
ITEM.MaxWeight = 500

ITEM.IconAngle = Angle(75, -80, 90)
ITEM.IconFOV = 14

-- We get to feel special and don't have to worry about how much our contents weigh
function ITEM:GetWeight()
	return self:GetData("BaseWeight", self.BaseWeight)
end
