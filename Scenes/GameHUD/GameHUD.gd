extends CanvasLayer

onready var coin_label = $Container/CoinLabel
onready var score_label = $Container/ScoreLabel
onready var pause_box = $Container/PauseBox

func track_player(player):
	player.connect("got_coin", self, "_on_got_coin", [player])
	player.connect("score_changed", self, "_on_score_changed", [player])

func _on_got_coin(player):
	coin_label.text = str(player.coins)

func _on_score_changed(player):
	score_label.text = "Score: "+str(player.score)

func on_pause():
	pause_box.visible = true

func on_unpause():
	pause_box.visible = false
