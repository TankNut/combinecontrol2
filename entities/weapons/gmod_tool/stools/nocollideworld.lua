TOOL.Category = "Construction"
TOOL.Name     = "#tool.nocollideworld.name"

if CLIENT then
	TOOL.Information = {
		{ name = "left" },
		{ name = "right" }
	}

	language.Add("tool.nocollideworld.name", "No Collide World")
	language.Add("tool.nocollideworld.desc", "Disable collisions between a prop and the world")
	language.Add("tool.nocollideworld.panel", "Optionally enable or disable collisions between a prop and the world")
	language.Add("tool.nocollideworld.left", "Select an object to disable world collisions")
	language.Add("tool.nocollideworld.right", "Restore world collision to an object")
end

local function IsValidConstraintTarget(ent, bone)
	if not IsValid(ent) or ent:IsPlayer() or ent:IsWorld() or ent:IsNPC() then
		return false
	end

	if CLIENT then
		return true
	end

	return util.IsValidPhysicsObject(ent, bone)
end

local function FindOrCreateConstraintSystem(parent, child)
	local constaintSystem

	if not parent:IsWorld() and parent:GetTable().ConstraintSystem and parent:GetTable().ConstraintSystem:IsValid() then
		constaintSystem = parent:GetTable().ConstraintSystem

		if constaintSystem:IsValid() and constaintSystem:GetVar("constraints", 0) > 100 then
			constaintSystem = nil
		end
	end

	if not constaintSystem and not child:IsWorld() and child:GetTable().ConstraintSystem and child:GetTable().ConstraintSystem:IsValid() then
		constaintSystem = child:GetTable().ConstraintSystem

		if constaintSystem:IsValid() and constaintSystem:GetVar("constraints", 0) > 100 then
			constaintSystem = nil
		end
	end

	if not constaintSystem or not constaintSystem:IsValid() then
		constaintSystem = ents.Create("phys_constraintsystem")

		constaintSystem:SetKeyValue("additionaliterations", GetConVar("gmod_physiterations"):GetInt())
		constaintSystem:Spawn()
		constaintSystem:Activate()
	end

	parent.ConstraintSystem = constaintSystem
	child.ConstraintSystem = constaintSystem

	constaintSystem.UsedEntities = constaintSystem.UsedEntities or {}
	table.insert(constaintSystem.UsedEntities, parent)
	table.insert(constaintSystem.UsedEntities, child)

	constaintSystem:SetVar("constraints", constaintSystem:GetVar("constraints", 0) + 1)

	return constaintSystem
end

local function CreateNoCollideWorldConstraint(ent, bone)
	if not ent:IsValid() then
		return false
	end

	local world = game.GetWorld()
	local worldBone = 0

	local entPhysicsObject = ent:GetPhysicsObjectNum(bone)
	local worldPhysicsObject = world:GetPhysicsObjectNum(worldBone)

	if not IsValid(entPhysicsObject) or not IsValid(worldPhysicsObject) then
		return false
	end

	local constraints = ent:GetTable().Constraints

	if constraints then
		for _, link in pairs(constraints) do
			if link:IsValid() or link == world then
				local tab = link:GetTable()

				if tab.Type == "NoCollideWorld" and tab.Ent1 == ent then
					return false
				end
			end
		end
	end

	SetPhysConstraintSystem(FindOrCreateConstraintSystem(ent, world))
	local physicsEntity = ents.Create("phys_ragdollconstraint")
		physicsEntity:SetKeyValue("xmin", -180)
		physicsEntity:SetKeyValue("xmax", 180)
		physicsEntity:SetKeyValue("ymin", -180)
		physicsEntity:SetKeyValue("ymax", 180)
		physicsEntity:SetKeyValue("zmin", -180)
		physicsEntity:SetKeyValue("zmax", 180)
		physicsEntity:SetKeyValue("spawnflags", 3)
		physicsEntity:SetPhysConstraintObjects(entPhysicsObject, worldPhysicsObject)
		physicsEntity:Spawn()
		physicsEntity:Activate()
	SetPhysConstraintSystem(NULL)

	constraint.AddConstraintTable(ent, physicsEntity, world)

	local tab = {
		Type = "NoCollideWorld",
		Ent1 = ent,
		Bone1 = bone
	}

	physicsEntity:SetTable(tab)

	return physicsEntity
end
duplicator.RegisterConstraint("NoCollideWorld", CreateNoCollideWorldConstraint, "Ent1", "Bone1")

function TOOL:LeftClick(tr)
	local ent = tr.Entity
	local bone = tr.PhysicsBone
	local ply = self:GetOwner()

	if not IsValidConstraintTarget(ent, bone) or not ply:CheckLimit("constraints") then
		return false
	end

	if SERVER then
		local constr = CreateNoCollideWorldConstraint(ent, bone)

		if not constr then
			return false
		end

		undo.Create("No Collide World")
			undo.AddEntity(constr)
			undo.SetPlayer(ply)
		undo.Finish()

		ply:AddCount("constraints", constr)

		DoPropSpawnedEffect(ent)
	end

	return true
end

function TOOL:RightClick(tr)
	local ent = tr.Entity
	local bone = tr.PhysicsBone

	if not IsValidConstraintTarget(ent, bone) then
		return false
	end

	if SERVER and constraint.FindConstraint(ent, "NoCollideWorld") ~= nil then
		constraint.RemoveConstraints(ent, "NoCollideWorld")
	end

	return true
end

function TOOL:Reload(tr)
	return false
end

function TOOL.BuildCPanel(panel)
	panel:AddControl("Header", {
		Text = "#tool.nocollideworld.name",
		Description = "#tool.nocollideworld.panel"
	})
end
