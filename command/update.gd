extends BaseCommand


func description() -> String:
	return 'Updates all dependencies according to dotpm.json'

func execute(_command: Array, _options: Dictionary) -> int:
	CacheHandler.ensure_cache_directory()

	PackageMetaReader.load_project_data()
	PackageMetaReader.load_installed_packages()
	CacheHandler.build_package_cache()
	PackageInstaller.synchronise_packages()
	PackageMetaReader.write_installed_packages()
	PackageMetaReader.write_lock_file()

	return 1
