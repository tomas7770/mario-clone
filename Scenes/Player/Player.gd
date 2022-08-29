extends KinematicBody2D
class_name Player

signal coins_changed
signal score_changed
signal hp_changed
signal lives_changed
signal died

enum MOVE_DIR {LEFT, RIGHT}

const IDLE_ANIM = "idle"
const WALK_ANIM = "walk"
const JUMP_ANIM = "jump"

const MAX_HP = 3
const DEFAULT_LIVES = 5

const COINS_1UP_LIMIT = 100

export (float) var gravity = 1200.0
export (float) var acceleration = 500.0
export (float) var deceleration = 1200.0
export (float) var max_speed = 200.0
export (float) var jump_velocity = 450.0
export (float) var stop_jump_factor = 0.2
export (float) var enemy_bounce = 200.0
export (float) var death_bounce = 200.0

onready var body_area = $BodyArea
onready var damage_timer = $DamageTimer
onready var sprite = $AnimatedSprite
onready var camera = $AnimatedSprite/Camera2D
onready var jump_sound = $JumpSound
onready var coin_sound = $CoinSound
onready var animation_player = $AnimationPlayer

var velocity = Vector2()
var current_move_dir = MOVE_DIR.RIGHT
var jumping = false

var coins = 0
var score = 0
var hp = MAX_HP
var lives = DEFAULT_LIVES
var alive = true

var bottom_pos

func _ready():
	var tilemap = get_parent().get_node_or_null("TileMap")
	if tilemap:
		var used_rect = tilemap.get_used_rect()
		camera.limit_left = used_rect.position.x*tilemap.cell_size.x
		camera.limit_right = used_rect.end.x*tilemap.cell_size.x
		camera.limit_top = used_rect.position.y*tilemap.cell_size.y-240
		camera.limit_bottom = used_rect.end.y*tilemap.cell_size.y
		bottom_pos = used_rect.end.y*tilemap.cell_size.y

func init_stats(prev_stats):
	for stat in prev_stats:
		if stat == "hp" and prev_stats[stat] <= 0:
			continue
		self[stat] = prev_stats[stat]

func _process_animations():
	if is_on_floor():
		if is_zero_approx(velocity.x):
			if sprite.animation != IDLE_ANIM:
				sprite.animation = IDLE_ANIM
		else:
			if sprite.animation != WALK_ANIM:
				sprite.animation = WALK_ANIM
	else:
		if jumping and sprite.animation != JUMP_ANIM:
			sprite.animation = JUMP_ANIM
	match current_move_dir:
		MOVE_DIR.RIGHT:
			sprite.flip_h = false
		MOVE_DIR.LEFT:
			sprite.flip_h = true

func _process(_delta):
	if alive:
		_process_animations()

func _attempt_move(delta, left):
	current_move_dir = MOVE_DIR.LEFT if left else MOVE_DIR.RIGHT
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
	if jumping or !is_on_floor():
		return
	velocity.y = -jump_velocity
	jumping = true
	jump_sound.play()

func _stomp_enemy(enemy):
	enemy.stomp(self)
	if Input.is_action_pressed("plr1_jump"):
		velocity.y = -jump_velocity
		jumping = true
	else:
		velocity.y = -enemy_bounce

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
	elif !Input.is_action_pressed("plr1_jump"):
		_stop_jump()

func _breakblocks():
	for i in range(get_slide_count()):
			var collision = get_slide_collision(i)
			if Vector2.DOWN.dot(collision.normal) > 0.01:
				var other_body = collision.collider
				if other_body is BreakBlock:
					other_body.do_break(self)

func handle_touching_enemies():
	if !damage_timer.is_stopped():
		return
	var overlapping_areas = body_area.get_overlapping_areas()
	for area in overlapping_areas:
		var enemy = area.get_parent()
		if enemy and enemy.is_in_group("Enemies") and enemy.alive:
			if velocity.y <= 0:
				take_damage()

func _check_fall_death():
	return position.y > bottom_pos + $CollisionShape2D.shape.extents.y

func _physics_process(delta):
	velocity.y += gravity*delta
	if alive:
		_physics_input(delta)
		velocity = move_and_slide(velocity, Vector2.UP)
		_breakblocks()
		handle_touching_enemies()
		if _check_fall_death():
			die()
	else:
		position += velocity*delta

func _on_BodyArea_area_entered(area):
	if !alive:
		return
	var area_parent = area.get_parent()
	if area_parent and area_parent.is_in_group("Enemies"):
		if velocity.y > 0:
			_stomp_enemy(area_parent)
	elif area is Item:
		area.pick_up(self)

func give_coin():
	coins += 1
	coin_sound.play()
	if coins >= COINS_1UP_LIMIT:
		coins = 0
		give_life()
	emit_signal("coins_changed")

func give_score(amount):
	score += amount
	emit_signal("score_changed")

func give_hp():
	if !alive:
		return
	hp += 1
	if hp > MAX_HP:
		hp = MAX_HP
	emit_signal("hp_changed")

func take_damage():
	if !alive:
		return
	hp -= 1
	if hp <= 0:
		die()
	else:
		damage_timer.start()
		animation_player.stop()
		animation_player.play("Damage")
		animation_player.seek(0.1)
		emit_signal("hp_changed")

func _on_DamageTimer_timeout():
	animation_player.seek(0, true)
	animation_player.stop()

func give_life():
	lives += 1
	emit_signal("lives_changed")

func take_life():
	lives -= 1
	emit_signal("lives_changed")

func die():
	hp = 0
	take_life()
	alive = false
	velocity = death_bounce*Vector2.UP
	sprite.animation = IDLE_ANIM
	if animation_player.is_playing():
		animation_player.seek(0, true)
		animation_player.stop()
	emit_signal("hp_changed")
	emit_signal("died")
