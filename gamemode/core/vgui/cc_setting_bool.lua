local PANEL = {}

function PANEL:Init()
	self.CheckBox = self:Add("DCheckBox")
	self.CheckBox.OnChange = function(_, bool)
		self:SaveSetting(bool)
	end
end

function PANEL:ApplySetting(value)
	self.CheckBox:SetChecked(value)
end

function PANEL:PerformLayout(w, h)
	self.CheckBox:MoveRightOf(self.Label, 5)
	self.CheckBox:CenterVertical(0.5)
end

derma.DefineControl("CC_Setting_Bool", "", PANEL, "CC_Setting")
