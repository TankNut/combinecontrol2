local COMPONENT = {
	Name = {"text"}
}

function COMPONENT:Initialize(str)
	self.Text = string.Unescape(str)
	self.Buffer = {}
end

function COMPONENT:Draw()
	local ctx = self.Context
	local caret = ctx.Caret
	local storeBuffer = {}

	self.Buffer = {}

	self.BufferWidth = 0
	self.RenderIndex = 0

	local text = self.Text

	for _, handler in pairs(ctx.TextModifiers) do
		text = handler:ModifyText(self, text)
	end

	if not text then
		return
	end

	for _, code in utf8.codes(text) do
		local char = utf8.char(code)

		if code == 10 then
			self:FlushBuffer(true)

			continue
		end

		local w = surface.GetFontSize(ctx.Font, char)

		if caret.x + self.BufferWidth + w > ctx.MaxWidth then
			local last = string.LastSpace(self.Buffer) -- Does actually work if you pass it a table of characters!

			if last then
				for i = last + 1, #self.Buffer do
					table.insert(storeBuffer, self.Buffer[i])
					self.Buffer[i] = nil
				end

				self:FlushBuffer(true)
				self.Buffer = {}

				for k, v in pairs(storeBuffer) do
					self.Buffer[k] = v
					storeBuffer[k] = nil
				end

				self.BufferWidth = surface.GetFontSize(ctx.Font, table.concat(self.Buffer))
			else
				self:FlushBuffer(true)
			end
		end

		self.Buffer[#self.Buffer + 1] = char
		self.BufferWidth = self.BufferWidth + w
	end

	self:FlushBuffer()
end

function COMPONENT:FlushBuffer(newline)
	local ctx = self.Context

	if self.BufferWidth == 0 then
		if newline then
			if ctx.LineHeight == 0 then
				local _, h = surface.GetFontSize(ctx.Font, "a")

				ctx.LineHeight = h
			end

			ctx:Newline()
		end

		return
	end

	local caret = ctx.Caret
	local pos = ctx.Pos

	if ctx.Complex then
		for _, v in ipairs(self.Buffer) do
			self.RenderIndex = self.RenderIndex + 1

			local w, h = surface.GetFontSize(ctx.Font, v)

			local data = {
				Text = v,
				x = pos.x + caret.x,
				y = pos.y + caret.y,
				w = w,
				h = h
			}

			local skip = false

			for _, handler in pairs(ctx.RenderHooks) do
				if handler.PreDrawText and handler:PreDrawText(self, data) then
					skip = true
				end
			end

			if not skip then
				self:DrawText(data.Text, data.x, data.y)
			end

			for _, handler in pairs(ctx.RenderHooks) do
				if handler.PostDrawText then
					handler:PostDrawText(self, data)
				end
			end

			ctx.LineHeight = math.max(ctx.LineHeight, data.h)
			caret.x = caret.x + data.w
		end
	else
		self.RenderIndex = self.RenderIndex + 1

		local text = table.concat(self.Buffer)
		local w, h = surface.GetFontSize(ctx.Font, text)

		local data = {
			Text = text,
			x = pos.x + caret.x,
			y = pos.y + caret.y,
			w = w,
			h = h
		}

		local skip = false

		for _, handler in pairs(ctx.RenderHooks) do
			if handler.PreDrawText and handler:PreDrawText(self, data) then
				skip = true
			end
		end

		if not skip then
			self:DrawText(data.Text, data.x, data.y)
		end

		for _, handler in pairs(ctx.RenderHooks) do
			if handler.PostDrawText then
				handler:PostDrawText(self, data)
			end
		end

		ctx.LineHeight = math.max(ctx.LineHeight, data.h)
		caret.x = caret.x + data.w
	end

	self.Buffer = {}
	self.BufferWidth = 0

	if newline then
		ctx:Newline()
	end
end

scribe.Register(COMPONENT)
