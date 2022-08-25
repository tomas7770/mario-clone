extends Item

func pick_up(player):
	.pick_up(player)
	player.give_coin()
	queue_free()
