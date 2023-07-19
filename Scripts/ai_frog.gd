extends CharacterBody2D

@onready var animation_tree = $AnimationTree
@onready var state_machine = animation_tree["parameters/playback"]
@onready var sprite_2d = $Sprite2D
@onready var stun_sprite = $StunSprite
@onready var shield_sprite = $ShieldSprite

@onready var music = get_node("/root/Main/Music")
@onready var frog_sound = $FrogSound
@onready var jump_sound = $JumpSound
@onready var restrict_sound = $RestrictSound
@onready var splash_sound = $SplashSound
@onready var success_sound = $SuccessSound
@onready var stun_sound = $StunSound
@onready var swallow_sound = $SwallowSound
@onready var game_over_sound = $GameOverSound
@onready var window = $Window
@onready var loss_menu = $Window/LossMenu
@onready var point_light_2d = $PointLight2D

@onready var speed = 150
@onready var navigation_agent = $NavigationAgent2D
@onready var jump_distance = 45
@onready var moving = false
@onready var destination
@onready var checkpoint
@onready var stunned = false
@onready var shield_up = false

@onready var screen_size = get_viewport_rect().size

# Called when the node enters the scene tree for the first time.
func _ready():
	navigation_agent.path_desired_distance = 5.0
	navigation_agent.target_desired_distance = 5.0
	
	animation_tree.active = true
	state_machine.start("idle_0")

func is_stunned():
	return stunned

func move_left():
	if stunned:
		return BTTickResult.FAILURE
	if not moving:
		sprite_2d.scale = Vector2(1, 1)
		destination = position + jump_distance*Vector2.LEFT
		if destination.x >= 45:
			state_machine.start("jump")
			moving = true
			navigation_agent.target_position = destination
			return BTTickResult.RUNNING
		restrict_sound.play()
		return BTTickResult.FAILURE
	else:
		var current_agent_position: Vector2 = global_position
		var next_path_position: Vector2 = navigation_agent.get_next_path_position()

		var new_velocity: Vector2 = next_path_position - current_agent_position
		new_velocity = new_velocity.normalized()
		new_velocity = new_velocity * speed

		navigation_agent.set_velocity(new_velocity) 
		velocity = new_velocity
#		move_and_slide()
		if position.y <= -15:
			music.stop()
			get_tree().paused = true
			splash_sound.play()
		if navigation_agent.is_navigation_finished():
			moving = false
			return BTTickResult.SUCCESS
		return  BTTickResult.RUNNING

func move_right():
	if stunned:
		return BTTickResult.FAILURE
	if not moving:
		sprite_2d.scale = Vector2(-1, 1)
		destination = position + jump_distance*Vector2.RIGHT
		if destination.x <= 585:
			state_machine.start("jump")
			moving = true
			navigation_agent.target_position = destination
			return BTTickResult.RUNNING
		restrict_sound.play()
		return BTTickResult.FAILURE
	else:
		var current_agent_position: Vector2 = global_position
		var next_path_position: Vector2 = navigation_agent.get_next_path_position()

		var new_velocity: Vector2 = next_path_position - current_agent_position
		new_velocity = new_velocity.normalized()
		new_velocity = new_velocity * speed

		navigation_agent.set_velocity(new_velocity) 
		velocity = new_velocity
#		move_and_slide()
		if position.y <= -15:
			music.stop()
			get_tree().paused = true
			splash_sound.play()
		if navigation_agent.is_navigation_finished():
			moving = false
			return BTTickResult.SUCCESS
		return  BTTickResult.RUNNING

func move_up():
	if stunned:
		return BTTickResult.FAILURE
	if not moving:
		destination = position + jump_distance*Vector2.UP
		var checkpoints = get_tree().get_nodes_in_group("checkpoints")
		for checkpoint in checkpoints:
			if checkpoint.overlaps_body(self):
				destination = position + 4*jump_distance*Vector2.UP
				speed = 300
		if destination.y > -50:
			state_machine.start("jump")
			moving = true
			navigation_agent.target_position = destination
			return BTTickResult.RUNNING
		restrict_sound.play()
		return BTTickResult.FAILURE
	else:
		var current_agent_position: Vector2 = global_position
		var next_path_position: Vector2 = navigation_agent.get_next_path_position()

		var new_velocity: Vector2 = next_path_position - current_agent_position
		new_velocity = new_velocity.normalized()
		new_velocity = new_velocity * speed

		navigation_agent.set_velocity(new_velocity) 
		velocity = new_velocity
#		move_and_slide()
		if position.y <= -15:
			music.stop()
			get_tree().paused = true
			splash_sound.play()
		if navigation_agent.is_navigation_finished():
			speed = 150
			moving = false
			return BTTickResult.SUCCESS
		return  BTTickResult.RUNNING

func _on_velocity_computed(safe_velocity):
	velocity = safe_velocity
	if velocity.length() > 100:
		state_machine.travel("jump")
	move_and_slide()
	if position.x < 45:
		position.x = 45
	if position.x > 585:
		position.x = 585

func stun(by):
	speed = 150
	stun_sprite.show()
	stun_sound.play()
	moving = false
	stunned = true
	animation_tree.active = false
	navigation_agent.avoidance_enabled = false
	set_collision_layer_value(1, false)
	var tween = create_tween()
	tween.tween_property(self, "rotation", PI, 0.5)
	if by == "car":
		tween.parallel()
		var new_position = Vector2(global_position.x, checkpoint)
		tween.tween_property(self, "global_position", new_position, 0.5)
	await stun_sound.finished
	navigation_agent.avoidance_enabled = true
	stun_sprite.hide()
	stun_sound.stop()
	stunned = false
	animation_tree.active = true
	set_collision_layer_value(1, true)
	tween = create_tween()
	tween.tween_property(self, "rotation", 0.0, 0.5)

func activate_shield():
	shield_up = true
	swallow_sound.play()
	var tween = create_tween()
	tween.tween_method(set_shader_value, 0.0, 1.0, 0.5);
	tween.parallel().tween_property(point_light_2d, "color", Color.WHITE, 0.5)
	tween.tween_method(set_shader_value, 1.0, 0.0, 5.0).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE);
	tween.parallel().tween_property(point_light_2d, "color", Color.TRANSPARENT, 5.0).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE);
	await tween.finished
	shield_up = false

func set_shader_value(value: float):
	shield_sprite.material.set_shader_parameter("FloatParameter", value);

func _on_animation_tree_animation_started(anim_name):
	if anim_name == 'idle_1':
		frog_sound.play()
	elif anim_name == 'jump':
		jump_sound.play()

func _on_splash_sound_finished():
	game_over_sound.play()

func _on_game_over_sound_finished():
	get_tree().paused = true
	window.show()
	loss_menu.button_grab_focus()

func death_animation():
	var tween = create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(sprite_2d, "rotation", -2.0, 0.5)
	tween.parallel()
	tween.tween_property(sprite_2d, "scale", Vector2.ZERO, 0.5).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_EXPO)
