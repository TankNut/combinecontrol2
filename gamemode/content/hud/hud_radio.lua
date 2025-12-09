HUD.Name = "Legacy Radio"

HUD.Setting = "LegacyRadio"

HUD.Height    = ui.Scale(16)
HUD.MaxHeight = HUD.Height * 15.25

HUD.Position  = {}
HUD.TextColor = Color(255, 255, 255)

HUD.BufferSize = 0
HUD.Buffer     = {}

function HUD:Initialize()
	self:SetupPosition()

	hook.Add("OnChatScaleSettingChanged", self, function()
		jank(function() self:SetupPosition() end)
	end)
end

function HUD:SetupPosition()
	local x, y = ui.Get("Chat"):GetPos()
	local offset = ui.Scale(15)

	self.Position[1] = x + offset
	self.Position[2] = y - offset
end

function HUD:AddMessage(text, font)
	local data = {
		Text        = text,
		LegacyFont  = font,
		ReceiveTime = CurTime()
	}

	table.insert(self.Buffer, data)
	self.BufferSize = self.BufferSize + self.Height

	while self.BufferSize > self.MaxHeight do
		local line = table.remove(self.Buffer, 1)

		self.BufferSize = self.BufferSize - self.Height
	end
end

function HUD:Paint(w, h)
	local color, height, pos = self.TextColor, self.Height, self.Position
	local x, y = pos[1], pos[2]
	local time = CurTime()

	for i = #self.Buffer, 1, -1 do
		local data = self.Buffer[i]
		local lifetime = time - data.ReceiveTime
		local alpha = 255

		if lifetime >= 15 then
			break -- All other messages are assumed to be older, no need to iterate them
		else
			alpha = (15 - lifetime) * 0.2 * 255
		end

		color.a = alpha

		y = y - height

		draw.SimpleText(data.Text, data.LegacyFont, x, y, color)
	end
end
