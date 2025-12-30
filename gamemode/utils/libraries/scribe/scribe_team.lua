local COMPONENT = {
	Name = {"team"}
}

function COMPONENT:Initialize(index)
	self.Color = team.GetColor(tonumber(index))
end

function COMPONENT:Push()
	self.Context:PushColor(self.Color)
end

function COMPONENT:Pop()
	self.Context:PopColor()
end

scribe.Register(COMPONENT)
