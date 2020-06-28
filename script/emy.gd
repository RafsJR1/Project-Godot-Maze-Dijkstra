extends KinematicBody2D

var speed = 300
var vel = Vector2()
var a = 1

func _physics_process(delta):
	if a == 1 or a == 5:
		vel.x = speed
		$Sprite/AnimationPlayer.play("r")
	elif a == 2 or a == 6:
		vel.y = speed
		$Sprite/AnimationPlayer.play("d")
	elif a == 3 or a == 8:
		vel.x = -speed
		$Sprite/AnimationPlayer.play("l")
	elif a == 4 or a == 7:
		vel.y = -speed
		$Sprite/AnimationPlayer.play("u")
		
	vel=move_and_slide(vel)
	
	if is_on_wall():
		if a == 1:
			a = a+1
		elif a == 2:
			a = a+1
		elif a == 3:
			a = a+1
		elif a == 4:
			a = a+1
		if a == 5:
			a = a+1
		elif a == 6:
			a = a+1
		elif a == 7:
			a = a+1
		elif a == 8:
			a = a-7
			
	

	if get_slide_count() > 0:
		for i in range(get_slide_count()):
			if 'player' in get_slide_collision(i).collider.name:
				get_slide_collision(i).collider.dead()
	 
