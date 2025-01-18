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

function PANEL:Setup(names, val)
	if names then
		local buttons = self.Canvas:Add("DPanel")

		buttons:Dock(TOP)
		buttons:SetTall(22)
		buttons:SetPaintBackground(false)

		local button = buttons:Add("DButton")

		button:DockMargin(0, 0, 5, 0)
		button:Dock(LEFT)
		button:SetText("Random Names")
		button:SizeToContentsX(20)

		-- Override func to prevent the menu from closing when clicked
		local func = function(pnl, mousecode)
			DButton.OnMouseReleased(pnl, mousecode)

			if self.m_MenuClicking and mousecode == MOUSE_LEFT then
				self.m_MenuClicking = false
			end
		end

		button.DoClick = function()
			local dmenu = DermaMenu(false, button)
			local tree = {
				_panel = dmenu
			}

			for _, index in ipairs(names) do
				local exploded = string.Explode("/", index)
				local node = tree

				for k, name in ipairs(exploded) do
					if k == #exploded then
						node._panel:AddOption(name, function()
							self.Entry:SetValue(CharCreate.GetRandomName(index))
						end).OnMouseReleased = func

						continue
					end

					if not tree[name] then
						local submenu, panel = node._panel:AddSubMenu(name)

						panel.OnMouseReleased = func

						tree[name] = {
							_panel = submenu
						}
					end

					node = tree[name]
				end
			end

			dmenu:Open()
		end
	end

	if val then
		self.Entry:SetText(val)
	else
		self:SetOption("")
	end
end

derma.DefineControl("CC_CharCreate_Name", "", PANEL, "CC_CharCreate")
