extends Control

@onready var restart_button = %restart_button
@onready var exit_button = %exit_button

@onready var focus_sound = $FocusSound


func _ready():
	restart_button.button_up.connect(_on_restart_pressed)
	restart_button.focus_entered.connect(play_focus_sound)
	exit_button.button_up.connect(_on_exit_pressed)
	exit_button.focus_entered.connect(play_focus_sound)

func _on_restart_pressed():
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_exit_pressed():
	get_tree().quit()

func play_focus_sound():
	focus_sound.play()

func button_grab_focus():
	restart_button.grab_focus()
