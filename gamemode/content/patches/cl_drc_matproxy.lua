local function resolveEntity(ent)
	if IsValid(ent) and ent:GetClass() == "viewmodel" then
		return ent:GetOwner():GetActiveWeapon()
	end

	return ent
end

local function getHeat(ent)
	return IsValid(ent) and ent.GetHeat and ent:GetHeat() or 0
end

local function getClip1(ent)
	if not IsValid(ent) or not ent:IsWeapon() then
		return 0
	end

	return math.Clamp(ent:Clip1() / ent:GetMaxClip1(), 0, 1)
end

matproxy.Add({
	name = "drc_CurHeat",
	init = function(self, mat, values)
		self.ResultTo = values.resultvar
		self.MinVec = mat:GetVector("$colourfrom") or Vector(0, 0, 0)
		self.MaxVec = mat:GetVector("$colourto") or Vector(0, 0, 0)
		self.MulInt = mat:GetFloat("$colourmul") or 1
	end,
	bind = function(self, mat, ent)
		mat:SetVector(self.ResultTo, LerpVector(getHeat(resolveEntity(ent)), self.MinVec, self.MaxVec) * self.MulInt)
	end
} )

matproxy.Add({
	name = "drc_ScrollHeat",
	init = function(self, mat, values)
		self.ResultTo = values.resultvar

		self.FlipVar = mat:GetFloat("$flipscroll") or 0
		self.VarMult = mat:GetFloat("$scrollmult") or 1
		self.LerpPower = mat:GetFloat("$scroll_ls") or 1
	end,
	bind = function(self, mat, ent)
		local target = getHeat(resolveEntity(ent)) / 2 * self.VarMult

		if IsValid(ent) then
			target = Lerp(RealFrameTime() * (self.LerpPower * 2.5), ent.drc_ScrollHeat or target, target)

			ent.drc_ScrollHeat = target
		end

		if self.FlipVar == 0 then
			mat:SetVector(self.ResultTo, Vector(target, 0, 0))
		else
			mat:SetVector(self.ResultTo, Vector(-target, 0, 0))
		end
	end
})

-- Approximate DRCFunction implementation
local MATTYPE_VECTOR = 0
local MATTYPE_STRING = 1
local MATTYPE_NUMBER = 2
local MATTYPE_TEXTURE = 3
local MATTYPE_TRANSLATE = 4

local materialTypes = {
	["$basetexture"] = MATTYPE_TEXTURE,
	["$bumpmap"] = MATTYPE_TEXTURE,
	["$normalmap"] = MATTYPE_TEXTURE,
	["$lightwarptexture"] = MATTYPE_TEXTURE,
	["$detail"] = MATTYPE_TEXTURE,
	["$detailscale"] = MATTYPE_NUMBER,
	["$detailblendmode"] = MATTYPE_NUMBER,
	["$detailblendfactor"] = MATTYPE_NUMBER,
	["$color"] = MATTYPE_VECTOR,
	["$color2"] = MATTYPE_VECTOR,
	["$blendtintbybasealpha"] = MATTYPE_NUMBER,
	["$blendtintcoloroverbase"] = MATTYPE_NUMBER,
	["$phong"] = MATTYPE_NUMBER,
	["$phongexponent"] = MATTYPE_NUMBER,
	["$phongboost"] = MATTYPE_NUMBER,
	["$phongtint"] = MATTYPE_VECTOR,
	["$phongfresnelranges"] = MATTYPE_VECTOR,
	["$phongexponenttexture"] = MATTYPE_TEXTURE,
	["$phongexponentfactor"] = MATTYPE_NUMBER,
	["$phongwarptexture"] = MATTYPE_TEXTURE,
	["$phongdisablehalflambert"] = MATTYPE_NUMBER,
	["$phongalbedotint"] = MATTYPE_NUMBER,
	["$phongalbedoboost"] = MATTYPE_NUMBER,
	["$basemapalphaphongmask"] = MATTYPE_NUMBER,
	["$basemapalphaenvmapmask"] = MATTYPE_NUMBER,
	["$normalmapalphaenvmapmask"] = MATTYPE_NUMBER,
	["$envmap"] = MATTYPE_STRING,
	["$envmaptint"] = MATTYPE_VECTOR,
	["$selfillum"] = MATTYPE_NUMBER,
	["$selfillumtint"] = MATTYPE_VECTOR,
	["$emissiveblendenabled"] = MATTYPE_NUMBER,
	["$emissiveblendtexture"] = MATTYPE_TEXTURE,
	["$emissiveblendbasetexture"] = MATTYPE_TEXTURE,
	["$emissiveblendflowtexture"] = MATTYPE_TEXTURE,
	["$emissiveblendtint"] = MATTYPE_VECTOR,
	["$emissiveblendstrength"] = MATTYPE_NUMBER,
	["$emissiveblendscrollvector"] = MATTYPE_VECTOR,
	["$rimlight"] = MATTYPE_NUMBER,
	["$rimlightexponent"] = MATTYPE_NUMBER,
	["$rimlightboost"] = MATTYPE_NUMBER,
	["$cloakpassenabled"] = MATTYPE_NUMBER,
	["$cloakfactor"] = MATTYPE_NUMBER,
	["$cloakcolortint"] = MATTYPE_VECTOR,
	["$refractamount"] = MATTYPE_NUMBER,
	["$refracttint"] = MATTYPE_VECTOR,
	["$frame"] = MATTYPE_NUMBER,
	-- These few below technically don't exist, but are the most common used for translations
	["$angle"] = MATTYPE_NUMBER,
	["$translate"] = MATTYPE_VECTOR,
	["$center"] = MATTYPE_VECTOR,
	["$offset"] = MATTYPE_NUMBER,
	-- Draconic parameters beyond this point
	["$envmapfallback"] = MATTYPE_STRING,
	["$cmpower"] = MATTYPE_NUMBER,
	["$cmpower_fb"] = MATTYPE_NUMBER,
	["$cmtint"] = MATTYPE_VECTOR,
	["$cmtint_fb"] = MATTYPE_VECTOR,
	["$cmshiftpower"] = MATTYPE_NUMBER,
	["$cmshift"] = MATTYPE_VECTOR,
	["$rimlightpower"] = MATTYPE_NUMBER,
	-- Function matproxy workarounds
	["basetranslate"] = MATTYPE_TRANSLATE
}

