extends Area2D

func _on_picked_up():
	get_node("CollisionShape2D").set_deferred("disabled", true)
	queue_free()

func _on_body_entered(other_body):
	if other_body is Player:
		other_body.give_coin()
		_on_picked_up()
