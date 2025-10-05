local COMPONENT = {
	Name = {"ol", "outline"}
}

local black = Color(0, 0, 0)

function COMPONENT:Initialize(width)
	self.Width = tonumber(width) or true
end

function COMPONENT:Push()
	self:AddRenderHook()
end

function COMPONENT:Pop()
	self:RemoveRenderHook()
end

function COMPONENT:PreDrawText(part, data)
	local color = self.Context.Color

	self.Context:SetColor(black)

	if self.Width == true then
		self:DrawText(data.Text, data.x + 1, data.y + 1, true)
	else
		data.w = data.w + self.Width * 2
		data.h = data.h + self.Width * 2

		data.x = data.x + self.Width
		data.y = data.y + self.Width

		local steps = math.max((self.Width * 2) / 3, 1)

		for _x = -self.Width, self.Width, steps do
			for _y = -self.Width, self.Width, steps do
				self:DrawText(data.Text, data.x + _x, data.y + _y, true)
			end
		end
	end

	self.Context:SetColor(color)
end

scribe.Register(COMPONENT)
