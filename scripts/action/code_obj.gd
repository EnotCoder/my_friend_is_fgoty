extends Area3D

@export var texture_obj: Texture;

const AMPLITUDE: float = 0.2;
const SPEED_SIN: float = 2.0;
const SPEED_ROT: float = 1.8;
const SPEED_SCALE_CODE: float = 5.0;
const SPEED_SCALE_SHADOW: float = 4.0;

@onready var sprite_code: Sprite3D = $sprite_code
@onready var grass_shadow_cell: MeshInstance3D = $GrassShadowCell
@onready var ui: Control = $ui/ui
@onready var code: TextureRect = $ui/ui/code

var time: float = 0.0;
var start_y: float = 0.0;
var del_scale: Vector3 = Vector3.ZERO;

func _process(delta: float) -> void:
	time += delta;
	sprite_code.position.y = start_y + sin(time * SPEED_SIN) * AMPLITUDE;	
	sprite_code.rotation.y += delta * SPEED_ROT;

	if sprite_code.scale != del_scale:
		sprite_code.scale = lerp(sprite_code.scale, del_scale, 
			delta * SPEED_SCALE_CODE);
		grass_shadow_cell.scale = lerp(grass_shadow_cell.scale, 
			del_scale, delta * SPEED_SCALE_SHADOW);
		

func _ready() -> void:
	code.texture = texture_obj;
	body_entered.connect(on_player_entered);
	start_y = sprite_code.position.y;
	del_scale = sprite_code.scale;
	
func on_player_entered(body: Node3D) -> void:
	if body is Player:
		set_deferred("monitoring", false)
		del_scale = Vector3.ZERO;
		
		ui.start();
