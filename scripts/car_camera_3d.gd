extends Camera3D

@export var sensibilidade: float = 0.1

@onready var pivot: Node3D = get_parent() 

func _input(event: InputEvent) -> void:
	if not is_current(): 
		return
	
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		pivot.rotate_y(deg_to_rad(-event.relative.x * sensibilidade))
