local ANGLE = FindMetaTable("Angle")

function ANGLE:Approach(dest, speed)
	self.p = math.ApproachSpeed(self.p, dest.p, speed)
	self.y = math.ApproachSpeed(self.y, dest.y, speed)
	self.r = math.ApproachSpeed(self.r, dest.r, speed)

	return self
end

function ANGLE:LengthSqr()
	return self.p^2 + self.y^2 + self.z^2
end

function ANGLE:ViewClamp()
	self.p = math.Clamp(self.p, -89, 89)
	self.y = math.Clamp(self.y, -179, 179)
	self.r = math.Clamp(self.r, -89, 89)
end

function ANGLE:NormalizeAngle()
	self.p = math.NormalizeAngle(self.p)
	self.y = math.NormalizeAngle(self.y)
	self.r = math.NormalizeAngle(self.r)
end

function ANGLE:SetPitch(p) self.p = p return self end
function ANGLE:SetYaw(y) self.y = y return self end
function ANGLE:SetRoll(r) self.r = r return self end

function ANGLE:AddPitch(p) self.p = self.p + p return self end
function ANGLE:AddYaw(y) self.y = self.y + y return self end
function ANGLE:AddRoll(r) self.r = self.r + r return self end

function ANGLE:SubPitch(p) self.p = self.p - p return self end
function ANGLE:SubYaw(y) self.y = self.y - y return self end
function ANGLE:SubRoll(r) self.r = self.r - r return self end

function ANGLE:MulPitch(p) self.p = self.p * p return self end
function ANGLE:MulYaw(y) self.y = self.y * y return self end
function ANGLE:MulRoll(r) self.r = self.r * r return self end

function ANGLE:DivPitch(p) self.p = self.p / p return self end
function ANGLE:DivYaw(y) self.y = self.y / y return self end
function ANGLE:DivRoll(r) self.r = self.r / r return self end

function ANGLE:CheckNaN()
	if self.p != self.p then self.p = 0 end
	if self.y != self.y then self.y = 0 end
	if self.r != self.r then self.r = 0 end
end
