<#-- @formatter:off -->
package ${package}.network;

import ${package}.${JavaModName};
import net.minecraft.world.entity.Entity;

@Mod.EventBusSubscriber(bus = Mod.EventBusSubscriber.Bus.MOD) public class ${JavaModName}Variables {

	<#if w.hasVariablesOfScope("GLOBAL_SESSION")>
		<#list variables as var>
			<#if var.getScope().name() == "GLOBAL_SESSION">
				<@var.getType().getScopeDefinition(generator.getWorkspace(), "GLOBAL_SESSION")['init']?interpret/>
			</#if>
		</#list>
	</#if>

	@SubscribeEvent public static void init(FMLCommonSetupEvent event) {
		<#if w.hasVariablesOfScope("GLOBAL_WORLD") || w.hasVariablesOfScope("GLOBAL_MAP")>
			${JavaModName}.addNetworkMessage(SavedDataSyncMessage.ID, SavedDataSyncMessage::new, SavedDataSyncMessage::handleData);
		</#if>

		<#if w.hasVariablesOfScope("PLAYER_LIFETIME") || w.hasVariablesOfScope("PLAYER_PERSISTENT")>
			${JavaModName}.addNetworkMessage(PlayerVariablesSyncMessage.ID, PlayerVariablesSyncMessage::new, PlayerVariablesSyncMessage::handleData);
		</#if>
	}

	<#if w.hasVariablesOfScope("GLOBAL_WORLD") || w.hasVariablesOfScope("GLOBAL_MAP") || w.hasVariablesOfScope("PLAYER_LIFETIME") || w.hasVariablesOfScope("PLAYER_PERSISTENT")>
    @Mod.EventBusSubscriber public static class EventBusVariableHandlers {
		<#if w.hasVariablesOfScope("PLAYER_LIFETIME") || w.hasVariablesOfScope("PLAYER_PERSISTENT")>
        @SubscribeEvent public static void onPlayerLoggedInSyncPlayerVariables(PlayerEvent.PlayerLoggedInEvent event) {
            if (event.getEntity() instanceof ServerPlayer player)
                ${JavaModName}.sendToPlayer(player, new PlayerVariablesSyncMessage(getPlayerVariables(player)));
        }

        @SubscribeEvent public static void onPlayerRespawnedSyncPlayerVariables(PlayerEvent.PlayerRespawnEvent event) {
            if (event.getEntity() instanceof ServerPlayer player)
                ${JavaModName}.sendToPlayer(player, new PlayerVariablesSyncMessage(getPlayerVariables(player)));
        }

        @SubscribeEvent public static void onPlayerChangedDimensionSyncPlayerVariables(PlayerEvent.PlayerChangedDimensionEvent event) {
            if (event.getEntity() instanceof ServerPlayer player)
                ${JavaModName}.sendToPlayer(player, new PlayerVariablesSyncMessage(getPlayerVariables(player)));
        }

        @SubscribeEvent public static void onPlayerTickUpdateSyncPlayerVariables(TickEvent.PlayerTickEvent event) {
            if (event.phase == TickEvent.Phase.END && event.player instanceof ServerPlayer player
                    && getPlayerVariables(player)._syncDirty) {
                ${JavaModName}.sendToPlayer(player, new PlayerVariablesSyncMessage(getPlayerVariables(player)));
                getPlayerVariables(player)._syncDirty = false;
            }
        }

        @SubscribeEvent public static void clonePlayer(PlayerEvent.Clone event) {
            PlayerVariables original = getPlayerVariables(event.getOriginal());
            PlayerVariables clone = PlayerVariablesStore.get(event.getEntity()).get(event.getEntity().getUUID());
            <#list variables as var>
                <#if var.getScope().name() == "PLAYER_PERSISTENT">
                clone.${var.getName()} = original.${var.getName()};
                </#if>
            </#list>
            if (!event.isWasDeath()) {
                <#list variables as var>
                    <#if var.getScope().name() == "PLAYER_LIFETIME">
                    clone.${var.getName()} = original.${var.getName()};
                    </#if>
                </#list>
            }
            PlayerVariablesStore.get(event.getEntity()).put(event.getEntity().getUUID(), clone);
        }
        </#if>

        <#if w.hasVariablesOfScope("GLOBAL_WORLD") || w.hasVariablesOfScope("GLOBAL_MAP")>
        @SubscribeEvent public static void onPlayerLoggedIn(PlayerEvent.PlayerLoggedInEvent event) {
            if (event.getEntity() instanceof ServerPlayer player) {
                SavedData mapdata = MapVariables.get(player.level());
                SavedData worlddata = WorldVariables.get(player.level());
                if (mapdata != null)
                    ${JavaModName}.sendToPlayer(player, new SavedDataSyncMessage(0, mapdata));
                if (worlddata != null)
                    ${JavaModName}.sendToPlayer(player, new SavedDataSyncMessage(1, worlddata));
            }
        }

        @SubscribeEvent public static void onPlayerChangedDimension(PlayerEvent.PlayerChangedDimensionEvent event) {
            if (event.getEntity() instanceof ServerPlayer player) {
                SavedData worlddata = WorldVariables.get(player.level());
                if (worlddata != null)
                    ${JavaModName}.sendToPlayer(player, new SavedDataSyncMessage(1, worlddata));
            }
        }

        @SubscribeEvent public static void onWorldTick(TickEvent.LevelTickEvent event) {
            if (event.phase == TickEvent.Phase.END && event.level instanceof ServerLevel level) {
                WorldVariables worldVariables = WorldVariables.get(level);
                if (worldVariables._syncDirty) {
                    ${JavaModName}.sendToDimension(level.dimension(), new SavedDataSyncMessage(1, worldVariables));
                    worldVariables._syncDirty = false;
                }

                MapVariables mapVariables = MapVariables.get(level);
                if (mapVariables._syncDirty) {
                    ${JavaModName}.sendToAll(new SavedDataSyncMessage(0, mapVariables));
                    mapVariables._syncDirty = false;
                }
            }
        }
		</#if>
	}
	</#if>

	<#if w.hasVariablesOfScope("GLOBAL_WORLD") || w.hasVariablesOfScope("GLOBAL_MAP")>
	public static class WorldVariables extends SavedData {

		public static final String DATA_NAME = "${modid}_worldvars";

		boolean _syncDirty = false;

		<#list variables as var>
			<#if var.getScope().name() == "GLOBAL_WORLD">
				<@var.getType().getScopeDefinition(generator.getWorkspace(), "GLOBAL_WORLD")['init']?interpret/>
			</#if>
		</#list>

		public static WorldVariables load(CompoundTag tag) {
			WorldVariables data = new WorldVariables();
			data.read(tag);
			return data;
		}

		public void read(CompoundTag nbt) {
			<#list variables as var>
				<#if var.getScope().name() == "GLOBAL_WORLD">
					<@var.getType().getScopeDefinition(generator.getWorkspace(), "GLOBAL_WORLD")['read']?interpret/>
				</#if>
			</#list>
		}

		@Override public CompoundTag save(CompoundTag nbt) {
			<#list variables as var>
				<#if var.getScope().name() == "GLOBAL_WORLD">
					<@var.getType().getScopeDefinition(generator.getWorkspace(), "GLOBAL_WORLD")['write']?interpret/>
				</#if>
			</#list>
			return nbt;
		}

		public void markSyncDirty() {
			this.setDirty();
			this._syncDirty = true;
		}

		static WorldVariables clientSide = new WorldVariables();

		public static WorldVariables get(LevelAccessor world) {
			if (world instanceof ServerLevel level) {
				return level.getDataStorage().computeIfAbsent(new SavedData.Factory<WorldVariables>(WorldVariables::new, WorldVariables::load, net.minecraft.util.datafix.DataFixTypes.LEVEL), DATA_NAME);
			} else {
				return clientSide;
			}
		}
	}

	public static class MapVariables extends SavedData {

		public static final String DATA_NAME = "${modid}_mapvars";

		boolean _syncDirty = false;

		<#list variables as var>
			<#if var.getScope().name() == "GLOBAL_MAP">
				<@var.getType().getScopeDefinition(generator.getWorkspace(), "GLOBAL_MAP")['init']?interpret/>
			</#if>
		</#list>

		public static MapVariables load(CompoundTag tag) {
			MapVariables data = new MapVariables();
			data.read(tag);
			return data;
		}

		public void read(CompoundTag nbt) {
			<#list variables as var>
				<#if var.getScope().name() == "GLOBAL_MAP">
					<@var.getType().getScopeDefinition(generator.getWorkspace(), "GLOBAL_MAP")['read']?interpret/>
				</#if>
			</#list>
		}

		@Override public CompoundTag save(CompoundTag nbt) {
			<#list variables as var>
				<#if var.getScope().name() == "GLOBAL_MAP">
					<@var.getType().getScopeDefinition(generator.getWorkspace(), "GLOBAL_MAP")['write']?interpret/>
				</#if>
			</#list>
			return nbt;
		}

		public void markSyncDirty() {
			this.setDirty();
			_syncDirty = true;
		}

		static MapVariables clientSide = new MapVariables();

		public static MapVariables get(LevelAccessor world) {
			if (world instanceof ServerLevelAccessor serverLevelAcc) {
				return serverLevelAcc.getLevel().getServer().getLevel(Level.OVERWORLD).getDataStorage()
						.computeIfAbsent(new SavedData.Factory<MapVariables>(MapVariables::new, MapVariables::load, net.minecraft.util.datafix.DataFixTypes.LEVEL), DATA_NAME);
			} else {
				return clientSide;
			}
		}
	}

	public static class SavedDataSyncMessage implements CustomPacketPayload {

		private final int dataType;
		private final SavedData data;

		public static final ResourceLocation ID = new ResourceLocation(${JavaModName}.MODID, "saved_data_sync");

		public SavedDataSyncMessage(int dataType, SavedData data) {
			this.dataType = dataType;
			this.data = data;
		}

		public SavedDataSyncMessage(FriendlyByteBuf buffer) {
			int dataType = buffer.readInt();
			CompoundTag nbt = buffer.readNbt();
			SavedData data = null;
			if (nbt != null) {
				data = dataType == 0 ? new MapVariables() : new WorldVariables();
				if (data instanceof MapVariables mapVariables)
					mapVariables.read(nbt);
				else if (data instanceof WorldVariables worldVariables)
					worldVariables.read(nbt);
			}
			this.dataType = dataType;
			this.data = data;
		}

		@Override public void write(final FriendlyByteBuf buffer) {
			buffer.writeInt(dataType);
			if (data != null)
				buffer.writeNbt(data.save(new CompoundTag()));
		}

		@Override public ResourceLocation id() {
			return ID;
		}

		public static void handleData(final SavedDataSyncMessage message, final PlayPayloadContext context) {
			if (context.flow() == PacketFlow.CLIENTBOUND && message.data != null) {
				context.workHandler().submitAsync(() -> {
					if (message.dataType == 0)
						MapVariables.clientSide.read(message.data.save(new CompoundTag()));
					else
						WorldVariables.clientSide.read(message.data.save(new CompoundTag()));
				}).exceptionally(e -> {
					context.packetHandler().disconnect(Component.literal(e.getMessage()));
					return null;
				});
			}
		}
	}
	</#if>

	<#if w.hasVariablesOfScope("PLAYER_LIFETIME") || w.hasVariablesOfScope("PLAYER_PERSISTENT")>
	public static class PlayerVariables implements INBTSerializable<CompoundTag> {

		private final UUID playerUUID;
		private final PlayerVariablesStore store;
		boolean _syncDirty = false;

		public PlayerVariables(UUID playerUUID, PlayerVariablesStore store) {
			this.playerUUID = playerUUID;
			this.store = store;
		}

		<#list variables as var>
			<#if var.getScope().name() == "PLAYER_LIFETIME">
				<@var.getType().getScopeDefinition(generator.getWorkspace(), "PLAYER_LIFETIME")['init']?interpret/>
			<#elseif var.getScope().name() == "PLAYER_PERSISTENT">
				<@var.getType().getScopeDefinition(generator.getWorkspace(), "PLAYER_PERSISTENT")['init']?interpret/>
			</#if>
		</#list>

		@Override public CompoundTag serializeNBT() {
			CompoundTag nbt = new CompoundTag();
			<#list variables as var>
				<#if var.getScope().name() == "PLAYER_LIFETIME">
					<@var.getType().getScopeDefinition(generator.getWorkspace(), "PLAYER_LIFETIME")['write']?interpret/>
				<#elseif var.getScope().name() == "PLAYER_PERSISTENT">
					<@var.getType().getScopeDefinition(generator.getWorkspace(), "PLAYER_PERSISTENT")['write']?interpret/>
				</#if>
			</#list>
			return nbt;
		}

		@Override public void deserializeNBT(CompoundTag nbt) {
			<#list variables as var>
				<#if var.getScope().name() == "PLAYER_LIFETIME">
					<@var.getType().getScopeDefinition(generator.getWorkspace(), "PLAYER_LIFETIME")['read']?interpret/>
				<#elseif var.getScope().name() == "PLAYER_PERSISTENT">
					<@var.getType().getScopeDefinition(generator.getWorkspace(), "PLAYER_PERSISTENT")['read']?interpret/>
				</#if>
			</#list>
		}

		public void markSyncDirty() {
			_syncDirty = true;
			if (store != null)
				store.setDirty();
		}
	}

	public static class PlayerVariablesStore extends SavedData {

		public static final String DATA_NAME = "${modid}_playervars";

		private final Map<UUID, PlayerVariables> values = new HashMap<>();

		public static PlayerVariablesStore load(CompoundTag tag) {
			PlayerVariablesStore store = new PlayerVariablesStore();
			ListTag list = tag.getList("players", Tag.TAG_COMPOUND);
			for (int i = 0; i < list.size(); i++) {
				CompoundTag entry = list.getCompound(i);
				UUID uuid = entry.getUUID("uuid");
				PlayerVariables vars = new PlayerVariables(uuid, store);
				vars.deserializeNBT(entry.getCompound("data"));
				store.values.put(uuid, vars);
			}
			return store;
		}

		@Override public CompoundTag save(CompoundTag tag) {
			ListTag list = new ListTag();
			for (Map.Entry<UUID, PlayerVariables> entry : values.entrySet()) {
				CompoundTag item = new CompoundTag();
				item.putUUID("uuid", entry.getKey());
				item.put("data", entry.getValue().serializeNBT());
				list.add(item);
			}
			tag.put("players", list);
			return tag;
		}

		public PlayerVariables get(UUID uuid) {
			return values.computeIfAbsent(uuid, id -> new PlayerVariables(id, this));
		}

		public void put(UUID uuid, PlayerVariables variables) {
			values.put(uuid, variables);
			setDirty();
		}

		public static PlayerVariablesStore get(ServerLevel level) {
			return level.getServer().getLevel(Level.OVERWORLD).getDataStorage()
					.computeIfAbsent(new SavedData.Factory<PlayerVariablesStore>(PlayerVariablesStore::new, PlayerVariablesStore::load, net.minecraft.util.datafix.DataFixTypes.LEVEL), DATA_NAME);
		}

		public static PlayerVariablesStore get(ServerPlayer player) {
			return get(player.serverLevel());
		}

		public static PlayerVariablesStore get(Player player) {
			if (player instanceof ServerPlayer serverPlayer)
				return get(serverPlayer);
			throw new IllegalStateException("Player variables are only available on the server");
		}
	}

	public static PlayerVariables getPlayerVariables(Entity entity) {
		if (entity instanceof Player player)
			return getPlayerVariables(player);
		return new PlayerVariables(entity.getUUID(), null);
	}

	public static PlayerVariables getPlayerVariables(Player player) {
		if (player instanceof ServerPlayer serverPlayer)
			return PlayerVariablesStore.get(serverPlayer).get(player.getUUID());

		PlayerVariables client = CLIENT_PLAYER_VARIABLES.get(player.getUUID());
		if (client == null) {
			client = new PlayerVariables(player.getUUID(), null);
			CLIENT_PLAYER_VARIABLES.put(player.getUUID(), client);
		}
		return client;
	}

	private static final Map<UUID, PlayerVariables> CLIENT_PLAYER_VARIABLES = new HashMap<>();

	public record PlayerVariablesSyncMessage(PlayerVariables data) implements CustomPacketPayload {

		public static final ResourceLocation ID = new ResourceLocation(${JavaModName}.MODID, "player_variables_sync");

		public PlayerVariablesSyncMessage(FriendlyByteBuf buffer) {
			this(read(buffer));
		}

		private static PlayerVariables read(FriendlyByteBuf buffer) {
			UUID uuid = buffer.readUUID();
			PlayerVariables data = new PlayerVariables(uuid, null);
			CompoundTag nbt = buffer.readNbt();
			if (nbt != null)
				data.deserializeNBT(nbt);
			return data;
		}

		@Override public void write(final FriendlyByteBuf buffer) {
			buffer.writeUUID(data.playerUUID);
			buffer.writeNbt(data.serializeNBT());
		}

		@Override public ResourceLocation id() {
			return ID;
		}

		public static void handleData(final PlayerVariablesSyncMessage message, final PlayPayloadContext context) {
			if (context.flow() == PacketFlow.CLIENTBOUND && message.data != null) {
				context.workHandler().submitAsync(() -> CLIENT_PLAYER_VARIABLES.put(message.data.playerUUID, message.data))
						.exceptionally(e -> {
							context.packetHandler().disconnect(Component.literal(e.getMessage()));
							return null;
						});
			}
		}
	}
	</#if>
}
<#-- @formatter:on -->
