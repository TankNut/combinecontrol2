module("progress", package.seeall)

Active = Active or {}

function Start(ply, data)
	data.Player = ply

	data.StartTime = data.StartTime or CurTime()
	data.EndTime = data.EndTime or CurTime() + 1

	data.Validate = data.Validate or {}
	data.Fraction = 0

	table.insert(Active, data)

	if data.Callback == nil then
		data.Coroutine = async.Assert()

		return coroutine.yield()
	end
end

function Player(target, options)
	options = options or {}

	local pos = target:GetPos()

	return function(ply)
		if not IsValid(target) then
			return true
		end

		if options.Alive and not target:Alive() then
			return true
		end

		if not options.AllowMove and target:GetPos():Distance(pos) > 2 then
			return true
		end

		if options.Range and not ply:WithinInteractRange(target, options.Range) then
			return true
		end
	end
end

function ShouldAbort(data)
	for _, callback in ipairs(data.Validate) do
		if callback(data.Player) then
			return true
		end
	end
end

function Update(data, time)
	if not IsValid(data.Player) then
		return true
	end

	data.Fraction = math.Clamp(math.TimeFraction(data.StartTime, data.EndTime, time), 0, 1)

	if data.Fraction == 1 or ShouldAbort(data) then
		if data.Coroutine then
			async.Handle(data.Coroutine, data.Fraction)
		else
			data.Callback(data.Fraction)
		end

		return true
	end
end

hook.Add("Think", "progress", function()
	local time = CurTime()
	local index = 1

	for k, v in ipairs(Active) do
		if Update(v, time) then
			Active[k] = nil
		else
			if index != k then
				Active[index] = v
				Active[k] = nil
			end

			index = index + 1
		end
	end
end)
