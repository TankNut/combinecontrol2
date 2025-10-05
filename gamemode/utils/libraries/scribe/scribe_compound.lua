local COMPONENT = {
	Name = {"compound"},
	Components = {}
}

function COMPONENT:Initialize()
	self._Components = {}

	for k, v in pairs(self.Components) do
		self._Components[k] = scribe.Components[v[1]](self.Context, unpack(v, 2))
	end
end

function COMPONENT:Push()
	for _, component in SortedPairs(self._Components) do
		component:Push()
	end
end

function COMPONENT:Pop()
	for _, component in SortedPairs(self._Components, true) do
		component:Pop()
	end
end

scribe.Register(COMPONENT)
