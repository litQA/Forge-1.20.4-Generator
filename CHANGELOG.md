# Changelog

## 2026.3-1.0.0.1-beta

### New Content

- Forge 1.20.4 generator packaging for MCreator 2026.3.44621, with a single
  discoverable `forge-1.20.4` generator and a private `datapack-1.20.4`
  template bundle.
- Forge workspace base using ForgeGradle 6.0.54, Gradle 8.14.5, Java 17,
  Forge 49.2.13, and official 1.20.4 mappings.
- Forge networking, `SavedData`/UUID variables, capabilities, registries,
  menus, fluids, sounds, biomes, dimensions, features, armor trims, villager
  trades, procedures, and AI task support.
- Multipart block-state generation, force-redstone conduction, synced-data
  layer and animation conditions, and void dimension generation.
- Custom `fixed_placement` placement modifier with chunk filtering.
- Split Mixin configuration for development and production, including an
  annotation-processor-generated production refmap.

### Changes

- Base type initialization uses the MCreator 2026.3 `base_blocks`,
  `base_blockentities`, `base_items`, `base_entities`, and `base_features`
  template keys.
- The generated workspace archive is named `modid-1.0.jar`, matching
  `export_file` and the official generator convention.
- Strict JSON output now uses quoted keys, JSON booleans, and array-valued item
  predicates.
- Sign and hanging-sign elements keep only custom properties prefixed with
  `CUSTOM:` to avoid an incompatible vanilla property/state explosion.
- The feature test fixture uses a deterministic vanilla block for its
  blockstate selector instead of a random custom block.

### Fixes

Fixed 12 bugs.

- Forge `mods.toml` dependency metadata now uses `mandatory` and Forge/Minecraft
  version ranges.
- Base registry initialization no longer relies on obsolete `types["base:*"]`
  keys.
- Custom portal POI listeners are registered after blocks, removing the
  `Registry Object not present` failure.
- Invalid 1.20.4 `fixed_placement` JSON was replaced by a Forge placement
  modifier.
- Development and production Mixin configs no longer share an incompatible
  refmap.
- Multiplayer variable networking uses the Forge channel send contract.
- Forge capability lookups, menu types, fluids, sounds, and item/block APIs
  compile against Forge 49.2.13.
- Generated advancement item predicates emit arrays.
- Hanging-sign block-state construction no longer exhausts the state-definition
  neighbor map.
- Source jars and the code provider resolve Forge official mappings.
- Generated workspace export names match the artifact produced by `jar` and
  `reobfJar`.
- The server integration test reaches `Done` without Mixin-apply or
  block-entity registry failures.

### Known Limitations

- Sign and hanging-sign blocks do not accept non-`CUSTOM:` properties.
- Minecraft 1.21/NeoForge-only APIs and 1.21.4 dimension visuals are not
  available on Forge 1.20.4.
- Client rendering and GUI behavior require a real-machine smoke test; the
  automated suite validates generation, compilation, and dedicated-server
  startup.
