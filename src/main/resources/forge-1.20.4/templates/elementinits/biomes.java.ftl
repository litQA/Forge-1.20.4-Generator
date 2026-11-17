<#--
 # MCreator (https://mcreator.net/)
 # Copyright (C) 2012-2020, Pylo
 # Copyright (C) 2020-2023, Pylo, opensource contributors
 #
 # This program is free software: you can redistribute it and/or modify
 # it under the terms of the GNU General Public License as published by
 # the Free Software Foundation, either version 3 of the License, or
 # (at your option) any later version.
 #
 # This program is distributed in the hope that it will be useful,
 # but WITHOUT ANY WARRANTY; without even the implied warranty of
 # MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 # GNU General Public License for more details.
 #
 # You should have received a copy of the GNU General Public License
 # along with this program.  If not, see <https://www.gnu.org/licenses/>.
 #
 # Additional permission for code generator templates (*.ftl files)
 #
 # As a special exception, you may create a larger work that contains part or
 # all of the MCreator code generator templates (*.ftl files) and distribute
 # that work under terms of your choice, so long as that work isn't itself a
 # template for code generation. Alternatively, if you modify or redistribute
 # the template itself, you may (at your option) remove this special exception,
 # which will cause the template and the resulting code generator output files
 # to be licensed under the GNU General Public License without this special
 # exception.
-->

<#-- @formatter:off -->
<#include "../mcitems.ftl">

/*
 *    MCreator note: This file will be REGENERATED on each build.
 */

package ${package}.init;

import com.mojang.datafixers.util.Pair;
import com.google.common.base.Suppliers;

<#assign spawn_overworld = biomes?filter(biome -> biome.spawnBiome)>
<#assign spawn_overworld_caves = biomes?filter(biome -> biome.spawnInCaves)>
<#assign spawn_nether = biomes?filter(biome -> biome.spawnBiomeNether)>

