extends Node


export(Array) var levels = []

func _init():
	
	print("Creating Levels")
	
	var one = Level.new()
	one.number = 1
	one.receivers = 1
	one.senders = 1
	one.messages = 10
	one.send_rate = .75
	one.ratio = 5
	
	var two = Level.new()
	two.number = 2
	two.receivers = 1
	two.senders = 2
	two.messages = 15
	two.send_rate = .75
	two.ratio = 5
	
	var three = Level.new()
	three.number = 3
	three.receivers = 2
	three.senders = 2
	three.messages = 20
	three.send_rate = .75
	three.ratio = 5
	
	var four = Level.new()
	four.number = 4
	four.receivers = 2
	four.senders = 3
	four.messages = 25
	four.send_rate = .5
	four.ratio = 5
	
	var five = Level.new()
	five.number = 5
	five.receivers = 2
	five.senders = 4
	five.messages = 30
	five.send_rate = .5
	five.ratio = 5
	
	levels.append(one)
	levels.append(two)
	levels.append(three)
	levels.append(four)
	levels.append(five)
	
	print(levels)
