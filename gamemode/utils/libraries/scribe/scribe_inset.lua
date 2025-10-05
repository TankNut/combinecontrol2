local COMPONENT = {
	Name = {"iset", "inset"}
}

function COMPONENT:Initialize(inset)
	self.Inset = tonumber(inset)
end

function COMPONENT:Push()
	self:AddRenderHook()
end

function COMPONENT:Pop()
	self:RemoveRenderHook()
end

function COMPONENT:PreDrawText(part, data)
	if self.Context.Caret.x == 0 then
		data.x = data.x + self.Inset
		data.w = data.w + self.Inset
	end
end

scribe.Register(COMPONENT)
