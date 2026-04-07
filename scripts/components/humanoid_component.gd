class_name HumanoidComponent
extends Component

#region Export Variables

@export_range(0, 200, 5) var health := 100.0:
	set = _set_health
@export_range(0, 200, 5) var max_health := 100.0:
	set = _set_max_health

@export_range(0, 10, 1) var walk_speed := 5
@export_range(0, 10, 1) var jump_power := 2

#endregion
#region Constants

const INITIAL_STATE = IDLE

#endregion
#region Variables

var move_direction := Vector2.ZERO
var jumping := false

#endregion
#region Signals

signal died
signal health_changed(new : float, old: float)

signal state_changed(new : HUMANOID_STATES, old : HUMANOID_STATES)

#endregion
#region State Machine Variables

var state : HUMANOID_STATES
var old_state : HUMANOID_STATES

enum HUMANOID_STATES {
	IDLE,
	FALLING,
	MOVING,
	DEAD,
	RAGDOLLING
}

const IDLE := HUMANOID_STATES.IDLE
const FALLING := HUMANOID_STATES.FALLING
const MOVING := HUMANOID_STATES.MOVING
const DEAD := HUMANOID_STATES.DEAD
const RAGDOLLING := HUMANOID_STATES.RAGDOLLING

#endregion
#region Getters/Setters

func _set_health(value: float) -> void:
	var old = health
	health = clampf(value, 0, max_health)
	
	if health != old:
		health_changed.emit(health, old)
	
	if health == 0:
		died.emit()
		change_state(DEAD)

func _set_max_health(value: float) -> void:
	max_health = value
	_set_health(health)

func get_root_node() -> RBCharacter:
	return _root_node as RBCharacter

#endregion
#region Finite State Machine

func _on_state_changed() -> void:
	match state:
		IDLE:
			pass
		FALLING:
			pass
		MOVING:
			pass
		DEAD:
			pass
		RAGDOLLING:
			pass

func _on_process(delta: float) -> void:
	match state:
		IDLE:
			pass
		FALLING:
			pass
		MOVING:
			pass
		DEAD:
			pass
		RAGDOLLING:
			pass
	
	match state:
		IDLE, MOVING:
			_jump_logic()
			_move_logic()
		FALLING:
			_move_logic()

func _transition_logic() -> void:
	match state:
		IDLE:
			# transition to falling
			if not get_root_node().is_on_floor():
				return change_state(FALLING)
			
			# transition to moving
			elif move_direction.length() > 0:
				return change_state(MOVING)
		FALLING:
			# grounded
			if get_root_node().is_on_floor():
				# transition to moving
				if move_direction.length() > 0:
					return change_state(IDLE)
				
				# transition to idle
				else:
					return change_state(MOVING)
		MOVING:
			# transition to falling
			if not get_root_node().is_on_floor():
				return change_state(FALLING)
			
			# transition to idle
			if move_direction.length() == 0:
				return change_state(IDLE)
		DEAD:
			pass
		RAGDOLLING:
			pass

func change_state(new : HUMANOID_STATES) -> void:
	old_state = state
	state = new
	
	state_changed.emit(state, old_state)
	_on_state_changed()

#endregion
#region Misc

# handles jumping
func _jump_logic() -> void:
	if not get_multiplayer_authority():
		return
	
	if jumping:
		get_root_node().apply_central_impulse(Vector3.UP * jump_power)

# handles movement
func _move_logic() -> void:
	if not get_multiplayer_authority():
		return
	
	var wish = Vector3(move_direction.x, 0, move_direction.y)
	wish *= walk_speed
	get_root_node().velocity = wish

#endregion
#region Processors

func _process(delta: float) -> void:
	_on_process(delta)
	_transition_logic()

func _ready() -> void:
	change_state(INITIAL_STATE)

#endregion
