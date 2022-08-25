extends Area2D
class_name Item

export (int) var score = 0

func pick_up(player):
	player.give_score(score)
	get_node("CollisionShape2D").set_deferred("disabled", true)
