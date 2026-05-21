HUD.Name = "Button Labels"

HUD.Setting = "ButtonLabels"

function HUD:PaintBackground(w, h)
	local eye = lp:EyePos()

	for button in Buttons.Iterator() do
		if button:IsDormant() or #button:ButtonName() == 0 then
			continue
		end

		local pos = button:WorldSpaceCenter()

		if not button.PixVis then
			button.PixVis = util.GetPixelVisibleHandle()
		end

		local visible = util.PixelVisible(pos, 1, button.PixVis)
		local alpha = math.ClampedRemap(eye:Distance(pos), MAX_USE_DISTANCE * 1.25, MAX_USE_DISTANCE * 2, 1, 0) * visible

		if alpha <= 0 then
			continue
		end

		self:AddWorldLabel(button:WorldSpaceCenter(), {{
			scribe.Parse(string.format("<f=BudgetLabel>%s", button:ButtonName())), alpha
		}})
	end
end