local function Run(self, ent, minInput, maxInput)
	local function calc(fraction, invert)
		local function ease(f, min, max)
			return Lerp(self.EaseFunc(fraction), min, max)
		end

		local mid = math.Clamp(math.abs(0.5 + fraction), 0, 1) * fraction
		local newMin = LerpVector(mid, minInput, Vector(self.Mid) * 5)

		if invert then newMin = -maxInput end

		local val = LerpVector(fraction, newMin, maxInput)
		val:SetUnpacked(
			ease(fraction, newMin.x, maxInput.x),
			ease(fraction, newMin.y, maxInput.y),
			ease(fraction, newMin.z, maxInput.z)
		)

		return val
	end

	if self.Input == "heat" then
		return calc(getHeat(ent))
	elseif self.Input == "clip1" then
		return calc(getClip1(ent))
	end
end

local function Return(val, mat, target, mul)
	local matType = materialTypes[target]

	if matType == MATTYPE_VECTOR then
		mat:SetVector(target, val * mul)
	elseif matType == MATTYPE_STRING then
		mat:SetString(target, val * mul)
	elseif matType == MATTYPE_NUMBER then
		mat:SetFloat(target, val.x * mul)
	elseif matType == MATTYPE_TEXTURE then
		mat:SetTexture(target, val)
	elseif matType == MATTYPE_TRANSLATE then
		val:Mul(mul)

		mat:SetMatrix("$basetexturetransform", Matrix({
			{1, 0, 0, val.y},
			{0, 1, 0, -val.x},
			{0, 0, 0, 0},
			{0, 0, 0, 0}
		}))
	end
end

-- Can also be used to ignore inputs we don't care about
local handledInputs = table.Lookup({
	"heat", "clip1"
})

local function DRCInit(self, mat, values)
	self.Input = values.input

	if not handledInputs[self.Input] and lp:IsDeveloper() then
		print("Initialized unimplemented DRC material input:", self.Input)
	end

	self.EaseFunc = math.ease[values.ease] or function(val) return val end

	self.Mod = values.mod
	self.Mid = values.mid

	self.Min = {values.min, values.min2 or values.min, values.min3 or values.min}
	self.Max = {values.max, values.max2 or values.max, values.max3 or values.max}
	self.Mul = {values.mul1 or 1, values.mul2 or 1, values.mul3 or 1}

	self.ReturnValues = {values.resultvar, values.resultvar2, values.resultvar3}
end

local function DRCBind(self, mat, ent)
	ent = resolveEntity(ent)

	for k, target in ipairs(self.ReturnValues) do
		local val = Run(self, ent, Vector(self.Min[k]), Vector(self.Max[k]))

		if val != nil then
			Return(val, mat, target, self.Mul[k])
		end
	end
end

matproxy.Add({name = "drc_FunctionA", init = DRCInit, bind = DRCBind})
matproxy.Add({name = "drc_FunctionB", init = DRCInit, bind = DRCBind})
matproxy.Add({name = "drc_FunctionC", init = DRCInit, bind = DRCBind})
matproxy.Add({name = "drc_FunctionD", init = DRCInit, bind = DRCBind})

-- Disabling material proxies we don't want to deal with (like the needle rifle being player weapon colored)
local disableList = {
	"drc_PlayerWeaponColours",
	"drc_ReflectionTint_WeaponColour"
}

for _, name in ipairs(disableList) do
	matproxy.Add({
		name = name,
		init = function() end,
		bind = function() end
	})
end
