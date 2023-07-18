extends Area2D

@onready var screen_size = get_viewport_rect().size
@onready var velocity = Vector2(-120, 0)

@onready var music = get_node("/root/Main/Music")
@onready var hit_sound = $HitSound
@onready var game_over_sound = $GameOverSound

@onready var frog = get_node("/root/Main/Frog")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	position += velocity*delta
	position.x = wrapf(position.x, -30, screen_size.x+30)

#func _on_body_entered(body):
#	music.stop()
#	hit_sound.play()
#	frog.death_animation()
#	get_tree().paused = true

func _on_body_entered(body):
	if not frog.shield_up:
		hit_sound.play()
		frog.stun("car")

#func _on_hit_sound_finished():
#	game_over_sound.play()

#func _on_game_over_sound_finished():
#	get_tree().paused = false
#	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")

