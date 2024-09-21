extends Area2D
class_name afterimage


@export var player: Node2D


func create(playerNode: Node2D, frame: int) -> void:
	player = playerNode
	position = player.position
	transform.x.x = player.transform.x.x
	$Sprite2D.frame = frame
	await $AnimationPlayer.animation_finished
	queue_free()


# stun enemy if they hit the afterimage
func _on_area_entered(area: Area2D) -> void:
	if not area.is_in_group("Enemy Hitbox"): return
	var skeleton = area.get_parent()
	$AnimationPlayer.play("Hit")
	skeleton.state = skeleton.States.STUN
	await $AnimationPlayer.animation_finished
	queue_free()
