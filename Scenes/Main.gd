extends Control

onready var level = $Level
onready var game_hud = $GameHUD

func _ready():
	for child in level.get_children():
		if child is Player:
			game_hud.track_player(child)
