@tool

# Tileset Post-Import Template for LDTK-Importer.

func post_import(tilesets: Dictionary) -> Dictionary:
	# Behaviour goes here
	for tileset: TileSet in tilesets.values():
<<<<<<< HEAD
		#print("Tileset: ", tileset, tileset.tile_size)
		pass
=======
		print("Tileset: ", tileset, tileset.tile_size)
>>>>>>> 566e3afaee1913f90c2a2904506d1917d80b4620
	return tilesets
