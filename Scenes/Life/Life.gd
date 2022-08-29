extends Item

var body_gravity = ProjectSettings.get_setting("physics/2d/default_gravity")*0.1
var velocity = Vector2()

onready var body = $Body

func _physics_process(delta):
	velocity.y += body_gravity*delta
	velocity = body.move_and_slide(velocity, Vector2.UP)
	position = body.global_position
	body.position = Vector2.ZERO

func pick_up(player):
	.pick_up(player)
	player.give_life()
	queue_free()
