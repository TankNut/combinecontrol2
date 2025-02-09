local PANEL = {}

function PANEL:Init()
	self:SetSize(800, 500)

	self:SetToggleKey("gm_showhelp")
	self:SetDraggable(true)
	self:SetCloseOnPause(true)
	self:SetTopBar("Help Menu")

	self.LeftBar = self:Add("Panel")
	self.LeftBar:DockPadding(5, 10, 5, 10)
	self.LeftBar:SetWidth(150)
	self.LeftBar:Dock(LEFT)

	self.LeftBar.Paint = function(_, w, h)
		surface.SetDrawColor(0, 0, 0, 70)
		surface.DrawRect(0, 0, w, h)

		surface.SetDrawColor(0, 0, 0, 100)
		surface.DrawOutlinedRect(0, 0, w, h)
	end

	self.MenuButtons = {}
	self.SelectedMenu = 0

	self.Content = self:Add("Panel")
	self.Content:DockPadding(10, 10, 10, 10)
	self.Content:Dock(FILL)

	self:MakePopup()
	self:Center()
end

function PANEL:AddMenu(order, name, content)
	self.MenuButtons[order] = {
		Name = name,
		Content = content
	}
end

function PANEL:Populate()
	for index, option in SortedPairs(self.MenuButtons) do
		local button = self.LeftBar:Add("DButton")

		button:DockMargin(0, 0, 0, 5)
		button:Dock(TOP)
		button:SetText(option.Name)

		button.DoClick = function()
			self:SelectMenu(index)
		end

		option.Button = button
	end

	self:SelectMenu(1)
end

function PANEL:SelectMenu(index)
	if self.SelectedMenu == index then
		return
	end

	self.SelectedMenu = index
	self.Content:Clear()

	local option = self.MenuButtons[index]

	self.ContentScroll = self.Content:Add("DScrollPanel")
	self.ContentScribe = self.ContentScroll:Add("ScribeLabel")

	if isfunction(option.Content) then
		self.ContentScribe:SetText(option.Content(LocalPlayer()))
	else
		self.ContentScribe:SetText(option.Content)
	end

	self.ContentScribe:Dock(TOP)
	self.ContentScribe:SetAutoStretchVertical(true)

	self.ContentScroll:SetVerticalScrollbarEnabled(true)
	self.ContentScroll:Dock(FILL)

	self:UpdateMenuButtons()
end

function PANEL:UpdateMenuButtons()
	for index, option in pairs(self.MenuButtons) do
		option.Button:SetDisabled(self.SelectedMenu == index)
	end
end

derma.DefineControl("GUI_HelpMenu", "", PANEL, "CC_Frame")

GUI.Register("HelpMenu", function()
	local instance = vgui.Create("GUI_HelpMenu")

	hook.Run("PopulateHelpMenu", instance)

	instance:Populate()

	return instance
end, true)

