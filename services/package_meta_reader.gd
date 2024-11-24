extends Node

var work_dir: String

var lock_hash: String
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

	lock_hash = FileAccess.get_file_as_string(work_dir + '/dotpm.json').md5_text()
	var lock_content: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(work_dir + '/dotpm-lock.json'))

	for package: String in lock_content.require:
		requirements[package] = PackageMetaReader.get_requested_project_data(package, lock_content.require[package])

func load_installed_packages() -> void:
	if not FileAccess.file_exists(work_dir + '/addons/installed.json'):
		return

	installed = JSON.parse_string(FileAccess.get_file_as_string(work_dir + '/addons/installed.json'))

func validate_lock_hash() -> Error:
	if FileAccess.get_file_as_string(work_dir + '/dotpm.json').md5_text() != lock_hash:
		return ERR_FILE_CORRUPT

	return OK

func set_installed_package(package_name: String, package_cache: PackageCache) -> void:
	installed_changed = true
	installed[package_name] = {
		'type': package_cache.install_type,
		'install_path': package_cache.package_target,
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
	var lock: Dictionary = {}
	var cache: PackageCache
	for package: String in requirements:
		cache = requirements[package]

		if cache.install_type == 'clone':
			lock[package] = '#' + cache.cache_version
		else:
			lock[package] = '-no-implemented-'

	var file: FileAccess = FileAccess.open(work_dir + '/dotpm-lock.json', FileAccess.WRITE)
	file.store_string(JSON.stringify(
		{
			'hash': FileAccess.get_file_as_string(work_dir + '/dotpm.json').md5_text(),
			'require': lock,
		},
		"\t"
	))
	file.close()

func get_package_diff() -> Array[String]:
	var diff: Array[String] = []
	var cache: PackageCache

	for package: String in requirements:
		cache = requirements[package]
		if cache.install_type == 'clone':
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
	if project.begins_with('https://') and project.ends_with('.git'):
		var cache: PackageCache = CacheHandler.resolve_package_cache(
			project,
			{
				'code_source': project,
				'install_type': 'clone'
			}
		)
		cache.set_requesed_version(version)

		return cache

	return null
