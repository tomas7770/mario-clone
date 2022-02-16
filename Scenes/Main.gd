extends Control

onready var level = $Level
onready var game_hud = $GameHUD

func _ready():
	for child in level.get_children():
		if child is Player:
			game_hud.track_player(child)
			break

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		toggle_pause()

func toggle_pause():
	get_tree().paused = !get_tree().paused
	if get_tree().paused:
		game_hud.on_pause()
	else:
		game_hud.on_unpause()
