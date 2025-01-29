DEFINE_BASECLASS("CC_Frame")

local PANEL = {}

function PANEL:Init()
	self:SetSize(300, 90)
	self:SetDraggable(true)

	self.Input = self:Add("DTextEntry")
	self.Input:SetTall(30)
	self.Input:SetFont("CombineControl.LabelBig")

	self.Input:SetUpdateOnType(true)

	self.Input.OnEnter = function()
		if self:CheckInput() then
			async.Handle(self.Coroutine, self:GetValue())

			self:Remove()
		end
	end

	self.Input.OnValueChange = function(_, val)
		self:CheckInput()
	end

	self.ErrorText = self:Add("DLabel")
	self.ErrorText:SetTextColor(Color("cc_bad"))
	self.ErrorText:SetContentAlignment(4)
	self.ErrorText:SetTextInset(2, 0)
	self.ErrorText:SetWrap(true)

	self.Submit = self:Add("DButton")
	self.Submit:SetText("Submit")
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

	self.Input:AlignLeft(10)
	self.Input:AlignTop(34)
	self.Input:StretchToParent(nil, nil, 10, nil)

	self.Submit:AlignBottom(10)
	self.Submit:AlignRight(10)

	self.ErrorText:AlignLeft(10)
	self.ErrorText:MoveBelow(self.Input, 5)
	self.ErrorText:StretchRightTo(self.Submit, 5)
	self.ErrorText:StretchToParent(nil, nil, nil, 10)
end

derma.DefineControl("GUI_Input_Text", "", PANEL, "CC_Frame")

PANEL = {}

function PANEL:Init()
	self.Input:SetNumeric(true)
end

function PANEL:GetValue()
	return tonumber(self.Input:GetValue())
end

derma.DefineControl("GUI_Input_Number", "", PANEL, "GUI_Input_Text")

PANEL = {}

function PANEL:Init()
	self:SetTall(500)

	self.Input:SetTall(220)
	self.Input:SetFont("CombineControl.LabelSmall")
	self.Input:SetMultiline(true)
end

derma.DefineControl("GUI_Input_Multiline", "", PANEL, "GUI_Input_Text")

GUI.Register("Input", function(subtype, title, data)
	local panel

	if subtype == "string" then
		panel = vgui.Create("GUI_Input_Text")
	elseif subtype == "number" then
		panel = vgui.Create("GUI_Input_Number")
	elseif subtype == "multiline" then
		panel = vgui.Create("GUI_Input_Multiline")
	end

	panel:SetCloseOnPause(true)

	panel:SetTopBar(title)
	panel:Setup(data)

	panel:MakePopup()
	panel:Center()

	return coroutine.yield()
end)
