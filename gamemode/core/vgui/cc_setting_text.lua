local PANEL = {}

function PANEL:Init()
	self.Preview = self:Add("DTextEntry")
	self.Preview:DockMargin(0, 1, 0, 1)
	self.Preview:Dock(LEFT)
	self.Preview:SetWide(300)
	self.Preview:SetEditable(false)

	self.Edit = self:Add("DButton")
	self.Edit:DockMargin(0, 1, 5, 1)
	self.Edit:Dock(RIGHT)
	self.Edit:SetText("Edit")
	self.Edit:SetWide(44)

	self.Edit.DoClick = function(pnl)
		async.Start(function()
			local val = GUI.Open("Input", self.InputType, "Edit " .. self.Setting.Name, {
				Validate = self.Setting.Validate,
				Default = self:GetSetting(),
				Name = self.NameOverride or self.Setting.Name
			})

			self.Preview:SetValue(val)
			self:SaveSetting(val)
			pnl:SetDisabled(true)
		end)
	end
end

function PANEL:ApplySetting(value)
	self.Preview:SetValue(value)
end

function PANEL:Setup(args)
	args = args or {}

	self.NameOverride = args.Name

	if args.Numeric then
		self.InputType = "number"
	elseif args.Multiline then
		self.InputType = "multiline"
	else
		self.InputType = "string"
	end
end

derma.DefineControl("CC_Setting_Text", "", PANEL, "CC_Setting")
