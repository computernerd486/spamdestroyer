extends Node2D


#These will be dynamically added on start dependin on level for number
onready var rng = RandomNumberGenerator.new()

onready var timer : = $SendTimer


onready var hud : = $Hud
onready var hud_filtered : = $Hud/Filtered
onready var hud_processed := $Hud/Processed
onready var hud_level : = $Hud/Level

onready var main_menu : = $MainMenu
onready var start : = $MainMenu/Panel/VBoxContainer/StartGame
onready var customLevel : = $MainMenu/Panel/VBoxContainer/CustomConfig

onready var complete_dialog : = $LevelOver

onready var menu_to_main : = $LevelOver/Panel/VBoxContainer/HBoxContainer/MainMenu
onready var menu_next_level : = $LevelOver/Panel/VBoxContainer/HBoxContainer/Next
onready var menu_replay_level : = $LevelOver/Panel/VBoxContainer/HBoxContainer/Replay

onready var stats_spam_sent : = $LevelOver/Panel/VBoxContainer/GridContainer/SpamSent
onready var stats_spam_burnt : = $LevelOver/Panel/VBoxContainer/GridContainer/BurnedSpam
onready var stats_spam_recv : = $LevelOver/Panel/VBoxContainer/GridContainer/RecSpam
onready var stats_legit_sent : = $LevelOver/Panel/VBoxContainer/GridContainer/LegitSent
onready var stats_legit_burnt : = $LevelOver/Panel/VBoxContainer/GridContainer/BurnedLegit
onready var stats_legit_recv : = $LevelOver/Panel/VBoxContainer/GridContainer/RecLegit
onready var stats_success : = $LevelOver/Panel/VBoxContainer/GridContainer/SuccessRate

var SpawnerTemplate = preload("res://Assets/mail/Spawner.tscn")
var TargetTemplate = preload("res://Assets/pc/Pc.tscn")
var Levels = preload("res://Assets/Levels.gd")

onready var audioEffects : = $EffectPlayer
var audio_start = preload("res://Assets/audio/menu_click.ogg")


var sent : int
var remaining : int
var level_num : int

# Level Settings

var messages_to_send : = 10
var messages_handled := 0

# Scores
var received_clean : = 0
var received_spam : = 0

var burnt_clean := 0
var burnt_spam := 0

var sent_spam := 0
var sent_clean := 0

var level : Level
var levels

func _init():
	level_num = 0
	levels = Levels.new()
	level = levels.levels[level_num]
	
	sent = 0
	remaining = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	start.connect("pressed", self, "start_game")
	menu_next_level.connect("pressed", self, "next_level")
	menu_replay_level.connect("pressed", self, "replay_level")
	menu_to_main.connect("pressed", self, "show_main_menu")
	timer.connect("timeout", self, "send_mail")
	
func show_main_menu():
	main_menu.visible = true
	hud.visible = false
	complete_dialog.visible = false
	
	clear_level()

	#TODO: Clear state here just in case

func start_game() :
	if customLevel.is_custom : custom_level()
	
	#Stats
	sent_clean = 0
	sent_spam = 0
	burnt_clean = 0
	burnt_spam = 0
	received_clean = 0
	received_spam = 0
	
	messages_to_send = level.messages
	messages_handled = 0
	
	sent = 0
	remaining = level.messages
	
	main_menu.visible = false
	hud.visible = true
	
	create_spawners(level.senders)
	create_targets(level.receivers)
	
	get_tree().call_group("spawners", "set_active", true)
	
	timer.start(level.send_rate)
	timer.paused = false
	
	# audioEffects.stream = audio_start
	# audioEffects.play()
	
func replay_level() :
	print("Replay Level")
	load_level()
	start_game()

func next_level() :
	print("Next Level")
	level_num = clamp(level_num + 1, 0, 4)
	load_level()
	start_game()
	
func custom_level() :
	print("Custom Level")

	var custom = Level.new()
	custom.number = 9
	custom.messages = customLevel.messages
	custom.send_rate = 1.0 / customLevel.rate #This is in messages/second
	custom.senders = customLevel.senders
	custom.receivers = customLevel.receivers
	custom.ratio = 5
	
	levels.levels.append(custom)
	level_num = 5
	
	hud_level.text = "X"
	level = custom

