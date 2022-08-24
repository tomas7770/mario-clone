extends CanvasLayer

onready var coin_label = $Container/CoinLabel
onready var score_label = $Container/ScoreLabel
onready var pause_box = $Container/PauseBox
onready var heart_container = $Container/HeartContainer

func track_player(player):
	player.connect("got_coin", self, "_on_got_coin", [player])
	player.connect("score_changed", self, "_on_score_changed", [player])
	player.connect("hp_changed", self, "_on_hp_changed", [player])

func _on_got_coin(player):
	coin_label.text = str(player.coins)

func _on_score_changed(player):
	score_label.text = "Score: "+str(player.score)

func _on_hp_changed(player):
	var i = 1
	for heart in heart_container.get_children():
		if i <= player.hp:
			heart.self_modulate = Color(1,1,1)
		else:
			heart.self_modulate = Color(0,0,0)
		i += 1

func on_pause():
	pause_box.visible = true

func on_unpause():
	pause_box.visible = false
