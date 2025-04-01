DEFINE_BASECLASS("EditablePanel")

local PANEL = {}

function PANEL:Init()
	-- Not CC_Frame derived so we have to manually set this
	self:SetSkin("CombineControl")

	self:SetCloseOnPause(true)

	self:ResizeWithScale(1.0)
	self:MakePopup()

	self.Scroll = self:Add("CC_ChatScroll")
	self.Scroll:Dock(FILL)
	self.Scroll:DockMargin(10, 5, 10, 5)

	local topBar = self:Add("Panel")
	topBar:Dock(TOP)
	topBar:DockMargin(10, 10, 10, 5)
	topBar:SetTall(20)

	self.Tabs = cookie.GetNumber("cc_chat_tabs", 0)
	self.Buttons = {}

	local tabs = {
		{"LOOC", 	TAB_LOOC},
		{"OOC",		TAB_OOC},
		{"IC",		TAB_IC},
		{"Admin",	TAB_ADMIN},
		{"PM",		TAB_PM},
		{"Radio",	TAB_RADIO}
	}

	for _, v in pairs(tabs) do
		local button = topBar:Add("DButton")

		button:SetFont("CombineControl.LabelSmall")
		button:SetText(v[1])
		button:Dock(LEFT)
		button:DockMargin(0, 0, 5, 0)

		button.SkinVar = "Active"
		button.SkinInverted = true

		button.Active = self:CanSeeTab(v[2])
		button.Tab = v[2]

		button.DoClick = function(pnl)
			pnl.Active = not pnl.Active
			pnl:SetTextColor(nil)

			self:SaveTabConfig()
		end

		table.insert(self.Buttons, button)
	end

	self.Input = self:Add("CC_ChatInput")
	self.Input:Dock(BOTTOM)
	self.Input:DockMargin(10, 5, 10, 10)
	self.Input:SetTall(20)

	self.CloseButton = topBar:Add("DButton")
	self.CloseButton:SetFont("marlett")
	self.CloseButton:SetText("r")
	self.CloseButton:Dock(RIGHT)
	self.CloseButton:SetWide(20)

	self.CloseButton.DoClick = function(pnl)
		self:Close()
	end

	hook.Add("OnChatScaleSettingChanged", self, function(_, _, old, new)
		self:ResizeWithScale(new)
	end)
end

function PANEL:ResizeWithScale(multiplier)
	local scaleW, scaleH = 200,	133 -- Magic values from TankNut :smilecat:
	multiplier = multiplier or 1.0

	BaseClass.SetSize(self, ScreenScale(scaleW) * multiplier, ScreenScaleH(scaleH) * multiplier)

	self:SetPos(20, ScrH() - self:GetTall() - 200)
end

function PANEL:Close()
	self:OnClose()
end

function PANEL:OnClose()
	Chat.Hide()
end

function PANEL:SaveTabConfig()
	local val = 0

	for _, v in pairs(self.Buttons) do
		if not v.Active then
			val = val + v.Tab
		end
	end

	self.Tabs = val

	cookie.Set("cc_chat_tabs", val)
end

function PANEL:CanSeeTab(tab)
	if not tab then
		return true
	end

	return not tobool(bit.band(self.Tabs, tab))
end

function PANEL:AddMessage(message, consoleMessage, tabs)
	self.Scroll:AddMessage(message, consoleMessage, tabs)

	if tabs then
		for _, button in pairs(self.Buttons) do
			if tobool(bit.band(button.Tab, tabs)) and not button.Active then
				button:SetTextColor(self:GetSkin().Text.Primary)
			end
		end
	end
end

-- We explicitly don't call back to normal show/hide since we don't want to hide everything
-- most notably we want to keep the canvas around so we can draw chat without too much extra work

function PANEL:Show()
	self.IsOpen = true

	self:SetKeyboardInputEnabled(true)
	self:SetMouseInputEnabled(true)

	self.Scroll:Show()

	self.Input:Show()
	self.Input:RequestFocus()
	self.Input.HistoryIndex = 0

	for _, v in pairs(self.Buttons) do
		v:Show()
	end

	self.CloseButton:Show()
end

function PANEL:Hide()
	self.IsOpen = false

	self:SetKeyboardInputEnabled(false)
	self:SetMouseInputEnabled(false)

	self.Scroll:Hide()

	self.Input:Hide()
	self.Input:SetText("")

	for _, v in pairs(self.Buttons) do
		v:Hide()
	end

	self.CloseButton:Hide()
end

function PANEL:ExportBuffer()
	return {
		self.Scroll.Buffer,
		self.Scroll.BufferSize,
		self.IsOpen,
		self.Scroll.VBar:GetScroll(),
		self.Input:GetText(),
		self.Input.History,
		self.Input.HistoryIndex
	}
end

function PANEL:ImportBuffer(buffer)
	self.Scroll.Buffer = buffer[1]
	self.Scroll.BufferSize = buffer[2]

	self.Scroll:InvalidateLayout()

	if buffer[3] then
		self:Show()
		self.Scroll.VBar:SetScroll(buffer[4])
	end

	self.Input:SetText(buffer[5] or "")
	self.Input.History = buffer[6]
	self.Input.HistoryIndex = buffer[7]
end

function PANEL:Paint(w, h)
	if self.IsOpen then
		derma.SkinHook("Paint", "Chat", self, w, h)
	end
end

derma.DefineControl("GUI_Chat", "", PANEL, "EditablePanel")

GUI.Register("Chat", function()
	local panel = vgui.Create("GUI_Chat")

	panel:Hide()

	return panel
end, true)
