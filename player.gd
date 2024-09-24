extends CharacterBody2D
class_name Player


@export var health: float = 3
@export var invincible: bool = false
@export var dead: bool = false
@export var run_speed: int = 75
@export var afterimage_scene: PackedScene = preload("res://afterimage.tscn")
@export var dashes: float = 3


func _physics_process(delta: float) -> void:
	if health <= 0: dead = true

	if $AnimationPlayer.current_animation == "Attack": return
	move_and_slide()
	if $AnimationPlayer.current_animation == "Hurt": return

	if invincible: $Sprite2D.modulate = "#cc7780"

	if dashes >= 3: dashes = 3
	else: dashes += 0.075 * delta
	if health >= 3: health = 3
	else: health += 0.025 * delta


	var dir = Input.get_vector("Move Left", "Move Right", "Move Up", "Move Down")
	velocity = dir * run_speed

	if velocity.x != 0: transform.x.x = sign(velocity.x)

	if velocity.length() > 0: $AnimationPlayer.play("Running")
	else: $AnimationPlayer.play("Idle")


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("dash"): dash()
	elif event.is_action_pressed("attack"): attack()


func dash() -> void:
	if dashes < 1: return

	var spawned_afterimage = afterimage_scene.instantiate()
	get_tree().root.add_child(spawned_afterimage)
	spawned_afterimage.create(self, $Sprite2D.frame)

	position += velocity * 0.35

	dashes -= 1


func attack() -> void: $AnimationPlayer.play("Attack")


func _on_hurtbox_area_entered(area: Area2D) -> void:
	if not area.is_in_group("Enemy Hitbox") or invincible: return

	var enemy: Node2D = area.get_parent()
	health -= 1
	$AnimationPlayer.play("Hurt")
	velocity = (-1) * global_position.direction_to(enemy.global_position) * 50
	invincible = true
	$InvincibilityTimer.start()


func _on_invincibility_timer_timeout() -> void:
	invincible = false
	$Sprite2D.modulate = "#ffffff"
