local CLASS = CustomMetaTable("Queue")

function CLASS:Push(item)
	local index = self.Last + 1

	self.Last = index
	self.Items[index] = item
end

function CLASS:Pop()
	local index = self.First

	if index > self.Last then
		return nil -- Empty
	end

	local item = self.Items[index]

	self.Items[index] = nil
	self.First = index + 1

	return item
end

function CLASS:Peek()
	return self.Items[self.First]
end

function CLASS:Count()
	return self.Last - self.First + 1
end

function util.Queue()
	return setmetatable({
		First = 0,
		Last = -1,
		Items = {}
	}, CLASS)
end
