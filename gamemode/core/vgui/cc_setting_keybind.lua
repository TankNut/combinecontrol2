local PANEL = {}

function PANEL:Init()
	self.DBinder = self:Add("DBinder")
	self.DBinder.OnChange = function(_, key)
		self:SaveSetting(key)
	end
	self.DBinder.UpdateText = function(binder)
		local str = input.GetKeyName(binder:GetSelectedNumber())

		if not str then
			str = "NONE"
		else
			str = string.upper(language.GetPhrase(str))
		end

		binder:SetText(str)
	end
end

function PANEL:ApplySetting(value)
	self.DBinder:SetValue(value)
end

function PANEL:PerformLayout(w, h)
	self.DBinder:MoveRightOf(self.Label, 5)
	self.DBinder:CenterVertical(0.5)
	self.DBinder:SetTall(20)
	self.DBinder:SetWide(100)
end

derma.DefineControl("CC_Setting_Keybind", "", PANEL, "CC_Setting")
