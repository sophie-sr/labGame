extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -700.0
const FRICTION: float = 0.15
const GRAVITY: int = 300

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
	
func apply_gravity(delta: float) -> void:
	velocity.y += GRAVITY * delta
	
func apply_friction() -> void:
	velocity.x = lerp(velocity.x, 0.0, FRICTION)
