local COMPONENT = {
	Name = {"stutter"}
}

function COMPONENT:Initialize(chance)
	self.Chance = tonumber(chance) or 100
end

function COMPONENT:Push()
	self:AddTextModifier()
end

function COMPONENT:Pop()
	self:RemoveTextModifier()
end

local gibberish = {"#", "@", "&", "%", "$", "/", "<", ">", ";", "*", "*", "*", "*", "*", "*", "*", "*"}
local textEffects = {
	upper = function(char) return string.upper(char) end,
	gibberish = function() return gibberish[math.random(#gibberish)] end
}

function COMPONENT:ModifyText(part, text)
	local str = string.Explode("", text)

	for index, char in ipairs(str) do
		if math.Maybe(1 + 5 * (self.Chance / 15)) then
			str[index] = table.Random(textEffects)(char)
		end
	end

	return table.concat(str)
end

scribe.Register(COMPONENT)
