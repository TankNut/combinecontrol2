DEFINE_BASECLASS("CC_Frame")

local PANEL = {}

function PANEL:Init()
	self:SetSize(ui.Scale(300), ui.Scale(90))
	self:SetDraggable(true)

	self.Input = self:Add("DTextEntry")
	self.Input:SetTall(ui.Scale(30))
	self.Input:SetFont("CombineControl.LabelBig")

	self.Input:SetUpdateOnType(true)

	self.Input.OnEnter = function()
		self.Submit:DoClick()
	end

	self.Input.OnValueChange = function(_, val)
		self:CheckInput()
	end

	self.ErrorText = self:Add("DLabel")
	self.ErrorText:SetTextColor(Color("cc_bad"))
	self.ErrorText:SetContentAlignment(4)
	self.ErrorText:SetTextInset(ui.Scale(2), 0)
	self.ErrorText:SetWrap(true)

	self.Submit = self:Add("DButton")
	self.Submit:SetText("Submit")

	self.Submit.DoClick = function()
		if self:CheckInput() then
			async.Handle(self.Coroutine, self:GetValue())

			self:Remove()
		end
	end
end

function PANEL:Setup(data)
	self.Coroutine = coroutine.running()

	self.Validate = data.Validate
	self.Name = data.Name
	self.Input:SetValue(data.Default or "")
end

function PANEL:GetValue()
	return self.Input:GetValue()
end

function PANEL:CheckInput()
	local val = self:GetValue()

	if self.Validate then
		local ok, err = validate.Value(val, self.Validate, self.Name or "Input")

		self.Submit:SetDisabled(not ok)
		self.ErrorText:SetText(not ok and err or "")

		return ok
	end

	return true
end

function PANEL:PerformLayout(w, h)
	BaseClass.PerformLayout(self, w, h)

	local offset = ui.Scale(10)
	local offsetRight = offset * 0.5

	self.Input:AlignLeft(offset)
	self.Input:AlignTop(ui.Scale(34))
	self.Input:StretchToParent(nil, nil, offset, nil)

	self.Submit:AlignBottom(offset)
	self.Submit:AlignRight(offset)

	self.ErrorText:AlignLeft(offset)
	self.ErrorText:MoveBelow(self.Input, offsetRight)
	self.ErrorText:StretchRightTo(self.Submit, offsetRight)
	self.ErrorText:StretchToParent(nil, nil, nil, offset)
end

vgui.Register("GUI_Input_Text", PANEL, "CC_Frame")

PANEL = {}

function PANEL:Init()
	self.Input:SetNumeric(true)
end

function PANEL:GetValue()
	return tonumber(self.Input:GetValue())
end

vgui.Register("GUI_Input_Number", PANEL, "GUI_Input_Text")

PANEL = {}

function PANEL:Init()
	self:SetSize(500, 280)

	self.Input:SetTall(220)
	self.Input:SetFont("CombineControl.LabelSmall")
	self.Input:SetMultiline(true)
end

vgui.Register("GUI_Input_Multiline", PANEL, "GUI_Input_Text")

PANEL = {}

function PANEL:Init()
	self:SetSize(250, 90)
	self:SetDraggable(true)

	self.Submit:Remove()
	self.Input:Remove()
	self.ErrorText:Remove()

	self.Prompt = self:Add("DLabel")
	self.Prompt:SetContentAlignment(4)
	self.Prompt:SetTextInset(2, 0)
	self.Prompt:SetWrap(true)
	self.Prompt:SetAutoStretchVertical(true)

	self.Confirm = self:Add("DButton")
	self.Confirm:SetText("Confirm")
	self.Confirm:SetWide(110)

	self.Confirm.DoClick = function()
		async.Handle(self.Coroutine, true)

		self:Remove()
	end

	self.Cancel = self:Add("DButton")
	self.Cancel:SetText("Cancel")
	self.Cancel:SetWide(110)

	self.Cancel.DoClick = function()
		async.Handle(self.Coroutine, false)

		self:Remove()
	end
end

function PANEL:Setup(data)
	self.Coroutine = coroutine.running()

	self.Prompt:SetText(data.Prompt and data.Prompt or "Are you sure you'd like to do this?")
	self.Confirm:SetText(data.Confirm and data.Confirm or "Confirm")
	self.Cancel:SetText(data.Cancel and data.Cancel or "Cancel")
end

function PANEL:PerformLayout(w, h)
	BaseClass.PerformLayout(self, w, h)

	self.Prompt:AlignLeft(10)
	self.Prompt:AlignTop(34)
	self.Prompt:StretchToParent(nil, nil, 10, 35)

	self.Confirm:AlignBottom(10)
	self.Confirm:AlignRight(10)

	self.Cancel:AlignBottom(10)
	self.Cancel:AlignLeft(10)
end

vgui.Register("GUI_Input_Confirm", PANEL, "GUI_Input_Text")

ui.Register("Input", function(subtype, title, data)
	local panel

	if subtype == "string" then
		panel = vgui.Create("GUI_Input_Text")
	elseif subtype == "number" then
		panel = vgui.Create("GUI_Input_Number")
	elseif subtype == "multiline" then
		panel = vgui.Create("GUI_Input_Multiline")
	elseif subtype == "confirm" then
		panel = vgui.Create("GUI_Input_Confirm")
	end

	panel:SetCloseOnPause()

	panel:SetTopBar(title)
	panel:Setup(data)

	panel:MakePopup()
	panel:Center()

	return coroutine.yield()
end)
