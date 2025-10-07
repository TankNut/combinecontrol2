# cc2-halo

Requires [srlion/Hook-Library](https://github.com/srlion/Hook-Library) to be installed as an addon

## Coding conventions
#### Generic libraries/modules are in snake_case, gamemode specific ones are in PascalCase
If it goes into the gamemode core or content, it's specific. If it does into utils, it's generic.

#### Hook naming
For event names, follow Garry's Mod's standard naming scheme of PascalCase. String identifiers should use the format of `cc2.PascalCase` (don't add the name of the hook itself, it's redundant)
