extends KinematicBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

signal burnt
signal received

const ZONE = 20

var burning : = false
var destroyed : = false
var received : = false
var direction : = Vector2.ZERO
var speed := 0

var velocity : = Vector2.ZERO
var target_pos := Vector2.ZERO
var is_spam : = true

onready var animation : = $AnimationPlayer
onready var audio : = $AudioStreamPlayer2D
onready var sprite : = $Sprite
onready var collsion : = $ClickArea

var burn_sound = preload("res://Assets/audio/burn.ogg")
var recv_sound = preload("res://Assets/audio/received.ogg")

# Called when the node enters the scene tree for the first time.
func _ready():
	animation.connect("animation_finished", self, "ani_callback")
	collsion.connect("clicked", self, "clicked")
	if is_spam : animation.play("Spam", -1, .5 )
	
func _physics_process(delta):
	if animation.get_current_animation() == "Burn" and animation.is_active() == false :
		animation.play("Burnt")
		
	var dir = ( target_pos - self.position).normalized()
	var distance = self.position.distance_to(target_pos)

	if not received and not burning and distance < ZONE : 
		received = true
		animation.play("Received")
		audio.stream = recv_sound
		audio.play()

	
	velocity = velocity.move_toward(dir * speed, speed * delta)
	velocity = move_and_slide(velocity)

func clicked() :
	if not burning and not received:
		burning = true
		animation.play("Burn", -1, .5)
		audio.stream = burn_sound
		audio.play()

func ani_callback(animation) :
	destroyed = true
	
	match animation:
		"Burn":
			emit_signal("burnt", self)
		"Received":
			emit_signal("received", self)

func set_direction(dir : Vector2) :
	self.direction = dir
	
func set_speed(spd : int) :
	self.speed = spd
	
func set_spam(is_spam : bool) :
	self.is_spam = is_spam
	
func set_target(pos : Vector2) :
	self.target_pos = pos
