class_name RBCharacter
extends NetworkRigidBody3D

#region Constants

const WALKSPEED := 8
const JUMPPOWER := 3

#endregion
#region Public Variables

var velocity := Vector3.ZERO

#endregion
#region Private Variables
var _actually_on_floor := false

var _DEFAULT_PHYS_MATERIAL := PhysicsMaterial.new()
var _floor_phys_material : PhysicsMaterial

#endregion
#region getters/setters

## returns true if character is on floor
func is_on_floor() -> bool:
	return _actually_on_floor

#endregion
#region Private Functions

## move the character
func _move(delta: float) -> void:
	var buffer = delta * 10
	
	var friction = 1.0 if not _floor_phys_material else _floor_phys_material.friction
	
	var correction = velocity - (linear_velocity * friction)
	correction *= buffer
	correction *= Vector3(1,0,1)
	velocity = correction
	velocity *= NetworkTime.physics_factor
	
	apply_central_impulse(velocity)

## checks contacts to see if character is on floor
func _check_contacts(state: PhysicsDirectBodyState3D) -> void:
	_actually_on_floor = false
	
	_floor_phys_material = null
	
	for i in get_contact_count():
		var norm := state.get_contact_local_normal(i)
		var collider := state.get_contact_collider_object(i)
		
		if norm.dot(Vector3.UP) > 0.9:
			_actually_on_floor = true
			if collider:
				_floor_phys_material = (
				collider.physics_material_override if collider.physics_material_override 
				else _DEFAULT_PHYS_MATERIAL)
			else:
				_floor_phys_material = _DEFAULT_PHYS_MATERIAL

#endregion
#region Processes

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	_check_contacts(state)

func _physics_rollback_tick(_delta, _tick):
	_physics_process(_delta)

func _physics_process(delta: float) -> void:
	_move(delta)
	
#endregion
