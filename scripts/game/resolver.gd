class_name Resolver extends RefCounted

var game : Game = null
var logic_db : Dictionary[StringName, Dictionary] = {}

# Inner dictionary expected type is [ StringName, Array[StringName] ]
var reached_nodes : Dictionary[StringName, Dictionary] = {}

var template_results : Dictionary[StringName, bool] = {}
var dock_results : Dictionary[StringName, bool] = {}

func _init(_game : Game, _logic_db : Dictionary[StringName, Dictionary]) -> void:
	game = _game
	logic_db = _logic_db
	
	for name in game._templates:
		template_results[name] = can_reach( game._templates[name], ReachResult.new(null, null) )
	
	# Pre-check templates, docks, and locks
	# This way they only need to be checked once
	for type in game._header.dock_weakness_database.types:
		for item in game._header.dock_weakness_database.types[type].items:
			var requirement : Dictionary = game._header.dock_weakness_database.types[type].items[item].requirement
			# Can be Dictionary or null
			var lock_buffer = game._header.dock_weakness_database.types[type].items[item].lock
			var lock = {} if lock_buffer == null else lock_buffer
			
			if requirement.type == &"template":
				dock_results[item] = template_results[requirement.data]
			else:
				dock_results[item] = can_reach( requirement, ReachResult.new(null, null) )
			
			if lock.is_empty():
				continue
			
			if lock.requirement.type == &"template":
				dock_results[lock.lock_type] = template_results[lock.requirement.data]
			else:
				dock_results[lock.lock_type] = can_reach( lock.requirement, ReachResult.new(null, null) )
	
	# Default case for absent lock
	dock_results[&"null"] = true

func resolve(start_node : NodeData) -> void:
	var queue : Array[NodeData] = [start_node]
	var event_waitlist : Dictionary[StringName, Array]
	
	for region in game.get_region_names():
		reached_nodes[region] = {}
	
	game.reset_events()
	
	while len(queue) > 0:
		var node : NodeData = queue.pop_front()
		var results : Array[ReachResult] = reach(node)
		for rr in results:
			if rr.reached:
				queue.append(rr.to)
				
				if rr.to.is_event():
					var id := rr.to.get_event_id()
					if not id in event_waitlist:
						continue
					
					queue.append_array( event_waitlist[id] )
					event_waitlist.erase(id)
				
				continue
			
			## Handle unreached nodes
			
			if &"events" in rr.reach_data:
				var ids := rr.reach_data.events.keys()
				for id in ids:
					var event_queue : Array = event_waitlist.get_or_add(id, [])
					event_queue.append(node)

func reach(node : NodeData) -> Array[ReachResult]:
	var results : Array[ReachResult] = []
	
	# Check if there's an outside connection
	var default_connection : NodeData = node.default_connection
	if (
		is_instance_valid(default_connection) and
		not is_reached(default_connection)
		):
		var result := ReachResult.new(node, default_connection)
		result.reached = can_reach_external(result.from, result.to)
		if result.reached:
			add_reached(default_connection)
		results.append(result)
	
	for internal in node.connections:
		if is_reached(internal):
			continue
		
		var result := ReachResult.new(node, internal)
		result.reached = can_reach_internal(result.from, result.to, result)
		
		if result.reached:
			add_reached(internal)
			
			if internal.is_event():
				game.set_event( internal.get_event_id(), true )
		
		results.append(result)
	
	return results

func add_reached(node : NodeData) -> void:
	if not reached_nodes.has(node.region):
		reached_nodes[node.region] = {}
	
	if not reached_nodes[node.region].has(node.room_name):
		reached_nodes[node.region][node.room_name] = []
	
	reached_nodes[node.region][node.room_name].append( node.name )

func is_reached(node : NodeData) -> bool:
	return (
		reached_nodes.has(node.region) and 
		reached_nodes[node.region].has(node.room_name) and
		node.name in reached_nodes[node.region][node.room_name]
	)

func can_reach_external(from_node : NodeData, _to_node : NodeData) -> bool:
	# TODO - Check other side too?
	return (dock_results[ from_node.get_dock_weakness() ])

func can_reach_internal(from_node : NodeData, to_node : NodeData, reach_result : ReachResult) -> bool:
	var logic : Dictionary = \
	logic_db[from_node.region].areas[from_node.room_name].nodes[from_node.name].connections[to_node.name]
	
	return can_reach(logic, reach_result)

func has_resource(logic_data : Dictionary) -> bool:
	var type : StringName = logic_data.type
	var name : StringName = logic_data.name
	var amount : int = logic_data.amount
	var negate : bool = logic_data.negate
	var result := false
	
	match type:
		&"items":
			result = game.get_item(name).has()
		&"events":
			result = game.get_event(name).reached
		&"tricks":
			result = game.get_trick(name).can_perform(amount)
		&"damage": # TODO
			result = true
		&"misc":
			result = game.get_misc_setting(name).is_enabled()
		_:
			push_error("Unhandled resource type: %s" % type)
	
	if negate:
		result = not result
	
	return result

func can_reach(logic : Dictionary, reach_result : ReachResult, _depth : int = 0) -> bool:
	match logic.type:
		"and":
			if logic.data.items.is_empty():
				return true
			
			for i in range(logic.data.items.size()):
				if not can_reach(logic.data.items[i], reach_result, _depth + 1):
					return false
			return true
		
		"or":
			for i in range(logic.data.items.size()):
				if can_reach(logic.data.items[i], reach_result, _depth + 1):
					return true
			return false
		
		"resource":
			var has : bool = has_resource(logic.data)
			if not has:
				reach_result.log_failed_reach(logic.data)
			return has
		
		"template":
			var result : bool = false
			
			if not logic.data in template_results:
				# Runs when templates rely on each-other
				# while pre-solving them during _init()
				result = can_reach( game._templates[logic.data], reach_result )
			else:
				result = template_results[logic.data]
				if not result:
					reach_result.log_failed_reach(logic)
			
			return result
		
		_:
			push_error("Unhandled logic type: %s" % logic.type)
	
	return false

class ReachResult:
	var from : NodeData = null
	var to : NodeData = null
	var reached : bool = false
	
	## Tracks how many times a reach failed due to not having
	## a resource or template
	##
	## Inner dictionary expected type is StringName, int
	var reach_data : Dictionary[StringName, Dictionary] = {}
	
	func _init(_from : NodeData, _to : NodeData) -> void:
		from = _from
		to = _to
	
	func log_failed_reach(logic_data : Dictionary) -> void:
		var type : StringName = logic_data.type
		var name : StringName = &""
		if type == &"template":
			name = logic_data.data
		else:
			name = logic_data.name
		#var amount : int = logic_data.amount
		#var negate : bool = logic_data.negate
		
		if not type in reach_data:
			reach_data[type] = { name : 1 }
			return
		
		if not name in reach_data[type]:
			reach_data[type][name] = 1
			return
		
		reach_data[type][name] += 1
