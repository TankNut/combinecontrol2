local PANEL = {}

AccessorFunc(PANEL, "AllowManipulation", "AllowManipulation")

AccessorFunc(PANEL, "CamPosRange", "CamPosRange")
AccessorFunc(PANEL, "LookAtRange", "LookAtRange")
AccessorFunc(PANEL, "FOVRange", "FOVRange")

AccessorFunc(PANEL, "BaseYaw", "BaseYaw")
AccessorFunc(PANEL, "Player", "Player")

function PANEL:Init()
	self:SetCamPosRange({Vector(100, 0, 50), Vector(50, 0, 64)})
	self:SetLookAtRange({Vector(0, 0, 36), Vector(0, 0, 64)})
	self:SetFOVRange({45, 25})

	self:SetBaseYaw(0)

	self.MouseYaw = 0
	self.YawAdd = 0
	self.Zoom = 0.6

	hook.Add("OnAppearanceChanged", self, self.OnAppearanceChanged)
end

function PANEL:OnAppearanceChanged(ply, old, new)
	if ply != self:GetPlayer() then
		return
	end

	self:SetAppearance(new)
end

function PANEL:SetPlayer(ply)
	self:SetAppearance(ply:Appearance())
	self.Player = ply
end

function PANEL:SetEntity(ent)
	DModelPanel.SetEntity(self, ent)

	ent.PanelLayoutDone = false
end

function PANEL:SetModel(mdl)
	local cycle = math.random()
	local ent = self.Entity

	if IsValid(ent) then
		cycle = ent:GetCycle()

		part.Clear(ent)

		if ent:GetModel() == mdl then
			return
		end
	end

	DModelPanel.SetModel(self, mdl)

	ent = self.Entity
	ent:SetCycle(cycle)

	local views = ModelData.GetViews(mdl)

	self:SetCamPosRange(views.CamPos)
	self:SetLookAtRange(views.LookAt)

	if views.Sequence then
		ent:ResetSequence(ent:LookupSequence(views.Sequence))
	end
end

function PANEL:SetAppearance(appearance)
	local base = assert(appearance._base, "SetAppearance somehow ended up without _base model data!")

	self:SetModel(base.Model)

	local ent = self:GetEntity()

	ent:ApplyModel(base)

	local outfit = {}

	for name, data in pairs(appearance) do
		if name == "_base" then
			continue
		end

		if data.Bonemerge == nil then
			data.Bonemerge = true
		end

		outfit[name] = data
	end

	part.Add(ent, "appearance", outfit)
end

function PANEL:PostDrawModel(ent)
	part.Draw(ent)
end

function PANEL:GetCameraTarget()
	local pos = LerpVector(self.Zoom, unpack(self.CamPosRange))
	local look = LerpVector(self.Zoom, unpack(self.LookAtRange))

	local fov = Lerp(self.Zoom, unpack(self.FOVRange))
	local ratio = self:GetWide() / self:GetTall()

	return self.Entity:GetPos() + pos, self.Entity:LocalToWorld(look), fov * ratio
end

function PANEL:LayoutEntity(ent)
	if not ent.PanelLayoutDone then
		ent:SetAngles(Angle(0, self:GetBaseYaw(), 0))
	end

	local pos, look, fov = self:GetCameraTarget()

	if not ent.PanelLayoutDone then
		ent.PanelLayoutDone = true

		self:SetCamPos(pos)
		self:SetLookAt(look)
		self:SetFOV(fov)
	end

	self:SetCamPos(self:GetCamPos():Approach(pos, 10))
	self:SetLookAt(self:GetLookAt():Approach(look, 10))
	self:SetFOV(math.ApproachSpeed(self:GetFOV(), fov, 10))

	local ang = Angle(0, self:GetBaseYaw(), 0)

	if self.Dragging then
		self.MouseYaw = self.MouseYaw + self:GetMouseDrag()
	end

	self.YawAdd = math.ApproachSpeed(self.YawAdd, self.MouseYaw, 30)

	ang:Sub(Angle(0, self.YawAdd, 0))

	local att = ent:GetAttachment(ent:LookupAttachment("eyes"))

	if att then
		local height = att and att.Pos.z or 64
		local dir = att.Ang:Forward() or ent:GetForward()

		ent:SetEyeTarget(Vector(0, 0, height) + dir * 50)
	end

	ent:SetAngles(ang)
	ent:FrameAdvance()
end

function PANEL:OnMouseWheeled(delta)
	if delta > 0 then
		self.Zoom = math.Approach(self.Zoom, 1, 0.2)
	else
		self.Zoom = math.Approach(self.Zoom, 0, 0.2)
	end
end

function PANEL:GetMouseDrag()
	if not self.Dragging then
		return 0
	end

	local offset = gui.MouseX() - self.DragStart
	local diff = self.LastDrag - offset

	self.LastDrag = offset

	return diff
end

function PANEL:OnMousePressed(mouse)
	if self.AllowManipulation then
		if mouse == MOUSE_LEFT then
			self:MouseCapture(true)

			self.Dragging = true
			self.DragStart = gui.MouseX()
			self.LastDrag = 0
		else
			self.YawAdd = math.NormalizeAngle(self.YawAdd)
			self.MouseYaw = 0
		end
	end
end

function PANEL:OnMouseReleased()
	self:MouseCapture(false)
	self.Dragging = false
end

vgui.Register("CC_CharacterModel", PANEL, "DModelPanel")
