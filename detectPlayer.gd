extends Area3D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	#set_monitoring(true) # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass



func _on_body_entered(body):
	if body.name == 'Player':
		print('player entered')
		#emit_signal('player_entered_interactable') 
		#make the code to have a pop up appear.
