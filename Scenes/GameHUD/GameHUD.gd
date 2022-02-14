extends CanvasLayer

onready var coin_label = $Container/CoinLabel

func track_player(player):
	player.connect("got_coin", self, "_on_got_coin", [player])

func _on_got_coin(player):
	coin_label.text = str(player.coins)
