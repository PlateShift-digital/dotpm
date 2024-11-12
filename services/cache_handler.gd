extends Node

var cache_dir: String


func _init() -> void:
	if OS.get_environment('DOTPM_CACHE_DIR'):
		cache_dir = OS.get_environment('DOTPM_CACHE_DIR')
	else:
		var home_dir = (OS.get_environment("USERPROFILE") if OS.has_feature("windows") else OS.get_environment("HOME")).replace('\\', '/')
		cache_dir = home_dir + '/.dotpm/cache'

func build_package_cache() -> void:
	var diff: Dictionary = PackageMetaReader.get_package_diff()

	for request: String in diff:
		var request_data: Dictionary = diff[request]
		var cache_target: String = cache_dir + '/' + request

		if request_data.source.requested.begins_with('@'):
			CacheHandler.clone_into_cache(cache_target, request_data)
		elif request_data.data.versions.has(request_data.requested):
			print_debug('it has the version')
		else: # try to clone it directly as the version is unknown
			print_debug('version unknown, trying to clone it directly')

func ensure_cache_directory() -> void:
	DirAccess.make_dir_recursive_absolute(cache_dir)

func clone_into_cache(cache_target: String, request_data: Dictionary) -> int:
	cache_target = cache_target + '/clone'
	var command_options: Array

	if DirAccess.dir_exists_absolute(cache_target):
		# TODO: not just pull but check if checked out branch is correct.
		command_options = [
			'-C',
			cache_target,
			'pull',
		]

		return OS.execute('git', command_options)
	else:
		# cloning branch directly
		command_options = [
			'clone',
			'--branch=' + request_data.requested.substr(1),
			request_data.data.code_source,
			cache_target,
		]

		return OS.execute('git', command_options)
