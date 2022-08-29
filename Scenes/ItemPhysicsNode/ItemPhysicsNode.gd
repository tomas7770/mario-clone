extends Node

var body_gravity = ProjectSettings.get_setting("physics/2d/default_gravity")*0.1
var velocity = Vector2()

onready var item = get_parent()
onready var body = item.get_node("Body")

func _physics_process(delta):
	velocity.y += body_gravity*delta
	velocity = body.move_and_slide(velocity, Vector2.UP)
	item.position = body.global_position
	body.position = Vector2.ZERO
