extends FiniteState

# State depencies go here. Its reccomended to replace the class_name
# with one more fitting with what you intend to do.
@export_custom(Component.PROPERTY_HINT_COMPONENT, "", 0) var input: HumanoidComponent

# Returns the root node of the state. Its a good idea to
# replace the returning class (Node) with one more fitting for what
# you intend to do.
func get_root_node() -> Node:
	return _root_node as Node

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _on_process(delta: float) -> void:
	pass

# Called every physics step. 'delta' is the elapsed time since the previous frame.
func _on_physics_process(delta: float) -> void:
	pass

# Called when theres an unhandled input.
func _on_unhandled_input(event: InputEvent) -> void:
	pass

# Called when the state is entered
func _enter() -> void:
	print("Piss!")

# Called when the state is exited.
func _exit() -> void:
	pass
