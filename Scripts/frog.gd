extends CharacterBody2D

@onready var animation_tree = $AnimationTree
@onready var state_machine = animation_tree["parameters/playback"]
@onready var sprite_2d = $Sprite2D
@onready var stun_sprite = $StunSprite
@onready var shield_sprite = $ShieldSprite
@onready var point_light_2d = $PointLight2D

@onready var music = get_node("/root/Main/Music")
@onready var frog_sound = $FrogSound
@onready var jump_sound = $JumpSound
@onready var restrict_sound = $RestrictSound
@onready var splash_sound = $SplashSound
@onready var success_sound = $SuccessSound
@onready var stun_sound = $StunSound
@onready var swallow_sound = $SwallowSound
@onready var cpu_particles_2d = $CPUParticles2D

@onready var speed = 180
@onready var jump_distance = 45
@onready var moving = false
@onready var destination
@onready var checkpoint
@onready var stunned = false
@onready var shield_up = false

@onready var screen_size = get_viewport_rect().size

# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().paused = false
	animation_tree.active = true
	state_machine.start("idle_0")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if stunned:
		return
	if Input.is_action_just_pressed("left") and not moving:
		sprite_2d.scale = Vector2(1, 1)
		destination = position + jump_distance*Vector2.LEFT
		if destination.x > 0:
			jump_sound.play()
			state_machine.start("jump")
			moving = true
		else:
			restrict_sound.play()
	
	if Input.is_action_just_pressed("right") and not moving:
		sprite_2d.scale = Vector2(-1, 1)
		destination = position + jump_distance*Vector2.RIGHT
		if destination.x < screen_size.x:
			jump_sound.play()
			state_machine.start("jump")
			moving = true
		else:
			restrict_sound.play()
	
	if Input.is_action_just_pressed("up") and not moving:
		destination = position + jump_distance*Vector2.UP
		if destination.y > -30:
			jump_sound.play()
			state_machine.start("jump")
			moving = true
		else:
			restrict_sound.play()
	
	if Input.is_action_just_pressed("down") and not moving:
		destination = position + jump_distance*Vector2.DOWN
		if destination.y < screen_size.y:
			jump_sound.play()
			state_machine.start("jump")
			moving = true
		else:
			restrict_sound.play()
	
	if moving:
		position = position.move_toward(destination, delta*speed)
		if position == destination:
			moving = false
		if position.y <= -15:
			music.stop()
			get_tree().paused = true
			splash_sound.play()

func stun(by):
	cpu_particles_2d.emitting = true
	stun_sprite.show()
	stun_sound.play()
	moving = false
	stunned = true
	animation_tree.active = false
	set_collision_layer_value(1, false)
	var tween = create_tween()
	tween.tween_property(self, "rotation", PI, 0.5)
	if by == "car":
		tween.parallel()
		var new_position = Vector2(global_position.x, checkpoint)
		tween.tween_property(self, "global_position", new_position, 0.5)
	await stun_sound.finished
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

func _on_splash_sound_finished():
	success_sound.play()

func _on_success_sound_finished():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")

func death_animation():
	var tween = create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(sprite_2d, "rotation", -2.0, 0.5)
	tween.parallel()
	tween.tween_property(sprite_2d, "scale", Vector2.ZERO, 0.5).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_EXPO)
