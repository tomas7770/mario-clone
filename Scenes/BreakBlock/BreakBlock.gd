extends Node2D
class_name BreakBlock

enum CONT_TYPE {NONE, COINS}

export (CONT_TYPE) var content_type = CONT_TYPE.NONE
export (int) var coin_amount = 0

onready var collision_shape = $Body/CollisionShape2D
onready var sprite = $AnimatedSprite
onready var break_particles = $BreakParticles
onready var coin_particle = $CoinParticle

var is_broken = false

func _destroy_on_timeout(timeout):
	var timer = Timer.new()
	timer.one_shot = true
	timer.connect("timeout", self, "queue_free")
	add_child(timer)
	timer.start(timeout)

func do_break(player):
	if is_broken:
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
