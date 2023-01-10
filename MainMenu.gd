extends MarginContainer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var junkmail : = $Panel/Spam/Mail
onready var spam : = $Panel/Spam

#All the Level Select Stuff here

onready var seperator : = $Panel/VBoxContainer/HSeparator
onready var level_list : = $Panel/VBoxContainer/LevelSelect
onready var custom : = $Panel/VBoxContainer/CustomConfig

onready var level_button : = $Panel/VBoxContainer/HBoxContainer/LevelSelect
onready var custom_button : = $Panel/VBoxContainer/HBoxContainer/CustomGame

onready var custom_config := $Panel/VBoxContainer/CustomConfig

# Called when the node enters the scene tree for the first time.
func _ready():
	junkmail.received = false
	junkmail.set_spam(true)
	

func burn_sample() :
	pass


func _on_MainMenu_hide():
	if spam != null :
		remove_child(spam)
		spam.queue_free()


func _on_LevelSelect_toggled(button_pressed):
	custom_button.pressed = false
	
	seperator.visible = button_pressed
	level_list.visible = button_pressed
	

func _on_CustomGame_toggled(button_pressed):
	level_button.pressed = false
	
	custom_config.is_custom = button_pressed
	seperator.visible = button_pressed
	custom.visible = button_pressed
	
	
