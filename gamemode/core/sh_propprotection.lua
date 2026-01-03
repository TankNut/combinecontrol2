local PLAYER = FindMetaTable("Player")
local ENTITY = FindMetaTable("Entity")

EntityVar.Add("OwnerID", {})
EntityVar.Add("OwnerName", {})

function ENTITY:GetCreator()
	local val = self.m_PlayerCreator

	if IsValid(val) then
		return val
	elseif val == nil then -- No owner
		return nil
	else -- Offline/missing player
		val = player.GetBySteamID(self:OwnerID()) -- We optimize this it's fiiiiine

		if val then
			self.m_PlayerCreator = val

			return val
		end

		return NULL
	end
end

function PLAYER:IsCreator(ent)
	return self:SteamID() == ent:OwnerID()
end

if SERVER then
	function ENTITY:SetCreator(ply)
		if self:EntIndex() == 0 then
			return
		end

		if IsValid(ply) and ply:IsPlayer() then
			self:SetOwnerID(ply:SteamID())
			self:SetOwnerName(ply:VisibleRPName())
		else
			self:SetOwnerID(nil)
			self:SetOwnerName(nil)
		end
	end

	if not cleanup.ccAdd then
		cleanup.ccAdd = cleanup.Add
	end

	function cleanup.Add(ply, name, ent)
		if IsValid(ent) then
			ent:SetCreator(ply)
		end

		return cleanup.ccAdd(ply, name, ent)
	end

	if not PLAYER.ccAddCount then
		PLAYER.ccAddCount = PLAYER.AddCount
	end

	function PLAYER:AddCount(name, ent)
		ent:SetCreator(self)

		return PLAYER.ccAddCount(self, name, ent)
	end

	local undoList = {}
	local undoPlayer

	if not undo.ccHooked then
		undo.ccAddEntity = undo.AddEntity
		undo.ccSetPlayer = undo.SetPlayer
		undo.ccFinish = undo.Finish

		undo.ccHooked = true
	end

	function undo.AddEntity(ent)
		table.insert(undoList, ent)

		undo.ccAddEntity(ent)
	end

	function undo.SetPlayer(ply)
		undoPlayer = ply

		undo.ccSetPlayer(ply)
	end

	function undo.Finish(name)
		for _, ent in ipairs(undoList) do
			ent:SetCreator(undoPlayer)
		end

		undoList = {}
		undoPlayer = nil

		undo.ccFinish(name)
	end
end

function GM:OnOwnerIDChanged(ent, old, new, loaded)
	if new == nil then
		ent.m_PlayerCreator = nil
	else
		ent.m_PlayerCreator = player.GetBySteamID(new)
	end
end
