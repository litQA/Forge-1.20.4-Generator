private static void setStackInSlot(IItemHandler handler, int index, ItemStack resource, int amount) {
	if (handler == null || index < 0 || index >= handler.getSlots())
		return;
	ItemStack stack = resource.copy();
	stack.setCount(amount);
	if (handler instanceof IItemHandlerModifiable modifiable) {
		modifiable.setStackInSlot(index, stack);
	} else {
		handler.extractItem(index, handler.getStackInSlot(index).getCount(), false);
		handler.insertItem(index, stack, false);
	}
}
