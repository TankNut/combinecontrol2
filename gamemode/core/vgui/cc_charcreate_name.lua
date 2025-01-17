local PANEL = {}

function PANEL:Init()
	self.Entry = self.Canvas:Add("DTextEntry")
	self.Entry:DockMargin(0, 0, 0, 5)
	self.Entry:Dock(TOP)
	self.Entry:SetUpdateOnType(true)

	self.Entry.OnValueChange = function(_, val)
		self:SetOption(val)
	end
end

function PANEL:Setup(args, val)
	if args.RandomNames then
		local buttons = self.Canvas:Add("DPanel")

		buttons:Dock(TOP)
		buttons:SetTall(22)
		buttons:SetPaintBackground(false)

		for _, index in ipairs(args.RandomNames) do
			local button = buttons:Add("DButton")

			button:DockMargin(0, 0, 5, 0)
			button:Dock(LEFT)
			button:SetText("Random " .. index)
			button:SizeToContentsX(20)

			button.DoClick = function()
				self.Entry:SetValue(CharCreate.GetRandomName(index))
			end
		end

		self:SetTall(47)
	else
		self:SetTall(20)
	end

	if val then
		self.Entry:SetText(val)
	else
		self:SetOption("")
	end
end

derma.DefineControl("CC_CharCreate_Name", "", PANEL, "CC_CharCreate")
