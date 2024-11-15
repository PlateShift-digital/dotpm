extends Node

var cache_data: Dictionary = {}
var cache_dir: String


func _init() -> void:
	if OS.get_environment('DOTPM_CACHE_DIR'):
		cache_dir = OS.get_environment('DOTPM_CACHE_DIR')
	else:
		var home_dir = (OS.get_environment("USERPROFILE") if OS.has_feature("windows") else OS.get_environment("HOME")).replace('\\', '/')
		cache_dir = home_dir + '/.dotpm/cache'

func build_package_cache() -> void:
	for request: String in PackageMetaReader.requirements:
		var request_data: PackageCache = PackageMetaReader.requirements[request]
		var cache_target: String = cache_dir + '/' + request

		if request_data.request_version.begins_with('@'):
			CacheHandler.clone_into_cache(cache_target, request_data)
		elif request_data.data.versions.has(request_data.request_version):
			print_debug('it has the version')
		else: # try to clone it directly as the version is unknown
			print_debug('version unknown, trying to clone it directly')


func resolve_package_cache(project: String, data: Dictionary) -> PackageCache:
	var cache: PackageCache = PackageCache.new(project, data)

	cache_data[project] = cache

	return cache

func get_package_cache(package: String) -> PackageCache:
	if cache_data.has(package):
		return cache_data.get(package)

	return null

func ensure_cache_directory() -> void:
	DirAccess.make_dir_recursive_absolute(cache_dir)

func clone_into_cache(cache_target: String, request_data: PackageCache) -> void:
	cache_target = cache_target + '/clone'
	var command_options: Array

	print_debug(cache_target)
	if DirAccess.dir_exists_absolute(cache_target):
		# fetch from origin, checkout branch and pull to make sure updates arrived
		GitHandler.execute(cache_target, ['fetch', 'origin', '-p'])
		GitHandler.execute(cache_target, ['checkout', request_data.request_version.substr(1)])
		#GitHandler.execute(cache_target, ['pull'])
	else:
		# cloning branch directly
		GitHandler.clone(request_data.code_source, request_data.request_version.substr(1), cache_target)

	request_data.set_cache_version(GitHandler.execute_with_result(cache_target, ['rev-parse', 'HEAD']).trim_suffix('\n'))
