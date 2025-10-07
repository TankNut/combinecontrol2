local PANEL = {}

function PANEL:Init()
	self.Dropdown = self.Canvas:Add("DComboBox")
	self.Dropdown:SetWide(ui.Scale(150))

	self.Dropdown.OnSelect = function(_, _, _, data)
		self:SetOption(data)
	end
end

function PANEL:Setup(options, val)
	for _, option in ipairs(options) do
		self.Dropdown:AddChoice(option.Name, option.Value, val == option.Value)
	end

	if val == nil then
		self.Dropdown:ChooseOptionID(1)
	end
end

vgui.Register("CC_CharCreate_Dropdown", PANEL, "CC_CharCreate")
