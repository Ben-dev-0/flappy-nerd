extends Node2D

# In the future the speed could be set by the main script and
# even update obstacles after instantiation if the speed ever changes.
@export var speed = 200

func _physics_process(delta: float) -> void:
	position.x -= speed * delta

## open the obstacle according to the size of the gap
func open(gap_height: float) -> void:
	$BottomHalf.position.y += gap_height/2
	$TopHalf.position.y -= gap_height/2

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
