extends StaticBody2D


const Enemy = preload("res://Enemy.tscn")

export var max_enemies = 4
export var initial_health_points = 100.0
var health_points = initial_health_points

var is_dying = false
var dying_seconds = 2.0


func _ready():
	self.spawn_enemy()

func _on_SpawnTimer_timeout():
	if $Enemies.get_child_count() < self.max_enemies:
		self.spawn_enemy()

func spawn_enemy():
	var enemy = Enemy.instance()
	$Enemies.add_child(enemy)

func _on_HitBox_body_entered(body):
	print("body entered")
	if body is Bullet:
		body.queue_free()
		self._handle_damage(body)

func _handle_damage(bullet: Bullet):
	self.health_points -= bullet.damage
	self.update_ui()

	if self.health_points <= 0:
		self._die()

func update_ui():
	$HealthBar.set_value(
		(self.health_points / self.initial_health_points) * $HealthBar.max_value
	)

func _die():
	self.is_dying = true
	for enemy in $Enemies.get_children():
		enemy._die()

func _process(delta):
	if dying_seconds <= 0:
		self.queue_free()
	if is_dying:
		self.dying_seconds -= delta
		return
