module("scribe", package.seeall)

Timeout = 5

Components = Components or {}
Cache = Cache or {}

DefaultFont = DefaultFont or "ChatFont"
DefaultColor = DefaultColor or color_white

function Register(component, base)
	base = Components[base] or BaseComponent

	local meta = {
		__index = component
	}

	setmetatable(component, {
		__call = function(_, ctx, ...)
			local instance = setmetatable({
				Context = ctx,
				Handlers = {}
			}, meta)

			instance:Initialize(...)

			return instance
		end,
		__index = base
	})

	for _, name in pairs(component.Name) do
		Components[name] = component
	end
end

function Parse(str, maxWidth)
	local crc = util.CRC(str .. (maxWidth or 0))
	local cache = Cache[crc]

	if cache then
		cache.LastUsed = CurTime()

		return cache.Instance
	end

	local instance = setmetatable({}, {
		__index = Core
	})

	instance:Initialize(str, maxWidth)

	Cache[crc] = {
		Instance = instance,
		LastUsed = CurTime()
	}

	return instance
end

hook.Add("Think", "cc2.ScribeCache", function()
	for crc, cache in pairs(Cache) do
		if CurTime() - cache.LastUsed > Timeout then
			Cache[crc] = nil
		end
	end
end)

Core = Core or {}

function Core:Initialize(str, maxWidth)
	self.Pos = {x = 0, y = 0}
	self.Caret = {x = 0, y = 0}
	self.Size = {x = 0, y = 0}

	self.LineHeight = 0
	self.MaxWidth = maxWidth or math.huge

	self.Blocks = {}

	self.Stack = {}
	self.RenderHooks = {}
	self.TextModifiers = {}

	self.Complex = false

	self.Font = DefaultFont
	self.Color = DefaultColor

	self:Parse(str)
end

function Core:ProcessMatch(stack, str)
	if not str or str == "" or str == "<nop>" then
		return
	end

	local order = stack.Order
	local tags = stack.Tags

	if str[1] == "<" then
		string.gsub(str, "<([/%a]*)=?([^>]*)", function(tag, args)
			if tag == "reset" then
				for k in SortedPairsByValue(stack.Order) do
					table.insert(self.Blocks, k)
				end

				stack.Order = {}
				stack.Tags = {}

				return
			end

			local unset = tag[1] == "/"

			if unset then
				tag = string.sub(tag, 2)
			end

			if not Components[tag] then
				return
			end

			tags[tag] = tags[tag] or util.Stack()

			if unset then
				if not tags[tag] or tags[tag]:Size() == 0 then
					return
				end

				local component = tags[tag]:Pop()

				table.insert(self.Blocks, component)

				order[component] = nil
			else
				local component = Components[tag](self, args)

				if not component.Draw then
					tags[tag]:Push(component)
					order[component] = stack.Counter

					stack.Counter = stack.Counter + 1
				end

				table.insert(self.Blocks, component)
			end
		end)
	else
		table.insert(self.Blocks, Components["text"](self, str))
	end
end

function Core:Parse(str)
	self.Blocks = {}

	local stack = {
		Counter = 1,
		Order = {},
		Tags = {}
	}

	(str .. "<nop>"):gsub("([^<>]*)(<[^>]+.)([^<>]*)", function(...)
		for _, v in ipairs({...}) do
			self:ProcessMatch(stack, v)
		end
	end)

	for k in SortedPairsByValue(stack.Order) do
		table.insert(self.Blocks, k)
	end

	self:Recalculate()
end

function Core:Recalculate()
	self.DryRun = true
	self:Draw(0, 0)
	self.DryRun = nil
end

function Core:Newline()
	self.TotalWidth = math.max(self.TotalWidth, self.Caret.x)

	self.Caret.x = 0
	self.Caret.y = self.Caret.y + self.LineHeight

	self.LineHeight = 0

	if self.Console then
		table.insert(self.Buffer, "\n")
	end
end

function Core:SetFont(font)
	self.Font = font

	surface.SetFont(font)
end

function Core:SetColor(color)
	self.Color = color

	surface.SetTextColor(color.r, color.g, color.b, color.a * self.Alpha)
end

-- Stack handling

function Core:PushStack(index, val)
	self.Stack[index] = self.Stack[index] or util.Stack()
	self.Stack[index]:Push(val)
end

function Core:PopStack(index)
	if not self.Stack[index] then
		return
	end

	self.Stack[index]:Pop()

	return self.Stack[index]:Top()
end

function Core:PushColor(color)
	self:PushStack("Color", color)
	self:SetColor(color)
end

function Core:PopColor()
	self:SetColor(self:PopStack("Color") or scribe.DefaultColor)
end

function Core:PushFont(font)
	self:PushStack("Font", font)
	self:SetFont(font)
end

function Core:PopFont()
	self:SetFont(self:PopStack("Font") or scribe.DefaultFont)
end

function Core:PushComplex()
	self:PushStack("Complex", self.Complex)
	self.Complex = true
end

function Core:PopComplex()
	self.Complex = self:PopStack("Complex") or false
end

-- Drawing

function Core:Draw(x, y, alpha, xAlign, yAlign)
	self.Stack = {}
	self.RenderHooks = {}
	self.TextModifiers = {}

	self.Complex = false

	self.Font = scribe.DefaultFont
	self.Color = scribe.DefaultColor

	xAlign = xAlign or TEXT_ALIGN_LEFT
	yAlign = yAlign or TEXT_ALIGN_TOP

	local w, h = self:GetSize()

	if xAlign == TEXT_ALIGN_CENTER then
		x = x - (w * 0.5)
	elseif xAlign == TEXT_ALIGN_RIGHT then
		x = x - w
	end

	if yAlign == TEXT_ALIGN_CENTER then
		y = y - (h * 0.5)
	elseif yAlign == TEXT_ALIGN_BOTTOM then
		y = y - h
	end

	self.Alpha = alpha or 1

	self.Pos.x = x
	self.Pos.y = y

	self.Caret.x = 0
	self.Caret.y = 0

	self.TotalWidth = 0
	self.LineHeight = 0

	self:SetFont(self.Font)
	self:SetColor(self.Color)

	for _, v in ipairs(self.Blocks) do
		if v.Draw then
			v:Draw(self)
		else
			if v.Active then
				v:Pop(self)
				v.Active = false
			else
				v:Push(self)
				v.Active = true
			end
		end
	end

	self:Newline()

	self.Size.x = self.TotalWidth
	self.Size.y = self.Caret.y
end

function Core:PrintToConsole()
	self.Buffer = {DefaultColor}
	self.LastColor = DefaultColor

	self.Console = true
	self:Draw(0, 0)
	self.Console = nil

	MsgC(unpack(self.Buffer))
end

function Core:GetText()
	self.Buffer = {DefaultColor}
	self.LastColor = DefaultColor

	self.Console = true
	self:Draw(0, 0)
	self.Console = nil

	local str = {}

	for _, v in ipairs(self.Buffer) do
		if isstring(v) then
			table.insert(str, v)
		end
	end

	return table.concat(str)
end

function Core:GetSize()
	return self.Size.x, self.Size.y
end

function Core:GetWide()
	return self.Size.x
end

function Core:GetTall()
	return self.Size.y
end
