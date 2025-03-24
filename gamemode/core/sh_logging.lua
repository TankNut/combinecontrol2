module("Log", package.seeall)

Types = Types or {}

function AddType(name, callback)
	Types[name] = callback
end
