local PANEL = {}

function PANEL:Init()
	self.Right = self:Add("Panel")
	self.Right:DockMargin(10, 0, 0, 0)
	self.Right:Dock(RIGHT)
	self.Right:SetWide(120)

	self.LinksLabel = self.Right:Add("DLabel")
	self.LinksLabel:DockMargin(0, 0, 0, 5)
	self.LinksLabel:Dock(TOP)
	self.LinksLabel:SetFont("CombineControl.LabelMediumBold")
	self.LinksLabel:SetContentAlignment(5)
	self.LinksLabel:SetText("Important Links")

	for _, data in ipairs(Config.Get("CommunityLinks")) do
		local button = self.Right:Add("DButton")

		button:DockMargin(0, 0, 0, 5)
		button:Dock(TOP)
		button:SetText(data[1])
		button.DoClick = function()
			gui.OpenURL(data[2])
		end
	end

	self.MOTD = self.Right:Add("DButton")
	self.MOTD:DockMargin(0, 0, 0, 5)
	self.MOTD:Dock(TOP)
	self.MOTD:SetText("Server Updates")
	self.MOTD.DoClick = function()
		GUI.Open("MOTD")
	end

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
