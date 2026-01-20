local ENTITY = FindMetaTable("Entity")

function ENTITY:ClearBodyGroups()
	for i = 0, self:GetNumBodyGroups() - 1 do
		self:SetBodygroup(i, 0)
	end
end

function ENTITY:SetBodygroupList(data)
	for _, bodygroup in ipairs(self:GetBodyGroups()) do
		self:SetBodygroup(bodygroup.id, math.min(data[bodygroup.name] or 0, bodygroup.num - 1))
	end
end

function ENTITY:SetMaterials(mats)
	self:SetSubMaterial()

	if isstring(mats) then
		self:SetMaterial(mats)

		return
	end

	self:SetMaterial("")

	if istable(mats) then
		local materials = util.GetModelMaterials(self:GetModel())

		for index, mat in pairs(materials) do
			if mats[mat] then
				self:SetSubMaterial(index - 1, mats[mat])
			end
		end
	end
end

function ENTITY:CopyModel(to)
	local data = {
		Model = self:GetModel()
	}

	local skinIndex = self:GetSkin()

	if skinIndex > 0 then
		data.Skin = skinIndex
	end

	local materialOverride = self:GetMaterial()

	if #materialOverride > 0 then
		data.Materials = materialOverride
	else
		local materials = self:GetMaterials()
		local submaterials = {}

		for k, material in ipairs(materials) do
			local submaterial = self:GetSubMaterial(k - 1)

			if #submaterial > 0 then
				submaterials[material] = submaterial
			end
		end

		if table.Count(submaterials) > 0 then
			data.Materials = submaterials
		end
	end

	local color = self:GetColor()

	if color != color_white then
		data.EntityColor = color
	end

	local playerColor = self:GetPlayerColor():ToColor()

	if playerColor != color_white then
		data.Color = playerColor
	end

	local bodygroups = {}

	for _, bodygroup in ipairs(self:GetBodyGroups()) do
		local index = self:GetBodygroup(bodygroup.id)

		if index > 0 then
			bodygroups[bodygroup.name] = index
		end
	end

	if table.Count(bodygroups) > 0 then
		data.Bodygroups = bodygroups
	end

	if to then
		to:ApplyModel(data)
	else
		return data
	end
end

function ENTITY:ApplyModel(data)
	if data.Model then
		self:SetModel(data.Model)
	end

	self:SetSkin(data.Skin or 0)

	self:SetBodygroupList(data.Bodygroups or {})
	self:SetMaterials(data.Materials)

	local color = data.Color or color_white
	local vec = color:ToVector()

	if self:IsPlayer() then
		self:SetPlayerColor(vec)
	else
		self.GetPlayerColor = function() return vec end
	end

	self:SetColor(data.EntityColor or color_white)
end

if SERVER then
	function ENTITY:SetForceTransmit(force)
		if force then
			self:AddEFlags(EFL_IN_SKYBOX)
		else
			self:RemoveEFlags(EFL_IN_SKYBOX)
		end
	end

	function ENTITY:ScaleMaxHealth(newMax)
		local ratio = self:Health() / self:GetMaxHealth()
		local newValue = math.Round(ratio * newMax)

		self:SetMaxHealth(newMax)
		self:SetHealth(math.max(newValue, 1))
	end
end

function ENTITY:PhysFreeze()
	local phys = self:GetPhysicsObject()

	if not IsValid(phys) then
		return
	end

	phys:EnableMotion(false)
	phys:Sleep()
end

function ENTITY:IsType(base)
	if self:IsWeapon() then
		return weapons.IsType(self:GetClass(), base)
	else
		return scripted_ents.IsType(self:GetClass(), base)
	end
end

function ENTITY:UpdatePos(x, y, z)
	local pos = self:GetPos()

	if x != nil then pos.x = x end
	if y != nil then pos.y = y end
	if z != nil then pos.z = z end

	self:SetPos(pos)
end

function ENTITY:UpdateAngles(p, y, r)
	local ang = self:GetAngles()

	if p != nil then ang.p = p end
	if y != nil then ang.y = y end
	if r != nil then ang.r = r end

	self:SetAngles(ang)
end

for k, v in ipairs({"Pitch", "Yaw", "Roll"}) do
	ENTITY["Get" .. v] = function(self)
		return self:GetAngles()[v]
	end

	ENTITY["Set" .. v] = function(self, val)
		local ang = self:GetAngles()

		ang[k] = val

		self:SetAngles(ang)
	end
end

for k, v in ipairs({"X", "Y", "Z"}) do
	ENTITY["Get" .. v] = function(self)
		return self:GetPos()[v]
	end

	ENTITY["Set" .. v] = function(self, val)
		local pos = self:GetPos()

		pos[k] = val

		self:SetPos(pos)
	end
end
