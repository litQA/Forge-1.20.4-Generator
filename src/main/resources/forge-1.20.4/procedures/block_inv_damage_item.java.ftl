<#include "mcelements.ftl">
<#-- @formatter:off -->
if (world instanceof Level _ext && getBlockCapability(_ext, ${toBlockPos(input$x,input$y,input$z)}, null, ForgeCapabilities.ITEM_HANDLER) instanceof IItemHandlerModifiable _itemHandlerModifiable) {
	int _slotid = ${opt.toInt(input$slotid)};
	ItemStack _stk = _itemHandlerModifiable.getStackInSlot(_slotid).copy();
	if (_stk.hurt(${opt.toInt(input$amount)}, RandomSource.create(), null)) {
		_stk.shrink(1);
		_stk.setDamageValue(0);
	}
	_itemHandlerModifiable.setStackInSlot(_slotid, _stk);
}
<#-- @formatter:on -->