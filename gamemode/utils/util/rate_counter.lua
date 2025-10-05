local CLASS = CustomMetaTable("RateCounter")

function CLASS:Add(i)
	-- Clean out old entries
	while self.Queue:Count() > 0 and CurTime() - self.Queue:Peek()[1] > self.MaxTimer do
		self.Queue:Pop()
	end

	self.Queue:Push({CurTime(), i or 1})
end

function CLASS:GetData()
	local counts = {}
	local now = CurTime()

	for _, time in pairs(self.Timers) do
		counts[time] = {
			Count = 0,
			Average = 0,
			Total = 0,
			Median = 0
		}
	end

	for _, entry in pairs(self.Queue.Items) do
		for time, data in pairs(counts) do
			if now - entry[1] > time then -- Check if we're valid
				continue
			end

			data.Count = data.Count + 1
			data.Total = data.Total + entry[2]
		end
	end

	for _, data in pairs(counts) do
		if data.Count > 0 then
			data.Average = data.Total / data.Count

			local sorted = table.Map(self.Queue.Items, function(entry) return entry[2] end)
			table.sort(sorted)

			local index = #sorted / 2

			if index % 1 == 0 then
				data.Median = sorted[index]
			else
				data.Median = (sorted[index - 0.5] + sorted[index + 0.5]) / 2
			end
		end
	end

	return counts
end

function util.RateCounter(...)
	local timers = {...}
	local max = 0

	for _, v in ipairs(timers) do
		max = math.max(max, v)
	end

	return setmetatable({
		Queue = util.Queue(),
		MaxTimer = max,
		Timers = timers
	}, CLASS)
end
