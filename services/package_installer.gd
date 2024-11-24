extends Node

var cache_dir: String
var work_dir: String


func _init() -> void:
	work_dir = ProjectSettings.globalize_path(DirAccess.open('.').get_current_dir(true)).replace('\\', '/')

	if OS.get_environment('DOTPM_CACHE_DIR'):
		cache_dir = OS.get_environment('DOTPM_CACHE_DIR')
	else:
		var home_dir: String = (OS.get_environment("USERPROFILE") if OS.has_feature("windows") else OS.get_environment("HOME")).replace('\\', '/')
		cache_dir = home_dir + '/.dotpm/cache'

func synchronise_packages() -> void:
	var access: DirAccess = DirAccess.open(work_dir)
	if not access.dir_exists('addons'):
		access.make_dir('addons')

	var cache: PackageCache
	var diff: Array[String] = PackageMetaReader.get_package_diff()

	if diff.size() > 0:
		print('change detected. ' + str(diff.size()) + ' packages will be updated or installed...')

		for package_name in diff:
			cache = _synchronise_package(package_name)
			if cache:
				PackageMetaReader.set_installed_package(package_name, cache)
	else:
		print('nothing to install or update. you are up to date!')

func _synchronise_package(package_name: String) -> PackageCache:
	var source_dir: String
	var cache: PackageCache = CacheHandler.get_package_cache(package_name)
	if not cache.package_target or cache.package_target.length() == 0:
		return null

	if not cache.is_installable():
		print('  unable to install package ' + package_name)
		return null

	var target_dir: String = work_dir + '/' + cache.package_target

	DirAccess.make_dir_recursive_absolute(target_dir)

	if cache.install_type == 'clone':
		source_dir = cache.cache_dir + '/clone/' + cache.package_source

		if PackageMetaReader.installed.has(package_name):
			print('  updating package ' + package_name + ' (' + PackageMetaReader.installed[package_name].version.installed.substr(0, 8) + ' -> ' + cache.cache_version.substr(0, 8) + ')')
		else:
			print('  installing package ' + package_name + ' (' + cache.cache_version.substr(0, 8) + ')')


		_delete_directory_recursive(target_dir)
		_copy_directory_recursive(source_dir, target_dir)

		return cache

	return null

func _remove_package(package_dir: String) -> void:
	_delete_directory_recursive(package_dir)

func _install_package(source_meta: Dictionary, target: String) -> void:
	pass

func _update_package() -> void:
	pass

func _copy_directory_recursive(from: String, to: String) -> void:
	var dir: DirAccess = DirAccess.open(from)
	dir.list_dir_begin()

	for sub_dir: String in dir.get_directories():
		DirAccess.make_dir_recursive_absolute(to + '/' + sub_dir)
		_copy_directory_recursive(from + '/' + sub_dir, to + '/' + sub_dir)

	for file: String in dir.get_files():
		DirAccess.copy_absolute(from + '/' + file, to + '/' + file)

func _delete_directory_recursive(directory: String) -> void:
	var dir: DirAccess = DirAccess.open(directory)
	dir.list_dir_begin()

	for sub_dir: String in dir.get_directories():
		_delete_directory_recursive(directory + '/' + sub_dir)

	for file: String in dir.get_files():
		DirAccess.remove_absolute(directory)

	DirAccess.remove_absolute(directory)
