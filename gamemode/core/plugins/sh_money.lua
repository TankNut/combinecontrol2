local PLAYER = FindMetaTable("Player")

CharacterVar.Add("CharacterMoney", {
	Default = 0,
	Private = true,
	Field = "Money",
	DataType = INT()
})

function PLAYER:GetMoney()
	return self:CharacterMoney()
end

function PLAYER:HasMoney(amt)
	return self:CharacterMoney() >= amt
end

function PLAYER:AddMoney(amt)
	self:SetMoney(self:CharacterMoney() + amt)
end

function PLAYER:SetMoney(amt)
	self:SetCharacterMoney(math.max(amt, 0))
end
