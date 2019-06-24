tool
extends Area2D
"""Detects and returns the best snapping target for the hook"""


onready var hint: Position2D = $HookingHint
onready var ray: RayCast2D = $RayCast2D

var target: HookTarget setget set_target


func _on_Hook_hooked_onto_target(pull_force) -> void:
	if not target:
		return
	target.is_active = false
	target = null


func _physics_process(delta: float) -> void:
	self.target = find_best_target()


func find_best_target() -> HookTarget:
	force_update_transform()
	var targets: = get_overlapping_areas()
	if not targets:
		return null

	var closest_target: HookTarget = null
	var distance_to_closest: = 100000.0
	for t in targets:
		if not t.is_active:
			continue
		
		var distance: = global_position.distance_to(t.global_position)
		if distance > distance_to_closest:
			continue
		
		ray.global_position = global_position
		ray.cast_to = t.global_position - global_position
		ray.force_update_transform()
		if ray.is_colliding():
			continue
		
		distance_to_closest = distance
		closest_target = t
	return closest_target


func has_target() -> bool:
	return target != null


"""
Returns the length of the hook, from the origin to the tip of the collision shape
"""
func calculate_length() -> float:
	var length: = -1.0
	for collider in [$CapsuleH, $CapsuleV]:
		if not collider:
			continue
		var capsule: CapsuleShape2D = collider.shape
		var capsule_length: float = collider.position.length() + capsule.height / 2 * sin(collider.rotation) + capsule.radius
		length = max(length, capsule_length)
	return length


func set_target(value: HookTarget) -> void:
	if not value:
		return
	target = value
	hint.visible = target != null
	if target:
		hint.global_position = target.global_position
