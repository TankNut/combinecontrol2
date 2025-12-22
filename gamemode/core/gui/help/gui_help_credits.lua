local text = [[<massive><b><ol=1><c=white>Combine</c><c=red>Control</c></ol></b></massive>
<iset=3><dark>Built for Taco N Banana</dark>

<giant><b>Credits</b></giant>
	TankNut:	<dark>Lead Developer</dark>
	Somedude:	<dark>Developer</dark>

<giant><b>Special Thanks</b></giant>
	Dave Brown:	<dark>You might have not have created TnB but you were always at the heart of it</dark>
	Gangleider:	<dark>For keeping the lights on all these years</dark>
	Hoplite:	<dark>For giving input on various code and design related things</dark>
	Rowtree:	<dark>Responsible for dragging me into TnB in the first place, clearly this is all your fault</dark>

<dark>Based on a gamemode by Disseminate</dark>]]

hook.Add("PopulateHelpMenu", "credits", function(panel)
	panel:AddMenu(1, "Gamemode Credits", text)
end)
