extends KinematicBody2D


onready var hook: Position2D = $Hook
onready var camera: Position2D = $CameraRig
onready var shaking_camera: Camera2D = $CameraRig/ShakingCamera
onready var area_detector: Area2D = $AnchorDetector
onready var ledge_detector: Position2D = $LedgeDetector
onready var floor_detector: RayCast2D = $FloorDetector
onready var skin: Position2D = $Skin
onready var stats: Stats = $Stats
onready var state_machine: StateMachine = $StateMachine
onready var collider: CollisionShape2D = $CollisionShape2D
onready var hitbox: Area2D = $HitBox

const FLOOR_NORMAL: = Vector2.UP

var active: = true setget set_active
var info_dict: = {} setget set_info_dict


func _ready() -> void:
	area_detector.connect("area_entered", self, "_on_AreaDetector_area", ["entered"])
	area_detector.connect("area_exited", self, "_on_AreaDetector_area", ["exited"])
	state_machine.setup(self)


func _on_AreaDetector_area(area: Area2D, which: String) -> void:
	if not area.is_in_group("anchor"):
		return
	
	shaking_camera.smoothing_speed = 1.5 if which == "entered" else shaking_camera.default_smoothing_speed


func take_damage(source: Hit) -> void:
	stats.take_damage(source)


func set_active(value: bool) -> void:
	active = value
	if not collider:
		return
	collider.disabled = not value
	hook.active = value
	ledge_detector.active = value
	hitbox.monitoring = value


func set_info_dict(value: Dictionary) -> void:
	info_dict = value
	Events.emit_signal("player_info_updated", info_dict)
