extends Sprite

signal sent

onready var player : = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	player.connect("animation_finished", self, "_sent")

func send():
	player.play("Send")
	
func _sent(animation) :
	if animation == "Send":
		emit_signal("sent")
		player.play("Idle")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
