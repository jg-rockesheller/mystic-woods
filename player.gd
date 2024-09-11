extends CharacterBody2D
class_name Player

@export var run_speed: int = 75

func _physics_process(_delta: float) -> void:
	var dir = Input.get_vector("Move Left", "Move Right", "Move Up", "Move Down")
	velocity = dir * run_speed
	move_and_slide()

	if velocity.x != 0:
		$Sprite2D.flip_h = velocity.x < 0

	if velocity.length() > 0:
		$AnimationPlayer.play("Running")
	else:
		$AnimationPlayer.play("Idle")
