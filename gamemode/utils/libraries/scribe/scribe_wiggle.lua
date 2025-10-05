local COMPONENT = {
	Name = {"wiggle"}
}

function COMPONENT:Initialize(args)
	args = string.Explode("[,%s]", args, true)

	self.Mult = tonumber(args[1]) or 1
	self.Chance = tonumber(args[2]) or 100
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
	if math.Maybe(self.Chance) then
		matrix:SetField(1, 4, math.Rand(-self.Mult, self.Mult))
		matrix:SetField(2, 4, math.Rand(-self.Mult, self.Mult))
	else
		matrix:SetField(1, 4, 0)
		matrix:SetField(2, 4, 0)
	end

	cam.PushModelMatrix(matrix, true)
end

function COMPONENT:PostDrawText(part, data)
	cam.PopModelMatrix()
end

scribe.Register(COMPONENT)
