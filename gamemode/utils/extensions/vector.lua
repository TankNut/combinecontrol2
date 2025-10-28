local VECTOR = FindMetaTable("Vector")

function VECTOR:Approach(dest, speed)
	self.x = math.ApproachSpeed(self.x, dest.x, speed)
	self.y = math.ApproachSpeed(self.y, dest.y, speed)
	self.z = math.ApproachSpeed(self.z, dest.z, speed)

	return self
end

function VECTOR:SetX(x) self.x = x return self end
function VECTOR:SetY(y) self.y = y return self end
function VECTOR:SetZ(z) self.z = z return self end

function VECTOR:AddX(x) self.x = self.x + x return self end
function VECTOR:AddY(y) self.y = self.y + y return self end
function VECTOR:AddZ(z) self.z = self.z + z return self end

function VECTOR:SubX(x) self.x = self.x - x return self end
function VECTOR:SubY(y) self.y = self.y - y return self end
function VECTOR:SubZ(z) self.z = self.z - z return self end

function VECTOR:MulX(x) self.x = self.x * x return self end
function VECTOR:MulY(y) self.y = self.y * y return self end
function VECTOR:MulZ(z) self.z = self.z * z return self end

function VECTOR:DivX(x) self.x = self.x / x return self end
function VECTOR:DivY(y) self.y = self.y / y return self end
function VECTOR:DivZ(z) self.z = self.z / z return self end

function VECTOR:GetReflection(normal)
	local factor = -2 * normal:Dot(self)

	return Vector(factor * normal.x + self.x,
		factor * normal.y + self.y,
		factor * normal.z + self.z)
end
