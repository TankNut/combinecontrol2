local PANEL = {}

function PANEL:Init()
	self:SetFont("CombineControl.LabelBig")
	self:SetUpdateOnType(true)

	self.MultiLine = false
	self.m_bLoseFocusOnClickAway = false

	self.History = {}
	self.HistoryIndex = 0
end

function PANEL:OnKeyCodeTyped(code)
	self:OnKeyCode(code)

	if code == KEY_ENTER then
		self:OnEnter()

		return true
	elseif code == KEY_UP or code == KEY_DOWN then
		self:CycleChatHistory(code)

		return true
	end
end

function PANEL:CycleChatHistory(code)
	if code == KEY_UP and self.HistoryIndex == 1 then
		return
	elseif code == KEY_DOWN and self.HistoryIndex == 0 then
		return
	elseif code == KEY_UP and self.HistoryIndex == 0 then
		self.Backup = self:GetText()
	end

	local change = (code == KEY_DOWN) and 1 or -1
	local index = (self.HistoryIndex + change) % (#self.History + 1)
	local text

	if index == 0 then
		text = self.Backup
		self.Backup = nil
	else
		text = self.History[index]
	end

	self:SetText(text)

	self:SetCaretPos(#text)
	self:UpdateHeight(text)
	self.HistoryIndex = index
end

function PANEL:OnValueChange(str)
	self:UpdateHeight(str)

	local _, cmd, args = Chat.Process(lp, str)
	local command = Chat.Commands[cmd]

	if not command or not command.Typing or #args < 1 or args == "/" then
		cmd = nil
	end

	if cmd != lp:Typing() then
		lp:SetTyping(cmd)

		netstream.Send("Typing", cmd)
	end
end

function PANEL:UpdateHeight(str)
	local multi = Settings.Get("ExpandChatInput")
	local height = self:GetTall()
	local target = ui.Scale(20)

	if multi != self.MultiLine then
		self:SetMultiline(multi)
		self.MultiLine = multi
	end

	if not multi then
		if height != target then
			self:SetTall(target)
		end

		return
	end

	local font = self:GetFont()
	local maxWidth = self:GetWide() - 6

	local acc = 0
	local lines = 1

	for _, code in utf8.codes(str) do
		local char = utf8.char(code)
		local w = surface.GetFontSize(font, char)

		if acc + w > maxWidth then
			lines = lines + 1
			acc = 0
		end

		acc = acc + w
	end

	local targetHeight = math.max(lines * target, target)

	if height != targetHeight then
		self:SetTall(targetHeight)
	end
end

function PANEL:OnEnter()
	local str = self:GetText()

	if #str == 0 then
		Chat.Hide()

		return
	end

	if #self.History > 100 then
		table.remove(self.History, 1)
	end

	table.insert(self.History, str)

	Chat.Parse(lp, str)
	Chat.Hide()
end

function PANEL:AllowInput(char)
	if #self:GetValue() > Config.Get("ChatLimit") then
		surface.PlaySound("weapons/pistol/pistol_empty.wav")

		return true
	elseif char == input.LookupBinding("toggleconsole") then
		return true
	end
end

vgui.Register("CC_ChatInput", PANEL, "DTextEntry")
