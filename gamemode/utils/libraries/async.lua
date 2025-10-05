module("async", package.seeall)

function Assert()
	local cr = coroutine.running()

	if not cr then
		error("Function requires an async context but doesn't have one", 3)
	end

	return cr
end

function Start(func, ...)
	Handle(coroutine.create(func), ...)
end

function Wait(delay)
	local cr = Assert()

	timer.Simple(delay, function()
		Handle(cr)
	end)

	return coroutine.yield()
end

function Handle(cr, ...)
	if coroutine.status(cr) == "dead" then
		return
	end

	local args = {coroutine.resume(cr, ...)}
	local ok = table.remove(args, 1)

	if not ok then
		ErrorNoHalt("\n", debug.traceback(cr, "[ERROR] " .. args[1]), "\n")
	end
end
