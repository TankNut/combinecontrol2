local COMPONENT = {
	Name = {}
}

function COMPONENT:Initialize()
end

function COMPONENT:AddHandler(handler)
	local index = #self.Context[handler] + 1

	self.Handlers[handler] = index
	self.Context[handler][index] = self
end

function COMPONENT:RemoveHandler(handler)
	self.Context[handler][self.Handlers[handler]] = nil
	self.Handlers[handler] = nil
end

function COMPONENT:AddRenderHook() self:AddHandler("RenderHooks") end
function COMPONENT:RemoveRenderHook() self:RemoveHandler("RenderHooks") end

function COMPONENT:AddTextModifier() self:AddHandler("TextModifiers") end
function COMPONENT:RemoveTextModifier() self:RemoveHandler("TextModifiers") end

function COMPONENT:Push() end
function COMPONENT:Pop() end

function COMPONENT:ModifyText(part, text) return text end

function COMPONENT:DrawText(text, x, y, effect)
	if self.Context.Console and not effect then
		local buffer = self.Context.Buffer
		local color = self.Context.Color

		if color != self.Context.LastColor then
			self.Context.LastColor = color

			table.insert(buffer, color)
		end

		table.insert(buffer, text)
	elseif not self.Context.DryRun then
		surface.SetTextPos(x, y)
		surface.DrawText(text)
	end
end

scribe.BaseComponent = COMPONENT
