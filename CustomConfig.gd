extends GridContainer

onready var val_sender = $ValueSender
onready var val_reciv = $ValueReceivers
onready var val_rate = $ValueRate
onready var val_mesg = $ValueMessages

export(int) var senders : = 1
export(int) var receivers : int = 1
export(int) var rate : int = 1 
export(int) var messages : int = 10
export(bool) var is_custom : bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _on_Senders_value_changed(value):
	senders = value
	val_sender.text = str(value)


func _on_Rate_value_changed(value):
	rate = value
	val_rate.text = str(value)


func _on_Receivers_value_changed(value):
	receivers = value
	val_reciv.text = str(value)


func _on_Messages_value_changed(value):
	messages = value
	val_mesg.text = str(value)
