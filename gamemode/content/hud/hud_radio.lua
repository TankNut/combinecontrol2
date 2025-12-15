HUD.Name = "Legacy Radio"

HUD.Setting = "LegacyRadio"

HUD.Height    = ui.Scale(16)
HUD.MaxHeight = HUD.Height * 15.25

HUD.Position = {}
HUD.Color    = Color(255, 255, 255)

HUD.BufferSize = 0
HUD.Buffer     = {}

function HUD:Initialize()
	self:SetupPosition()

	hook.Add("OnChatScaleSettingChanged", self, function(_, _, _, scale)
		jank(function() self:SetupPosition(scale) end)
	end)
end

function HUD:SetupPosition(scale)
	local x, y = ui.Get("Chat"):GetPos()
	local offset = ui.Scale(15)

	self.Position[1] = x + offset
	self.Position[2] = y - offset

	self.Scale = scale or 1
end

function HUD:WrapText(text)
	local limit, index, lines = ui.Scale(75) * self.Scale, 1, 1

	return text:gsub("(%s+)()(%S+)()", function(separator, startPos, word, endPos)
		if endPos - index > limit then
			index = startPos
			lines = lines + 1

			return string.format("\n%s", word)
		else
			return string.format("%s%s", separator, word)
		end
	end), lines
end

function HUD:AddMessage(text, font)
	local wrappedText, lines = self:WrapText(text)
	local data = {
		Text        = wrappedText,
		Lines       = lines,
		Font        = font,
		ReceiveTime = CurTime()
	}

	table.insert(self.Buffer, data)
	self.BufferSize = self.BufferSize + (self.Height * lines)

	while self.BufferSize > self.MaxHeight do
		local data = table.remove(self.Buffer, 1)

		self.BufferSize = self.BufferSize - (self.Height * data.Lines)
	end
end

function HUD:Paint(w, h)
	local height, pos = self.Height, self.Position
	local color = self.Color
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

		y = y - (height * data.Lines)

		draw.DrawText(data.Text, data.Font, x, y, color)
	end
end
