<#-- @formatter:off -->
package ${package};

import com.mojang.serialization.Codec;
import com.mojang.serialization.codecs.RecordCodecBuilder;
import io.netty.buffer.Unpooled;
import it.unimi.dsi.fastutil.ints.IntObjectImmutablePair;
import it.unimi.dsi.fastutil.ints.IntObjectPair;
import net.minecraft.core.BlockPos;
import net.minecraft.core.registries.Registries;
import net.minecraft.network.FriendlyByteBuf;
import net.minecraft.resources.ResourceKey;
import net.minecraft.resources.ResourceLocation;
import net.minecraft.server.TickTask;
import net.minecraft.server.level.ServerLevel;
import net.minecraft.server.level.ServerPlayer;
import net.minecraft.util.RandomSource;
import net.minecraft.world.level.Level;
import net.minecraft.world.level.levelgen.placement.PlacementContext;
import net.minecraft.world.level.levelgen.placement.PlacementModifier;
import net.minecraft.world.level.levelgen.placement.PlacementModifierType;
import net.minecraftforge.common.MinecraftForge;
import net.minecraftforge.event.TickEvent;
import net.minecraftforge.event.network.CustomPayloadEvent;
import net.minecraftforge.eventbus.api.IEventBus;
import net.minecraftforge.eventbus.api.SubscribeEvent;
import net.minecraftforge.fml.common.Mod;
import net.minecraftforge.fml.javafmlmod.FMLJavaModLoadingContext;
import net.minecraftforge.network.ChannelBuilder;
import net.minecraftforge.network.PacketDistributor;
import net.minecraftforge.network.SimpleChannel;
import net.minecraftforge.registries.DeferredRegister;
import net.minecraftforge.registries.RegistryObject;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import ${package}.network.CustomPacketPayload;
import ${package}.network.IPlayPayloadHandler;
import ${package}.network.PlayPayloadContext;

import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.PriorityQueue;
import java.util.Queue;
import java.util.concurrent.ConcurrentLinkedQueue;
import java.util.function.Function;
import java.util.stream.IntStream;
import java.util.stream.Stream;

@Mod("${modid}") public class ${JavaModName} {

	public static final String MODID = "${modid}";
	public static final Logger LOGGER = LogManager.getLogger(${JavaModName}.class);
	public static final DeferredRegister<PlacementModifierType<?>> PLACEMENT_MODIFIERS = DeferredRegister
			.create(Registries.PLACEMENT_MODIFIER_TYPE, MODID);
	public static final RegistryObject<PlacementModifierType<?>> FIXED_PLACEMENT = PLACEMENT_MODIFIERS
			.register("fixed_placement", () -> FixedPlacementModifier.TYPE);

