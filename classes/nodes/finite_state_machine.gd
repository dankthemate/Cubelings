class_name FiniteStateMachine
extends Node

#region Public Variables

@export var component_manager: ComponentManager
@export var root_node: Node
@export var initial_state: FiniteState

#endregion
#region Private Variables

var _states: Dictionary[String, FiniteState]
var _state: FiniteState
var _debounce := true

#endregion
#region Signals

signal state_added(state: FiniteState)
signal state_removed(state: FiniteState)
signal state_changed(new: FiniteState, old: FiniteState)

#endregion
#region Public Functions

func pause() -> void:
	_debounce = true

func start() -> void:
	_debounce = false

func add_state(state: FiniteState, resolve := true) -> bool:
	pause()
	
	# ignore if state is null
	if not state: 
		start()
		return false
	
	var key = state.name
	
	# ignore if the state is already registered
	if _states.has(key): 
		start()
		return false
	
	# set state values
	state._fsm = self
	state._root_node = root_node
	
	# append to list
	_states[key] = state
	state_added.emit(state)
	
	# resolve if needed
	if resolve and component_manager:
		component_manager.resolve_dependencies(state)
	
	start()
	return true

func remove_state(query: Variant) -> bool:
	pause()
	
	# get key
	var key := _fetch_key(query, true)
	if key == "":
		start()
		return false
	
	# ignore if key does not exist
	if not _states.has(key):
		start()
		return false
	
	# remove component
	var state: FiniteState = _states.get(key)
	if state:
		_states.erase(key)
		state_removed.emit(state)
		start()
		return true
	
		start()
	return false

func get_state(query: Variant) -> Component:
	var key = _fetch_key(query)
	return _states.get(key)

func clear_states(free_nodes := false) -> void:
	pause()
	
	# ignore if list is empty
	if _states.is_empty():
		return start()
	
	# fetch removed components and clear list
	var removed: Array[Component]
	removed.assign(_states.values().duplicate())
	_states.clear()
	
	# signal and queue free nodes if needed
	for state in removed:
		if state:
			state_removed.emit(state)
			if free_nodes:
				state.queue_free()
	
	start()

func reload_states_from_children(resolve := false) -> void:
	pause()
	
	# clear list
	clear_states()
	
	# add components
	for child in get_children():
		if child is FiniteState:
			add_state(child, false)
	
	# resolve if needed
	if resolve and component_manager:
		for state in _states.values():
			component_manager.resolve_dependencies(state)
	
	start()

func change_state(new_state: FiniteState) -> void:
	pause()
	
	if not new_state:
		return start()
	
	if _state:
		_state.exited.emit()
		_state._exit()
	
	var old = _state
	_state = new_state
	
	if _state:
		_state.entered.emit()
		_state._enter()
	
	state_changed.emit(_state, old)
	
	start()

#endregion
#region Private Functions

func _process(delta: float) -> void:
	if _debounce:
		return
	
	if _state:
		_state._on_process(delta)
		_state._transition_logic()

func _physics_process(delta: float) -> void:
	if _debounce:
		return
	
	if _state:
		_state._on_physics_process(delta)

func _unhandled_input(event: InputEvent) -> void:
	if _debounce:
		return
	
	if _state:
		_state._on_unhandled_input(event)

func _fetch_key(query: Variant, check_for_state := false) -> StringName:
	var key: StringName = ""
	
	if query is FiniteState and check_for_state:
		# return if invlaid
		if not query: 
			return ""
		
		key = query.name
	
	elif query is String or query is StringName:
		key = query
	
	return key

func _enter_tree() -> void:
	_state = initial_state
	reload_states_from_children(true)

#endregion
