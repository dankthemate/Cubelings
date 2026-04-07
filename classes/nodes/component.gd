class_name Component
extends Node

## Root node of the component.
var _root_node : Node

## The component manager for this component
var _component_manager : ComponentManager

const PROPERTY_HINT_COMPONENT: PropertyHint = PROPERTY_HINT_MAX + 454664445

## Returns the Component's root node.
func get_root_node() -> Node:
	return _root_node

## Returns the Component's Component Manager
func get_component_manager() -> ComponentManager:
	return _component_manager

## Called after the component gets intialized for the first time
## after the Component Manager enters the scene tree.
func _component_init() -> void:
	pass
