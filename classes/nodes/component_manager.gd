class_name ComponentManager
extends Node

#region Export Variables

@export var root_node : Node
@export var reload_on_start := true

#endregion
#region Private Variables

var _components : Dictionary[String, Component]

#endregion
#region Public Functions

func add_component(component: Component, resolve_node_dependencies := true) -> bool:
	var script: Script = component.get_script()
	var key := script.get_global_name()
	
	if _components.has(key):
		return false
	
	if resolve_node_dependencies:
		resolve_dependecies(component)
	
	_components[key] = component
	
	component.component_manager = self
	component.root_node = root_node
	
	return true

func remove_component(query: Variant, free := false) -> bool:
	var key: StringName = ""
	
	# if querey is a component
	if query is Component:
		var script: Script = query.get_script()
		key = script.get_global_name()
	
	# if querey is a script
	elif query is Script:
		key = query.get_global_name()
	
	# if querey is a straight up string
	elif query is String or query is StringName:
		key = query
	
	else: 
		return false
	
	var component: Component = _components.get(key)
	_components.erase(key)
	
	# queue free if 
	if free:
		component.queue_free()
	
	return true

func get_component(query: Variant) -> Component:
	var key: StringName = ""
	
	if query is Script:
		key = query.get_global_name()
	elif query is String or query is StringName:
		key = query
	
	return _components.get(key)

func clear_components(free := false) -> void:
	for i in _components.keys():
		remove_component(i, free)

func resolve_dependecies(node: Node) -> void:
	for i in node.get_property_list():
		if i.hint == Component.PROPERTY_HINT_COMPONENT:
			node.set(i.name, get_component(i.class_name))

func reload_components(resolve_node_dependencies := true) -> void:
	clear_components()
	
	for i in get_children():
		if i is Component:
			add_component(i, false)
	if resolve_node_dependencies:
		for i in _components.values():
			resolve_dependecies(i)

#endregion
#region Static Functions

func from_node(node : Node) -> ComponentManager:
	if not is_instance_valid(node):
		return null
	
	for i in node.get_children():
		if i is ComponentManager:
			return i
	return null

#endregion
#region Private Functions

func _ready() -> void:
	reload_components()

#endregion
