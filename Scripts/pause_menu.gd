extends SubViewportContainer

@onready var continue_button = %continue_button
@onready var restart_button = %restart_button
@onready var exit_button = %exit_button

@onready var music = $"../Music"


func _ready():
	continue_button.button_up.connect(_on_continue_pressed)
	restart_button.button_up.connect(_on_restart_pressed)
	exit_button.button_up.connect(_on_exit_pressed)

func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		visible = !visible
		get_tree().paused = visible
		if visible:
			continue_button.grab_focus()
			music.bus = 'Pause'
		else:
			music.bus = 'Master'

func _on_continue_pressed():
	get_tree().paused = false
	music.bus = 'Master'
	hide()
	
func _on_restart_pressed():
	get_tree().reload_current_scene()
	get_tree().paused = false
	music.bus = 'Master'
	
func _on_exit_pressed():
	get_tree().quit()
