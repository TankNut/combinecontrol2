-- 5/25/2013

DeriveGamemode("sandbox")

GM.Name = "CombineControl: TnB"
GM.Author = "Taco N Banana"
GM.Website = "http://taconbanana.com"
GM.Email = "gangleider@taconbanana.com"

function GM:GetGameDescription()
	return self.Name
end

local ENTITY = FindMetaTable("Entity")

function ENTITY:IsDoor()
	if self:GetClass() == "prop_door_rotating" then return true end
	if self:GetClass() == "func_door_rotating" then return true end
	if self:GetClass() == "func_door" then return true end

	return false
end

function GM:GetHandTrace(ply, len)
	local trace = {}
	trace.start = ply:EyePos()
	trace.endpos = trace.start + ply:GetAimVector() * (len or 50)
	trace.filter = ply

	return util.TraceLine(trace)
end
