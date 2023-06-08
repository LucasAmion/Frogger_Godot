extends MarginContainer
@onready var play_button = %play_button
@onready var exit_button = %exit_button
@onready var animation_player = $Sprite2D/AnimationPlayer

@onready var focus_sound = $"../FocusSound"

func _ready():
	play_button.grab_focus()
	play_button.button_up.connect(_on_play_pressed)
	play_button.focus_entered.connect(play_focus_sound)
	
	exit_button.button_up.connect(_on_exit_pressed)
	exit_button.focus_entered.connect(play_focus_sound)
	animation_player.play("idle")

func _on_play_pressed():
	get_tree().change_scene_to_file("res://Scenes/main.tscn")

func _on_exit_pressed():
	get_tree().quit()

func play_focus_sound():
	focus_sound.play()
