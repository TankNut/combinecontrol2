module("deferred", package.seeall)

local logger = log.Create("deferred")

Timers = Timers or {}

function Call(name, delay, callback)
	local index = "deferred." .. name

	if timer.Exists(index) then
		logger:Debug("Overwrite: %s (%s)", name, string.NiceTime(delay))
	else
		logger:Debug("New: %s (%s)", name, string.NiceTime(delay))
	end

	timer.Create(index, delay, 1, function()
		if not Timers[name] then
			return
		end

		logger:Info("Running callback: %s", name)

		callback()

		Timers[name] = nil
	end)

	Timers[name] = callback
end

function Cancel(name)
	local index = "deferred." .. name

	if timer.Exists(index) then
		logger:Info("Cancelling callback: %s", name)

		timer.Remove(index)
		Timers[name] = nil
	end
end

function Force()
	logger:Info("Force-running pending calls")

	for name, callback in pairs(Timers) do
		logger:Debug("Running forced callback: %s", name)

		timer.Remove("deferred." .. name)
		callback()
	end

	Timers = {}
end

hook.Add("ShutDown", "cc2.ForceDeferred", Force)
hook.Add("PreCleanupMap", "cc2.ForceDeferred", Force)
