private static ItemStack getEntitySlot(Entity entity, int slot) {
	if (entity != null) {
		IItemHandler itemHandler = entity.getCapability(ForgeCapabilities.ITEM_HANDLER, null).orElse(null);
		if (itemHandler != null && slot >= 0 && slot < itemHandler.getSlots()) {
			return itemHandler.getStackInSlot(slot).copy();
		}
	}
	return ItemStack.EMPTY;
}
