extends CharacterBody2D
class_name Skeleton

var player: Node2D

var health: int = 3

@export var walk_speed: int = 50
enum States {PATROL, CHASE, ATTACK, HURT, DEAD}
var state: States = States.PATROL

@export var patrol_route: Array[Vector2] = []
@export var alert: bool = false


func _physics_process(_delta: float) -> void:
	choose_action()
	move_and_slide()


func _on_attack_area_body_entered(_body: Node2D) -> void:
	state = States.ATTACK


func _on_attack_area_body_exited(_body: Node2D) -> void:
	state = States.CHASE


func _on_chase_area_body_entered(body: Node2D) -> void:
	player = body
	if state != States.ATTACK: state = States.CHASE
	alert = true
	$AlertTimer.start(0)


func _on_chase_area_body_exited(_body: Node2D) -> void:
	if alert == false: state = States.PATROL


func choose_action() -> void:
	$Label.text = States.keys()[state]
	print(States.keys()[state])
	if $AnimationPlayer.current_animation != "Attack":
		match state:
			States.PATROL:
				$AnimationPlayer.play("Idle")
				velocity = Vector2.ZERO
				patrol()
			States.CHASE:
				if self.global_position.distance_to(player.global_position) >= 275:
					alert = false
					$AlertTimer.stop()
					state = States.PATROL
					
				$AnimationPlayer.play("Running")
				velocity = position.direction_to(player.position) * walk_speed
				if velocity.x != 0:
					transform.x.x = sign(velocity.x)
			States.ATTACK:
				velocity = Vector2.ZERO
				transform.x.x = sign(player.position.x - position.x)
				$AnimationPlayer.play("Attack")
	if state != States.PATROL: stop_patrol()


func patrol() -> void:
	$ChaseArea/CollisionShape2D.position = Vector2(82.5, -10)
	# TODO: go on patrols


func stop_patrol() -> void:
	$ChaseArea/CollisionShape2D.position = Vector2(0, 0)
	# TODO: stop following path2d


func _on_alert_timer_timeout() -> void:
	alert = false
	print("timeout")
