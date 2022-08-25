extends Area2D
class_name Coin

func pick_up():
	get_node("CollisionShape2D").set_deferred("disabled", true)
	queue_free()
