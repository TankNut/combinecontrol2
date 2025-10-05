local COMPONENT = {
	Name = {"lang"}
}

function COMPONENT:Initialize(inset)
	self.Inset = tonumber(inset)
end

function COMPONENT:Push()
	self:AddTextModifier()
end

function COMPONENT:Pop()
	self:RemoveTextModifier()
end

function COMPONENT:ModifyText(part, text)
	return language.GetPhrase(text)
end

scribe.Register(COMPONENT)
