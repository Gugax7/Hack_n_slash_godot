extends CharacterBody2D

var dir: Vector2
var is_chasing: bool
var speed = 100
var player: CharacterBody2D
var is_taking_damage: bool = false
var dead: bool = false
var health = 50
@onready var hitbox = $Hitbox
@onready var collision = $CollisionShape2D


func _ready():
	is_chasing = true
	player = Global.player_body
func _process(delta):
	move(delta)
	handle_animation()

func move(delta):
	if !is_taking_damage and !dead:
		if is_chasing:
			velocity = self.global_position.direction_to(player.position) * speed
		elif not is_chasing:
			velocity = dir * speed
	elif is_taking_damage and !dead:
		velocity = position.direction_to(player.position) * -50
	else:
		velocity.x = 0
		velocity.y += 10 * delta
	move_and_slide()
func handle_animation():
	var animation = $AnimatedSprite2D
	if !dead:
		if !is_taking_damage:
			animation.play("Fly")
			if velocity.x > 0 and !is_taking_damage:
				animation.flip_h = false
			elif velocity.x < 0 and !is_taking_damage:
				animation.flip_h = true
		else:
			animation.play("Damage")
			await get_tree().create_timer(0.8).timeout
			is_taking_damage = false
	else:
		animation.play("Death")
		collision.disabled = true
		await get_tree().create_timer(0.5).timeout
		animation.pause()

func _on_timer_timeout():
	$Timer.wait_time = choose([1.0,1.5,2.0])
	if !is_chasing:
		dir = choose([Vector2.RIGHT, Vector2.LEFT, Vector2.UP, Vector2.DOWN, Vector2(1,1)])
func choose(array):
	array.shuffle()
	return array.front()


func _on_hitbox_area_entered(area):
	if area == Global.player_attack_area and !is_taking_damage:
		is_taking_damage = true
		var damage = Global.player_damage_amount
		take_damage(damage)
func take_damage(damage):
	health-=damage
	if health <= 0:
		health = 0
		dead = true
	print(str(self), " HEALTH: ", health)
