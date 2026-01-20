-- A bit archaic with how things are included, that's because we don't use the cl/sh/sv prefix method here

-- Libraries used elsewhere
shared("libraries/async.lua")
shared("libraries/log.lua")
shared("libraries/memoization.lua")

sfs = shared("libraries/sfs.lua")
shared("libraries/netstream.lua")
shared("libraries/request.lua")
shared("libraries/inherit.lua")

shared("constants.lua")
shared("globals.lua")

shared("libraries/console.lua")

-- Extensions
client("extensions/draw.lua")
client("extensions/render.lua")
client("extensions/surface.lua")
client("extensions/panel.lua")

shared("extensions/angle.lua")
shared("extensions/bit.lua")
shared("extensions/cmovedata.lua")
shared("extensions/color.lua")
shared("extensions/entity.lua")
shared("extensions/file.lua")
shared("extensions/game.lua")
shared("extensions/math.lua")
shared("extensions/player.lua")
shared("extensions/scripted_ents.lua")
shared("extensions/string.lua")
shared("extensions/table.lua")
shared("extensions/util.lua")
shared("extensions/vector.lua")
shared("extensions/weapons.lua")

-- Libraries
client("libraries/cloak.lua")

client("libraries/scribe.lua")
client("libraries/scribe/scribe_alpha.lua")
client("libraries/scribe/scribe_basecomponent.lua")
client("libraries/scribe/scribe_chroma.lua")
client("libraries/scribe/scribe_color.lua")
client("libraries/scribe/scribe_compound.lua")
client("libraries/scribe/scribe_font.lua")
client("libraries/scribe/scribe_inset.lua")
client("libraries/scribe/scribe_language.lua")
client("libraries/scribe/scribe_outline.lua")
client("libraries/scribe/scribe_rainbow.lua")
client("libraries/scribe/scribe_stutter.lua")
client("libraries/scribe/scribe_text.lua")
client("libraries/scribe/scribe_wave.lua")
client("libraries/scribe/scribe_wiggle.lua")
client("libraries/scribe/scribe_team.lua")

client("libraries/scribe/scribe_label.lua")

shared("libraries/buff.lua")
shared("libraries/deferred.lua")
shared("libraries/door.lua")
shared("libraries/ui.lua")
shared("libraries/netvar.lua")
shared("libraries/player_ready.lua")
shared("libraries/progress.lua")
shared("libraries/validate.lua")
shared("libraries/zone.lua")
shared("libraries/unit.lua")

server("libraries/database.lua")

-- utils
client("util/trail_renderer.lua")

shared("util/shapes/shape_box.lua")
shared("util/shapes/shape_plane.lua")
shared("util/shapes/shape_sphere.lua")

shared("util/duration.lua")
shared("util/menu_builder.lua")
shared("util/queue.lua")
shared("util/rate_counter.lua")
shared("util/transition.lua")

-- vgui stuff
client("vgui/code_editor.lua")
client("vgui/editor_server_globals.lua")

-- Tools
shared("tools/generate_global_lookup.lua")
shared("tools/database_tools.lua")
