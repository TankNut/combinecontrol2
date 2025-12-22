function render.GetViewID(noPlayer)
	return render.GetViewSetup(noPlayer).viewid
end

function render.IsDrawingMainView()
	return render.GetViewID(true) == VIEW_MAIN
end

function render.DrawWorldText(pos, text, noz)
	local ang = (pos - EyePos()):Angle()

	cam.Start3D2D(pos, Angle(0, ang.y - 90, 90), 0.25)
		if noz then
			render.DepthRange(0, 0)
		end

		render.PushFilterMag(TEXFILTER.POINT)
		render.PushFilterMin(TEXFILTER.POINT)
			surface.SetFont("BudgetLabel")

			local w, h = surface.GetFontSize("BudgetLabel", text)

			surface.SetTextColor(255, 255, 255, 255)
			surface.SetTextPos(-w * 0.5, -h * 0.5)

			surface.DrawText(text)
		render.PopFilterMin()
		render.PopFilterMag()

		if noz then
			render.DepthRange(0, 1)
		end
	cam.End3D2D()
end
