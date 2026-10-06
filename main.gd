extends Node

@export var obstacle_scene: PackedScene
@export var spike_ball_scene: PackedScene
@export var player_scene: PackedScene
@export var max_obstacle_distance_from_last = 0.7
@export var min_obstacle_distance = 0.15
@export var max_obstacle_distance = 0.85
@export var spike_ball_min_speed = 100
@export var spike_ball_max_speed = 400

@onready var obstacle_spawn_point = $ObstacleSpawner/ObstacleSpawnPoint
var last_obstacle_progress_ratio = 0.5
var previous_gap_dimensions = []

func _ready() -> void:
	spawn_player()

func _on_obstacle_spawn_timer_timeout() -> void:
	obstacle_spawn_point.progress_ratio = clampf(
		clampf(randf(), min_obstacle_distance, max_obstacle_distance),
		last_obstacle_progress_ratio - max_obstacle_distance_from_last/2,
		last_obstacle_progress_ratio + max_obstacle_distance_from_last/2
	)
	
	last_obstacle_progress_ratio = obstacle_spawn_point.progress_ratio
	var obstacle = obstacle_scene.instantiate()
	obstacle.position = obstacle_spawn_point.position
	var gap_height = randf_range(200.0, 400.0)
	obstacle.open(gap_height)
	
	previous_gap_dimensions.push_back([obstacle.position.y - gap_height, obstacle.position.y + gap_height])
	if len(previous_gap_dimensions) > 3:
		previous_gap_dimensions.pop_front()
	
	add_child(obstacle)

func _on_spike_ball_spawn_timer_timeout() -> void:
	obstacle_spawn_point.progress_ratio = clampf(randf(), min_obstacle_distance, max_obstacle_distance)
	var spike_ball = spike_ball_scene.instantiate()
	spike_ball.position = obstacle_spawn_point.position
	spike_ball.velocity = Vector2(-randf_range(spike_ball_min_speed, spike_ball_max_speed), 0)
	
	if abs(obstacle_spawn_point.progress_ratio - last_obstacle_progress_ratio) < 0.2:
		if obstacle_spawn_point.progress_ratio >= last_obstacle_progress_ratio:
			obstacle_spawn_point.progress_ratio += 0.1
		else:
			obstacle_spawn_point.progress_ratio -= 0.1
		spike_ball.change_color(Color(1.0, 0.365, 0.769, 0.545))
	
	add_child(spike_ball)

func _on_player_hit():
	for n in get_tree().get_nodes_in_group("obstacles"):
		n.call_deferred("queue_free")
	$HUD.reset_score()
	call_deferred("spawn_player")
	$ObstacleSpawnTimer.start()

func spawn_player():
	var player = player_scene.instantiate()
	player.hit.connect(_on_player_hit)
	player.scored.connect($HUD.increment_score)
	player.position = $PlayerSpawnPoint.position
	add_child(player)
