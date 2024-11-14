extends Node

var cache_dir: String
var work_dir: String


func _init() -> void:
	work_dir = ProjectSettings.globalize_path(DirAccess.open('.').get_current_dir(true)).replace('\\', '/')

	if OS.get_environment('DOTPM_CACHE_DIR'):
		cache_dir = OS.get_environment('DOTPM_CACHE_DIR')
	else:
		var home_dir = (OS.get_environment("USERPROFILE") if OS.has_feature("windows") else OS.get_environment("HOME")).replace('\\', '/')
		cache_dir = home_dir + '/.dotpm/cache'

func synchronise_packages() -> void:
	var access = DirAccess.open(work_dir)
	if not access.dir_exists('addons'):
		access.make_dir('addons')

	var diff: Dictionary = PackageMetaReader.get_package_diff()
	for package_name in diff:
		_synchronise_package(package_name, diff[package_name].source, diff[package_name].installed)
		PackageMetaReader.set_installed_package(package_name, diff[package_name].source)

func _synchronise_package(package_name: String, source_meta, installed_meta) -> void:
	var source_dir: String = cache_dir + '/' + package_name + '/clone/' + source_meta.data.source
	var target_dir: String = work_dir + '/' + source_meta.data.target

	DirAccess.make_dir_recursive_absolute(target_dir)

	if source_meta.data.type == 'clone':
		_delete_directory_recursive(target_dir)
		_copy_directory_recursive(source_dir, target_dir)
	# TODO: sync package
	pass

func _remove_package(package_dir: String) -> void:
	pass

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
