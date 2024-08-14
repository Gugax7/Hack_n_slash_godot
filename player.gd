extends CharacterBody2D

var with_weapon = false
const SPEED = 150.0
const jump_power = -300.0
var current_attack: bool
@onready var animation = $AnimatedSprite2D
@onready var attack_area = $Attack_area

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = 900

func _ready():
	Global.player_attack_area = attack_area
	Global.player_body = self
	current_attack = false

func _physics_process(delta):
	if Input.is_action_just_pressed("weapon"):
		if with_weapon:
			with_weapon = false
		else:
			with_weapon = true

	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_power
	
	if (Input.is_action_just_pressed("left_mouse") or Input.is_action_just_pressed("right_mouse")) and !current_attack:
		var attack_type
		current_attack = true
		if Input.is_action_just_pressed("left_mouse") and is_on_floor():
			attack_type = "Basic"
		if Input.is_action_just_pressed("right_mouse") and is_on_floor():
			attack_type = "Double"
		else:
			attack_type = "Air"
		handle_attack_animation(attack_type)
		toggle_attack_collision(attack_type)
		
	var direction = Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	if velocity.x > 0:
		animation.flip_h = false
		attack_area.scale.x = 1
		
	elif velocity.x < 0:
		animation.flip_h = true
		attack_area.scale.x = -1
	move_and_slide()
	animate()
func animate():
	if with_weapon and !current_attack:
		if velocity.length() == 0:
			animation.play("Idle_weapon")
		if velocity.x != 0 and is_on_floor():
			animation.play("Run_weapon")
		if not is_on_floor() and velocity.y < 0:
			animation.play("Jump")
		if not is_on_floor() and velocity.y > 0:
			animation.play("Fall_weapon")
	elif !current_attack:
		if velocity.length() == 0:
			animation.play("Idle")
		if velocity.x > 0 and is_on_floor():
			animation.play("Run")
		if velocity.x < 0 and is_on_floor():
			animation.play("Run")
		if not is_on_floor() and velocity.y < 0:
			animation.play("Jump")
		if not is_on_floor() and velocity.y > 0:
			animation.play("Fall")
func handle_attack_animation(attack_type):
	animation.play(str(attack_type, "_Attack"))
func toggle_attack_collision(attack_type):
	var wait_time: float
	var damage_zone = attack_area.get_node("CollisionPolygon2D")
	if attack_type == "Air":
		wait_time = 0.8
	elif attack_type == "Double":
		wait_time = 0.7
	elif attack_type == "Basic":
		wait_time = 0.6
	damage_zone.disabled = false
	damage_zone.visible = true
	await get_tree().create_timer(wait_time).timeout
	damage_zone.disabled = true
	damage_zone.visible = false
	current_attack = false
