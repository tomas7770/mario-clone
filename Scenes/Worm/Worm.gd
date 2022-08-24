extends KinematicBody2D

export (float) var speed = 15.0
export (int) var score = 100

onready var body_area = $BodyArea
onready var sprite = $AnimatedSprite
onready var removal_timer = $RemovalTimer

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var velocity = Vector2.LEFT*speed
var alive = true

func _ready():
	sprite.playing = true

func _set_move_dir(left):
	var dir = -1 if left else 1
	velocity.x = dir*speed
	sprite.flip_h = true if left else false

func stomp(player):
	alive = false
	body_area.set_deferred("monitorable", false)
	velocity.x = 0
	sprite.animation = "dead"
	removal_timer.start()
	player.give_score(score)

func _physics_process(delta):
	velocity.y += gravity*delta
	velocity = move_and_slide(velocity, Vector2.UP)
	if alive:
		for i in range(get_slide_count()):
			var collision = get_slide_collision(i)
			if Vector2.LEFT.dot(collision.normal) > 0.01:
				_set_move_dir(true)
			elif Vector2.RIGHT.dot(collision.normal) > 0.01:
				_set_move_dir(false)

func _on_RemovalTimer_timeout():
	queue_free()
