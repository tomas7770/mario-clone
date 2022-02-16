extends CanvasLayer

onready var coin_label = $Container/CoinLabel
onready var pause_box = $Container/PauseBox

func track_player(player):
	player.connect("got_coin", self, "_on_got_coin", [player])

func _on_got_coin(player):
	coin_label.text = str(player.coins)

func on_pause():
	pause_box.visible = true

func on_unpause():
	pause_box.visible = false
