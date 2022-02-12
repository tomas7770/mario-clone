extends Node2D

export (float) var gravity = 2500.0

onready var body = $Body
onready var sprite = $AnimatedSprite

var velocity = Vector2()

func _ready():
	pass

func _process(_delta):
	sprite.transform = body.transform

func _physics_process(delta):
	velocity.y += gravity*delta
	velocity = body.move_and_slide(velocity, Vector2(0, -1))