func clear_level() :
	var spawners = get_tree().get_nodes_in_group("spawners")
	
	for spawner in spawners:
		remove_child(spawner)
		spawner.queue_free()
		
	var targets = get_tree().get_nodes_in_group("targets")
	
	for target in targets:
		remove_child(target)
		target.queue_free()
		
	var mail = get_tree().get_nodes_in_group("mail")
	
	for m in mail:
		remove_child(m)
		m.queue_free()
	

func load_level() :
	print("Loading Level")
	level = levels.levels[level_num]
	hud_level.text = str(level_num + 1)
	
	complete_dialog.visible = false
	clear_level()

	start_game()
	
func create_spawners(num) :
	var step = 320 / ( num + 1 )
	
	for i in num:
		var spawner = SpawnerTemplate.instance()
		spawner.connect("spawn", self, "mail_created")
		spawner.set_ratio(level.ratio)
		spawner.position = Vector2(75, (i + 1) * step)
		spawner.add_to_group("spawners")
		add_child(spawner)
	
func create_targets(num) :
	var step = 320 / ( num + 1 )
	
	for i in num:
		var trg = TargetTemplate.instance()
		trg.add_to_group("targets")
		trg.position = Vector2(640 - 75, (i + 1) * step)
		add_child(trg)

# Picks a random spawner and sends it from that
func send_mail() :
	
	if (sent >= messages_to_send) :
		timer.paused = true
		return
	
	rng.randi_range(1, level.senders)
	var arr = get_tree().get_nodes_in_group("spawners")
	
	arr.shuffle()
	arr.front().send()
		
func pick_target() :
	var arr = get_tree().get_nodes_in_group("targets")
	
	arr.shuffle()
	return arr.front().position

func mail_created(mail) :
	mail.connect("burnt", self, "mail_burnt")
	mail.connect("received", self, "mail_received")
	mail.set_target(pick_target())
	add_child(mail)
	mail.add_to_group("mail")
		
	if mail.is_spam :
		sent_spam += 1
	else :
		sent_clean += 1
	
	sent += 1

func mail_burnt(mail) :
	if mail.is_spam :
		burnt_spam += 1
	else :
		burnt_clean += 1
		
	mail_end(mail)
	
func mail_received(mail) :	
	if mail.is_spam :
		received_spam += 1
	else :
		received_clean += 1
		
	mail_end(mail)
	
func mail_end(mail):
	remove_child(mail)
	#mail.queue_free()
	
	messages_handled += 1
	
	print("Sent: " + str(sent) + " Handled: " + str(messages_handled))
	
	var message_group = get_tree().get_nodes_in_group("mail")
	print(message_group.size())
	
	# Game breaking fix, in case it destorys messages
	if timer.paused and message_group.size() == 0 :
		finish_level()
	
	if messages_handled >= sent :
		finish_level()
		

func finish_level() :
	timer.paused = true
	complete_dialog.visible = true
	
	stats_spam_sent.text = str(sent_spam)
	stats_spam_burnt.text = str(burnt_spam)
	stats_spam_recv.text = str(received_spam)
	
	stats_legit_sent.text = str(sent_clean)
	stats_legit_burnt.text = str(burnt_clean)
	stats_legit_recv.text = str(received_clean)
	
	
	var success = int(float(burnt_spam + received_clean) / float(sent_spam + sent_clean) * 100)
	stats_success.text = str(success) + "%"
	
	menu_next_level.visible = (level_num < 4)
	menu_to_main.visible = not menu_next_level.visible
	
	print("Level Complete")
	
func _process(_delta):
	print_score()
	
func print_score() :
	hud_filtered.text = str(burnt_spam) + "/" + str(sent_spam)
	hud_processed.text = str(messages_handled) + "/" + str(sent)
	
	
	# print("Burn : [S: " + str(burnt_spam) + " C: " + str(burnt_clean) + "] Received : [S: " + str(received_spam) + " C: " + str(received_clean) + "]")

func _on_level_pressed(num):
	level_num = num
	level = levels.levels[level_num]
	hud_level.text = str(level_num + 1)
	start_game()
