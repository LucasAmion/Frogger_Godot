extends Area2D

@onready var screen_size = get_viewport_rect().size
@onready var velocity = Vector2(-120, 0)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	position += velocity*delta
	position.x = wrapf(position.x, -26, screen_size.x+26)

func _on_body_entered(body):
	get_tree().reload_current_scene()
