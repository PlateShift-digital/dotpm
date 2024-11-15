extends Node

var work_dir: String

var requirements: Dictionary = {}
var installed: Dictionary = {}
var installed_changed: bool = false


func _init() -> void:
	work_dir = ProjectSettings.globalize_path(DirAccess.open('.').get_current_dir(true)).replace('\\', '/')

func load_project_data() -> void:
	var project_config: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(work_dir + '/dotpm.json'))

	if project_config.has('require'):
		for package: String in project_config.require:
			requirements[package] = PackageMetaReader.get_requested_project_data(package, project_config.require[package])

func load_lock_file() -> void:
	if not FileAccess.file_exists(work_dir + '/dotpm-lock.json'):
		return

	# TODO: load and parse lock file

func load_installed_packages() -> void:
	if not FileAccess.file_exists(work_dir + '/addons/installed.json'):
		return

	installed = JSON.parse_string(FileAccess.get_file_as_string(work_dir + '/addons/installed.json'))

func set_installed_package(package_name: String, package_cache: PackageCache) -> void:
	installed_changed = true
	installed[package_name] = {
		'type': package_cache.install_type,
		'version': {
			'requested': package_cache.request_version,
			'installed': package_cache.cache_version,
		}
	}

func write_installed_packages() -> void:
	if not installed_changed:
		return

	var file: FileAccess = FileAccess.open(work_dir + '/addons/installed.json', FileAccess.WRITE)
	file.store_string(JSON.stringify(installed, "\t"))
	file.close()

func write_lock_file() -> void:
	var file: FileAccess = FileAccess.open(work_dir + '/dotpm-lock.json', FileAccess.WRITE)
	file.store_string(JSON.stringify(installed, "\t"))
	file.close()

func get_package_diff() -> Array[String]:
	var diff: Array[String] = []
	var cache: PackageCache

	for package in requirements:
		cache = requirements[package]
		print_debug(cache.install_type)
		if cache.install_type == 'clone':
			print_debug(cache.cache_version)
			print_debug(installed[package].version.installed)
			if not installed.has(package):
				diff.append(package)
			elif installed.has(package) and cache.cache_version != installed[package].version.installed:
				diff.append(package)
		else:
			#TODO: implement non-source installation
			pass

	return diff

func package_configuration_exists() -> bool:
	return FileAccess.file_exists(work_dir + '/dotpm.json')

func package_lock_exists() -> bool:
	return FileAccess.file_exists(work_dir + '/dotpm-lock.json')

func get_requested_project_data(project: String, version: String) -> PackageCache:
	#TODO: implement a solution to load package data
	if project == 'plateshift/advanced-input-map':
		var cache: PackageCache = CacheHandler.resolve_package_cache(
			project,
			{
				'code_source': 'https://github.com/PlateShift-digital/advanced-input-map.git',
				'install_type': 'clone' if version.begins_with('@') or version.begins_with('#') else '-not-implemented-',
				'package_target': 'addons/advanced_input_map',
				'package_source': 'addons/advanced_input_map',
				'versions': {}
			}
		)
		cache.set_requesed_version(version)

		return cache

	return null
