extends Node

var work_dir: String

var requirements: Dictionary = {}
var lock: Dictionary = {}
var installed: Dictionary = {}


func _init() -> void:
	work_dir = ProjectSettings.globalize_path(DirAccess.open('.').get_current_dir(true)).replace('\\', '/')

func load_project_data() -> void:
	var project_config: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(work_dir + '/dotpm.json'))

	if project_config.has('require'):
		for project: String in project_config.require:
			requirements[project] = {
				'data': PackageMetaReader.get_requested_project_data(project),
				'requested': project_config.require[project],
			}

func load_lock_file() -> void:
	if not FileAccess.file_exists(work_dir + '/dotpm.lock'):
		return

	# TODO: load and parse lock file

func load_installed_packages() -> void:
	if not FileAccess.file_exists(work_dir + '/addons/installed.json'):
		return

	installed = JSON.parse_string(FileAccess.get_file_as_string(work_dir + '/addons/installed.json'))

func set_installed_package(package_name: String, package_meta: Dictionary) -> void:
	pass

func write_installed_packages() -> void:
	var file: FileAccess = FileAccess.open(work_dir + '/addons/installed.json', FileAccess.WRITE)
	file.store_string(JSON.stringify(installed, "\t"))
	file.close()

func get_package_diff() -> Dictionary:
	var diff: Dictionary = {}

	for package in requirements:
		if not installed.has(package):
			diff[package] = {
				'source': requirements[package],
				'installed': null,
			}

	return diff

func package_configuration_exists() -> bool:
	return FileAccess.file_exists(work_dir + '/dotpm.json')

func package_lock_exists() -> bool:
	return FileAccess.file_exists(work_dir + '/dotpm.lock')

func get_requested_project_data(project: String) -> Dictionary:
	if project == 'plateshift/advanced-input-map':
		return {
			'code_source': 'https://github.com/PlateShift-digital/advanced-input-map.git',
			'type': 'clone',
			'target': 'addons/advanced_input_map',
			'source': 'addons/advanced_input_map',
			'versions': {
				#'@master': {
					#'type': 'clone',
					#'branch': 'master',
				#},
			}
		}

	return {}
