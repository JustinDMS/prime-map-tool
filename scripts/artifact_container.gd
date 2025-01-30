class_name ArtifactContainer extends Control

const BLUE := Color("#4CDAF5")
const ORANGE := Color("#F1A34C")

@onready var textures : Array[TextureRect] = [
	$truth,
	$strength,
	$elder,
	$wild,
	$lifegiver,
	$warrior,
	$chozo, 
	$nature, 
	$sun, 
	$world, 
	$spirit, 
	$newborn
]

func set_unreached(artifact : PrimeInventory.Artifact) -> void:
	for i in range(PrimeInventory.Artifact.MAX):
		if i == artifact:
			set_artifact_color(artifact, BLUE)
			continue
		set_artifact_color(i, Color.INDIAN_RED)

func apply_offset() -> void:
	position -= Vector2(225, -190)

func set_artifact_as_focused(artifact : PrimeInventory.Artifact) -> void:
	for i in range(PrimeInventory.Artifact.MAX):
		if i == artifact:
			set_artifact_color(artifact, ORANGE)
			continue
		set_artifact_color(i, BLUE)

func set_artifact_color(artifact : PrimeInventory.Artifact, color : Color) -> void:
	const COLOR_CHANGE_DURATION : float = 0.1
	
	var tween := create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_property(
			textures[artifact], 
			"self_modulate", color,
			COLOR_CHANGE_DURATION
			)
