extends Node2D

# In the future the speed could be set by the main script and
# even update obstacles after instantiation if the speed ever changes.
@export var speed = 200

func _physics_process(delta: float) -> void:
	position.x -= speed * delta

## open the obstacle according to the size of the gap
func open(bottom_position:Vector2, top_position: Vector2) -> void:
	$BottomPivot.position = bottom_position - position
	$TopPivot.position = top_position - position

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()

func change_top_color(c: Color):
	$TopPivot/TopPillar.change_color(c)

func change_bottom_color(c: Color):
	$BottomPivot/BottomPillar.change_color(c)

func place_top_spike_ball(spike_ball_scene: PackedScene):
	var spike_ball = spike_ball_scene.instantiate()
	$TopPivot/TopSpikeBallSpawner.add_child(spike_ball)

func place_bottom_spike_ball(spike_ball_scene: PackedScene):
	var spike_ball = spike_ball_scene.instantiate()
	$BottomPivot/BottomSpikeBallSpawner.add_child(spike_ball)
