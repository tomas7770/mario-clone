extends StaticBody2D
class_name BreakBlock

enum CONT_TYPE {NONE, COINS, HEART}

export (CONT_TYPE) var content_type = CONT_TYPE.NONE
export (int) var coin_amount = 0

var heart_scene = preload("res://Scenes/Heart/Heart.tscn")

onready var collision_shape = $CollisionShape2D
onready var sprite = $AnimatedSprite
onready var break_particles = $BreakParticles
onready var coin_particle = $CoinParticle

var is_broken = false
var hit_this_tick = false

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
				sprite.modulate = Color(0,1,1)
				is_broken = true
		CONT_TYPE.HEART:
			var new_heart = heart_scene.instance()
			new_heart.position = position + Vector2(0, -12)
			get_parent().add_child(new_heart)
			sprite.modulate = Color(0,1,1)
			is_broken = true
	hit_this_tick = true

func _physics_process(_delta):
	hit_this_tick = false
