GM:Include("sh_defines.lua")
GM:Include("sh_names.lua")
GM:Include("sh_sandbox.lua")

-- Load order determines category order, plugins shouldn't matter too much so we let those sort themselves out
GM:Include("settings/settings_general.lua")
GM:Include("settings/settings_hud.lua")
GM:Include("settings/settings_admin.lua")
