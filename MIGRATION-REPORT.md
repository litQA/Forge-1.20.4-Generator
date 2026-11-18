# Migration Report

## Scope

This report documents the migration from the official MCreator 2026.1
NeoForge 1.20.4 generator baseline to the Forge 1.20.4 generator for
MCreator 2026.3.44621.

- Target plugin: `generator-forge-1.20.4`
- Plugin version: `2026.3-1.0.1.2-beta`
- Target MCreator: 2026.3.44621
- Supported MCreator range: `202600344621` through `202600399999`
- Minecraft: 1.20.4
- Forge: 49.2.13
- Generated workspace: ForgeGradle 6.0.54, Gradle 8.14.5, Java 17
- Plugin build: Gradle 9.9.1, Java 25

The migration keeps one discoverable generator, `forge-1.20.4`. The private
`datapack-1.20.4` bundle contains templates, procedures, triggers, and utility
data only; it has no `generator.yaml` and is not exposed as a second generator.

## Compatibility Decisions

Forge 1.20.4 predates the 1.21 data-component and enchantment-component APIs,
and it does not provide every NeoForge-only extension point used by the 2026.3
NeoForge generator. Features that require those APIs are listed as **N/A** or
**Partial** below rather than silently emitting code that cannot compile.

The generated workspace uses ForgeGradle because Forge 1.20.4 has no
NeoForge-style userdev workspace. ForgeGradle 6.0.54 was the newest release
compatible with the required Gradle 8.x toolchain; Gradle 9.x is rejected by
that ForgeGradle release.

## MCreator 2026.3 Items

| Item | Status | Notes |
| --- | --- | --- |
| Armor durability 0 | Implemented | `getDurabilityForType` uses `data.maxDamage`; a value of 0 produces a non-damageable 1.20.4 armor item. |
| Synced-data entity layer conditions | Implemented | Synced data is available to layer/animation conditions. |
| Attribute-modifier enchantment component | N/A | Requires 1.21 enchantment data components. |
| Creative-tab hide title | N/A | The Forge 1.20.4 creative-tab builder has no hide-title operation. |
| Custom attack AI | Implemented | Forge goal/task adapters, including attack and target tasks. |
| Is-entity-moving procedure | Partial | Movement helpers exist in procedure code; not every 2026.3 UI variant is exposed. |
| Item repair / empty / piglin / damage-source blocks | Implemented | Forge item/stack and damage-source procedure adapters. |
| Multipart block states | Implemented | Multipart-aware Java and JSON templates. |
| Synced animation conditions | Implemented | Animation conditions read synced entity data. |
| Shadow blocks | Partial | The generic block renderer supports normal block rendering; the 2026.3 shadow-block mode is not a separate template mode. |
| Force redstone conduction | Implemented | Forge block-state conduction override. |
| Loot tables as loot modifiers | N/A | Requires the 1.21 loot-modifier serializer. |
| Void dimension | Implemented | Void dimension and noise-router JSON templates. |
| Enchantment weapon/armor effects | Partial | Custom enchantment classes generate; the 1.21 effect-component system is not available. |
| Ordered enchantment value modifiers | N/A | Requires 1.21 ordered enchantment value modifiers. |
| Level-based enchantment inputs | N/A | Requires the 1.21 enchantment input API. |
| Raytrace water/fall reset modes | Partial | Basic raytrace procedure support exists; the newer fluid/fall reset variants were not exhaustively ported. |
| Strong power emission | Implemented | Strong/weak redstone emission handling. |
| Vector dot / cross product | Partial | Dot product is implemented; cross product is not yet a dedicated procedure template. |
| Entity LOS / invulnerable / attack cooldown / force attack | Implemented | Forge combat/AI procedure adapters. |
| NeoForge dry-foliage support | N/A | NeoForge-only feature; no Forge 1.20.4 equivalent. |

## MCreator 2026.2 Items