	public ${JavaModName}() {
		IEventBus modEventBus = FMLJavaModLoadingContext.get().getModEventBus();
		MinecraftForge.EVENT_BUS.register(this);

		<@javacompress>
		<#if w.hasSounds()>${JavaModName}Sounds.REGISTRY.register(modEventBus);</#if>
		<#if types.base_blocks?has_content>${JavaModName}Blocks.REGISTRY.register(modEventBus);</#if>
		<#list w.getGElementsOfType("dimension") as dimension><#if dimension.enablePortal>
		modEventBus.addListener(${package}.world.teleporter.${dimension.getModElement().getName()}Teleporter::registerPointOfInterest);</#if></#list>
		<#if types.base_blockentities?has_content>${JavaModName}BlockEntities.REGISTRY.register(modEventBus);</#if>
		<#if types.base_items?has_content>${JavaModName}Items.register(modEventBus);</#if>
		<#if types.base_entities?has_content>${JavaModName}Entities.REGISTRY.register(modEventBus);</#if>
		<#if w.hasItemsInTabs()>${JavaModName}Tabs.REGISTRY.register(modEventBus);</#if>
		<#if types.base_features?has_content>${JavaModName}Features.REGISTRY.register(modEventBus);</#if>
		PLACEMENT_MODIFIERS.register(modEventBus);
		<#if w.getElementsOfType("feature")?filter(e -> e.getMetadata("has_nbt_structure")??)?size != 0>StructureFeature.REGISTRY.register(modEventBus);</#if>
		<#if types["paintings"]??>${JavaModName}Paintings.REGISTRY.register(modEventBus);</#if>
		<#if types["potions"]??>${JavaModName}Potions.REGISTRY.register(modEventBus);</#if>
		<#if types["potioneffects"]??>${JavaModName}MobEffects.REGISTRY.register(modEventBus);</#if>
		<#if types["enchantments"]??>${JavaModName}Enchantments.REGISTRY.register(modEventBus);</#if>
		<#if types["guis"]??>${JavaModName}Menus.REGISTRY.register(modEventBus);</#if>
		<#if types["particles"]??>${JavaModName}ParticleTypes.REGISTRY.register(modEventBus);</#if>
		<#if types["villagerprofessions"]??>${JavaModName}VillagerProfessions.PROFESSIONS.register(modEventBus);</#if>
		<#if types["fluids"]??>
			${JavaModName}Fluids.REGISTRY.register(modEventBus);
			${JavaModName}FluidTypes.REGISTRY.register(modEventBus);
		</#if>
		<#if types["attributes"]??>${JavaModName}Attributes.REGISTRY.register(modEventBus);</#if>
		<#if w.hasElementsOfType("bannerpattern")>${JavaModName}BannerPatterns.REGISTRY.register(modEventBus);</#if>
		</@javacompress>

		// Start of user code block mod init
		// End of user code block mod init
	}

	// Start of user code block mod methods
	// End of user code block mod methods

	public static ServerPlayer getRandomPlayer(Level level) {
		if (!(level instanceof ServerLevel serverLevel))
			return null;
		var players = serverLevel.getServer().getPlayerList().getPlayers();
		return players.isEmpty() ? null : players.get(serverLevel.random.nextInt(players.size()));
	}

	private static final SimpleChannel NETWORK = ChannelBuilder.named(new ResourceLocation(MODID, "main"))
			.networkProtocolVersion(1)
			.simpleChannel();

	private record NetworkMessage(Function<FriendlyByteBuf, ?> reader, IPlayPayloadHandler<?> handler) {}

	private static final Map<ResourceLocation, NetworkMessage> MESSAGES = new HashMap<>();
	private static boolean networkingRegistered = false;

	public static <T extends CustomPacketPayload> void addNetworkMessage(ResourceLocation id,
			Function<FriendlyByteBuf, T> reader, IPlayPayloadHandler<T> handler) {
		ensureNetworkInitialized();
		MESSAGES.put(id, new NetworkMessage(reader, handler));
	}

	private static void ensureNetworkInitialized() {
		if (!networkingRegistered) {
			NETWORK.messageBuilder(NetworkEnvelope.class, 0)
					.encoder(NetworkEnvelope::encode)
					.decoder(NetworkEnvelope::new)
					.consumerMainThread(NetworkEnvelope::handle)
					.add();
			networkingRegistered = true;
		}
	}

	private static byte[] encodePayload(CustomPacketPayload message) {
		FriendlyByteBuf buffer = new FriendlyByteBuf(Unpooled.buffer());
		message.write(buffer);
		byte[] data = new byte[buffer.readableBytes()];
		buffer.readBytes(data);
		return data;
	}

	public static void sendToPlayer(ServerPlayer player, CustomPacketPayload message) {
		ensureNetworkInitialized();
		NETWORK.send(new NetworkEnvelope(message.id(), encodePayload(message)), PacketDistributor.PLAYER.with(player));
	}

	public static void sendToServer(CustomPacketPayload message) {
		ensureNetworkInitialized();
		NETWORK.send(new NetworkEnvelope(message.id(), encodePayload(message)), PacketDistributor.SERVER.noArg());
	}

	public static void sendToAll(CustomPacketPayload message) {
		ensureNetworkInitialized();
		NETWORK.send(new NetworkEnvelope(message.id(), encodePayload(message)), PacketDistributor.ALL.noArg());
	}