function GM:PopulateHelpMenu(panel)
	local playerCommands = {}

	for name, command in SortedPairs(console.Commands) do
		if not string.StartsWith(name, "rp_") or not console.IsVisible(command) or not command:CanAccess(LocalPlayer()) then
			continue
		end
		playerCommands[name] = command
	end

	panel:AddMenu(1, "Gamemode Credits", [[
<massive><b><c=cc_primary>CombineControl</c></b></massive>
<iset=3><dark>Built for Taco N Banana</dark>

<giant><b>Credits</b></giant>
	TankNut:	<dark>Lead Developer</dark>
	Drewerth:	<dark>Code</dark>
	Hoplite:	<dark>Technical Design</dark>

<giant><b>Special Thanks</b></giant>
	Dave Brown:	<dark>For keeping TnB alive over the years by shooting cops and bots alike</dark>
	Gangleider:	<dark>For taking over the mantle from Dave and getting this project off the ground</dark>

<dark>Based on a gamemode by Disseminate</dark>
]])

	panel:AddMenu(2, "Menus and Commands", function(ply)
		local str = ""

		-- Menu Commands
		local function addMenuCommand(name, binding)
			local lookup = input.LookupBinding(binding, true)
			str = str .. string.format("\n\t%s - %s (or use %s)", lookup and lookup or "Unbound", name, binding)
		end

		str = str .. "<b>In-Game Menus:</b>"
		addMenuCommand("Help Menu", "gm_showhelp")
		addMenuCommand("Character Selection", "gm_showteam")
		addMenuCommand("Player Menu", "gm_showspare1")
		addMenuCommand("Administration Menu", "gm_showspare2")
		addMenuCommand("Context Menu", "+menu_context")

		-- Weapon Holstering
		str = str .. "\n\n<b>Weapon Holstering:</b>\n\trp_toggleholster - B"

		-- Non-Admin Commands
		if table.Count(playerCommands) > 0 then
			str = str .. "\n\n<b>Useful Commands:</b>"

			for name, command in SortedPairs(playerCommands) do
				str = str .. string.format("\n\t%s - %s", name, command.Description)
			end
		end

		return str
	end)
	panel:AddMenu(3, "Chat Functionality", function(ply)
		local str = ""

		-- The Basics
		str = str .. "<b>The Basics:</b>"
		str = str .. "\nEntering anything into your chatbox will make you speak using in-character text, which is limited by range and can be blocked by world geometry. Additional commands exist to help facilitate additional interaction, functionality, and the use of unique character languages."

		-- Chat Commands (Minus Set Language)
		str = str .. "\n\n<b>Chat Commands:</b>"

		for name, message in SortedPairs(Chat.List) do
			if table.Count(message.Commands) == 0 and table.Count(message.Aliases) == 0 or name == "Set language" then
				continue
			end

			local main = nil
			local alts = {}

			for index, command in pairs(message.Commands) do
				if index == 1 then
					main = "/" .. command
					continue
				end

				table.insert(alts, "/" .. command)
			end

			for _, alias in pairs(message.Aliases) do
				table.insert(alts, alias)
			end

			str = str .. string.format("\n\t%s%s - %s",
				main,
				#alts == 0 and "" or " (" .. table.concat(alts, ", ") .. ")",
				message.Description)
		end

		-- Language Command Syntax
		str = str .. "\n\n<b>Language Command Syntax (and Examples):</b>"
		str = str .. "\n\t/[lang].[cmd] [text] - Uses a command with the given language."
		str = str .. "\n\t/[lang] - Sets a default speaking language (/eng will set you back to default)."
		str = str .. "\n\t/rus.y Hello! - Yells in Russian."
		str = str .. "\n\t/fre.rw Hello! - Whispers over the radio in French."

		-- Available Languages
		str = str .. "\n\n<b>Available Languages:</b>"
		for _, lang in SortedPairs(Language.List) do
			str = str .. string.format("\n\t/%s - %s", lang.Command, lang.Name)
		end

		return str
	end)
	panel:AddMenu(4, "Sandbox Permissions", function(ply)
		local str = ""

		str = str .. "<b>Sandbox Permissions:</b>"
		str = str .. "\nTool, Physics, and Prop Spawning permissions are all contained to a single tooltrust permission in CombineControl. By default, you will be given untrusted access to these tools which will allow some basic access to the Garry's Mod sandbox. Server administrators have the ability to individually modify a player's tooltrust at any given time, including issuing a tooltrust ban to prevent abuse."

		-- Scoreboard Recognition
		str = str .. "\n\n<b>Scoreboard Recognition:</b>"
		str = str .. "\nPlayers who have either been banned from accessing the sandbox or granted advanced access to be represented with an icon on the scoreboard that all server administrators can see. Additionally, if you have been set to either of these tooltrust groups, you will see the scoreboard badge next to yourself."

		-- Tooltrust Levels
		local function addTooltrustLevel(tier, description)
			str = str .. string.format("\n\t%s - %s", tier, description)
		end

		str = str .. "\n\n<b>ToolTrust Access Levels:</b>"
		addTooltrustLevel("banned", "Restricted access to prevent sandbox interactions.")
		addTooltrustLevel("untrusted", "Default access with minimal tools, decreased entity counts, and non-solid props.")
		addTooltrustLevel("trusted", "Standard access with standard tools, standard entity counts, and solid props.")
		addTooltrustLevel("advanced", "Applied-for access with advanced tools, increased entity counts, and solid props.")

		return str
	end)
end
