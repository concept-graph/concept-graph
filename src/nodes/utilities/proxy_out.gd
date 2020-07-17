tool
extends ConceptNode


var _proxy_in


func _init() -> void:
	unique_id = "proxy_out"
	display_name = "Proxy (Out)"
	category = "Utilities"
	description = "When you need to access the same node from parts of the graph that are far away"

	set_input(0, "Name", ConceptGraphDataType.STRING)
	set_output(0, "", ConceptGraphDataType.ANY)


func _on_default_gui_ready() -> void:
	get_parent().connect("proxy_list_updated", self, "_link_proxy")
	get_parent().connect("template_loaded", self, "_link_proxy")


func _generate_outputs() -> void:
	#_update_output_type()
	var proxy_name: String = get_input_single(0, null)
	var proxy = get_parent().get_proxy(proxy_name)
	if proxy:
		output[0] = proxy.get_output(0)


func _on_default_gui_interaction(value, _control: Control, slot: int) -> void:
	if slot == 0:
		_link_proxy()


func _link_proxy() -> void:
	if _proxy_in:
		_proxy_in.disconnect("connection_changed", self, "_update_output_type")
		_proxy_in = null

	var proxy_name = get_input_single(0, "")
	_proxy_in = get_parent().get_proxy(proxy_name)
	_update_output_type()

	if _proxy_in:
		_proxy_in.connect("connection_changed", self, "_update_output_type")


func _update_output_type() -> void:
	var type = ConceptGraphDataType.ANY
	if _proxy_in and _proxy_in.is_input_connected(0):
		type = _proxy_in.get_connected_input_type(0)
		if type == -1:
			type = ConceptGraphDataType.ANY

	set_output(0, "", type)
	_setup_slots()
	get_parent().force_redraw()
