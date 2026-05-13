extends Node2D

var query_parameters := NavigationPathQueryParameters2D.new()
var query_result := NavigationPathQueryResult2D.new()

func create_path(start_position: Vector2, target_position: Vector2, navigation_layers: int = 1) -> PackedVector2Array:
	if !is_inside_tree():
		return PackedVector2Array()

	var map := get_world_2d().navigation_map

	if NavigationServer2D.map_get_iteration_id(map) == 0:
		return PackedVector2Array()

	query_parameters.map = map
	query_parameters.start_position = start_position
	query_parameters.target_position = target_position
	query_parameters.navigation_layers = navigation_layers
	query_parameters.path_postprocessing = NavigationPathQueryParameters2D.PATH_POSTPROCESSING_EDGECENTERED

	NavigationServer2D.query_path(query_parameters, query_result)

	return query_result.path

func get_next_node_index(position: Vector2, path: PackedVector2Array) -> int:
	if path.is_empty():
		return 0
	if path.size() < 2:
		return 0

	var closest_segment := 0
	var closest_distance := INF

	for i in range(path.size() - 1):
		var point := Geometry2D.get_closest_point_to_segment(position, path[i], path[i + 1])
		var distance := position.distance_squared_to(point)
		if distance <= closest_distance:
			closest_segment = i
			closest_distance = distance

	return closest_segment + 1
