local TOKEN_NONE      = 1
local TOKEN_NUMBER    = 2
local TOKEN_ENUM      = 3
local TOKEN_METATABLE = 4
local TOKEN_STRING    = 5
local TOKEN_KEYWORD   = 6
local TOKEN_OPERATOR  = 7
local TOKEN_COMMENT   = 8
local TOKEN_FUNCTION  = 9

local UNDO = 1
local REDO = 2

local theme = {
	[TOKEN_NONE]      = Color(204, 204, 204),
	[TOKEN_NUMBER]    = Color(218, 165, 32),
	[TOKEN_ENUM]      = Color(184, 134, 11),
	[TOKEN_METATABLE] = Color(0, 255, 125),
	[TOKEN_STRING]    = Color(206, 145, 120),
	[TOKEN_KEYWORD]   = Color(197, 134, 192),
	[TOKEN_OPERATOR]  = Color(0, 255, 255),
	[TOKEN_COMMENT]   = Color(0, 200, 0),
	[TOKEN_FUNCTION]  = Color(220, 220, 170),

	LineBar     = Color(15, 15, 15),
	LineNumber  = Color(128, 128, 128),
	CurrentLine = Color(20, 20, 20),
	Selection   = Color(70, 70, 70),
	Background  = Color(50, 50, 50),
	Caret       = Color(255, 255, 255)
}

local keywords = table.Lookup({
	"if", "elseif", "else", "then", "end", "function",
	"do", "while", "break", "for", "in", "local",
	"true", "false", "nil", "NULL", "and", "not", "or",
	"||", "&&", "!", "!=", "return", "continue", "goto",
	"repeat", "until", "~="
})

-- Bunch of lookups to save time individually comparing
local numbers = table.Lookup(string.Explode("", "1234567890"))
local letters = table.Lookup(string.Explode("", "abcdefghijklmnopqrstuvwxyz1234567890_"))

surface.CreateFont("tacolib.CodeEditor", {
	font = "Lucida Console",
	size = 14,
	weight = 400
})

local PANEL = {}

function PANEL:SetStyle(tab)
	self.Style = setmetatable(tab, {
		__index = theme
	})
end

function PANEL:Init()
	if not CLIENT_GLOBALS then
		CLIENT_GLOBALS = GetGlobalLookupTable()
	end

	self:SetCursor("Beam")

	self.FontWidth, self.FontHeight = surface.GetFontSize("tacolib.CodeEditor", " ")

	self.Style = theme

	self.Rows = {""}
	self.Caret = {1, 1}
	self.Start = {1, 1}
	self.Scroll = {1, 1}
	self.Size = {1, 1}

	self.Undo = {}
	self.Redo = {}

	self.PaintCache = {}

	self.Blink = RealTime()

	self.ScrollBar = self:Add("DVScrollBar")
	self.ScrollBar:SetUp(1, 1)

	self.TextEntry = self:Add("TextEntry")
	self.TextEntry:SetFontInternal("tacolib.CodeEditor")
	self.TextEntry:SetMultiline(true)
	self.TextEntry:SetAllowNonAsciiCharacters(true)
	self.TextEntry:SetSize(0, 0)

	self.TextEntry.OnLoseFocus = function() self:_OnLoseFocus() end
	self.TextEntry.OnTextChanged = function() self:_OnTextChanged() end
	self.TextEntry.OnKeyCodeTyped = function(_, code) self:_OnKeyCodeTyped(code) end

	self.TextEntry.Parent = self
	self.LastClick = 0
end

function PANEL:RequestFocus()
	self.TextEntry:RequestFocus()
end

function PANEL:OnGetFocus()
	self.TextEntry:RequestFocus()
end

