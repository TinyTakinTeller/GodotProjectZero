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


static func add_child(child: Node, parent: Node) -> void:
	parent.add_child(child)


static func add_child_front(child: Node, parent: Node) -> void:
	parent.add_child(child)
	parent.move_child(child, 0)


static func add_child_sorted(child: Node, parent: Node, compare_func: Callable) -> void:
	parent.add_child(child)
	var children: Array[Node] = parent.get_children()
	if children.size() == 0:
		return
	var position: int = children.bsearch_custom(child, compare_func)
	parent.move_child(child, position)


static func get_inherited_theme(control: Node) -> Resource:
	var theme: Resource = null
	while control != null && "theme" in control:
		theme = control.theme
		if theme != null:
			break
		control = control.get_parent()
	return theme
