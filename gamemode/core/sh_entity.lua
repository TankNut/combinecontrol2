local ENTITY = FindMetaTable("Entity")

EntityCache.Add("npcs", function(ent) return ent:IsNPC() end)

function ENTITY:GetPlayerColor()
	if self:IsFakePlayer() then
		return self:GetFakePlayer():GetPlayerColor()
	end

	local func = ENTITY.GetTable(self).GetPlayerColor

	if func then
		return func(self)
	end

	return Vector(0.2, 0.2, 0.2)
end

function GM:InitPostEntity()
	if CLIENT then
		Settings.LoadClient()

		hook.Run("CreateFonts")

		Chat.Create()
		Hud.Rebuild()

		if Settings.Get("Thirdperson") then
			ctp:Enable()
		end

		return
	end

	hook.Run("LoadDatabase")
end

function GM:OnEntityCreated(ent)
	if not IsValid(ent) then
		return
	end

	EntityCache.OnCreated(ent)

	if ent:IsPlayer() then
		Inventory.Init(ent)
		ent:SetupDataTables()
	end

	if SERVER then
		Buttons.OnCreated(ent)

		if ent:IsNPC() then
			Npc.OnCreated(ent)
		elseif ent:IsRagdoll() then
			ent:SetCollisionGroup(COLLISION_GROUP_WEAPON)
		end
	end
end

function GM:EntityRemoved(ent, fullUpdate)
	EntityCache.OnRemoved(ent)

	if not ent:IsPlayer() then
		Buttons.OnRemoved(ent)
	end

	if fullUpdate then
		return
	end

	if ent:IsPlayer() then
		Inventory.Clear(ent, true)
	else
		if SERVER and ent:IsFakePlayer() then
			local ply = ent:GetFakePlayer()

			ply:Kill()
		end
	end

	if SERVER then
		netvar.Clear(ent)
	end
end

function GM:PreRegisterSWEP(swep, class)
	if swep.Itemize then
		local itemClass = swep.ItemClass or string.Replace(class, "_cc", "")

		local data = table.Merge({
			Base = "base_weapon",
			Name = swep.PrintName,
			Model = swep.WorldModel,
			WeaponClass = class
		}, swep.Itemize)

		Item.Register(itemClass, data)
	end

	if SERVER then
		jank(function()
			-- Only firearms can be wielded by NPC's, because reasons
			if not weapons.IsBasedOn(class, "weapon_cc_base_gun") then
				return
			end

			local weapon = weapons.Get(class)

			if weapon.Settings.NoNPC then
				return
			end

			list.Add("NPCUsableWeapons", {
				title = weapon.PrintName,
				class = class,
			})
		end)
	end
end

function GM:PostCleanupMap()
	if SERVER then
		Buttons.Load()
		Doors.Load()
	end
end

if SERVER then
	function GM:EntityTakeDamage(ent, dmginfo)
		if ent:IsPlayer() then
			return hook.Run("PlayerTakeDamage", ent, dmginfo)
		end

		if ent:IsFakePlayer() and not dmginfo:IsDamageType(DMG_CRUSH) then
			RagdollDamage = true
				ent:FakePlayer():TakeDamageInfo(dmginfo)
			RagdollDamage = nil

			return true
		end
	end

	function GM:PostEntityTakeDamage(ent, dmginfo, wasTaken)
		if ent:IsNPC() then
			Npc.OnDamaged(ent, dmginfo)
		end
	end

	function GM:EntityKeyValue(ent, key, value)
		local override = Doors.EntityKeyValue(ent, key, value)

		if override != nil then
			return override
		end
	end
end