| Item | Status | Notes |
| --- | --- | --- |
| Advancement import/export | Implemented | Handled by MCreator's advancement model and generated data. |
| Advancement trigger templates | Implemented | 2026.2/2026.3 trigger templates are registered. |
| Blockly enchantment effect builder | Partial | Enchantment elements generate, but the 1.21 effect-component builder is not available. |
| Armor attribute modifiers | Partial | Item attribute-modifier support exists; the armor-specific 2026.2 editor fields are not fully emitted. |
| Dimension skybox/sun/moon | N/A | Requires 1.21.4 dimension visual settings. |
| Armor trims | Implemented | Trim definitions, palette assets, and JSON templates. |
| Raft / chest raft | N/A | No Forge 1.20.4 raft entity implementation in the target generator. |
| Special-entity item rarity | Partial | Rarity is supported on normal item/block/fluid items; special-entity item templates are not fully audited. |
| Enchantment XP / unequip / vanish effects | Partial | Custom enchantment shell exists; 1.21 effect components are not available. |
| Enchantment value modifiers | N/A | Requires 1.21 value-modifier APIs. |
| Follow-item list/tags | Partial | Follow AI tasks exist; the expanded 2026.2 item-list/tag fields are not fully exposed. |
| Advancement damage/enchantment predicates | Implemented | 1.20.4 item predicates and JSON triggers. |
| Item predicate triggers | Implemented | Item consumed/damaged/enchanted/inventory predicates. |
| Use-duration trigger | Implemented | Item-use-duration JSON trigger support. |
| Explosion trigger source | Partial | Explosion procedures exist; the 2026.2 source-type selector is not fully ported. |
| Math clamp/lerp | Implemented | Procedure math helpers. |
| Point-inside-solid | Implemented | Solid-block position predicate. |
| Eye position | Implemented | Entity eye-position vector procedure. |
| NeoForge entity tick/player collision | N/A | NeoForge-only events. |
| Wandering villager category | Partial | Villager trade generation is adapted; the wandering-trader-specific category is not fully verified. |
| Block inventory insert/extract | Implemented | Forge item-handler capability procedures. |

## Destructive Changes

- NeoForge `mods.toml` mixin sections were removed. Production Mixin discovery
  uses the jar manifest `MixinConfigs` entry.
- The production and development Mixin configurations are separate. Development
  uses named targets without a refmap; production uses the annotation-processor
  generated SRG refmap.
- The 2026.1 `types["base:*"]` template keys were replaced by the 2026.3
  `types.base_blocks`, `types.base_blockentities`, `types.base_items`,
  `types.base_entities`, and `types.base_features` keys.
- `fixed_placement` JSON was replaced by a Forge `PlacementModifierType` and
  codec; the modifier filters positions to the current chunk.
- Sign and hanging-sign blocks keep only user properties prefixed with
  `CUSTOM:`. Adding all vanilla properties produced 73,728 states and made
  `StateDefinition` construction pathological.
- The generated workspace archive is `modid-1.0.jar`, matching
  `export_file`.

## Pre-2026.1 Exclusions

The generator targets the 2026.1 NeoForge baseline and later 2026.3 templates.
Legacy generator APIs that were already removed before 2026.1 are not
reintroduced. The old community 2024 Forge generator is not used as a template
source because its generated workspaces were not a reliable compatibility
baseline.

## Known Limitations

- Client rendering, GUI interaction, particles, models, and blockstate visuals
  are not visually tested by the headless suite. They require a real-machine
  client smoke test.
- Hanging-sign custom properties are limited to `CUSTOM:`; this is documented
  behavior to avoid an incompatible state explosion.
- The 1.21/NeoForge-only features listed as N/A above are not emulated with
  private reimplementations.
- The automated server test uses a deterministic vanilla block for its feature
  blockstate selector. This avoids a pathological test-fixture case where a
  random custom block with a false `canSurvive` procedure is placed and then
  removed by world generation.

## Validation Record

The integration suite exercises workspace setup, texture references, base and
resource generation, all 41 registered mod element types, pack maker tools,
procedure blocks, JSON triggers, command arguments, features, enchantments,
AI tasks, base regeneration, JSON verification, the Gradle code provider, the
generated workspace build, and dedicated-server startup.

- Test 42: 22 tests completed, all passed.
- Test 43: 22 tests completed, 0 failures, 0 errors.
- Generated workspace build: passed in test 43.
- Test 43 dedicated server: reached `Done (65.853s)!`.
- No Mixin apply failure and no dummy-block-entity flood were observed in the
  passing runs.
- The test harness intentionally stops the running server after `Done`; the
  inner `runServer` task can therefore print `BUILD FAILED` while the
  integration test still reports `Testing server run PASSED`.
- The archive-name change is included in the final plugin jar. The generated
  workspace declares `build/libs/modid-1.0.jar`, matching `export_file`.
- A real generated test workspace built successfully after applying the
  ForgeGradle `jvmArg` run-config fix and skipping registrations for empty
  element types.

The plugin archive is intended to be tested once more on a real MCreator
installation and a client workspace before release.
