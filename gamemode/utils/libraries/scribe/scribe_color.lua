local COMPONENT = {
	Name = {"c", "col", "color"}
}

function COMPONENT:Initialize(args)
	args = string.Explode("[,%s]", args, true)

	self.Color = Color(args[1], args[2], args[3], args[4])
end

function COMPONENT:Push()
	self.Context:PushColor(self.Color)
end

function COMPONENT:Pop()
	self.Context:PopColor()
end

scribe.Register(COMPONENT)
