class_name PackageCache
extends Resource

var name: String
var cache_dir: String
var code_source: String
var install_type: String
var package_target: String
var package_source: String
var versions: Array[PackageVersion] = []
var cache_version: String
var request_version: String

func _init(package_name: String, data: Dictionary) -> void:
	name = package_name
	cache_dir = CacheHandler.cache_dir + '/' + package_name

	code_source = data.code_source
	install_type = data.install_type

	if data.has('package_target') and data.package_target:
		package_target = data.package_target
	if data.has('package_source') and data.package_source:
		package_source = data.package_source

	if data.has('versions') and data.size():
		for version in data.versions:
			versions.append(PackageVersion.new())

func set_cache_version(version: String) -> void:
	cache_version = version

func set_requesed_version(version: String) -> void:
	request_version = version

func is_installable() -> bool:
	if not package_target or not package_source:
		return false

	return true
