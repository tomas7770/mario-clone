extends Node2D

export (float) var gravity = 2500.0
export (float) var acceleration = 800.0
export (float) var deceleration = 2000.0
export (float) var max_speed = 500.0
export (float) var jump_velocity = 1000.0
export (float) var stop_jump_factor = 0.2

onready var body = $Body
onready var sprite = $AnimatedSprite

var velocity = Vector2()
var jumping = false

func _process(_delta):
	sprite.transform = body.transform

func _attempt_move(delta, left):
	var move_sign = -1 if left else 1
	if is_zero_approx(velocity.x) or sign(velocity.x) == move_sign:
		velocity.x += move_sign*acceleration*delta
	else:
		velocity.x += move_sign*deceleration*delta
	velocity.x = clamp(velocity.x, -max_speed, max_speed)

func _stop_move(delta):
	if !is_zero_approx(velocity.x):
		var move_sign = sign(velocity.x)
		var new_speed = abs(velocity.x)-deceleration*delta
		if new_speed > 0:
			velocity.x = move_sign*new_speed
		else:
			velocity.x = 0

func _attempt_jump():
	if jumping or !body.is_on_floor():
		return
	velocity.y -= jump_velocity
	jumping = true

func _stop_jump():
	if !jumping:
		return
	if velocity.y < 0:
		velocity.y *= stop_jump_factor
	jumping = false

func _physics_input(delta):
	if Input.is_action_pressed("plr1_right"):
		_attempt_move(delta, false)
	elif Input.is_action_pressed("plr1_left"):
		_attempt_move(delta, true)
	else:
		_stop_move(delta)
	if Input.is_action_just_pressed("plr1_jump"):
		_attempt_jump()
	elif Input.is_action_just_released("plr1_jump"):
		_stop_jump()

func _physics_process(delta):
	_physics_input(delta)
	velocity.y += gravity*delta
	velocity = body.move_and_slide(velocity, Vector2.UP)
