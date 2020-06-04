tool
extends ConceptNode

"""
Create plane mesh from transforms
"""

var mesh_optimizer = preload("res://addons/concept_graph/src/native/bin/mesh_optimizer.gdns").new()


func _init() -> void:
	unique_id = "mesh_decimate"
	display_name = "Mesh Decimate"
	category = "Meshes"
	description = "Reduce the mesh polycount"

	set_input(0, "Mesh", ConceptGraphDataType.MESH)
	set_input(1, "Amount", ConceptGraphDataType.SCALAR)
	set_output(0, "", ConceptGraphDataType.MESH)


func _generate_outputs() -> void:
	var meshes := get_input(0)
	var amount: float = get_input_single(1.0)

	var res = []
	for mi in meshes:
		var m = mesh_optimizer.optimize_mesh_instance(mi.mesh, amount, mi.skeleton, mi.name, mi.skin, true)
		m.transform = mi.transform
		res.append(m)

	output[0] = res