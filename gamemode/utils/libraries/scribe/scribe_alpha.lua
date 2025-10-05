local COMPONENT = {
	Name = {"a", "alpha"}
}

function COMPONENT:Initialize(alpha)
	self.Color = Color(255, 255, 255)
	self.Alpha = tonumber(alpha) or 255
end

function COMPONENT:Push()
	local r, g, b = self.Context.Color:Unpack()

	self.Color:SetUnpacked(r, g, b, self.Alpha)
	self.Context:PushColor(self.Color)
end

function COMPONENT:Pop() self.Context:PopColor() end

scribe.Register(COMPONENT)
