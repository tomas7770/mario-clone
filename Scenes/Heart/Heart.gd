extends Area2D
class_name Heart

export (int) var score = 1000

func pick_up():
	get_node("CollisionShape2D").set_deferred("disabled", true)
	queue_free()
