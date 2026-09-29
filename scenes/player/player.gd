extends CharacterBody2D

@onready var move_state_machine: AnimationNodeStateMachinePlayback = $Node/AnimationTree.get("parameters/MoveStateMachine/playback")
@onready var tool_state_machine: AnimationNodeStateMachinePlayback = $Node/AnimationTree.get("parameters/ToolStateMachine/playback")

var direction: Vector2
var speed := 300

enum Tools { HOE, AXE, WATER}
var current_tool: Tools = Tools.AXE
const tool_connection = {
	Tools.HOE: 'hoe',
	Tools.AXE: 'axe',
	Tools.WATER: 'water',
}

func _physics_process(_delta: float) -> void:
	get_input()
	velocity = direction * speed
	move_and_slide()
	animation()
	
func get_input():
	direction = Input.get_vector("left", "right", "up", "down")
	
	
	if Input.is_action_just_pressed("action"):
		tool_state_machine.travel(tool_connection[current_tool])
		$Node/AnimationTree.set("parameters/OneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	
	if Input.is_action_just_pressed('tool_forward') or Input.is_action_just_pressed('tool_backward'):
		var tool_direction = Input.get_axis('tool_backward', 'tool_forward') as int
		current_tool = posmod(current_tool + tool_direction, Tools.size()) as Tools
		print(current_tool)

func animation():
	if direction:
		move_state_machine.travel('move')
		var target_vector: Vector2 = Vector2(round(direction.x), round(direction.y))
		$Node/AnimationTree.set("parameters/MoveStateMachine/move/blend_position", target_vector)
		$Node/AnimationTree.set("parameters/MoveStateMachine/idle/blend_position", target_vector)
		for state in tool_connection.values():
			$Node/AnimationTree.set("parameters/ToolStateMachine/"+ state +"/blend_position", target_vector)
	else:
		move_state_machine.travel('idle')
