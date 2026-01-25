module("outline", package.seeall)

local matCopy = Material("pp/copy")
local matAdd  = Material("pp/add")
local matSub  = Material("pp/sub")

local rtStore = render.GetScreenEffectTexture(0)
local rtCopy = render.GetScreenEffectTexture(1)

List = {}
Entity = NULL

function Add(entities, color, add, fill, ignorez)
	if add == nil then add = true end

	if not istable(entities) then
		entities = {entities}
	end

	table.insert(List, {
		Ents = entities,
		Color = color,
		Additive = add,
		Fill = fill or 0,
		IgnoreZ = tobool(ignorez)
	})
end

function Render(entry)
	local rtScene = render.GetRenderTarget()

	render.CopyRenderTargetToTexture(rtStore)

	if entry.Additive then
		render.Clear(0, 0, 0, 255, false, true)
	else
		render.Clear(255, 255, 255, 255, false, true)
	end

	render.UpdateRefractTexture()

	cam.Start3D()
		render.SetStencilEnable(true)
		render.SuppressEngineLighting(true)

		cam.IgnoreZ(entry.IgnoreZ)
			render.SetStencilWriteMask(1)
			render.SetStencilTestMask(1)
			render.SetStencilReferenceValue(1)

			render.SetStencilCompareFunction(STENCIL_ALWAYS)
			render.SetStencilPassOperation(STENCIL_REPLACE)
			render.SetStencilFailOperation(STENCIL_KEEP)
			render.SetStencilZFailOperation(STENCIL_KEEP)

			for k, v in ipairs(entry.Ents) do
				if not IsValid(v) or v:GetNoDraw() then
					continue
				end

				Entity = v

				v:SetupBones()
				v:DrawModel()
			end

			Entity = NULL

			render.SetStencilCompareFunction(STENCIL_EQUAL)
			render.SetStencilPassOperation(STENCIL_KEEP)

			cam.Start2D()
				local entryColor = entry.Color

				surface.SetDrawColor(entryColor.r, entryColor.g, entryColor.b, entryColor.a)
				surface.DrawRect(0, 0, ScrW(), ScrH())
			cam.End2D()

		cam.IgnoreZ(false)
		render.SuppressEngineLighting(false)
		render.SetStencilEnable(false)
	cam.End3D()

	render.CopyRenderTargetToTexture(rtCopy)

	render.SetRenderTarget(rtScene)

	matCopy:SetTexture("$basetexture", rtStore)
	matCopy:SetString("$color", "1 1 1")
	matCopy:SetString("$alpha", "1")

	render.SetMaterial(matCopy)
	render.DrawScreenQuad()

	render.SetStencilEnable(true)
		local mat = entry.Additive and matAdd or matSub

		mat:SetTexture("$basetexture", rtCopy)
		render.SetMaterial(mat)

		if entry.Fill > 0 then
			render.SetStencilCompareFunction(STENCIL_EQUAL)

			mat:SetFloat("$alpha", entry.Fill)
			render.DrawScreenQuad()
			mat:SetFloat("$alpha", 1)
		end

		render.SetStencilCompareFunction(STENCIL_NOTEQUAL)

		local w, h = ScrW(), ScrH()

		render.DrawScreenQuadEx(-1, -1, w, h)
		render.DrawScreenQuadEx(-1, 0, w, h)
		render.DrawScreenQuadEx(-1, 1, w, h)
		render.DrawScreenQuadEx(0, -1, w, h)
		render.DrawScreenQuadEx(0, 1, w, h)
		render.DrawScreenQuadEx(1, -1, w, h)
		render.DrawScreenQuadEx(1, 0, w, h)
		render.DrawScreenQuadEx(1, 1, w, h)
	render.SetStencilEnable(false)

	-- Return original values
	render.SetStencilTestMask(0)
	render.SetStencilWriteMask(0)
	render.SetStencilReferenceValue(0)
end

hook.Add("PostDrawEffects", "RenderOutlines", function()
	hook.Run("PreDrawOutlines")

	if #List == 0 then return end

	for k, v in ipairs(List) do
		Render(v)
	end

	List = {}
end)
