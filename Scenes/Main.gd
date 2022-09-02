extends Control

onready var respawn_timer = $RespawnTimer

var game_hud_scene = preload("res://Scenes/GameHUD/GameHUD.tscn")
var level
var loaded_level_name
var game_hud
var player
var prev_player_stats = {}

func _ready():
	randomize()
	load_level("TestLevel2")

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		toggle_pause()

func toggle_pause():
	get_tree().paused = !get_tree().paused
	if get_tree().paused:
		game_hud.on_pause()
	else:
		game_hud.on_unpause()

func _on_player_died():
	respawn_timer.start()

func _on_RespawnTimer_timeout():
	load_level(loaded_level_name)

func load_level(level_name):
	_unload_level()
	var new_level = load("res://Scenes/Levels/"+level_name+".tscn")
	level = new_level.instance()
	add_child(level)
	loaded_level_name = level_name
	game_hud = game_hud_scene.instance()
	add_child(game_hud)
	for child in level.get_children():
		if child is Player:
			player = child
			player.init_stats(prev_player_stats)
			game_hud.track_player(child)
			child.connect("died", self, "_on_player_died")
			break
	if player:
		for enemy in get_tree().get_nodes_in_group("Enemies"):
			enemy.set_target_player(player)
	_add_invisible_walls()

func _add_invisible_walls():
	var tilemap = level.get_node_or_null("TileMap")
	if tilemap:
		var used_rect = tilemap.get_used_rect()
		var left_wall = StaticBody2D.new()
		var right_wall = StaticBody2D.new()
		level.add_child(left_wall)
		level.add_child(right_wall)
		left_wall.position = Vector2(used_rect.position.x*tilemap.cell_size.x - 8, 0)
		right_wall.position = Vector2(used_rect.end.x*tilemap.cell_size.x + 8, 0)
		_add_rectangular_collision(left_wall, Vector2(16, 1000000))
		_add_rectangular_collision(right_wall, Vector2(16, 1000000))

func _add_rectangular_collision(static_body, size):
	var collision_shape = CollisionShape2D.new()
	var rectangle_shape = RectangleShape2D.new()
	rectangle_shape.extents = size/2
	collision_shape.shape = rectangle_shape
	static_body.add_child(collision_shape)

func _unload_level():
	if level:
		remove_child(level)
		remove_child(game_hud)
	if player:
		_save_player_stats()

func _save_player_stats():
	prev_player_stats["coins"] = player.coins
	prev_player_stats["score"] = player.score
	prev_player_stats["hp"] = player.hp
	prev_player_stats["lives"] = player.lives
	prev_player_stats["active_powerup"] = player.active_powerup
