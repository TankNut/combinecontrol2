# cc2

:warning:**Under Construction**:warning:

I'm currently rewriting a lot of internals to support plugins as well as loading them (along with content) from the addons folder instead of requiring direct edits to the gamemode. If you do want to use this for any projects, either wait until these changes are done or accept that you're not getting any support whatsoever.

Requires [srlion/Hook-Library](https://github.com/srlion/Hook-Library) to be installed as an addon

## Naming conventions
#### Generic libraries/modules are in snake_case, gamemode specific ones are in PascalCase
If it goes into the gamemode core or content, it's specific. If it does into utils, it's generic.

#### Hook naming
For event names, follow Garry's Mod's standard naming scheme of PascalCase. String identifiers should use the format of `cc2.PascalCase` (don't add the name of the hook itself, it's redundant)
