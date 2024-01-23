extends Node2D


const TERRAIN = 0
const TERRAIN_SET = 0
const LAYER = 0
const BUILDING = 1
const CANDIDATE = 2
const BLOCKER = 3

const BLOCKER_OFF = 1
const CANDIDATE_OFF = 1

const WIDTH = [3, 5]
const LENGTH = [4, 6]


@onready var tile_map: TileMap = %TileMap
@onready var add_building_button: Button = %AddBuildingButton


func _ready() -> void:
	#on_add_building()
	#on_add_building()
	#on_add_building()
	#on_add_building()
	#on_add_building()
	randomize()
	add_building_button.pressed.connect(on_add_building)
	pass


# Assuming placing is valid adds tiles to the map
func place_building(rect: Rect2i) -> void:
	var cells: Array[Vector2i] = []
	cells.resize(rect.size.x * rect.size.y)
	var i = 0
	for x in rect.size.x:
		for y in rect.size.y:
			cells[i] = rect.position + Vector2i(x, y)
			i += 1
	
	var off = Vector2i(BLOCKER_OFF, BLOCKER_OFF)
	var off_rect = Rect2i(rect.position - off, rect.size + off * 2)
	for x in off_rect.size.x:
		for y in off_rect.size.y:
			var cell = off_rect.position + Vector2i(x, y)
			if is_blockable(cell):
				block_cell(cell)
	
	off = off + Vector2i(CANDIDATE_OFF, CANDIDATE_OFF)
	off_rect = Rect2i(rect.position - off, rect.size + off * 2)
	for x in off_rect.size.x:
		for y in off_rect.size.y:
			var cell = off_rect.position + Vector2i(x, y)
			if is_claimable(cell):
				claim_cell(cell)
	
	tile_map.set_cells_terrain_connect(0, cells, 0, 0)
	pass


## Checks is selected rect doesn't have blocker or building tiles
func validate_rect(rect: Rect2i) -> bool:
	if not rect:
		return false
	for x in rect.size.x:
		for y in rect.size.y:
			var cell = Vector2i(x, y) + rect.position
			if not is_claimable(cell):
				return false
	return true


## Evaluate building candidate score
## (the more candidate tiles it contains the better)
func candidate_score(rect: Rect2i) -> int:
	var result = 0
	for x in rect.size.x:
		for y in rect.size.y:
			var id = tile_map.get_cell_source_id(LAYER, Vector2i(x, y) + rect.position)
			if id == CANDIDATE:
				result += 0.5 + randf()
	return result


## Generates a spot for new building
func generate_rect(pos: Vector2i) -> Rect2i:
	var size = Vector2i(
		randi_range(WIDTH[0], WIDTH[1]),
		randi_range(LENGTH[0], LENGTH[1]),
	)
	if randf() < 0.5:
		size = Vector2i(size.y, size.x)
	if randf() < 0.5:
		pos.x -= size.x
	if randf() < 0.5:
		pos.y -= size.y
	return Rect2i(pos, size)


## Generates a suitable building candidate
func pick_candidate() -> Rect2i:
	var rect: Rect2i
	var counter = 100
	var score = 0
	var candidates = tile_map.get_used_cells_by_id(LAYER, CANDIDATE)
	
	while counter > 0:
		counter -= 1
		var test = generate_rect(candidates.pick_random())
		if validate_rect(test) == false:
			continue
		var test_score = candidate_score(test)
		if score > 0 and test_score < score:
			break
		if test_score < score:
			continue
		rect = test
		score = test_score
	
	return rect


## Call this when asked to add random building
func on_add_building() -> void:
	var rect = pick_candidate()
	if validate_rect(rect):
		place_building(rect)
	pass


## Returns true if blocker is allowed to be placed in this cell
## (anything but building)
func is_blockable(pos: Vector2i) -> bool:
	return tile_map.get_cell_source_id(LAYER, pos) != BUILDING


## Returns true if cell is allowed to be marked as candidate
## (empty or candidate, not blocker or building)
func is_claimable(pos: Vector2i) -> bool:
	var id = tile_map.get_cell_source_id(LAYER, pos) 
	return id == -1 or id == CANDIDATE


## Place blocker tile
func block_cell(pos: Vector2i) -> void:
	tile_map.set_cell(LAYER, pos, BLOCKER, Vector2i.ZERO)
	pass



## Place candidate tile
func claim_cell(pos:Vector2i) -> void:
	tile_map.set_cell(LAYER, pos, CANDIDATE, Vector2i.ZERO)
	pass







