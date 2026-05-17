HUD.Name = "Button Labels"

HUD.Setting = "ButtonLabels"

function HUD:PaintBackground(w, h)
	local eye = lp:EyePos()

	for button in Buttons.Iterator() do
		if button:IsDormant() or #button:ButtonName() == 0 then
			continue
		end

		local pos = button:WorldSpaceCenter()
		local alpha = math.ClampedRemap(eye:Distance(pos), MAX_USE_DISTANCE, MAX_USE_DISTANCE * 1.5, 1, 0)

		if alpha <= 0 then
			continue
		end

		self:AddWorldLabel(button:WorldSpaceCenter(), {{
			scribe.Parse(string.format("<f=BudgetLabel><ol>%s", button:ButtonName())), alpha
		}})
	end
end
