extends Node2D

var can_place = true
var snap_size = Vector2(16, 16)  # Adjust the snap size to match your tile size

@onready var level = get_node("/root/Level_Editor/Level")
@onready var item_select = get_node_or_null("Item_Select")
var current_item = null

var placing = false  # A flag for continuous placement
var removing = false  # A flag for continuous removal
var last_click_time = 0  # Time of the last click for double-click detection
var double_click_threshold = 500  # Time in milliseconds within which a second click counts as a double-click
var last_placed_position = Vector2.INF  # Track the last placed position

func _ready():
	if not item_select:
		print("Error: Item_Select node not found. Check the node path.")

func _process(delta):
	var mouse_position = get_global_mouse_position()
	var snapped_position = snap_position(mouse_position)

	if !LevelEditorGlobal.place_tile and can_place and not is_mouse_over_item_select(mouse_position):
		if Input.is_action_pressed("mb_left") and current_item != null:
			handle_placing(snapped_position)
		else:
			placing = false
			last_placed_position = Vector2.INF

		if Input.is_action_pressed("mb_right"):
			handle_removing(snapped_position)
		else:
			removing = false

func snap_position(position):
	return Vector2(int(position.x / snap_size.x) * snap_size.x, int(position.y / snap_size.y) * snap_size.y)

func place_current_item(position):
	if position != last_placed_position:
		var new_item = current_item.instantiate()
		level.add_child(new_item)
		new_item.global_position = position
		last_placed_position = position

func handle_placing(position):
	var current_time = Time.get_ticks_msec()
	if (current_time - last_click_time) < double_click_threshold and current_item != null:
		place_current_item(position)
	last_click_time = current_time

func handle_removing(position):
	if not removing or position != last_placed_position:
		remove_item_at(position)
		removing = true
		last_placed_position = position
		deselect_current()

func remove_item_at(position):
	for child in level.get_children():
		if child.global_position.distance_to(position) < snap_size.x / 2:
			child.queue_free()

func deselect_current():
	current_item = null

func is_mouse_over_item_select(mouse_position):
	if item_select and item_select.visible:
		return item_select.get_rect().has_point(item_select.to_local(mouse_position))
	return false
