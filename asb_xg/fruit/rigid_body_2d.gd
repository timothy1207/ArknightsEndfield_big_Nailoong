extends RigidBody2D

class_name Fruit



@export var fruit_level: int = 0
@export var radius: float = 20.0
@export var sprite_size: float = 1.0

var can_merge: bool = true
var is_dropping: bool = false
var has_landed: bool = false

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D


signal merged(fruit_a: Fruit, fruit_b: Fruit)



func _ready() -> void:

	gravity_scale = 1.0
	mass = 1.0
	linear_damp = 0.5
	angular_damp = 1.0
	
	
	var material := PhysicsMaterial.new()
	material.friction = 0.1
	material.bounce = 0.1
	physics_material_override = material
	
	

	contact_monitor = true
	max_contacts_reported = 4

	body_entered.connect(_on_body_entered)
	

	# 每一个水果创建独立的碰撞形状
	var circle: CircleShape2D = CircleShape2D.new()

	collision_shape.shape = circle

	update_visual()



func _physics_process(_delta: float) -> void:
	pass
	#print(has_landed)

#	if not is_dropping:
#		return

#	if linear_velocity.length() < 5.0:
#		is_dropping = false
#		has_landed = true
	



func update_visual() -> void:

	var texture_path: String = (
		"res://images//_%d.png" % (fruit_level + 1)
	)

	if ResourceLoader.exists(texture_path):
		sprite.texture = load(texture_path)
		sprite.scale = Vector2(sprite_size,sprite_size)

	var circle: CircleShape2D = (
		collision_shape.shape as CircleShape2D
	)

	if circle:
		circle.set_deferred("radius", radius)
		
		



func _on_body_entered(body: Node) -> void:
	

	has_landed = true

	if not can_merge:
		return

	if not body is Fruit:
		return

	var other: Fruit = body

	if not other.can_merge:
		return

	if other.fruit_level != fruit_level:
		return

	can_merge = false
	other.can_merge = false

	merged.emit(self, other)
