extends Item

func pick_up(player):
	.pick_up(player)
	player.give_powerup(player.POWERUP.FIRE_ESSENCE)
	queue_free()
