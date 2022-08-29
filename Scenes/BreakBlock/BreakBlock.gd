extends StaticBody2D
class_name BreakBlock

enum CONT_TYPE {
	NONE,
	COINS,
	HEART,
	LIFE,
}
const EMPTY_COLOR = Color(0,1,1)
const ITEM_LAUNCH_VEL = Vector2(15, -60)

export (CONT_TYPE) var content_type = CONT_TYPE.NONE
export (int) var coin_amount = 0
export (bool) var hidden = false

var heart_scene = preload("res://Scenes/Heart/Heart.tscn")
var life_scene = preload("res://Scenes/Life/Life.tscn")

onready var collision_shape = $CollisionShape2D
onready var sprite = $AnimatedSprite
onready var break_particles = $BreakParticles
onready var coin_particle = $CoinParticle

var is_broken = false
var hit_this_tick = false

func _ready():
	if hidden:
		sprite.visible = false
		collision_shape.one_way_collision = true

func _destroy_on_timeout(timeout):
	var timer = Timer.new()
	timer.one_shot = true
	timer.connect("timeout", self, "queue_free")
	add_child(timer)
	timer.start(timeout)

func do_break(player):
	if is_broken or hit_this_tick:
		return
	match content_type:
		CONT_TYPE.NONE:
			collision_shape.set_deferred("disabled", true)
			sprite.visible = false
			break_particles.emitting = true
			_destroy_on_timeout(break_particles.lifetime)
			is_broken = true
		CONT_TYPE.COINS:
			player.give_coin()
			coin_particle.restart()
			coin_particle.emitting = true
			coin_amount -= 1
			if coin_amount <= 0:
				sprite.modulate = EMPTY_COLOR
				is_broken = true
		CONT_TYPE.HEART:
			_shoot_item(heart_scene)
		CONT_TYPE.LIFE:
			_shoot_item(life_scene)
	hit_this_tick = true
	if hidden:
		sprite.visible = true
		collision_shape.one_way_collision = false

func _shoot_item(base_scene):
	var new_item = base_scene.instance()
	var physics_node = new_item.get_node_or_null("ItemPhysicsNode")
	if !physics_node:
		return
	new_item.position = position + Vector2(0, -12)
	physics_node.velocity = ITEM_LAUNCH_VEL
	# Randomize X direction
	if randi() % 2:
		physics_node.velocity.x = -physics_node.velocity.x
	get_parent().add_child(new_item)
	sprite.modulate = EMPTY_COLOR
	is_broken = true

func _physics_process(_delta):
	hit_this_tick = false