@Mod.EventBusSubscriber public class ${JavaModName}Biomes {

	@SubscribeEvent public static void onServerAboutToStart(ServerAboutToStartEvent event) {
		MinecraftServer server = event.getServer();
		Registry<LevelStem> levelStemTypeRegistry = server.registryAccess().registryOrThrow(Registries.LEVEL_STEM);
		Registry<Biome> biomeRegistry = server.registryAccess().registryOrThrow(Registries.BIOME);

		for (LevelStem levelStem : levelStemTypeRegistry.stream().toList()) {
			Holder<DimensionType> dimensionType = levelStem.type();

			<#if spawn_overworld?has_content || spawn_overworld_caves?has_content>
			if (dimensionType.is(BuiltinDimensionTypes.OVERWORLD)) {
				ChunkGenerator chunkGenerator = levelStem.generator();

				// Inject biomes to biome source
				if(chunkGenerator.getBiomeSource() instanceof MultiNoiseBiomeSource noiseSource) {
					List<Pair<Climate.ParameterPoint, Holder<Biome>>> parameters = new ArrayList<>(getBiomeParameters(noiseSource).values());

					<#list spawn_overworld as biome>
					addParameterPoint(parameters, new Pair<>(
						new Climate.ParameterPoint(
							Climate.Parameter.span(${biome.genTemperature.min}f, ${biome.genTemperature.max}f),
							Climate.Parameter.span(${biome.genHumidity.min}f, ${biome.genHumidity.max}f),
							Climate.Parameter.span(${biome.genContinentalness.min}f, ${biome.genContinentalness.max}f),
							Climate.Parameter.span(${biome.genErosion.min}f, ${biome.genErosion.max}f),
							Climate.Parameter.point(0.0f),
							Climate.Parameter.span(${biome.genWeirdness.min}f, ${biome.genWeirdness.max}f),
							0 <#-- offset -->
						),
						biomeRegistry.getHolderOrThrow(ResourceKey.create(Registries.BIOME, new ResourceLocation("${modid}", "${biome.getModElement().getRegistryName()}")))
					));
					addParameterPoint(parameters, new Pair<>(
						new Climate.ParameterPoint(
							Climate.Parameter.span(${biome.genTemperature.min}f, ${biome.genTemperature.max}f),
							Climate.Parameter.span(${biome.genHumidity.min}f, ${biome.genHumidity.max}f),
							Climate.Parameter.span(${biome.genContinentalness.min}f, ${biome.genContinentalness.max}f),
							Climate.Parameter.span(${biome.genErosion.min}f, ${biome.genErosion.max}f),
							Climate.Parameter.point(1.0f),
							Climate.Parameter.span(${biome.genWeirdness.min}f, ${biome.genWeirdness.max}f),
							0 <#-- offset -->
						),
						biomeRegistry.getHolderOrThrow(ResourceKey.create(Registries.BIOME, new ResourceLocation("${modid}", "${biome.getModElement().getRegistryName()}")))
					));
					</#list>

					<#list spawn_overworld_caves as biome>
					addParameterPoint(parameters, new Pair<>(
						new Climate.ParameterPoint(
							Climate.Parameter.span(${biome.genTemperature.min}f, ${biome.genTemperature.max}f),
							Climate.Parameter.span(${biome.genHumidity.min}f, ${biome.genHumidity.max}f),
							Climate.Parameter.span(${biome.genContinentalness.min}f, ${biome.genContinentalness.max}f),
							Climate.Parameter.span(${biome.genErosion.min}f, ${biome.genErosion.max}f),
							Climate.Parameter.span(${biome.genDepth.min}f, ${biome.genDepth.max}f),
							Climate.Parameter.span(${biome.genWeirdness.min}f, ${biome.genWeirdness.max}f),
							0 <#-- offset -->
						),
						biomeRegistry.getHolderOrThrow(ResourceKey.create(Registries.BIOME, new ResourceLocation("${modid}", "${biome.getModElement().getRegistryName()}")))
					));
					</#list>

					setBiomeSource(chunkGenerator, MultiNoiseBiomeSource.createFromList(new Climate.ParameterList<>(parameters)));
					rebuildFeaturesPerStep(chunkGenerator);
				}

				if(chunkGenerator instanceof NoiseBasedChunkGenerator noiseGenerator) {
					((${JavaModName}NoiseGeneratorSettings)(Object)noiseGenerator.generatorSettings().value()).set${modid}DimensionTypeReference(dimensionType);
				}
			}
			</#if>

			<#if spawn_nether?has_content>
			if (dimensionType.is(BuiltinDimensionTypes.NETHER)) {
				ChunkGenerator chunkGenerator = levelStem.generator();

				// Inject biomes to biome source
				if(chunkGenerator.getBiomeSource() instanceof MultiNoiseBiomeSource noiseSource) {
					List<Pair<Climate.ParameterPoint, Holder<Biome>>> parameters = new ArrayList<>(getBiomeParameters(noiseSource).values());

					<#list spawn_nether as biome>
					addParameterPoint(parameters, new Pair<>(
						new Climate.ParameterPoint(
							Climate.Parameter.span(${biome.genTemperature.min}f, ${biome.genTemperature.max}f),
							Climate.Parameter.span(${biome.genHumidity.min}f, ${biome.genHumidity.max}f),
							Climate.Parameter.span(${biome.genContinentalness.min}f, ${biome.genContinentalness.max}f),
							Climate.Parameter.span(${biome.genErosion.min}f, ${biome.genErosion.max}f),
							Climate.Parameter.point(0.0f),
							Climate.Parameter.span(${biome.genWeirdness.min}f, ${biome.genWeirdness.max}f),
							0 <#-- offset -->
						),
						biomeRegistry.getHolderOrThrow(ResourceKey.create(Registries.BIOME, new ResourceLocation("${modid}", "${biome.getModElement().getRegistryName()}")))
					));
					addParameterPoint(parameters, new Pair<>(
						new Climate.ParameterPoint(
							Climate.Parameter.span(${biome.genTemperature.min}f, ${biome.genTemperature.max}f),
							Climate.Parameter.span(${biome.genHumidity.min}f, ${biome.genHumidity.max}f),
							Climate.Parameter.span(${biome.genContinentalness.min}f, ${biome.genContinentalness.max}f),
							Climate.Parameter.span(${biome.genErosion.min}f, ${biome.genErosion.max}f),
							Climate.Parameter.point(1.0f),
							Climate.Parameter.span(${biome.genWeirdness.min}f, ${biome.genWeirdness.max}f),
							0 <#-- offset -->
						),
						biomeRegistry.getHolderOrThrow(ResourceKey.create(Registries.BIOME, new ResourceLocation("${modid}", "${biome.getModElement().getRegistryName()}")))
					));
					</#list>

					setBiomeSource(chunkGenerator, MultiNoiseBiomeSource.createFromList(new Climate.ParameterList<>(parameters)));
					rebuildFeaturesPerStep(chunkGenerator);
				}

				if(chunkGenerator instanceof NoiseBasedChunkGenerator noiseGenerator) {
					((${JavaModName}NoiseGeneratorSettings)(Object)noiseGenerator.generatorSettings().value()).set${modid}DimensionTypeReference(dimensionType);
				}
			}
			</#if>
		}
	}

	public static SurfaceRules.RuleSource adaptSurfaceRule(SurfaceRules.RuleSource currentRuleSource, Holder<DimensionType> dimensionType) {
		<#if spawn_overworld?has_content || spawn_overworld_caves?has_content>
		if (dimensionType.is(BuiltinDimensionTypes.OVERWORLD)) return injectOverworldSurfaceRules(currentRuleSource);
		</#if>

		<#if spawn_nether?has_content>
		if (dimensionType.is(BuiltinDimensionTypes.NETHER)) return injectNetherSurfaceRules(currentRuleSource);
		</#if>

		return currentRuleSource;
	}

	<#if spawn_overworld?has_content || spawn_overworld_caves?has_content>
	private static SurfaceRules.RuleSource injectOverworldSurfaceRules(SurfaceRules.RuleSource currentRuleSource) {
		List<SurfaceRules.RuleSource> customSurfaceRules = new ArrayList<>();

		<#list spawn_overworld_caves as biome>
		customSurfaceRules.add(anySurfaceRule(
			ResourceKey.create(Registries.BIOME, new ResourceLocation("${modid}", "${biome.getModElement().getRegistryName()}")),
			${mappedBlockToBlockStateCode(biome.groundBlock)},
			${mappedBlockToBlockStateCode(biome.undergroundBlock)},
			${mappedBlockToBlockStateCode(biome.getUnderwaterBlock())}
		));
		</#list>

		<#list spawn_overworld as biome>
		customSurfaceRules.add(preliminarySurfaceRule(
			ResourceKey.create(Registries.BIOME, new ResourceLocation("${modid}", "${biome.getModElement().getRegistryName()}")),
			${mappedBlockToBlockStateCode(biome.groundBlock)},
			${mappedBlockToBlockStateCode(biome.undergroundBlock)},
			${mappedBlockToBlockStateCode(biome.getUnderwaterBlock())}
		));
		</#list>

		customSurfaceRules.add(currentRuleSource);
		return SurfaceRules.sequence(customSurfaceRules.toArray(SurfaceRules.RuleSource[]::new));
	}
	</#if>

	<#if spawn_nether?has_content>
	private static SurfaceRules.RuleSource injectNetherSurfaceRules(SurfaceRules.RuleSource currentRuleSource) {
		List<SurfaceRules.RuleSource> customSurfaceRules = new ArrayList<>();

		<#list spawn_nether as biome>
		customSurfaceRules.add(anySurfaceRule(
			ResourceKey.create(Registries.BIOME, new ResourceLocation("${modid}", "${biome.getModElement().getRegistryName()}")),
			${mappedBlockToBlockStateCode(biome.groundBlock)},
			${mappedBlockToBlockStateCode(biome.undergroundBlock)},
			${mappedBlockToBlockStateCode(biome.getUnderwaterBlock())}
		));
		</#list>

		customSurfaceRules.add(currentRuleSource);
		return SurfaceRules.sequence(customSurfaceRules.toArray(SurfaceRules.RuleSource[]::new));
	}
	</#if>

	<#if spawn_overworld?has_content>
	private static SurfaceRules.RuleSource preliminarySurfaceRule(ResourceKey<Biome> biomeKey, BlockState groundBlock, BlockState undergroundBlock, BlockState underwaterBlock) {
		return SurfaceRules.ifTrue(SurfaceRules.isBiome(biomeKey),
			SurfaceRules.ifTrue(SurfaceRules.abovePreliminarySurface(),
				SurfaceRules.sequence(
					SurfaceRules.ifTrue(SurfaceRules.stoneDepthCheck(0, false, 0, CaveSurface.FLOOR),
						SurfaceRules.sequence(
							SurfaceRules.ifTrue(SurfaceRules.waterBlockCheck(-1, 0),
								SurfaceRules.state(groundBlock)
							),
							SurfaceRules.state(underwaterBlock)
						)
					),
					SurfaceRules.ifTrue(SurfaceRules.stoneDepthCheck(0, true, 0, CaveSurface.FLOOR),
						SurfaceRules.state(undergroundBlock)
					)
				)
			)
		);
	}
	</#if>

	<#if spawn_nether?has_content || spawn_overworld_caves?has_content>
	private static SurfaceRules.RuleSource anySurfaceRule(ResourceKey<Biome> biomeKey, BlockState groundBlock, BlockState undergroundBlock, BlockState underwaterBlock) {
		return SurfaceRules.ifTrue(SurfaceRules.isBiome(biomeKey),
			SurfaceRules.ifTrue(SurfaceRules.yBlockCheck(VerticalAnchor.aboveBottom(5), 0),
				SurfaceRules.ifTrue(SurfaceRules.not(SurfaceRules.yBlockCheck(VerticalAnchor.belowTop(5), 0)),
					SurfaceRules.sequence(
						SurfaceRules.ifTrue(SurfaceRules.stoneDepthCheck(0, false, 0, CaveSurface.FLOOR),
							SurfaceRules.sequence(
								SurfaceRules.ifTrue(SurfaceRules.waterBlockCheck(-1, 0),
									SurfaceRules.state(groundBlock)
								),
								SurfaceRules.state(underwaterBlock)
							)
						),
						SurfaceRules.ifTrue(SurfaceRules.stoneDepthCheck(0, true, 0, CaveSurface.FLOOR),
							SurfaceRules.state(undergroundBlock)
						)
					)
				)
			)
		);
	}
	</#if>

	private static void addParameterPoint(List<Pair<Climate.ParameterPoint, Holder<Biome>>> parameters, Pair<Climate.ParameterPoint, Holder<Biome>> point) {
		if (!parameters.contains(point))
			parameters.add(point);
	}


	private static Climate.ParameterList<Holder<Biome>> getBiomeParameters(MultiNoiseBiomeSource source) {
		try {
			java.lang.reflect.Method method = MultiNoiseBiomeSource.class.getDeclaredMethod("parameters");
			method.setAccessible(true);
			@SuppressWarnings("unchecked")
			Climate.ParameterList<Holder<Biome>> result = (Climate.ParameterList<Holder<Biome>>) method.invoke(source);
			return result;
		} catch (ReflectiveOperationException e) {
			throw new IllegalStateException("Failed to read multi-noise biome parameters", e);
		}
	}

	private static void setBiomeSource(ChunkGenerator generator, net.minecraft.world.level.biome.BiomeSource source) {
		try {
			java.lang.reflect.Field field = ChunkGenerator.class.getDeclaredField("biomeSource");
			field.setAccessible(true);
			field.set(generator, source);
		} catch (ReflectiveOperationException e) {
			throw new IllegalStateException("Failed to replace chunk generator biome source", e);
		}
	}

	private static void rebuildFeaturesPerStep(ChunkGenerator generator) {
		try {
			java.lang.reflect.Field settingsField = ChunkGenerator.class.getDeclaredField("generationSettingsGetter");
			settingsField.setAccessible(true);
			@SuppressWarnings("unchecked")
			java.util.function.Function<Holder<Biome>, net.minecraft.world.level.biome.BiomeGenerationSettings> settingsGetter =
					(java.util.function.Function<Holder<Biome>, net.minecraft.world.level.biome.BiomeGenerationSettings>) settingsField.get(generator);
			java.util.function.Supplier<java.util.List<FeatureSorter.StepFeatureData>> featuresPerStep =
					Suppliers.memoize(() -> FeatureSorter.buildFeaturesPerStep(List.copyOf(generator.getBiomeSource().possibleBiomes()),
							biome -> settingsGetter.apply(biome).features(), true));
			java.lang.reflect.Field featuresField = ChunkGenerator.class.getDeclaredField("featuresPerStep");
			featuresField.setAccessible(true);
			featuresField.set(generator, featuresPerStep);
		} catch (ReflectiveOperationException e) {
			throw new IllegalStateException("Failed to rebuild feature step data", e);
		}
	}

	public interface ${JavaModName}NoiseGeneratorSettings {
		void set${modid}DimensionTypeReference(Holder<DimensionType> dimensionType);
	}

}

<#-- @formatter:on -->
