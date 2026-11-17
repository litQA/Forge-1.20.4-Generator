package ${package}.network;

import net.minecraft.network.FriendlyByteBuf;
import net.minecraft.resources.ResourceLocation;

/**
 * Common contract used by all generated network messages.
 */
public interface CustomPacketPayload {
	void write(FriendlyByteBuf buffer);

	ResourceLocation id();
}
