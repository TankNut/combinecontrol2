local COMPONENT = {
	Name = {"f", "font"}
}

function COMPONENT:Initialize(font)
	self.Font = font
end

function COMPONENT:Push()
	self.Context:PushFont(self.Font)
end

function COMPONENT:Pop()
	self.Context:PopFont()
end

scribe.Register(COMPONENT)
