if (${input$entity} instanceof LivingEntity _living)
	_living.hurtTime = _living.invulnerableDuration - ${opt.toInt(input$invulnerableTime)};