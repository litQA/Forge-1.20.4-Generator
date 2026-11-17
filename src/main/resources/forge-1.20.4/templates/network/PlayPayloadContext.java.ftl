package ${package}.network;

import java.util.concurrent.CompletableFuture;
import java.util.function.Supplier;
import net.minecraft.network.Connection;
import net.minecraft.network.chat.Component;
import net.minecraft.server.level.ServerPlayer;
import net.minecraft.world.entity.player.Player;
import net.minecraftforge.event.network.CustomPayloadEvent;

/**
 * Small compatibility wrapper used by generated payload handlers.
 */
public final class PlayPayloadContext {
	private final CustomPayloadEvent.Context context;

	public PlayPayloadContext(CustomPayloadEvent.Context context) {
		this.context = context;
	}

	public PacketFlow flow() {
		return context.getConnection().getReceiving() == net.minecraft.network.protocol.PacketFlow.CLIENTBOUND
				? PacketFlow.CLIENTBOUND
				: PacketFlow.SERVERBOUND;
	}

	public WorkHandler workHandler() {
		return task -> context.enqueueWork(task);
	}

	public Supplier<Player> player() {
		return () -> {
			ServerPlayer sender = context.getSender();
			if (sender != null)
				return sender;
			return net.minecraft.client.Minecraft.getInstance().player;
		};
	}

	public PacketHandler packetHandler() {
		return this::disconnect;
	}

	private void disconnect(Component reason) {
		Connection connection = context.getConnection();
		if (connection != null)
			connection.disconnect(reason);
	}

	@FunctionalInterface public interface WorkHandler {
		CompletableFuture<Void> submitAsync(Runnable task);
	}

	@FunctionalInterface public interface PacketHandler {
		void disconnect(Component reason);
	}
}
