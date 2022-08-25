extends Control

var game_hud_scene = preload("res://Scenes/GameHUD/GameHUD.tscn")
var level
var game_hud

func _ready():
	randomize()
	load_level("TestLevel")

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		toggle_pause()

func toggle_pause():
	get_tree().paused = !get_tree().paused
	if get_tree().paused:
		game_hud.on_pause()
	else:
		game_hud.on_unpause()

func load_level(level_name):
	var new_level = load("res://Scenes/Levels/"+level_name+".tscn")
	level = new_level.instance()
	add_child(level)
	game_hud = game_hud_scene.instance()
	add_child(game_hud)
	for child in level.get_children():
		if child is Player:
			game_hud.track_player(child)
			break
