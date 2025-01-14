GM.FontFace = system.IsOSX() and "ChatFont" or "Myriad Pro"

surface.CreateFont("CombineControl.ChatSmall", {
	font = GM.FontFace,
	--size = 14,
	size = 15,
	weight = 100})

surface.CreateFont("CombineControl.ChatSmallItalic", {
	font = GM.FontFace,
	--size = 14,
	size = 15,
	weight = 500,
	italic = true})

surface.CreateFont("CombineControl.ChatNormal", {
	font = GM.FontFace,
	--size = 16,
	size = 18,
	weight = 500})

surface.CreateFont("CombineControl.ChatItalic", {
	font = GM.FontFace,
	--size = 16,
	size = 18,
	weight = 500,
	italic = true})

surface.CreateFont("CombineControl.ChatRadio", {
	font = "Lucida Console",
	--size = 12,
	size = 14,
	weight = 500})

surface.CreateFont("CombineControl.CombineScanner", {
	font = "Lucida Sans Typewriter",
	antialias = false,
	weight = 800,
	size = 18 })

surface.CreateFont("CombineControl.ChatBold", {
	font = GM.FontFace,
	size = 18,
	weight = 1600})

surface.CreateFont("CombineControl.ChatBigItalic", {
	font = GM.FontFace,
	size = 21,
	weight = 700,
	italic = true})

surface.CreateFont("CombineControl.ChatHuge", {
	font = GM.FontFace,
	size = 20,
	weight = 700})

surface.CreateFont("CombineControl.PlayerFont", {
	font = GM.FontFace,
	size = 17,
	weight = 700})

surface.CreateFont("CombineControl.HUDAmmo", {
	font = GM.FontFace,
	size = 50,
	weight = 500})

surface.CreateFont("CombineControl.HUDAmmoSmall", {
	font = GM.FontFace,
	size = 30,
	weight = 500})

surface.CreateFont("CombineControl.WepSelectHeader", {
	font = GM.FontFace,
	size = 20,
	weight = 700})

surface.CreateFont("CombineControl.WepSelectWep", {
	font = GM.FontFace,
	size = 18,
	weight = 500})

surface.CreateFont("CombineControl.WepSelectInfo", {
	font = GM.FontFace,
	size = 16,
	weight = 500})

surface.CreateFont("CombineControl.Written", {
	font = "Comic Sans MS",
	size = 20,
	weight = 700})

surface.CreateFont("CombineControl.Scope", {
	font = "Courier New",
	size = 28,
	weight = 1000})
