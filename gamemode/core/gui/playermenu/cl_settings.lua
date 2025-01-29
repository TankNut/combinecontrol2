local PANEL = {}

function PANEL:Init()
	self.CategoryList = self:Add("DScrollPanel")
	self.CategoryList:Dock(FILL)

	self:Populate()
end

function PANEL:Populate()
	self.CategoryList:Clear()

	for _, category in ipairs(Settings.Categories) do
		local panel = self.CategoryList:Add("CC_Settings_Category")

		panel:Dock(TOP)
		panel:Setup(category)
	end
end

derma.DefineControl("CC_PlayerMenu_Settings", "", PANEL, "Panel")
