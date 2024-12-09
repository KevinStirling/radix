class_name GameManager
extends Node

const INVERSE_SCALE: float = 0.03125

enum {
	WORLD_LAYER = (1 << 0),
	ACTOR_LAYER = (1 << 1),
	TRIGGER_LAYER = (1 << 2)
}

func _init():
	print("world layer : " + str(WORLD_LAYER))
	print("actor layer : " + str(ACTOR_LAYER))
	print("trigger layer : " + str(TRIGGER_LAYER))

func use_targets(activator: Node, target: String) -> void:
	var target_list: Array[Node] = get_tree().get_nodes_in_group(target)
	for targ in target_list:
		var f: String
		if 'targetfunc' in activator:
			f = activator.targetfunc
		if f.is_empty():
			f = "use"
		if targ.has_method(f):
			targ.call(f)

func set_targetname(node: Node, targetname: String) -> void:
	print("setting target - " + targetname)
	if node != null and not targetname.is_empty():
		node.add_to_group(targetname)
		print("added node" + node.name + " to group " + targetname)
