class_name ComponentManager
extends Node

#region Public Variables

@export var root_node: Node

#endregion
#region Private Variables

var _components: Dictionary[StringName, Component]

#endregion
#region Signals

signal component_added(component: Component)
signal component_removed(component: Component)

#endregion
#region Public Functions

func add_component(component: Component, resolve := true) -> bool:
	# ignore if component is null
	if not component: 
		return false
	
	# ignore if script is null
	var script: Script = component.get_script()
	if not script: 
		return false
	
	var key = script.get_global_name()
	
	# ignore if the component is already registered
	if _components.has(key): 
		return false
	
	# set component values
	component._component_manager = self
	component._root_node = root_node
	
	# append to list
	_components[key] = component
	component_added.emit(component)
	
	# resolve if needed
	if resolve:
		resolve_dependencies(component)
	
	return true

func remove_component(query: Variant) -> bool:
	# get key
	var key := _fetch_key(query, true)
	if key == "":
		return false
	
	# ignore if key does not exist
	if not _components.has(key):
		return false
	
	# remove component
	var component: Component = _components.get(key)
	if component:
		_components.erase(key)
		component_removed.emit(component)
		return true
	return false

func get_component(query: Variant) -> Component:
	var key = _fetch_key(query)
	return _components.get(key)

func clear_components(free_nodes := false) -> void:
	# ignore if list is empty
	if _components.is_empty():
		return
	
	# fetch removed components and clear list
	var removed: Array[Component]
	removed.assign(_components.values().duplicate())
	_components.clear()
	
	# signal and queue free nodes if needed
	for component in removed:
		if component:
			component_removed.emit(component)
			if free_nodes:
				component.queue_free()

func reload_components_from_children(resolve := false) -> void:
	# clear list
	clear_components()
	
	# add components
	for child in get_children():
		if child is Component:
			add_component(child, false)
	
	# resolve if needed
	if resolve:
		for component in _components.values():
			resolve_dependencies(component)

func resolve_dependencies(node: Node) -> void:
	for property in node.get_property_list():
		if property.hint == Component.PROPERTY_HINT_COMPONENT:
			node.set(property.name, get_component(property.class_name))

#endregion
#region Private Functions

func _enter_tree() -> void:
	reload_components_from_children(true)

func _fetch_key(query: Variant, check_for_component := false) -> StringName:
	var key: StringName = ""
	
	if query is Component and check_for_component:
		# return if invlaid
		if not query: 
			return ""
		
		# return if script is invalid
		var script: Script = query.get_script()
		if not script:
			return ""
		
		key = script.get_global_name()
	
	elif query is Script:
		key = query.get_global_name()
	
	elif query is String or query is StringName:
		key = query
	
	return key

#endregion
