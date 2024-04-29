class_name NodeUtils


static func clear_children(node: Node) -> void:
	for n: Node in node.get_children():
		node.remove_child(n)
		n.queue_free()


static func clear_children_of(node: Node, clazz_name: Variant) -> void:
	for n: Node in node.get_children():
		if is_instance_of(n, clazz_name):
			node.remove_child(n)
			n.queue_free()


static func remove_oldest(parent: Node) -> void:
	var oldest_child: Node = parent.get_child(parent.get_child_count() - 1)
	parent.remove_child(oldest_child)
	oldest_child.queue_free()
