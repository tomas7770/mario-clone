extends Node2D

onready var body = $Body
onready var sprite = $Sprite

func _process(_delta):
	sprite.transform = body.transform

func _on_picked_up():
	body.get_node("CollisionShape2D").set_deferred("disabled", true)
	queue_free()

func _on_body_entered(other_body):
	if other_body.get_parent() is Player:
		other_body.get_parent().give_coin()
		_on_picked_up()
