extends Node

signal progress_changed(progress)
signal load_finished

var loading_screen: PackedScene = preload("uid://n5yglydhnnhj")
var loaded_resource: PackedScene
var scene_path: String
var progress: Array = []
var use_sub_threads: bool = true

func _ready() -> void:
	LimboConsole.register_command(load_scene, "load_scene", "loads a scene by name")
	set_process(false)

func load_scene(_scene_name: String) -> void:
	# might want to also just have a func that takes a direct path
	scene_path = "res://scenes/levels/"+_scene_name+".tscn"
	# scene_path = _scene_name
	
	var new_load_screen = loading_screen.instantiate()
	add_child(new_load_screen)
	progress_changed.connect(new_load_screen._on_progress_changed)
	load_finished.connect(new_load_screen._on_load_finished)

	await new_load_screen.loading_screen_ready

	start_load()

func start_load() -> void:
	var state = ResourceLoader.load_threaded_request(scene_path, "", use_sub_threads)
	if state == OK:
		set_process(true)

func _process(_delta: float) -> void:
	var load_status = ResourceLoader.load_threaded_get_status(scene_path, progress)
	progress_changed.emit(progress[0])
	match load_status:
		ResourceLoader.THREAD_LOAD_INVALID_RESOURCE, ResourceLoader.THREAD_LOAD_FAILED:
			set_process(false)
		ResourceLoader.THREAD_LOAD_LOADED:
			loaded_resource = ResourceLoader.load_threaded_get(scene_path)
			# TODO update this so it changes the child of the "CurrentScene" node in my MainScene tree
			get_tree().change_scene_to_packed(loaded_resource)
			load_finished.emit()
