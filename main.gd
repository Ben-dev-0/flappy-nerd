extends Node

@export var obstacle_scene: PackedScene
@export var spike_ball_scene: PackedScene
@export var player_scene: PackedScene
@export var min_obstacle_distance = 0.15
@export var min_room_for_spike_ball = 0.2
@export var spike_ball_min_speed = 100
@export var spike_ball_max_speed = 400
@export var obstacle_height_increments = 20
@export var empty_column_chance = 0.5

@onready var top_obstacle_spawn_point = $ObstacleSpawner/TopObstacleSpawnPoint
@onready var bottom_obstacle_spawn_point = $ObstacleSpawner/BottomObstacleSpawnPoint

var obstacle_spawner_middle: Vector2
var last_upper_progress_ratio = 0.5
var last_lower_progress_ratio = 0.5

func _ready() -> void:
	top_obstacle_spawn_point.progress_ratio = 0.5
	obstacle_spawner_middle = top_obstacle_spawn_point.position
	spawn_player()

func _on_obstacle_spawn_timer_timeout() -> void:
	var obstacle = obstacle_scene.instantiate()
	obstacle.position = obstacle_spawner_middle
	
	obstacle.change_top_color(Color(1.0, 0.66, 0.666, 0.133))
	obstacle.change_bottom_color(Color(0.12, 1.0, 0.956, 0.133))
	
	if randf() < empty_column_chance:
		top_obstacle_spawn_point.progress_ratio = 1.0
		bottom_obstacle_spawn_point.progress_ratio = 0.0
	else:
		@warning_ignore("integer_division")
		top_obstacle_spawn_point.progress_ratio = randi_range(obstacle_height_increments/2, obstacle_height_increments) * (1.0/obstacle_height_increments)
		@warning_ignore("integer_division")
		bottom_obstacle_spawn_point.progress_ratio = randi_range(0, obstacle_height_increments/2) * (1.0/obstacle_height_increments)
		
	var gap_height = top_obstacle_spawn_point.progress_ratio - bottom_obstacle_spawn_point.progress_ratio
	
	#ensure minimum opening height
	if gap_height < min_obstacle_distance:
		gap_height = min_obstacle_distance - gap_height
		bottom_obstacle_spawn_point.progress_ratio -= gap_height/2
		top_obstacle_spawn_point.progress_ratio += gap_height/2
		gap_height = min_obstacle_distance
		
		obstacle.change_top_color(Color(1.0, 0.0, 0.017, 0.604))
		obstacle.change_bottom_color(Color(1.0, 0.0, 0.017, 0.604))
	
	# Floor and ceiling of the current obstacle are both higher than the last
	if top_obstacle_spawn_point.progress_ratio >= last_upper_progress_ratio and bottom_obstacle_spawn_point.progress_ratio >= last_lower_progress_ratio:
		if last_upper_progress_ratio - bottom_obstacle_spawn_point.progress_ratio < min_obstacle_distance:
			bottom_obstacle_spawn_point.progress_ratio = last_lower_progress_ratio
		if last_upper_progress_ratio - bottom_obstacle_spawn_point.progress_ratio >= min_room_for_spike_ball:
			obstacle.place_top_spike_ball(spike_ball_scene)
			
			obstacle.change_bottom_color(Color(0.12, 1.0, 0.956, 0.718))
	# Floor and ceiling of the current obstacle are both lower than the last
	elif top_obstacle_spawn_point.progress_ratio <= last_upper_progress_ratio and bottom_obstacle_spawn_point.progress_ratio <= last_lower_progress_ratio:
		if top_obstacle_spawn_point.progress_ratio - last_lower_progress_ratio < min_obstacle_distance:
			top_obstacle_spawn_point.progress_ratio = last_upper_progress_ratio
		if top_obstacle_spawn_point.progress_ratio - last_lower_progress_ratio >= min_room_for_spike_ball:
			obstacle.place_bottom_spike_ball(spike_ball_scene)
			
			obstacle.change_top_color(Color(1.0, 0.66, 0.666, 0.718))
	# Current floor is lower than the last and current ceiling is higher than the last
	elif top_obstacle_spawn_point.progress_ratio > last_upper_progress_ratio and bottom_obstacle_spawn_point.progress_ratio < last_lower_progress_ratio:
		obstacle.place_top_spike_ball(spike_ball_scene)
		obstacle.place_bottom_spike_ball(spike_ball_scene)
	
	# add spike balls
	#if (gap_height >= min_room_for_spike_ball):
		#obstacle.place_top_spike_ball(spike_ball_scene)
		#obstacle.place_bottom_spike_ball(spike_ball_scene)
	
	last_lower_progress_ratio = bottom_obstacle_spawn_point.progress_ratio
	last_upper_progress_ratio = top_obstacle_spawn_point.progress_ratio
	
	obstacle.open(bottom_obstacle_spawn_point.position, top_obstacle_spawn_point.position)
	add_child(obstacle)

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
