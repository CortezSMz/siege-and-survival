class_name GridUtils

const TILE_SIZE = 8.0

## Converts tile quantity to pixels
static func to_px(tiles: int) -> float:
	return tiles * TILE_SIZE


## Converts pixels quantity to tiles
## Throws error if the value is not aligned to grid (TILE_SIZE)
static func to_tiles(pixels: int) -> int:
	assert(pixels % int(TILE_SIZE) == 0, "Erro de alinhamento: Tentei converter " + str(pixels) + "px para tiles, mas não respeita o TILE_SIZE de " + str(TILE_SIZE))
	#var remainder = fmod(pixels, TILE_SIZE)

	# If theres remainder, value is out of grid
	#if remainder != 0:
		#push_error("GridUtils: Valor de pixels (", pixels, ") não é múltiplo de ", TILE_SIZE)
		#assert(remainder == 0, "Erro de alinhamento: Tentei converter " + str(pixels) + "px para tiles, mas não respeita o TILE_SIZE de " + str(TILE_SIZE))

	return int(pixels / TILE_SIZE)


## Returns an array with SNAP points (ex: [8, 16, 24])
static func get_step_offsets(total_size: float, step: float = TILE_SIZE) -> Array:
	return range(1, int(total_size / step) + 1).map(func(i): return i * step)


## Returns quantity of steps that fit total size
static func get_step_count(total_size: float, step: float = TILE_SIZE) -> int:
	return get_step_offsets(total_size, step).size()
