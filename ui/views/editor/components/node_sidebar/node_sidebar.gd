extends Control
class_name NodeSidebar


var _current: ConceptNode


onready var _default: Control = $MarginContainer/DefaultContent
onready var _properties: Control = $MarginContainer/Properties
onready var _name: Label = $MarginContainer/Properties/NameLabel
onready var _inputs: Control = $MarginContainer/Properties/Inputs
onready var _outputs: Control = $MarginContainer/Properties/Outputs


func clear() -> void:
	for c in _inputs.get_children():
		c.queue_free()
		
	for c in _outputs.get_children():
		c.queue_free()
	
	_current = null
	_name.text = ""
	_default.visible = true
	_properties.visible = false


func _rebuild_ui() -> void:
	if not _current:
		_default.visible = true
		_properties.visible = false
		return

	_default.visible = false
	_properties.visible = true
	_name.text = _current.display_name

	for index in _current._inputs.keys():
		var slot = _current._inputs[index]
		var name = slot["name"]
		var type = slot["type"]
		var value = _current._get_default_gui_value(index)
		var ui: SidebarProperty = preload("property.tscn").instance()
		_inputs.add_child(ui)
		ui.create_input(name, type, value, index)
		Signals.safe_connect(ui, "value_changed", self, "_on_sidebar_value_changed")

	for slot in _current._outputs.values():
		var name = slot["name"]
		var type = slot["type"]
		var ui: SidebarProperty = preload("property.tscn").instance()
		_outputs.add_child(ui)
		ui.create_generic(name, type)


func _on_node_selected(node) -> void:
	if not node:
		return
	
	if _current:
		Signals.safe_disconnect(_current, "gui_value_changed", self, "_on_node_value_changed")
		
	clear()
	_current = node
	_rebuild_ui()
	Signals.safe_connect(_current, "gui_value_changed", self, "_on_node_value_changed")


func _on_node_deleted(node) -> void:
	if node == _current:
		clear()


# Sync changes from the graph node to the side bar
func _on_node_value_changed(value, idx: int) -> void:
	for child in _inputs.get_children():
		if child is SidebarProperty and child.get_index() == idx:
			child.set_value(value)
			return


# Sync changes from the sidebar to the graphnode
func _on_sidebar_value_changed(value, idx: int) -> void:
	if not _current:
		return # Should not happen
	
	_current.set_default_gui_value(idx, value)
