extends PanelContainer

@onready var property_container = $MarginContainer/VBoxContainer
#var property
var frames_per_second : String

# Called when the node enters the scene tree for the first time.
func _ready():
	#set global reference to self in global singleton
	Global.debug = self
	#frames_per_second = "NO FRAMES DETECTED"
	visible = true 
	#add_property("FPS", frames_per_second, 2)

func _process(delta):
	frames_per_second = "%.2f" % (1.0/delta)
	track_and_update_property("FPS", frames_per_second, 2) 

func _input(event):
	#toggle debug panel
	if event.is_action_pressed("debug"):
		visible = !visible

#calls to this function must go into a type of _process function in order to be updated.
func track_and_update_property(title: String, value, order):
	var target
	target = property_container.find_child(title, true, false) # find label node with same name
	if !target: #If there is no current label node for property (i.e. initial load)
		target = Label.new()
		property_container.add_child(target)
		target.name = title #set name to title
		target.text = target.name + ": " + str(value)
	elif visible:
		target.text = title + ": " + str(value) 
		property_container.move_child(target, order) #reorder property based on given order value
		
#this approach is acceptable if you're fine calling a track_property call to instantiate and then only 
#expecting to update the values in _process. 
#Player speed is updated via _physics_process so this is probably not what we need.
#func update_properties(order, value):
	#if visible:
		#var properties = get_property_list()
		#for property in properties:
			#property.text = property.name + ": " + str(value) 
			#property_container.move_child(property, order)
