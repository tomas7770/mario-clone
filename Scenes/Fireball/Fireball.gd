extends KinematicBody2D

enum MOVE_DIR {LEFT, RIGHT}

export (float) var speed = 250.0
export (float) var rotation_speed = 360.0

onready var sprite = $Sprite

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var velocity = Vector2.UP*100
var current_move_dir = MOVE_DIR.RIGHT

var source

func set_move_dir(move_dir):
	current_move_dir = move_dir

# Set whatever entity shot this fireball
func set_source(ball_source):
	source = ball_source

func explode():
	queue_free()

func _process(delta):
	sprite.rotation += -rotation_speed*delta*velocity.x/speed

func _physics_process(delta):
	match current_move_dir:
		MOVE_DIR.RIGHT:
			velocity.x = speed
		MOVE_DIR.LEFT:
			velocity.x = -speed
	velocity.y += gravity*delta
	var prev_velocity = velocity
	velocity = move_and_slide(velocity, Vector2.UP)
	if is_on_floor() or is_on_ceiling():
		# Bounce
		velocity.y = -prev_velocity.y
	elif is_on_wall():
		explode()

func _on_BodyArea_area_entered(area):
	var enemy = area.get_parent()
	if enemy and enemy.is_in_group("Enemies") and enemy.alive:
		enemy.generic_kill(source)
		explode()
