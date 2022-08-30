extends KinematicBody2D

const PROCESS_DISTANCE = 600

export (float) var speed = 15.0
export (int) var score = 100
export (float) var death_bounce = 200.0

onready var body_area = $BodyArea
onready var sprite = $AnimatedSprite
onready var removal_timer = $RemovalTimer
onready var visibility_notifier = $AnimatedSprite/VisibilityNotifier

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var velocity = Vector2.LEFT*speed
var alive = true
var fall_off_screen = false
var processing = false
var target_player

func _ready():
	sprite.playing = true

func set_target_player(player):
	target_player = player

func _set_move_dir(left):
	var dir = -1 if left else 1
	velocity.x = dir*speed
	sprite.flip_h = true if left else false

func _die(player):
	alive = false
	body_area.set_deferred("monitorable", false)
	if player:
		player.give_score(score)

func stomp(player):
	_die(player)
	velocity.x = 0
	sprite.animation = "dead"
	removal_timer.start()

func generic_kill(player):
	_die(player)
	velocity.y = -death_bounce
	fall_off_screen = true
	if !visibility_notifier.is_on_screen():
		queue_free()

func _physics_process(delta):
	if !processing:
		_try_activate()
		return
	velocity.y += gravity*delta
	if !alive and fall_off_screen:
		position += velocity*delta
		return
	velocity = move_and_slide(velocity, Vector2.UP)
	if alive:
		for i in range(get_slide_count()):
			var collision = get_slide_collision(i)
			if Vector2.LEFT.dot(collision.normal) > 0.01:
				_set_move_dir(true)
			elif Vector2.RIGHT.dot(collision.normal) > 0.01:
				_set_move_dir(false)

func _try_activate():
	if target_player and position.x - target_player.position.x <= PROCESS_DISTANCE:
		processing = true

func _on_RemovalTimer_timeout():
	queue_free()

func _on_VisibilityNotifier_screen_exited():
	if fall_off_screen:
		queue_free()
