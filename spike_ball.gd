extends Area2D

@export var velocity = Vector2(0, 0)

func _physics_process(delta: float) -> void:
	position += velocity * delta

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()

func change_color(col: Color):
	$CollisionShape2D.debug_color = col
