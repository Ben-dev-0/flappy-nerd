extends Node

@export var obstacle_scene: PackedScene
@export var spike_ball_scene: PackedScene
@export var player_scene: PackedScene
@export var min_obstacle_distance = 0.15
@export var spike_ball_min_speed = 100
@export var spike_ball_max_speed = 400
@export var obstacle_height_increments = 20

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
	
	top_obstacle_spawn_point.progress_ratio = randi_range(obstacle_height_increments/2, obstacle_height_increments) * (1.0/obstacle_height_increments)
	bottom_obstacle_spawn_point.progress_ratio = randi_range(0, obstacle_height_increments/2) * (1.0/obstacle_height_increments)
	
	print(str(top_obstacle_spawn_point.progress_ratio) + "<-->" + str(bottom_obstacle_spawn_point.progress_ratio))
	
	#ensure minimum opening height
	if top_obstacle_spawn_point.progress_ratio - bottom_obstacle_spawn_point.progress_ratio < min_obstacle_distance:
		var difference = top_obstacle_spawn_point.progress_ratio - bottom_obstacle_spawn_point.progress_ratio
		difference = min_obstacle_distance - difference
		bottom_obstacle_spawn_point.progress_ratio -= difference/2
		top_obstacle_spawn_point.progress_ratio += difference/2
		
		obstacle.change_top_color(Color(1.0, 0.0, 0.017, 0.604))
		obstacle.change_bottom_color(Color(1.0, 0.0, 0.017, 0.604))
	
	# Bt > At and Bb > Ab
	if top_obstacle_spawn_point.progress_ratio > last_upper_progress_ratio and bottom_obstacle_spawn_point.progress_ratio > last_lower_progress_ratio:
		if last_upper_progress_ratio - bottom_obstacle_spawn_point.progress_ratio < min_obstacle_distance:
			bottom_obstacle_spawn_point.progress_ratio = last_lower_progress_ratio
			
			obstacle.change_bottom_color(Color(0.12, 1.0, 0.956, 0.718))
	# Bt < At and Bb < Ab
	elif top_obstacle_spawn_point.progress_ratio < last_upper_progress_ratio and bottom_obstacle_spawn_point.progress_ratio < last_lower_progress_ratio:
		if top_obstacle_spawn_point.progress_ratio - last_lower_progress_ratio < min_obstacle_distance:
			top_obstacle_spawn_point.progress_ratio = last_upper_progress_ratio
			
			obstacle.change_top_color(Color(1.0, 0.66, 0.666, 0.718))
	
	last_lower_progress_ratio = bottom_obstacle_spawn_point.progress_ratio
	last_upper_progress_ratio = top_obstacle_spawn_point.progress_ratio
	
	obstacle.open(bottom_obstacle_spawn_point.position, top_obstacle_spawn_point.position)
	add_child(obstacle)

#func generate_obstacle_sequence(origin:Vector2, length:int, min_gap:float, max_gap:float,
#max_shift:float) -> void:
	#var current_position = origin
	#for i in range(length):
		#var obstacle = obstacle_scene.instantiate()
		#obstacle.position = current_position
		#var gap_height = randf_range(min_gap, max_gap)
		#obstacle.open(gap_height)
		#add_child(obstacle)
		#print(obstacle.get_width())
		#current_position.y = randf_range(current_position.y - max_shift, current_position.y + max_shift)
		#current_position.x = current_position.x + obstacle.get_width()
	
	#$ObstacleSpawnTimer.start()

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
