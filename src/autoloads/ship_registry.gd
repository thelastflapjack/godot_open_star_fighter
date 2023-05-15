extends Node
#class_name ShipRegistry


var _ships: Array[Ship]
var _team_counts: Dictionary = {Ship.Team.BLUE: 0, Ship.Team.RED: 0}


func register(new_ship: Ship) -> void:
	_ships.append(new_ship)
	_team_counts[new_ship.team] += 1
	new_ship.destroyed.connect(_on_ship_destroyed)


func all_ships() -> Array[Ship]:
	return _ships


func ship_count() -> int:
	return _ships.size()


func team_count(team: Ship.Team) -> int:
	return _team_counts[team]


func clear() -> void:
	_ships.clear()
	_team_counts = {Ship.Team.BLUE: 0, Ship.Team.RED: 0}


func rand_enemy_ship(my_team: Ship.Team) -> Ship:
	for ship in _ships:
		if ship.team != my_team:
			return ship
	return null


func rand_ship() -> Ship:
	return _ships.pick_random()


func _on_ship_destroyed(destroyed_ship: Ship) -> void:
	_team_counts[destroyed_ship.team] -= 1
	_ships.erase(destroyed_ship)

