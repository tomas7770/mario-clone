extends CanvasLayer

onready var coin_label = $Container/CoinLabel
onready var score_label = $Container/ScoreLabel
onready var pause_box = $Container/PauseBox
onready var heart_container = $Container/HeartContainer
onready var life_label = $Container/LifeLabel

func track_player(player):
	player.connect("coins_changed", self, "_on_coins_changed", [player])
	player.connect("score_changed", self, "_on_score_changed", [player])
	player.connect("hp_changed", self, "_on_hp_changed", [player])
	player.connect("lives_changed", self, "_on_lives_changed", [player])
	_on_coins_changed(player)
	_on_score_changed(player)
	_on_hp_changed(player)
	_on_lives_changed(player)

func _on_coins_changed(player):
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

func _on_lives_changed(player):
	life_label.text = "x" + str(player.lives)

func on_pause():
	pause_box.visible = true

func on_unpause():
	pause_box.visible = false
