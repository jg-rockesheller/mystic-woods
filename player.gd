extends CharacterBody2D
class_name Player


@export var health: int = 3
@export var run_speed: int = 75
@export var afterimage_scene: PackedScene = preload("res://afterimage.tscn")
@export var dashes: float = 3 # TODO: implement recharging dashes


func _physics_process(delta: float) -> void:
	if $AnimationPlayer.current_animation == "Attack": return
	print(dashes)
	if dashes >= 3: dashes = 3
	else: dashes += 0.075 * delta

	var dir = Input.get_vector("Move Left", "Move Right", "Move Up", "Move Down")
	velocity = dir * run_speed
	move_and_slide()

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

	position += velocity * 0.25

	dashes -= 1

	# TODO: cooldowns


func attack() -> void: $AnimationPlayer.play("Attack")


func _on_hurtbox_area_entered(area: Area2D) -> void:
	if not area.is_in_group("Enemy Hitbox"): return
	pass # Replace with function body.
