class_name FiniteState
extends Node

#region Public Variables

@export var transitions: Array[FiniteStateTransition]

#endregion
#region Private Variables

var _root_node: Node
var _fsm: FiniteStateMachine
var _component_manager: ComponentManager

#endregion
#region Signals

signal entered
signal exited

#endregion
#region Public Functions

func get_root_node() -> Node:
	return _root_node

#endregion
#region Private Functions

func _on_process(delta: float) -> void:
	print("hi")
	pass

func _on_physics_process(delta: float) -> void:
	pass

func _on_unhandled_input(event: InputEvent) -> void:
	pass

func _enter() -> void:
	pass

func _exit() -> void:
	pass

func _transition_logic() -> void:
	for transition in transitions:
		if transition.validate(self):
			return _fsm.change_state(get_node(transition.new_state))

#endregion
