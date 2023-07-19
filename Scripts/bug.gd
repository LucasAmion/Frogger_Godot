extends CharacterBody2D

var has_target = false
var movement_speed: float = 50
@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D
@onready var area_2d = $"../NavigationRegion2D/Area2D"
@onready var frog = $"../Frog"

@onready var sprite_2d = $Sprite2D
@onready var animation_tree = $AnimationTree
@onready var state_machine = animation_tree["parameters/playback"]
@onready var sting_sound = $StingSound

# Called when the node enters the scene tree for the first time.
func _ready():
	navigation_agent.path_desired_distance = 5.0
	navigation_agent.target_desired_distance = 5.0
	
	animation_tree.active = true
	state_machine.start("move")
	
	call_deferred("actor_setup")

func actor_setup():
	# Wait for the first physics frame so the NavigationServer can sync.
	await get_tree().physics_frame

	# Now that the navigation map is no longer empty, set the movement target.
	navigation_agent.target_position = frog.global_position

func is_player_in_range():
	return area_2d.overlaps_body(frog)

func is_player_stunned():
	return frog.stunned

func is_shield_up():
	return frog.shield_up

func move_to_player():
	has_target == false
	navigation_agent.target_position = frog.global_position
	
	if navigation_agent.is_navigation_finished():
		return BTTickResult.SUCCESS
	
	var current_agent_position: Vector2 = global_position
	var next_path_position: Vector2 = navigation_agent.get_next_path_position()

	var new_velocity: Vector2 = next_path_position - current_agent_position
	new_velocity = new_velocity.normalized()
	new_velocity = new_velocity * movement_speed

	navigation_agent.set_velocity(new_velocity) 
	velocity = new_velocity
	if velocity.x < 0:
		sprite_2d.scale = Vector2(1, 1)
	elif velocity.x > 0:
		sprite_2d.scale = Vector2(-1, 1)
	move_and_slide()
	return BTTickResult.RUNNING

func sting():
	state_machine.travel("sting")
	sting_sound.play()
	frog.stun("bug")
	return  BTTickResult.SUCCESS

func move_randomly():
	if has_target == false:
		navigation_agent.target_position = global_position + Vector2(randi_range(-60, 60), randi_range(-60, 60))
		has_target = true
	
	if navigation_agent.is_navigation_finished():
		has_target = false
		return BTTickResult.SUCCESS
	
	var current_agent_position: Vector2 = global_position
	var next_path_position: Vector2 = navigation_agent.get_next_path_position()

	var new_velocity: Vector2 = next_path_position - current_agent_position
	new_velocity = new_velocity.normalized()
	new_velocity = new_velocity * movement_speed

	navigation_agent.set_velocity(new_velocity) 
	velocity = new_velocity
	if velocity.x < 0:
		sprite_2d.scale = Vector2(1, 1)
	elif velocity.x > 0:
		sprite_2d.scale = Vector2(-1, 1)
	move_and_slide()
	return  BTTickResult.RUNNING
