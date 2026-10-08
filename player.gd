extends CharacterBody2D

signal hit
signal scored

@export var gravity = 1000
@export var jump_impulse = 400
@export var god_mode = false

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta * -up_direction.y
		
	if Input.is_action_just_pressed("jump"):
		velocity.y = jump_impulse * up_direction.y
	
	move_and_slide()

func _on_hurtbox_area_entered(area: Area2D) -> void:
	if not god_mode and area.is_in_group("obstacles"):
		hit.emit()
		call_deferred("queue_free")
	if area.is_in_group("score lines"):
		scored.emit()

func flip_gravity():
	up_direction.y *= -1
