class_name InputComponent
extends Component

@export_custom(PROPERTY_HINT_COMPONENT, "", 0) var humanoid: HumanoidComponent

func _input_logic() -> void:
	if not humanoid:
		return
	
	var move_direction = Input.get_vector(&"MoveLeft", &"MoveRight", &"MoveForward", &"MoveBack")
	humanoid.move_direction = move_direction
	
	humanoid.jumping = Input.is_action_pressed(&"Jump")

func _process(delta: float) -> void:
	_input_logic()
