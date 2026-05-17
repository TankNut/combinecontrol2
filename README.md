# CombineControl 2

A roleplaying gamemode for Garry's Mod that continues the legacy of [CombineControl](https://github.com/disseminate/combinecontrol) by Disseminate while completely overhauling it's internals.

:warning:**Under Construction**:warning:

A lot of internals are currently being rewritten and things are actively being shuffled around. Unless you're feeling adventurous, this isn't ready for production use.

## Requirements
- [srlion/Hook-Library](https://github.com/srlion/Hook-Library) should be installed as an addon
- [gmsv_mysqloo](https://github.com/FredyH/MySQLOO) for database connections

## Schemas
CombineControl 2 works with schemas, though unlike other gamemodes it does this through an addon rather than a derived gamemode. This makes development easier as both the base gamemode and the schema can be edited and autorefreshed at the same time.

There are two 'official' schemas at the moment
- [Half-Life 2 Roleplay](https://github.com/TankNut/combinecontrol2-hl2) (Work in Progress)
- [Halo Roleplay](https://github.com/TankNut/combinecontrol2-halo)

## Development notes (temporary until I move them elsewhere)
### Generic libraries/modules are in snake_case, gamemode specific ones are in PascalCase
If it goes into the gamemode core or content, it's specific. If it does into utils, it's generic.

### Hook naming
For event names, follow Garry's Mod's standard naming scheme of PascalCase. String identifiers should use the format of `cc2.PascalCase` (don't add the name of the hook itself, it's redundant)