function PANEL:CursorToCaret()
	local x, y = self:CursorPos()

	x = math.max(x - (self.FontWidth * 3 + 6), 0)
	y = math.max(y, 0)

	local line = math.min(math.floor(y / self.FontHeight) + self.Scroll[1], #self.Rows)
	local length = #self.Rows[line]
	local char = math.min(math.floor(x / self.FontWidth * 0.5) + self.Scroll[2], length + 1)

	return {line, char}
end

function PANEL:OnMousePressed(code)
	if code == MOUSE_LEFT then
		local caret = self:CursorToCaret()
		local ct = CurTime()

		if ct - self.LastClick < 1 and self.Temp and caret[1] == self.Caret[1] and caret[2] == self.Caret[2] then
			self.Start = self:GetWordStart(self.Caret)
			self.Caret = self:GetWordEnd(self.Caret)
			self.Temp = nil

			return
		end

		self.Temp = true
		self.LastClick = ct
		self:RequestFocus()
		self.Blink = RealTime()
		self.MouseDown = true
		self.Caret = caret

		if not input.IsKeyDown(KEY_LSHIFT) and not input.IsKeyDown(KEY_RSHIFT) then
			self.Start = caret
		end
	elseif code == MOUSE_RIGHT then
		local dmenu = DermaMenu()
		local spacer = false

		if self:CanUndo() then
			dmenu:AddOption("Undo", function()
				self:DoUndo()
			end)
			spacer = true
		end

		if self:CanRedo() then
			dmenu:AddOption("Redo", function()
				self:DoRedo()
			end)
			spacer = true
		end

		if spacer then
			dmenu:AddSpacer()
		end

		local selection = self:HasSelection()

		if selection then
			dmenu:AddOption("Cut", function()
				self:DoCut()
			end)

			dmenu:AddOption("Copy", function()
				self:DoCopy()
			end)
		end

		dmenu:AddOption("Paste", function()
			if self.Clipboard then
				self:SetSelection(self.Clipboard)
			else
				self:SetSelection()
			end
		end)

		if selection then
			dmenu:AddOption("Delete", function()
				self:SetSelection()
			end)
		end

		dmenu:AddSpacer()

		dmenu:AddOption("Select all", function()
			self:SelectAll()
		end)

		dmenu:Open()
	end
end

function PANEL:OnMouseReleased(code)
	if not self.MouseDown then return end

	if code == MOUSE_LEFT then
		self.MouseDown = nil

		if not self.Temp then
			return
		end

		self.Caret = self:CursorToCaret()
	end
end

function PANEL:SetText(text)
	self.Rows = string.Explode("\n", text)

	if self.Rows[#self.Rows] != "" then
		self.Rows[#self.Rows + 1] = ""
	end

	self.Caret = {1, 1}
	self.Start = {1, 1}
	self.Scroll = {1, 1}

	self.Undo = {}
	self.Redo = {}
	self.PaintCache = {}

	self.ScrollBar:SetUp(self.Size[1], #self.Rows - 1)
end

function PANEL:GetValue()
	return table.concat(self.Rows, "\n")
end

function PANEL:NextChar()
	if not self.Char then
		return
	end

	self.Str = self.Str .. self.Char
	self.Pos = self.Pos + 1

	if self.Pos <= #self.Line then
		self.Char = string.sub(self.Line, self.Pos, self.Pos)
	else
		self.Char = nil
	end
end

do -- Tokenizing
	local line, pos, char, lower, str

	local function nextChar()
		if not char then
			return
		end

		str = str .. char
		pos = pos + 1

		if pos <= #line then
			char = line[pos]
			lower = string.lower(char)
		else
			char = nil
			lower = nil
		end
	end

	local function checkGlobal(index)
		return CLIENT_GLOBALS[index] or SERVER_GLOBALS[index]
	end

	function PANEL:SyntaxColorLine(row)
		local colors = {}

		line = self.Rows[row]
		pos = 0
		char = ""
		str = ""

		nextChar()

		while char do
			local token

			str = ""

			while char and char == " " do
				nextChar()
			end

			if not char then
				break
			end

			if numbers[lower] then
				while char and (numbers[lower] or lower == "x" or char == ".") do
					nextChar()
				end

				token = TOKEN_NUMBER
			elseif letters[lower] then
				while char and letters[lower] do
					nextChar()
				end

				local trim = string.Trim(str)

				if keywords[trim] then
					token = TOKEN_KEYWORD
				else
					local global = checkGlobal(trim)

					if global == "e" then
						token = TOKEN_ENUM
					elseif global == "m" then
						token = TOKEN_METATABLE
					elseif global == "f" then
						token = TOKEN_FUNCTION
					else
						token = TOKEN_NONE
					end
				end
			elseif char == "\"" or char == "'" then
				nextChar()

				while char and char != "\"" do
					if char == "\\" then
						nextChar()
					end

					nextChar()
				end

				nextChar()
				token = TOKEN_STRING
			elseif char == "'" then
				nextChar()

				while char and char != "'" do
					if char == "\\" then
						nextChar()
					end

					nextChar()
				end

				nextChar()
				token = TOKEN_STRING
			elseif char == "/" or char == "-" then
				local last = char

				nextChar()

				if char == last then
					while char do nextChar() end

					token = TOKEN_COMMENT
				else
					token = TOKEN_NONE
				end
			else
				nextChar()
				token = TOKEN_OPERATOR
			end

			local color = self.Style[token]
			local lastColor = colors[#colors]

			if lastColor and lastColor[2] == color then
				lastColor[1] = lastColor[1] .. str
			else
				table.insert(colors, {str, color})
			end
		end

		return colors
	end
end

function PANEL:PaintLine(row)
	if row > #self.Rows then return end

	if not self.PaintCache[row] then
		self.PaintCache[row] = self:SyntaxColorLine(row)
	end

	local width, height = self.FontWidth, self.FontHeight
	local lineOffset = width * 3 + 6
	local y = (row - self.Scroll[1]) * height

	if row == self.Caret[1] and self.TextEntry:HasFocus() then
		surface.SetDrawColor(self.Style.CurrentLine)
		surface.DrawRect(lineOffset - 1, (row - self.Scroll[1]) * height, self:GetWide() - (lineOffset - 1), height)
	end

	if self:HasSelection() then
		local start, stop = self:MakeSelection(self:Selection())
		local line, char = start[1], start[2]
		local endLine, endChar = stop[1], stop[2]

		surface.SetDrawColor(self.Style.Selection)

		local length = #self.Rows[row] - self.Scroll[2] + 1

		char = math.max(char - self.Scroll[2], 0)
		endChar = math.max(endChar - self.Scroll[2], 0)

		if row == line and line == endLine then
			surface.DrawRect(lineOffset + char * width, y, width * (endChar - char), height)
		elseif row == line then
			surface.DrawRect(lineOffset + char * width, y, width * (length - char + 1), height)
		elseif row == endLine then
			surface.DrawRect(lineOffset, y, width * endChar, height)
		elseif row > line and row < endLine then
			surface.DrawRect(lineOffset, y, width * (length + 1), height)
		end
	end

	draw.SimpleText(row, "tacolib.CodeEditor", width * 3, y, self.Style.LineNumber, TEXT_ALIGN_RIGHT)

	local offset = -self.Scroll[2] + 1

	for _, cell in ipairs(self.PaintCache[row]) do
		if offset < 0 then
			if #cell[1] > -offset then
				local line = string.sub(cell[1], -offset + 1)
				offset = #line

				draw.SimpleText(cell[1], "tacolib.CodeEditor", lineOffset + offset * width, y, cell[2])
			else
				offset = offset + #cell[1]
			end
		else
			draw.SimpleText(cell[1], "tacolib.CodeEditor", lineOffset + offset * width, y, cell[2])

			offset = offset + #cell[1]
		end
	end

	if row == self.Caret[1] and self.TextEntry:HasFocus() and (RealTime() - self.Blink) % 0.8 < 0.4 then
		surface.SetDrawColor(self.Style.Caret)
		surface.DrawRect(lineOffset + (self.Caret[2] - self.Scroll[2]) * width, (self.Caret[1] - self.Scroll[1]) * height, 1, height)
	end
end

function PANEL:PerformLayout()
	self.ScrollBar:SetSize(16, self:GetTall())
	self.ScrollBar:SetPos(self:GetWide() - 16, 0)

	self.Size[1] = math.floor(self:GetTall() / self.FontHeight) - 1
	self.Size[2] = math.floor((self:GetWide() - (self.FontWidth * 3 + 6) - 16) / self.FontWidth) - 1

	self.ScrollBar:SetUp(self.Size[1], #self.Rows - 1)
end

function PANEL:Paint()
	if not input.IsMouseDown(MOUSE_LEFT) then
		self:OnMouseReleased(MOUSE_LEFT)
	end

	if self.MouseDown then
		self.Caret = self:CursorToCaret()
	end

	surface.SetDrawColor(self.Style.LineBar)
	surface.DrawRect(0, 0, self.FontWidth * 3 + 4, self:GetTall())

	surface.SetDrawColor(self.Style.Background)
	surface.DrawRect(self.FontWidth * 3 + 5, 0, self:GetWide() - (self.FontWidth * 3 + 5), self:GetTall())

	surface.SetDrawColor(self.Style.LineNumber)
	surface.DrawRect(self.FontWidth * 3 + 4, 0, 1, self:GetTall())

	self.Scroll[1] = math.floor(self.ScrollBar:GetScroll() + 1)

	for i = self.Scroll[1], self.Scroll[1] + self.Size[1] + 1 do
		self:PaintLine(i)
	end

	return true
end

function PANEL:SetCaret(caret)
	self.Caret = self:CopyPosition(caret)
	self.Start = self:CopyPosition(caret)

	self:ScrollCaret()
end

function PANEL:CopyPosition(caret)
	return {caret[1], caret[2]}
end

function PANEL:MovePosition(caret, offset)
	caret = table.Copy(caret)

	if offset > 0 then
		while true do
			local length = #self.Rows[caret[1]] - caret[2] + 2

			if offset < length then
				caret[2] = caret[2] + offset

				break
			elseif caret[1] == #self.Rows then
				caret[2] = caret[2] + length - 1

				break
			else
				offset = offset - length

				caret[1] = caret[1] + 1
				caret[2] = 1
			end
		end
	elseif offset < 0 then
		offset = -offset

		while true do
			if offset < caret[2] then
				caret[2] = caret[2] - offset

				break
			elseif caret[1] == 1 then
				caret[2] = 1

				break
			else
				offset = offset - caret[2]

				caret[1] = caret[1] - 1
				caret[2] = #self.Rows[caret[1]] + 1
			end
		end
	end

	return caret
end

function PANEL:HasSelection()
	return self.Caret[1] != self.Start[1] or self.Caret[2] != self.Start[2]
end

function PANEL:Selection()
	return {
		table.Copy(self.Caret),
		table.Copy(self.Start)
	}
end

function PANEL:MakeSelection(selection)
	local start, stop = selection[1], selection[2]

	if start[1] < stop[1] or start[1] == stop[1] and start[2] < stop[2] then
		return start, stop
	else
		return stop, start
	end
end

function PANEL:GetArea(selection)
	local start, stop = self:MakeSelection(selection)
	local startLine = self.Rows[start[1]]

	if start[1] == stop[1] then
		return string.sub(startLine, start[2], stop[2] - 1)
	else
		local text = string.sub(startLine, start[2])

		for i = start[1] + 1, stop[1] - 1 do
			text = text .. "\n" .. self.Rows[i]
		end

		return text .. "\n" .. string.sub(self.Rows[stop[1]], 1, stop[2] - 1)
	end
end

function PANEL:SetArea(selection, text, mode, before, after)
	local start, stop = self:MakeSelection(selection)
	local buffer = self:GetArea(selection)

	self.PaintCache = {}

	if start[1] != stop[1] or start[2] != stop[2] then
		-- Clear selection
		self.Rows[start[1]] = string.sub(self.Rows[start[1]], 1, start[2] - 1) .. string.sub(self.Rows[stop[1]], stop[2])

		for _ = start[1] + 1, stop[1] do
			table.remove(self.Rows, start[1] + 1)
		end

		if self.Rows[#self.Rows] != "" then
			table.insert(self.Rows, "")
		end
	end

	if not text or text == "" then
		self.ScrollBar:SetUp(self.Size[1], #self.Rows - 1)
		self:OnTextChanged()

		if mode == REDO then
			table.insert(self.Undo, {
				{self:CopyPosition(start), self:CopyPosition(start)},
				buffer, after, before
			})

			return before
		elseif mode == UNDO then
			table.insert(self.Redo, {
				{self:CopyPosition(start), self:CopyPosition(start)},
				buffer, after, before
			})

			return before
		else
			self.Redo = {}

			table.insert(self.Undo, {
				{self:CopyPosition(start), self:CopyPosition(start)},
				buffer, self:CopyPosition(selection[1]), self:CopyPosition(start)
			})

			return start
		end
	end

	-- Insert text
	local rows = string.Explode("\n", text)
	local remainder = string.sub(self.Rows[start[1]], start[2])

	self.Rows[start[1]] = string.sub(self.Rows[start[1]], 1, start[2] - 1) .. rows[1]

	for i = 2, #rows do
		table.insert(self.Rows, start[1] + i - 1, rows[i])
	end

	stop = {start[1] + #rows - 1, #self.Rows[start[1] + #rows - 1] + 1}

	self.Rows[stop[1]] = self.Rows[stop[1]] .. remainder

	if self.Rows[#self.Rows] != "" then
		table.insert(self.Rows, "")
	end

	self.ScrollBar:SetUp(self.Size[1], #self.Rows - 1)
	self:OnTextChanged()

	if mode == REDO then
		table.insert(self.Undo, {
			{self:CopyPosition(start), self:CopyPosition(stop)},
			buffer, after, before
		})

		return before
	elseif mode == UNDO then
		table.insert(self.Redo, {
			{self:CopyPosition(start), self:CopyPosition(stop)},
			buffer, after, before
		})

		return before
	else
		self.Redo = {}

		table.insert(self.Undo, {
			{self:CopyPosition(start), self:CopyPosition(stop)},
			buffer, self:CopyPosition(selection[1]), self:CopyPosition(stop)
		})

		return stop
	end
end

function PANEL:GetSelection()
	return self:GetArea(self:Selection())
end

function PANEL:SetSelection(text)
	self:SetCaret(self:SetArea(self:Selection(), text))
end

function PANEL:_OnLoseFocus()
	if self.TabFocus then
		self:RequestFocus()
		self.TabFocus = nil
	end
end

function PANEL:_OnTextChanged()
	local ctrlv = false
	local text = self.TextEntry:GetValue()

	self.TextEntry:SetText("")

	if input.IsKeyDown(KEY_BACKQUOTE) and not input.IsKeyDown(KEY_LSHIFT) then
		return
	end

	if (input.IsKeyDown(KEY_LCONTROL) or input.IsKeyDown(KEY_RCONTROL)) and not (input.IsKeyDown(KEY_LALT) or input.IsKeyDown(KEY_RALT)) then

		-- ctrl+[shift+]key
		if input.IsKeyDown(KEY_V) then
			-- ctrl+[shift+]V
			ctrlv = true
		else
			-- ctrl+[shift+]key with key != V
			return
		end
	end

	if text == "" then
		return
	end

	if not ctrlv and text == "\n" then
		return
	end

	self:SetSelection(text)
end

function PANEL:OnMouseWheeled(delta)
	self.Scroll[1] = math.Clamp(self.Scroll[1] - 4 * delta, 1, #self.Rows)

	self.ScrollBar:SetScroll(self.Scroll[1] - 1)
end

function PANEL:ScrollCaret()
	if self.Caret[1] - self.Scroll[1] < 2 then
		self.Scroll[1] = math.max(self.Caret[1] - 2, 1)
	end

	if self.Caret[1] - self.Scroll[1] > self.Size[1] - 2 then
		self.Scroll[1] = math.max(self.Caret[1] - self.Size[1] + 2, 1)
	end

	if self.Caret[2] - self.Scroll[2] < 4 then
		self.Scroll[2] = math.max(self.Caret[2] - 4, 1)
	end

	if self.Caret[2] - 1 - self.Scroll[2] > self.Size[2] - 4 then
		self.Scroll[2] = math.max(self.Caret[2] - 1 - self.Size[2] + 4, 1)
	end

	self.ScrollBar:SetScroll(self.Scroll[1] - 1)
end

function PANEL:CanUndo()
	return #self.Undo > 0
end

function PANEL:DoUndo()
	if #self.Undo > 0 then
		local data = self.Undo[#self.Undo]

		self.Undo[#self.Undo] = nil
		self:SetCaret(self:SetArea(data[1], data[2], UNDO, data[3], data[4]))
	end
end

function PANEL:CanRedo()
	return #self.Redo > 0
end

function PANEL:DoRedo()
	if #self.Redo > 0 then
		local data = self.Redo[#self.Redo]

		self.Redo[#self.Redo] = nil
		self:SetCaret(self:SetArea(data[1], data[2], REDO, data[3], data[4]))
	end
end

function PANEL:SelectAll()
	self.Caret = {#self.Rows, #self.Rows[#self.Rows] + 1}
	self.Start = {1, 1}

	self:ScrollCaret()
end

function PANEL:DoCut()
	if self:HasSelection() then
		self.Clipboard = self:GetSelection()

		SetClipboardText(self.Clipboard)

		self:SetSelection()
	end
end

function PANEL:DoCopy()
	if self:HasSelection() then
		self.Clipboard = self:GetSelection()

		SetClipboardText(self.Clipboard)
	end
end

function PANEL:RunNewCommand() end
function PANEL:RunOpenCommand() end
function PANEL:RunSaveAsCommand() end
function PANEL:RunSaveCommand() end

function PANEL:_OnKeyCodeTyped(code)
	self.Blink = RealTime()

	local alt = input.IsKeyDown(KEY_LALT) or input.IsKeyDown(KEY_RALT)
	local shift = input.IsKeyDown(KEY_LSHIFT) or input.IsKeyDown(KEY_RSHIFT)
	local control = input.IsKeyDown(KEY_LCONTROL) or input.IsKeyDown(KEY_RCONTROL)

	if control and alt and code == KEY_S then
		self:RunSaveAsCommand()

		return
	end

	if alt then return end

	if control then
		if code == KEY_A then
			self:SelectAll()
		elseif code == KEY_Z then
			self:DoUndo()
		elseif code == KEY_Y then
			self:DoRedo()
		elseif code == KEY_X then -- Cut
			self:DoCut()
		elseif code == KEY_C then -- Copy
			self:DoCopy()
		elseif code == KEY_S then -- Save
			self:RunSaveCommand()
		elseif code == KEY_O then -- Open
			self:RunOpenCommand()
		elseif code == KEY_N then -- New tab
			self:RunNewCommand()
		elseif code == KEY_SLASH then -- Toggle comment selected lines
			local start, stop = self:MakeSelection(self:Selection())

			local before = self:GetArea(self:Selection())
			for i = start[1], stop[1] do
				local line = self.Rows[i]

				if line:sub(1, 2) == "--" then
					self.Rows[i] = line:sub(3)
				else
					if line != "" then
						self.Rows[i] = "-- " .. line
					end
				end
			end

			self.Undo[#self.Undo + 1] = {
				{ self:CopyPosition( start ), self:CopyPosition( stop ) },
				before, self:CopyPosition( start ), self:CopyPosition( stop )
			}

			self.PaintRows = {}
			self:OnTextChanged()
		elseif code == KEY_UP then -- Move line up
			self.Scroll[1] = math.max(self.Scroll[1] - 1, 1)
		elseif code == KEY_DOWN then -- Move line down
			self.Scroll[1] = self.Scroll[1] + 1
		elseif code == KEY_LEFT or code == KEY_LBRACKET then -- Unindent
			if self:HasSelection() and not shift then
				self.Start = self:CopyPosition(self.Caret)
			else
				self.Caret = self:GetWordStart(self:MovePosition(self.Caret, -4))
			end

			self:ScrollCaret()

			if not shift then
				self.Start = self:CopyPosition(self.Caret)
			end
		elseif code == KEY_RIGHT or code == KEY_RBRACKET then -- Indent
			if self:HasSelection() and not shift then
				self.Start = self:CopyPosition(self.Caret)
			else
				self.Caret = self:GetWordEnd(self:MovePosition(self.Caret, 1))
			end

			self:ScrollCaret()

			if not shift then
				self.Start = self:CopyPosition(self.Caret)
			end
		elseif code == KEY_HOME then -- Move to start of file
			self.Caret[1] = 1
			self.Caret[2] = 1

			self:ScrollCaret()

			if not shift then
				self.Start = self:CopyPosition(self.Caret)
			end
		elseif code == KEY_END then -- Move to end of file
			self.Caret[1] = #self.Rows
			self.Caret[2] = 1

			self:ScrollCaret()

			if not shift then
				self.Start = self:CopyPosition(self.Caret)
			end
		end
	else
		if code == KEY_ENTER then -- Auto indent the next line
			local row = self.Rows[self.Caret[1]]:sub(1, self.Caret[2] - 1)
			local diff = (row:find("%S") or row:len() + 1) - 1
			local tabs = string.rep("    ", math.floor(diff / 4))

			self:SetSelection("\n" .. tabs)
		elseif code == KEY_UP then
			if self.Caret[1] > 1 then
				self.Caret[1] = self.Caret[1] - 1

				local length = #self.Rows[self.Caret[1]]

				if self.Caret[2] > length + 1 then
					self.Caret[2] = length + 1
				end
			end

			self:ScrollCaret()

			if not shift then
				self.Start = self:CopyPosition(self.Caret)
			end
		elseif code == KEY_DOWN then
			if self.Caret[1] < #self.Rows then
				self.Caret[1] = self.Caret[1] + 1

				local length = #self.Rows[self.Caret[1]]

				if self.Caret[2] > length + 1 then
					self.Caret[2] = length + 1
				end
			end

			self:ScrollCaret()

			if not shift then
				self.Start = self:CopyPosition(self.Caret)
			end
		elseif code == KEY_LEFT then
			if self:HasSelection() and not shift then
				self.Start = self:CopyPosition(self.Caret)
			else
				self.Caret = self:MovePosition(self.Caret, -1)
			end

			self:ScrollCaret()

			if not shift then
				self.Start = self:CopyPosition(self.Caret)
			end
		elseif code == KEY_RIGHT then
			if self:HasSelection() and not shift then
				self.Start = self:CopyPosition(self.Caret)
			else
				self.Caret = self:MovePosition(self.Caret, 1)
			end

			self:ScrollCaret()

			if not shift then
				self.Start = self:CopyPosition(self.Caret)
			end
		elseif code == KEY_PAGEUP then
			self.Caret[1] = math.max(self.Caret[1] - math.ceil(self.Size[1] * 0.5), 1)
			self.Scroll[1] = self.Scroll[1] - math.ceil(self.Size[1] * 0.5)

			local length = #self.Rows[self.Caret[1]] + 1

			self.Caret[2] = math.min(self.Caret[2], length)
			self.Scroll[1] = math.max(self.Scroll[1], 1)
			self:ScrollCaret()

			if not shift then
				self.Start = self:CopyPosition(self.Caret)
			end
		elseif code == KEY_PAGEDOWN then
			self.Caret[1] = math.min(self.Caret[1] + math.ceil(self.Size[1] * 0.5), #self.Rows)
			self.Scroll[1] = self.Scroll[1] + math.ceil(self.Size[1] * 0.5)

			if self.Caret[1] == #self.Rows then
				self.Caret[2] = 1
			end

			local length = #self.Rows[self.Caret[1]] + 1

			self.Caret[2] = math.min(self.Caret[2], length)
			self:ScrollCaret()

			if not shift then
				self.Start = self:CopyPosition(self.Caret)
			end
		elseif code == KEY_HOME then
			local row = self.Rows[self.Caret[1]]
			local first_char = row:find("%S") or row:len() + 1

			if self.Caret[2] == first_char then
				self.Caret[2] = 1
			else
				self.Caret[2] = first_char
			end

			self:ScrollCaret()

			if not shift then
				self.Start = self:CopyPosition(self.Caret)
			end
		elseif code == KEY_END then
			local length = #self.Rows[self.Caret[1]]
			self.Caret[2] = length + 1
			self:ScrollCaret()

			if not shift then
				self.Start = self:CopyPosition(self.Caret)
			end
		elseif code == KEY_BACKSPACE then
			if self:HasSelection() then
				self:SetSelection()
			else
				local buffer = self:GetArea({
					self.Caret, {self.Caret[1], 1}
				})

				if self.Caret[2] % 4 == 1 and #buffer > 0 and string.rep(" ", #buffer) == buffer then
					self:SetCaret(self:SetArea({self.Caret, self:MovePosition(self.Caret, -4)}))
				else
					self:SetCaret(self:SetArea({self.Caret, self:MovePosition(self.Caret, -1)}))
				end
			end
		elseif code == KEY_DELETE then
			if self:HasSelection() then
				self:SetSelection()
			else
				local buffer = self:GetArea({
					{self.Caret[1], self.Caret[2] + 4},
					{self.Caret[1], 1}
				})

				if self.Caret[2] % 4 == 1 and string.rep(" ", #buffer) == buffer and #self.Rows[self.Caret[1]] >= self.Caret[2] + 4 - 1 then
					self:SetCaret(self:SetArea({self.Caret, self:MovePosition(self.Caret, 4)}))
				else
					self:SetCaret(self:SetArea({self.Caret, self:MovePosition(self.Caret, 1)}))
				end
			end
		end
	end

	if code == KEY_TAB or control and ( code == KEY_I or code == KEY_O ) then
		if code == KEY_O then
			shift = not shift
		end

		if code == KEY_TAB and control then
			shift = not shift
		end

		if self:HasSelection() then
			self:Indent(shift)
		else
			if shift then
				local newpos = math.max(self.Caret[2] - 4, 1)

				self.Start = {self.Caret[1], newpos}

				if self:GetSelection():find("%S") then
					self.Start = self:CopyPosition(self.Caret)
				else
					self:SetSelection("")
				end
			else
				local count = (self.Caret[2] + 2) % 4 + 1

				self:SetSelection(string.rep(" ", count))
			end
		end

		self.TabFocus = true
	end

	if control then
		self:OnShortcut(code)
	end
end

function PANEL:GetWordStart(caret)
	local line = string.ToTable(self.Rows[caret[1]])

	if #line < caret[2] then
		return caret
	end

	for i = 0, caret[2] do
		local char = line[caret[2] - 1]

		if not char then
			return {caret[1], caret[2] - i + 1}
		end

		if not letters[char] then
			return {caret[1], caret[2] - i + 1}
		end
	end

	return {caret[1], 1}
end

function PANEL:GetWordEnd(caret)
	local line = string.ToTable(self.Rows[caret[1]])

	if #line < caret[2] then
		return caret
	end

	for i = caret[2], #line do
		local char = line[i]

		if not char then
			return {caret[1], i}
		end

		if not letters[char] then
			return {caret[1], i}
		end
	end

	return {caret[1], #line + 1}
end

local function unindent(line)
	local i = line:find("%S")

	if i == nil or i > 5 then
		i = 5
	end

	return line:sub(i)
end

function PANEL:Indent(shift)
	local tabScroll = self:CopyPosition(self.Scroll)
	local tabStart, tabCaret = self:MakeSelection(self:Selection())
	tabStart[2] = 1

	if tabCaret[2] != 1 then
		tabCaret[1] = tabCaret[1] + 1
		tabCaret[2] = 1
	end

	self.Caret = self:CopyPosition(tabCaret)
	self.Start = self:CopyPosition(tabStart)

	if self.Caret[2] == 1 then
		self.Caret = self:MovePosition( self.Caret, -1 )
	end

	if shift then
		local tmp = self:GetSelection():gsub("\n ? ? ? ?", "\n")

		self:SetSelection(unindent(tmp))
	else
		self:SetSelection("    " .. self:GetSelection():gsub("\n", "\n    "))
	end

	self.Caret = self:CopyPosition(tabCaret)
	self.Start = self:CopyPosition(tabStart)
	self.Scroll = self:CopyPosition(tabScroll)

	self:ScrollCaret()
end

function PANEL:OnTextChanged()
end

function PANEL:OnShortcut(code)
end

vgui.Register("CC_CodeEditor", PANEL, "Panel")
