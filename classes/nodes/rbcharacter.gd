class_name RBCharacter
extends NetworkRigidBody3D

@export_range(0, 30, 1) var walk_speed := 5.0
@export_range(0, 30, 1) var jump_power := 8.0

var _actually_on_floor := false

var _DEFAULT_PHYS_MATERIAL := PhysicsMaterial.new()
var _floor_phys_material : PhysicsMaterial

var velocity := Vector3.ZERO
var jumping := false

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	_check_contacts(state)

## returns true if character is on floor
func is_on_floor() -> bool:
	return _actually_on_floor

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

## move the character
func _move(delta: float) -> void:
	var buffer = delta * 10
	
	var friction = 1.0 if not _floor_phys_material else _floor_phys_material.friction
	
	var correction = velocity - (linear_velocity * friction)
	correction *= buffer
	correction *= Vector3(1,0,1)
	velocity = correction
	
	if jumping and is_on_floor():
		velocity.y = jump_power
	
	apply_central_impulse(velocity)

func _physics_process(delta: float) -> void:
	temp_input()
	_move(delta)

func temp_input() -> void:
	var move_direction = Input.get_vector(&"MoveLeft",&"MoveRight",&"MoveForward",&"MoveBack")
	jumping = Input.is_action_just_pressed(&"Jump")
	
	velocity.x = move_direction.x * walk_speed
	velocity.z = move_direction.y * walk_speed
