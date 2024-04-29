class_name FileSystemUtis


static func get_files(path: String) -> Array[String]:
	var files: Array[String] = []
	for file: String in DirAccess.get_files_at(path):
		files.append(path + file)
	return files


static func get_resources(resource_path: String) -> Dictionary:
	var path: String = "res://resources/" + resource_path + "/"
	var resources: Dictionary = {}
	for file: String in DirAccess.get_files_at(path):
		if file.ends_with(".tres"):
			var resource: Resource = load(path + file) as Resource
			if resource != null:
				var id: String = file.split(".")[0]
				resources[id] = resource
	return resources
