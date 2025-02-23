module("Hull", package.seeall)

List = List or {}
Models = Models or {}

Default = {
	Standing = {Vector(-10, -10, 0), Vector(10, 10, 72), Vector(0, 0, 64)},
	Crouching = {Vector(-10, -10, 0), Vector(10, 10, 36), Vector(0, 0, 38)},
}

PlayerVar.Add("Scale", {Default = 0})
CharacterVar.Add("CharacterScale", {Default = 1, Field = "Scale", DataType = FLOAT()})

local PLAYER = FindMetaTable("Player")

function AddType(name, data)
	data.Standing = data.Standing or Default.Standing
	data.Crouching = data.Crouching or data.Standing

	List[name] = data
end

function AddModel(hull, ...)
	for _, match in ipairs({...}) do
		Models[match] = hull
	end
end

function Find(mdl)
	mdl = string.lower(mdl)

	for match, hull in pairs(Models) do
		if string.find(mdl, match) and List[hull] then
			return List[hull]
		end
	end

	return Default
end

function PLAYER:UpdateHull()
	local hull = Find(self:GetModel())
	local scale = hook.Run("GetPlayerScale", self)

	self:SetModelScale(scale, 0.0001)

	timer.Simple(0, function()
		if not IsValid(self) then
			return
		end

		self:SetHull(hull.Standing[1], hull.Standing[2])
		self:SetHullDuck(hull.Crouching[1], hull.Crouching[2])

		self:SetViewOffset(hull.Standing[3] * scale)
		self:SetViewOffsetDucked(hull.Crouching[3] * scale)
	end)
end

function GM:GetPlayerScale(ply)
	local scale = ply:Scale()

	return scale != 0 and scale or ply:RunCharFlag("PlayerScale")
end

function GM:OnScaleChanged(ply, old, new, loaded)
	if not loaded then
		ply:UpdateHull()
	end
end

function GM:OnCharacterScaleChanged(ply, old, new, loaded)
	if not loaded then
		ply:UpdateHull()
	end
end
