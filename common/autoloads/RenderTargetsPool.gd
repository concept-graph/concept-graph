extends Node

# Adds a viewport to the main scene tree and wait for the VisualServer
# to render them before removing the render target from the tree.
# This is called from a background thread where the nodes run because you can't
# yield from there without breaking everything.


var _running := []


func render(viewport: Viewport) -> void:
	var id = viewport.get_instance_id()
	if _running.has(id):
		# Viewport was already submitted, ignore
		return
	
	_running.push_back(id)

	add_child(viewport)
	viewport.render_target_clear_mode = Viewport.CLEAR_MODE_NEVER
	viewport.render_target_update_mode = Viewport.UPDATE_ALWAYS
	
	# Wait two frames, for some reason after a single frame, the
	# render target is still black sometimes. Make sure update mode is set to 
	# always otherwise this trick doesn't work.
	yield(get_tree(), "idle_frame")
	yield(VisualServer, "frame_post_draw")
	yield(get_tree(), "idle_frame")
	yield(VisualServer, "frame_post_draw")

	remove_child(viewport)
	_running.erase(id)


func is_ready(viewport: Viewport) -> bool:
	var id = viewport.get_instance_id()
	if id in _running:
		return false
	
	# If the viewport ID isn't store, it's either already rendered, or was
	# never submitted. Assume it's the first scenario.
	return true
