if CLIENT then
	module("ui", package.seeall)

	List = List or {}

	function Register(name, callback, single)
		if List[name] then
			List[name].Callback = callback

			return
		end

		List[name] = {
			Callback = callback,
			Single = single
		}

		if not single then
			List[name].Instances = {}
		end
	end

	function Open(name, ...)
		local ui = assert(List[name], "Attempt to open unknown gui: " .. name)

		if ui.Single then
			if IsValid(ui.Instance) then
				ui.Instance:Remove()
			end

			ui.Instance = ui.Callback(...)

			return ui.Instance
		else
			local panel = ui.Callback(...)

			if ispanel(panel) and IsValid(panel) then
				table.insert(ui.Instances, panel)
			end

			return panel
		end
	end

	function Get(name)
		local ui = assert(List[name], "Attempt to get unknown gui: " .. name)

		if ui.Single then
			return IsValid(ui.Instance) and ui.Instance or nil
		else
			return ui.Instances
		end
	end

	function Close(name)
		local ui = Get(name)

		if IsValid(ui) then
			ui:Remove()
		elseif istable(ui) then
			for _, v in ipairs(ui) do
				v:Remove()
			end
		end
	end

	local ref = ScrH()

	function Scale(size)
		return math.Round(size * (ref / 1080))
	end

	netstream.Hook("OpenUI", function(name, ...)
		Open(name, ...)
	end)

	netstream.Hook("CloseUI", function(name)
		Close(name)
	end)

	hook.Add("OnScreenSizeChanged", "ui.Scale", function(_, _, _, height)
		ref = height
	end)
else
	local PLAYER = FindMetaTable("Player")

	function PLAYER:OpenGUI(name, ...)
		netstream.Send(self, "OpenUI", name, ...)
	end

	function PLAYER:CloseGUI(name)
		netstream.Send(self, "CloseUI", name)
	end
end