	public static void sendToDimension(ResourceKey<Level> dimension, CustomPacketPayload message) {
		ensureNetworkInitialized();
		NETWORK.send(new NetworkEnvelope(message.id(), encodePayload(message)), PacketDistributor.DIMENSION.with(dimension));
	}

	private static final class NetworkEnvelope {
		private final ResourceLocation id;
		private final byte[] data;

		private NetworkEnvelope(ResourceLocation id, byte[] data) {
			this.id = id;
			this.data = data;
		}

		private NetworkEnvelope(FriendlyByteBuf buffer) {
			this(buffer.readResourceLocation(), buffer.readByteArray());
		}

		private void encode(FriendlyByteBuf buffer) {
			buffer.writeResourceLocation(id);
			buffer.writeByteArray(data);
		}

		@SuppressWarnings({"rawtypes", "unchecked"}) private static void handle(NetworkEnvelope envelope,
				CustomPayloadEvent.Context context) {
			NetworkMessage message = MESSAGES.get(envelope.id);
			if (message != null) {
				FriendlyByteBuf buffer = new FriendlyByteBuf(Unpooled.wrappedBuffer(envelope.data));
				Object decoded = message.reader().apply(buffer);
				((IPlayPayloadHandler) message.handler()).handle(decoded, new PlayPayloadContext(context));
			}
			context.setPacketHandled(true);
		}
	}

	public static class FixedPlacementModifier extends PlacementModifier {
		public static final Codec<FixedPlacementModifier> CODEC = RecordCodecBuilder.create(instance -> instance.group(
				Codec.INT.listOf().fieldOf("x").forGetter(modifier -> modifier.x),
				Codec.INT.listOf().fieldOf("y").forGetter(modifier -> modifier.y),
				Codec.INT.listOf().fieldOf("z").forGetter(modifier -> modifier.z)
		).apply(instance, FixedPlacementModifier::new));
		public static final PlacementModifierType<FixedPlacementModifier> TYPE = () -> CODEC;

		private final List<Integer> x;
		private final List<Integer> y;
		private final List<Integer> z;

		private FixedPlacementModifier(List<Integer> x, List<Integer> y, List<Integer> z) {
			this.x = x;
			this.y = y;
			this.z = z;
		}

		@Override public Stream<BlockPos> getPositions(PlacementContext context, RandomSource random, BlockPos pos) {
			int size = Math.min(x.size(), Math.min(y.size(), z.size()));
			int chunkX = pos.getX() >> 4;
			int chunkZ = pos.getZ() >> 4;
			return IntStream.range(0, size).mapToObj(i -> new BlockPos(x.get(i), y.get(i), z.get(i)))
					.filter(position -> (position.getX() >> 4) == chunkX && (position.getZ() >> 4) == chunkZ);
		}

		@Override public PlacementModifierType<?> type() {
			return TYPE;
		}
	}

	<#-- Wait procedure block support below -->
	private static final Queue<IntObjectPair<Runnable>> workToBeScheduled = new ConcurrentLinkedQueue<>();
	private static final PriorityQueue<TickTask> workQueue = new PriorityQueue<>(Comparator.comparingInt(TickTask::getTick));

	public static void queueServerWork(int delay, Runnable action) {
		workToBeScheduled.add(new IntObjectImmutablePair<>(delay, action));
	}

	@SubscribeEvent public void tick(TickEvent.ServerTickEvent event) {
		if (event.phase == TickEvent.Phase.END) {
			int currentTick = event.getServer().getTickCount();

			IntObjectPair<Runnable> work;
			while ((work = workToBeScheduled.poll()) != null) {
				workQueue.add(new TickTask(currentTick + work.leftInt(), work.right()));
			}

			while (!workQueue.isEmpty() && currentTick >= workQueue.peek().getTick()) {
				workQueue.poll().run();
			}
		}
	}
}
<#-- @formatter:on -->
