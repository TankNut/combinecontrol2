local PANEL = {}

function PANEL:Init()
	self.Dropdown = self:Add("DComboBox")
	self.Dropdown:DockMargin(0, 1, 0, 1)
	self.Dropdown:Dock(LEFT)
	self.Dropdown:SetWide(200)
	self.Dropdown:SetSortItems(false)

	self.Dropdown.OnSelect = function(_, _, _, option)
		self:SaveSetting(option)
	end
end

function PANEL:ApplySetting(selection)
	for index, data in ipairs(self.Setting.Args) do
		local value = data[2] != nil and data[2] or data[1]

		if value == selection then
			self.Dropdown:ChooseOptionID(index)
		end
	end
end

function PANEL:Setup(options)
	for index, data in ipairs(self.Setting.Args) do
		self.Dropdown:AddChoice(data[1], data[2])
	end
end

derma.DefineControl("CC_Setting_Dropdown", "", PANEL, "CC_Setting")
