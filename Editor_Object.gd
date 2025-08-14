extends Node2D

var can_place = true
var do_save = false

@onready var level = get_node("/root/Level_Editor/Level")
var item_select: Control 
var current_item = null
var cursor_sprite = Sprite2D.new()

var last_click_time = 0
var double_click_threshold = 500

@onready var popup : FileDialog = get_node("/root/Level_Editor/Item_Select/FileDialog")

func _ready():
	add_child(cursor_sprite)
	cursor_sprite.visible = false
	item_select = get_node_or_null("Item_Select")

func _process(delta):
	var mouse_position = get_global_mouse_position()
	cursor_sprite.position = mouse_position

	if !LevelEditorGlobal.place_tile and can_place and not is_mouse_over_item_select(mouse_position):
		if Input.is_action_just_pressed("mb_left") and current_item != null:
			handle_double_click(mouse_position)
		elif Input.is_action_just_pressed("mb_right"):
			remove_item_at(mouse_position)
			deselect_current()
			
	if Input.is_action_just_pressed("save"):
		LevelEditorGlobal.filesystem_shown = true
		do_save = true
		popup.file_mode = FileDialog.FILE_MODE_SAVE_FILE
		popup.show()
	if Input.is_action_just_pressed("load"):
		LevelEditorGlobal.filesystem_shown = true
		do_save = false
		popup.file_mode = FileDialog.FILE_MODE_OPEN_FILE
		popup.show()

func handle_double_click(position):
	var current_time = Time.get_ticks_msec()
	if (current_time - last_click_time) < double_click_threshold and current_item != null:
		place_current_item(position)
	last_click_time = current_time

func place_current_item(position):
	var new_item = current_item.instantiate()
	level.add_child(new_item)
	new_item.global_position = position

func remove_item_at(position):
	for child in level.get_children():
		if child.global_position.distance_to(position) < 10:
			child.queue_free()

func deselect_current():
	current_item = null
	cursor_sprite.visible = false

func is_in_game_area(position):
	return position.x > 200  # Can be adjusted

func is_mouse_over_item_select(mouse_position):
	if item_select and item_select.visible and item_select.get_rect().has_point(item_select.to_local(mouse_position)):
		return true
	return false

func select_item(item, texture):
	if current_item != item:
		deselect_current()
	current_item = item
	cursor_sprite.texture = texture
	cursor_sprite.visible = true

func _on_file_dialog_confirmed():
	pass


func _on_save_pressed():
	LevelEditorGlobal.filesystem_shown = true
	do_save = true
	popup.file_mode = FileDialog.FILE_MODE_SAVE_FILE
	popup.show()


func _on_load_pressed():
	LevelEditorGlobal.filesystem_shown = true
	do_save = false
	popup.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	popup.show()
