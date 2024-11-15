class_name PackageCache
extends Resource

var name: String
var cache_dir: String
var code_source: String
var install_type: String
var package_target: String
var package_source: String
var versions: Array[PackageVersion]
var cache_version: String
var request_version: String


func _init(name: String, data: Dictionary) -> void:
	name = name
	cache_dir = CacheHandler.cache_dir + '/' + name

	code_source = data.code_source
	install_type = data.install_type
	package_target = data.package_target
	package_source = data.package_source

	for version in data.versions:
		versions.append(PackageVersion.new())

func set_cache_version(version: String) -> void:
	cache_version = version

func set_requesed_version(version: String) -> void:
	request_version = version
