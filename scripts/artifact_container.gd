class_name ArtifactContainer extends Control

enum Artifact {
	TRUTH,
	STRENGTH,
	ELDER,
	WILD,
	LIFEGIVER,
	WARRIOR,
	CHOZO,
	NATURE,
	SUN,
	WORLD,
	SPIRIT,
	NEWBORN,
	MAX
}

const MIDPOINT := Vector2(225, -190)
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

static func get_artifact_from_name(_name : String) -> Artifact:
	match _name:
		"Artifact of Truth":
			return Artifact.TRUTH
		"Artifact of Strength":
			return Artifact.STRENGTH
		"Artifact of Elder":
			return Artifact.ELDER
		"Artifact of Wild":
			return Artifact.WILD
		"Artifact of Lifegiver":
			return Artifact.LIFEGIVER
		"Artifact of Warrior":
			return Artifact.WARRIOR
		"Artifact of Chozo":
			return Artifact.CHOZO
		"Artifact of Nature":
			return Artifact.NATURE
		"Artifact of Sun":
			return Artifact.SUN
		"Artifact of World":
			return Artifact.WORLD
		"Artifact of Spirit":
			return Artifact.SPIRIT
		"Artifact of Newborn":
			return Artifact.NEWBORN
	
	push_error("Couldn't find artifact from name: %s" % _name)
	return Artifact.TRUTH

func set_unreached(artifact : Artifact) -> void:
	for i in range(Artifact.MAX):
		if i == artifact:
			set_artifact_color(artifact, BLUE)
			continue
		set_artifact_color(i, Color.INDIAN_RED)

func apply_offset() -> void:
	position -= MIDPOINT

func set_artifact_as_focused(artifact : Artifact) -> void:
	for i in range(Artifact.MAX):
		if i == artifact:
			set_artifact_color(artifact, ORANGE)
			continue
		set_artifact_color(i, BLUE)

func set_artifact_color(artifact : Artifact, color : Color) -> void:
	const COLOR_CHANGE_DURATION : float = 0.1
	
	if not textures:
		return
	
	var tween := create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_property(
			textures[artifact], 
			"self_modulate", color,
			COLOR_CHANGE_DURATION
			)
