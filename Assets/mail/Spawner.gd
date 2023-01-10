extends Position2D


# Simple frequency based spawner, 
# - Sends a Signal with the mail Object when spawns
# - Sets the Direction and Speed of the new object
# - Locates it at the location of this spawner
var active : = false
var chance : = 0

var MailTemplate = preload("res://Assets/mail/Mail.tscn")

onready var pc = $Pc
onready var rng = RandomNumberGenerator.new()

signal spawn

# Called when the node enters the scene tree for the first time.
func _ready():
	pc.connect("sent", self, "_spawn")

func _spawn(): 
	var mail = MailTemplate.instance()
	mail.set_direction(Vector2(1, 0))
	mail.set_position(self.position)
	mail.set_speed(75)
	mail.set_spam(rng.randi_range(0, 10) < chance)
	emit_signal("spawn", mail)

func send(): 
	pc.send()

func set_active(active : bool) :
	self.active = active

# Chance percent to send spam, 1-10, 10 is everytime
func set_ratio(chance : int) :
	self.chance = chance
