# TODO: implement stunned enemies

extends CharacterBody2D
class_name Skeleton

var player: Node2D

var health: int = 3

@export var walk_speed: int = 50
enum States {PATROL, CHASE, ATTACK, STUN, HURT, DEAD}
@export var state: States = States.PATROL
@export var gave_reward: bool = false

@export var alert: bool = false
@export var stunned: bool = false


func _physics_process(_delta: float) -> void:
	choose_action()
	move_and_slide()


func _ready() -> void: $Hitbox/CollisionShape2D.disabled = true


func choose_action() -> void:
	$Label.text = States.keys()[state]
	if state not in [States.STUN, States.HURT, States.DEAD] and ($AnimationPlayer.current_animation in ["Attack", "Hurt", "Dead"] or stunned): return

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

		States.HURT:
			$AnimationPlayer.play("Hurt")
			velocity = (-1) * global_position.direction_to(player.global_position) * 35
			await $AnimationPlayer.animation_finished
			if health <= 0: state = States.DEAD
			else: state = States.CHASE

		States.DEAD:
			if $AnimationPlayer.current_animation == "Hurt": await $AnimationPlayer.animation_finished
			if not gave_reward:
				player.dashes += 1
				gave_reward = true
			$Hurtbox/CollisionShape2D.disabled = true
			$Hitbox/CollisionShape2D.disabled = true
			velocity *= 0
			$AnimationPlayer.play("Dead")
			await $AnimationPlayer.animation_finished
			queue_free()

		States.STUN:
			stunned = true
			$Sprite2D.modulate = "#b2b2b2"
			$StunnedTimer.start()

	if state != States.PATROL: stop_patrol()


# player enters/exits attack area
func _on_attack_area_body_entered(_body: Node2D) -> void:
	state = States.ATTACK


func _on_attack_area_body_exited(_body: Node2D) -> void:
	state = States.CHASE


# player enters/exits chase area
func _on_chase_area_body_entered(body: Node2D) -> void:
	player = body
	if state != States.ATTACK: state = States.CHASE
	alert = true
	$AlertTimer.start(0)


func _on_chase_area_body_exited(_body: Node2D) -> void:
	if alert == false: state = States.PATROL


# alert functions
func patrol() -> void:
	$ChaseArea/CollisionShape2D.position = Vector2(40, -10)
	$LOSEnabler/CollisionShape2D.disabled = true
	# TODO: go on patrols using path2d


func stop_patrol() -> void:
	$ChaseArea/CollisionShape2D.position = Vector2(0, 0)
	$LOSEnabler/CollisionShape2D.disabled = false
	# TODO: stop following path2d


func _on_alert_timer_timeout() -> void:
	alert = false


# is attacked by player
func _on_hurtbox_area_entered(area: Area2D) -> void:
	if not area.is_in_group("Player Hitbox"): return
	if not player: player = area.get_tree().get_root().get_node("World/Player")

	var dmg = 1
	if state in [States.PATROL, States.STUN]: dmg = 4
	health -= dmg
	state = States.HURT



func _on_line_of_sight_area_entered(area: Area2D) -> void:
	if not area.is_in_group("Enable LOS"): return
	if not player: player = area.get_tree().get_root().get_node("World/Player")
	state = States.CHASE


func _on_stunned_timer_timeout() -> void:
	stunned = false
	$Sprite2D.modulate = "#ffffff"
