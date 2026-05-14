@tool

# Entity Post-Import Template for LDTK-Importer.

func post_import(entity_layer: LDTKEntityLayer) -> LDTKEntityLayer:
	var definition: Dictionary = entity_layer.definition
	var entities: Array = entity_layer.entities

<<<<<<< HEAD
	#print("EntityLayer: ", entity_layer.name, " | Count: ", entities.size())
=======
	print("EntityLayer: ", entity_layer.name, " | Count: ", entities.size())
>>>>>>> 566e3afaee1913f90c2a2904506d1917d80b4620

	for entity in entities:
		# Perform operations here
		pass

	return entity_layer
