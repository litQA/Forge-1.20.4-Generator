<img width="1000"  alt="forge generator banner 1 20 4" src="https://github.com/user-attachments/assets/5c3dbefc-5476-45ff-a507-3bd7d5aa343e" />

# Minecraft Forge 1.20.4 Generator

An MCreator generator plugin that creates Minecraft Forge 1.20.4 workspaces and
generates Forge mod projects from MCreator 2026.3.

## Compatibility

| Component | Version |
| --- | --- |
| MCreator | 2026.3.44621 |
| Supported MCreator range | [202600344621, 202600399999] |
| Minecraft | 1.20.4 |
| Forge | 49.2.13 |
| ForgeGradle | 6.0.54 |
| Generated workspace Gradle | 8.14.5 |
| Generated workspace Java | 17 |
| Plugin project Gradle | 9.9.1 |
| Plugin project Java | 25 |

## Installation

1. Build or obtain `generator-forge-1.20.4.zip`.
2. Install it with MCreator's plugin installer, or place it in the MCreator
   plugins directory.
3. Enable Java plugins in MCreator and restart the application.
4. Create a new workspace and select **Minecraft Forge 1.20.4 Generator**.

The plugin registers one generator, `forge-1.20.4`. Its private
`datapack-1.20.4` bundle is an implementation detail and is not exposed as a
second generator.

## Generated Workspace

The generated workspace uses ForgeGradle 6.0.54, Gradle 8.14.5, Java 17, the
official 1.20.4 mappings, and Forge 49.2.13. It includes:

- Forge `DeferredRegister` registries and `RegistryObject` initialization.
- Forge `SimpleChannel` networking for variables and custom payloads.
- `SavedData` plus UUID persistence for player variables.
- Forge capability adapters for blocks, block entities, items, and entities.
- MCreator 2026.3 base-type initialization, multipart block states, synced
  animation/layer conditions, armor trims, villager trades, custom features,
  and procedure/AI support.
- A custom `fixed_placement` placement modifier for fixed block placement.
- Split dev/production Mixin configs and an annotation-processor-generated
  production refmap.

The generated mod jar is written to `build/libs/modid-1.0.jar`, matching the
generator's `export_file` declaration and the official generator convention.

## Building the Plugin

Requirements:

- JDK 25 for the plugin project.
- Network access for the first Gradle run, or a local Gradle dependency cache.

```text
cd {workspace_root}/plugin-branch-2026.3
./gradlew jar
```

The plugin archive is written to `build/libs/generator-forge-1.20.4.zip`.

## Validation

The integration suite exercises workspace setup, all 41 mod element types,
procedures, JSON triggers, pack maker tools, base regeneration, data-pack JSON
validation, the Gradle code provider, generation workspace build, and server
startup. The validated run completed all 22 tests, the generated workspace
build passed, and the dedicated server reached:

```text
Done (...s)! For help, type "help"
```

Some checks are intentionally limited to headless server validation. Client
rendering, GUI interaction, and visual model/blockstate behavior require a
real-machine client check. See `MIGRATION-REPORT.md` for the complete validation
record and limitations.

## Known Limitations

- Hanging-sign and sign elements retain only user properties prefixed with
  `CUSTOM:`. Vanilla sign properties are not added to those blocks, preventing
  a state-definition explosion caused by incompatible property combinations.
- Features that are exclusive to Minecraft 1.21 or NeoForge are not available
  in a Forge 1.20.4 generator. Examples include data components, the 1.21
  enchantment value-modifier APIs, creative-tab hide-title, 1.21.4 dimension
  skybox controls, rafts, and the 1.21 loot-modifier serializer.
- The server validation is headless. The user should perform the final client
  smoke test with the exported mod.

## Reports and License

- `CHANGELOG.md` -- release notes.
- `MIGRATION-REPORT.md` -- baseline/target mapping, destructive changes, status
  table, test evidence, and known limitations.
- `LICENSE` -- CC BY 4.0 for the original generator adaptation, with
  third-party notices.
