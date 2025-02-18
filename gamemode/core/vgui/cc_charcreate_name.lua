DEFINE_BASECLASS("CC_CharCreate")

local PANEL = {}

function PANEL:Init()
	self.Entry = self.Canvas:Add("DTextEntry")
	self.Entry:SetUpdateOnType(true)

	self.Entry.OnValueChange = function(_, val)
		self:SetOption(val)
	end
end

function PANEL:Setup(names, val)
	if names then
		self.RandomButton = self.Canvas:Add("DButton")

		self.RandomButton:SetText("Random Names")
		self.RandomButton:SizeToContentsX(20)

		-- Override func to prevent the menu from closing when clicked
		local func = function(pnl, mousecode)
			DButton.OnMouseReleased(pnl, mousecode)

			if self.m_MenuClicking and mousecode == MOUSE_LEFT then
				self.m_MenuClicking = false
			end
		end

		self.RandomButton.DoClick = function()
			local dmenu = DermaMenu(false, self.RandomButton)
			local tree = {
				_panel = dmenu
			}

			for _, index in ipairs(names) do
				local exploded = string.Explode("/", index)
				local node = tree

				for k, name in ipairs(exploded) do
					if k == #exploded then
						node._panel:AddOption(name, function()
							self.Entry:SetValue(CharacterCreate.GetRandomName(index))
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

function PANEL:PerformLayout(w, h)
	BaseClass.PerformLayout(self, w, h)

	self.Entry:StretchToParent(nil, nil, 0, nil)

	if self.RandomButton then
		self.RandomButton:MoveBelow(self.Entry, 5)
	end
end

derma.DefineControl("CC_CharCreate_Name", "", PANEL, "CC_CharCreate")
