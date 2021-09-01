extends Area2D


enum TYPES {
	AMMO,
	HEALTH,
	OXYGEN_TUBE
}

var ammo_texture = preload("res://Assets/ammo_icon.png")
var health_texture = preload("res://Assets/health_icon.png")
var oxygen_texture = preload("res://Assets/oxygen_icon.png")

var type = null

func _ready():
	self.type = TYPES[TYPES.keys()[randi() % len(TYPES)]]
	match self.type:
		TYPES.AMMO:
			$Sprite.set_texture(ammo_texture)
		TYPES.HEALTH:
			$Sprite.set_texture(health_texture)
		TYPES.OXYGEN_TUBE:
			$Sprite.set_texture(oxygen_texture)

func _on_Item_body_entered(body):
	if body is Player:
		match self.type:
			TYPES.AMMO:
				body.add_ammo(5)
			TYPES.HEALTH:
				body.add_health_points(10)
			TYPES.OXYGEN_TUBE:
				body.add_move_points(1)

		self.taken()

func taken():
	self.queue_free()
