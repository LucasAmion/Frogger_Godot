extends CharacterBody2D

@onready var animation_tree = $AnimationTree
@onready var state_machine = animation_tree["parameters/playback"]
@onready var sprite_2d = $Sprite2D

@onready var music = get_node("/root/Main/Music")
@onready var frog_sound = $FrogSound
@onready var jump_sound = $JumpSound
@onready var restrict_sound = $RestrictSound
@onready var splash_sound = $SplashSound
@onready var success_sound = $SuccessSound

@onready var speed = 180
@onready var jump_distance = 45
@onready var moving = false
@onready var destination

@onready var screen_size = get_viewport_rect().size

# Called when the node enters the scene tree for the first time.
func _ready():
	animation_tree.active = true
	state_machine.start("idle_0")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
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

func _on_animation_tree_animation_started(anim_name):
	if anim_name == 'idle_1':
		frog_sound.play()

func _on_splash_sound_finished():
	success_sound.play()

func _on_success_sound_finished():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
