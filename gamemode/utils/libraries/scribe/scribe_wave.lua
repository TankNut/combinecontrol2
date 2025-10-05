local COMPONENT = {
	Name = {"wave"}
}

function COMPONENT:Initialize(args)
	args = string.Explode("[,%s]", args, true)

	self.Mult = tonumber(args[1]) or 1
	self.Offset = tonumber(args[2]) or 0.1
	self.Speed = tonumber(args[3]) or 1
end

function COMPONENT:Push()
	self.Context:PushComplex()
	self:AddRenderHook()
end

function COMPONENT:Pop()
	self:RemoveRenderHook()
	self.Context:PopComplex()
end

local matrix = Matrix()

function COMPONENT:PreDrawText(part, data)
	matrix:SetField(2, 4, math.sin(((part.RenderIndex * self.Offset) + CurTime()) * self.Speed) * self.Mult)

	cam.PushModelMatrix(matrix, true)
end

function COMPONENT:PostDrawText(part, data)
	cam.PopModelMatrix()
end

scribe.Register(COMPONENT)
