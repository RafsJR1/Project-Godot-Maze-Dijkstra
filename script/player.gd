extends KinematicBody2D

var speed = 200
var vel = Vector2()
var dead = false

func _physics_process(delta):
	if dead == false:
		if Input.is_action_pressed("ui_left"):
			vel.x = -speed
			$Sprite/AnimationPlayer.play("wl")
			
		elif Input.is_action_pressed("ui_right"):
			vel.x = speed
			$Sprite/AnimationPlayer.play("wr")
				
		else:
			vel.x = 0
			
		if Input.is_action_pressed("ui_up"):
			vel.y = -speed
			$Sprite/AnimationPlayer.play("wu")
			
			
		elif Input.is_action_pressed("ui_down"):
			vel.y = speed
			$Sprite/AnimationPlayer.play("wd")
			
		else:
			vel.y = 0
			
			
		
		vel= move_and_slide(vel)
		
func dead():
	dead = true
	vel = Vector2(0, 0)
	$Sprite/AnimationPlayer.play("walkright")
	$CollisionShape2D.set_deferred('disabled', true)
	$Timer.start()
	

func _on_Timer_timeout():
	get_tree().change_scene("res://scn/lose.tscn")
