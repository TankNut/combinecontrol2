GM.ConnectMessages = {}
GM.EntryPortSpawns = {}

local files = file.Find(GM.FolderName .. "/gamemode/maps/" .. game.GetMap() .. ".lua", "LUA", "namedesc")

if #files > 0 then
	for _, v in pairs(files) do
		include("maps/" .. v)
	end

	MsgC(Color(200, 200, 200, 255), "Clientside map lua file for " .. game.GetMap() .. " loaded.\n")
else
	MsgC(Color(200, 200, 200, 255), "Warning: No clientside map lua file for " .. game.GetMap() .. ".\n")
end

if not GM.CurrentLocation then
	GM.CurrentLocation = LOCATION_CITY
end

function GM:CreateParticleEmitters()
	if not self.Emitter2D then

		self.Emitter2D = ParticleEmitter(LocalPlayer():GetPos())

	else

		self.Emitter2D:SetPos(LocalPlayer():GetPos())

	end

	if not self.Emitter3D then

		self.Emitter3D = ParticleEmitter(LocalPlayer():GetPos(), true)

	else

		self.Emitter3D:SetPos(LocalPlayer():GetPos())

	end
end
