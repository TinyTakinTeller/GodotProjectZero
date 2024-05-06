class_name FileSystemUtis


static func get_files(path: String) -> Array:
	var files: Array = []
	for file: String in DirAccess.get_files_at(path):
		files.append(path + file)
	return files


static func get_resources(resource_path: String, recursive: bool) -> Dictionary:
	var path: String = "res://resources/" + resource_path + "/"
	var resources: Dictionary = {}
	for file: String in DirAccess.get_files_at(path):
		if file.ends_with(".tres"):
			var resource: Resource = load(path + file) as Resource
			if resource != null:
				var id: String = file.split(".")[0]
				resources[id] = resource
	if recursive:
		for dir: String in DirAccess.get_directories_at(path):
			var resources_dir: Dictionary = get_resources(resource_path + "/" + dir, recursive)
			resources.merge(resources_dir)
	return resources
