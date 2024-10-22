@tool


static func get_child_of_type(node: Node, type: String, recursive: bool = false) -> Node:
	var l = node.find_children("", type, recursive, false)
	assert(len(l) == 1)
	return l[0]
