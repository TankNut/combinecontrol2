local meta = FindMetaTable("Player")

CharacterVar.Add("Money", {
	Default = "",
	Private = true,
	DataType = INT()
})

function meta:HasMoney(amt)
	return self:CharacterMoney() >= amt
end

function meta:AddMoney(amt)
	self:SetMoney(self:CharacterMoney() + amt)
end

function meta:SetMoney(amt)
	self:SetCharacterMoney(math.max(amt, 0))
end
