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

package ${package}.item.inventory;

import javax.annotation.Nonnull;
import net.minecraft.core.Direction;
import net.minecraft.nbt.CompoundTag;
import net.minecraft.world.entity.player.Player;
import net.minecraft.world.item.ItemStack;
import net.minecraftforge.common.capabilities.Capability;
import net.minecraftforge.common.capabilities.ForgeCapabilities;
import net.minecraftforge.common.capabilities.ICapabilitySerializable;
import net.minecraftforge.common.util.LazyOptional;
import net.minecraftforge.event.entity.item.ItemTossEvent;
import net.minecraftforge.eventbus.api.SubscribeEvent;
import net.minecraftforge.fml.common.Mod;
import net.minecraftforge.items.ItemStackHandler;

<@javacompress>
@Mod.EventBusSubscriber public class ${name}InventoryCapability extends ItemStackHandler implements ICapabilitySerializable<CompoundTag> {

	private final ItemStack stack;

	@SubscribeEvent public static void onItemDropped(ItemTossEvent event) {
		if (event.getEntity().getItem().getItem() == ${JavaModName}Items.${REGISTRYNAME}.get()) {
			Player player = event.getPlayer();
			if (player.containerMenu instanceof ${data.guiBoundTo}Menu)
				player.closeContainer();
		}
	}

	public ${name}InventoryCapability(ItemStack stack) {
		super(${data.inventorySize});
		this.stack = stack;
		CompoundTag tag = stack.getTagElement("Inventory");
		if (tag != null)
			deserializeNBT(tag);
	}

	<#if data.inventoryStackSize != 99>
	@Override public int getSlotLimit(int slot) {
		return ${data.inventoryStackSize};
	}
	</#if>

	@Override public boolean isItemValid(int slot, @Nonnull ItemStack stack) {
		return stack.getItem() != ${JavaModName}Items.${REGISTRYNAME}.get();
	}

	@Override public CompoundTag serializeNBT() {
		return super.serializeNBT();
	}

	@Override public void deserializeNBT(CompoundTag nbt) {
		super.deserializeNBT(nbt);
	}

	@Override protected void onContentsChanged(int slot) {
		stack.getOrCreateTag().put("Inventory", super.serializeNBT());
	}

	@Override public <T> LazyOptional<T> getCapability(Capability<T> capability, Direction side) {
		return capability == ForgeCapabilities.ITEM_HANDLER ? LazyOptional.of(() -> this).cast() : LazyOptional.empty();
	}

}
</@javacompress>

<#-- @formatter:on -->
