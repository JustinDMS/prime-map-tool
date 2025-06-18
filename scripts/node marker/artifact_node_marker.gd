class_name ArtifactNodeMarker extends NodeMarker

const ARTIFACT_CONTAINER := preload("res://resources/artifact_container.tscn")

var artifact_container : ArtifactContainer = null
var artifact : ArtifactContainer.Artifact

func init_node() -> void:
	super()
	artifact = ArtifactContainer.get_artifact_from_name(data.item_name)
	
	var game := GameMap.get_game()
	
	var new_artifact_container := ARTIFACT_CONTAINER.instantiate()
	artifact_container = new_artifact_container
	add_child(artifact_container)
	artifact_container.set_artifact_as_focused(ArtifactContainer.get_artifact_from_name(data.item_name))
	artifact_container.scale = 10.0 * game.get_region_scale()
	artifact_container.apply_offset()
	
	rect = Rect2(marker_offset + (artifact_container.position * game.get_region_scale()), abs(artifact_container.position * 2))

func set_reachable(reached : bool) -> void:
	if reached:
		artifact_container.set_artifact_as_focused(artifact)
		return
	artifact_container.set_unreached(artifact)
