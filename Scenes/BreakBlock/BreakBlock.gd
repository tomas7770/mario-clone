extends Node2D
class_name BreakBlock

onready var collision_shape = $Body/CollisionShape2D
onready var sprite = $AnimatedSprite
onready var break_particles = $BreakParticles

var is_broken = false

func _destroy_on_timeout(timeout):
	var timer = Timer.new()
	timer.one_shot = true
	timer.connect("timeout", self, "queue_free")
	add_child(timer)
	timer.start(timeout)

func do_break():
	if is_broken:
		return
	collision_shape.set_deferred("disabled", true)
	sprite.visible = false
	break_particles.emitting = true
	_destroy_on_timeout(break_particles.lifetime)
	is_broken = true
